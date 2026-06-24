param(
    [switch] $Json
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Read-JsonFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        return [PSCustomObject]@{
            parse_error = $_.Exception.Message
        }
    }
}

$mcpPath = Join-Path $Root '.cursor\mcp.json'
$settingsPath = Join-Path $Root '.vscode\settings.json'
$mcp = Read-JsonFile -Path $mcpPath
$settings = Read-JsonFile -Path $settingsPath

$servers = @()
if ($mcp -and $mcp.mcpServers) {
    foreach ($server in $mcp.mcpServers.PSObject.Properties) {
        $config = $server.Value
        $commandStatus = 'not_checked'
        if ($config.command) {
            $cmd = Get-Command $config.command -ErrorAction SilentlyContinue | Select-Object -First 1
            $commandStatus = if ($cmd) { 'command_resolves' } else { 'command_missing' }
        }
        $servers += [PSCustomObject]@{
            name = $server.Name
            config_path = '.cursor/mcp.json'
            command = $config.command
            command_status = $commandStatus
            status = 'configured'
            agent = 'Anubis'
            use = 'mcp_tool_surface'
            risk = 'requires_gate_before_execution'
            gate = 'mcp_execution_gate'
        }
    }
}

$payload = [PSCustomObject]@{
    command = 'ceo-mcp-status'
    root = $Root
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    mcp_config = if (Test-Path -LiteralPath $mcpPath) { '.cursor/mcp.json' } else { $null }
    vscode_settings = if (Test-Path -LiteralPath $settingsPath) { '.vscode/settings.json' } else { $null }
    server_count = @($servers).Count
    servers = @($servers)
    vscode_settings_parse = if ($settings -and $settings.parse_error) { 'parse_error' } elseif ($settings) { 'ok' } else { 'missing' }
    frontera = @{
        no_mcp_execution = $true
        no_secret_read = $true
        no_live = $true
        no_write = $true
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 8
}

