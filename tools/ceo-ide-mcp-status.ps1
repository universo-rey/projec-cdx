param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'

function Test-JsonFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return 'missing'
    }

    try {
        Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json > $null
        return 'ok'
    }
    catch {
        return 'parse_error'
    }
}

function Read-JsonFile {
    param([string] $Path)

    if ((Test-JsonFile -Path $Path) -ne 'ok') {
        return $null
    }

    Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $Path.Replace($Root + '\', '').Replace('\', '/')
}

function Redact-Value {
    param([object] $Value)

    if ($null -eq $Value) {
        return $null
    }

    $text = $Value.ToString()
    if ($text -match '(?i)(token|secret|password|apikey|api_key|key=|bearer)') {
        return '<redacted>'
    }

    return $text
}

function Get-McpAgentMapping {
    param([string] $Name)

    switch -Regex ($Name) {
        'agent|pipeline' {
            return [PSCustomObject]@{
                agent = 'THOT_IDE_CONTROL'
                reviewer = 'ANUBIS_IDE_GATE'
                carril = 'IDE_AGENT_MCP_CONTROL'
                use = 'agent_orchestration_mcp_surface'
            }
        }
        'github' {
            return [PSCustomObject]@{
                agent = 'ANUBIS_IDE_GATE'
                reviewer = 'MAAT_IDE_COMPLIANCE'
                carril = 'REMOTE_PUBLICATION_PIPELINE'
                use = 'repo_read_or_governed_remote_gate'
            }
        }
        'microsoft|sharepoint|teams|dataverse' {
            return [PSCustomObject]@{
                agent = 'ANUBIS_IDE_GATE'
                reviewer = 'SESHAT_IDE_EVIDENCE'
                carril = 'EXTERNAL_GOVERNED_SURFACE'
                use = 'live_gated_only'
            }
        }
        default {
            return [PSCustomObject]@{
                agent = 'THOT_IDE_CONTROL'
                reviewer = 'HORUS_IDE_SIGNAL'
                carril = 'MCP_HUB'
                use = 'tool_surface_observed'
            }
        }
    }
}

function Get-ConfiguredPathEntries {
    $entries = @()
    $configPath = Join-Path $Root '.codex\config.toml'
    if (Test-Path -LiteralPath $configPath) {
        $pathLine = Get-Content -LiteralPath $configPath | Where-Object { $_ -match '^\s*PATH\s*=' } | Select-Object -First 1
        if ($pathLine -and $pathLine -match "^\s*PATH\s*=\s*['""](.+)['""]\s*$") {
            $entries += @($Matches[1] -split ';' | Where-Object { $_ })
        }
    }

    $entries += @($env:PATH -split ';' | Where-Object { $_ })
    $entries | Select-Object -Unique
}

function Resolve-CommandPath {
    param([string] $Command)

    if ([string]::IsNullOrWhiteSpace($Command) -or $Command -eq '<redacted>') {
        return [PSCustomObject]@{
            resolves = $false
            source = $null
            source_type = 'none'
        }
    }

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) {
        return [PSCustomObject]@{
            resolves = $true
            source = $cmd.Source
            source_type = 'session_path'
        }
    }

    $candidateNames = if ([System.IO.Path]::GetExtension($Command)) { @($Command) } else { @("$Command.exe", "$Command.cmd", "$Command.ps1", $Command) }
    foreach ($entry in Get-ConfiguredPathEntries) {
        foreach ($name in $candidateNames) {
            $candidate = Join-Path $entry $name
            try {
                if (Test-Path -LiteralPath $candidate -ErrorAction Stop) {
                    return [PSCustomObject]@{
                        resolves = $true
                        source = $candidate
                        source_type = 'configured_runtime_path'
                    }
                }
            }
            catch {
                return [PSCustomObject]@{
                    resolves = $true
                    source = $candidate
                    source_type = 'configured_runtime_path_access_denied_in_sandbox'
                }
            }
        }
    }

    [PSCustomObject]@{
        resolves = $false
        source = $null
        source_type = 'missing'
    }
}

$configCandidates = @(
    '.cursor\mcp.json',
    '.vscode\mcp.json',
    '.codex\mcp.json'
)

$configs = foreach ($relative in $configCandidates) {
    $path = Join-Path $Root $relative
    [PSCustomObject]@{
        path = $relative.Replace('\', '/')
        full_path = $path
        state = Test-JsonFile -Path $path
    }
}

$servers = @()
foreach ($config in $configs | Where-Object { $_.state -eq 'ok' }) {
    $content = Read-JsonFile -Path $config.full_path
    $mcpServers = if ($content.mcpServers) { $content.mcpServers } elseif ($content.servers) { $content.servers } else { $null }
    if ($null -eq $mcpServers) {
        continue
    }

    foreach ($server in $mcpServers.PSObject.Properties) {
        $cfg = $server.Value
        $command = Redact-Value -Value $cfg.command
        $resolvedCommand = Resolve-CommandPath -Command $command
        $commandResolved = $resolvedCommand.resolves
        $commandSource = $resolvedCommand.source

        $mapping = Get-McpAgentMapping -Name $server.Name
        $envKeys = @()
        if ($cfg.env) {
            $envKeys = @($cfg.env.PSObject.Properties.Name)
        }

        $state = if ($cfg.disabled -eq $true) {
            'DISABLED'
        }
        elseif (-not $command) {
            'OBSERVED_NO_COMMAND'
        }
        elseif ($commandResolved) {
            'CONFIGURED_COMMAND_RESOLVES'
        }
        else {
            'BROKEN_COMMAND_MISSING'
        }

        $servers += [PSCustomObject]@{
            name = $server.Name
            config_path = $config.path
            state = $state
            command = $command
            command_source = $commandSource
            command_source_type = $resolvedCommand.source_type
            args = @($cfg.args | ForEach-Object { Redact-Value -Value $_ })
            env_keys = $envKeys
            env_values_printed = $false
            agent = $mapping.agent
            reviewer = $mapping.reviewer
            carril = $mapping.carril
            use = $mapping.use
            risk = 'requires_explicit_mcp_execution_gate'
        }
    }
}

$summary = [ordered]@{
    observed = @($servers).Count
    configured = @($servers | Where-Object { $_.state -eq 'CONFIGURED_COMMAND_RESOLVES' }).Count
    working = 0
    broken = @($servers | Where-Object { $_.state -like 'BROKEN*' }).Count
    disabled = @($servers | Where-Object { $_.state -eq 'DISABLED' }).Count
    candidate = @($configs | Where-Object { $_.state -eq 'missing' }).Count
}

$status = if ($summary.broken -eq 0 -and $summary.configured -gt 0) {
    'IDE_MCP_STATUS_READY'
}
elseif ($summary.observed -eq 0) {
    'IDE_MCP_STATUS_NO_CONFIG'
}
else {
    'IDE_MCP_STATUS_WARN'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-mcp-status'
    status = $status
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    configs = $configs | ForEach-Object {
        [PSCustomObject]@{
            path = $_.path
            state = $_.state
        }
    }
    summary = $summary
    servers = $servers
    frontera = @{
        no_mcp_execution = $true
        no_secret_read = $true
        no_secret_print = $true
        no_live = $true
        no_push = $true
        no_pr = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
