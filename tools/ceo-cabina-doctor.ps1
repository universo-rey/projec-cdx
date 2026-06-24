param(
    [switch] $Json
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$canonicalPython = Join-Path $Root '.venv\Scripts\python.exe'
$commandsToCheck = @('git', 'pwsh', 'python', 'node', 'code-insiders', 'codex')

function Get-CommandStatus {
    param([string] $Name)
    $resolved = @(Get-Command $Name -All -ErrorAction SilentlyContinue)
    [PSCustomObject]@{
        name = $Name
        count = $resolved.Count
        first_path = if ($resolved.Count -gt 0) { $resolved[0].Source } else { $null }
        status = if ($resolved.Count -gt 0) { 'resolves' } else { 'missing' }
    }
}

$status = @(git -C $Root status --short 2>$null)
$mcpPath = Join-Path $Root '.cursor\mcp.json'
$contractPath = Join-Path $Root '.cabina\SDU_RUNTIME_ROOT\05_CONFIG\cabina-contract.v1.json'

$payload = [PSCustomObject]@{
    command = 'ceo-cabina-doctor'
    root = $Root
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    branch = (git -C $Root branch --show-current 2>$null)
    commit = (git -C $Root rev-parse --short HEAD 2>$null)
    workspace = @{
        clean = ($status.Count -eq 0)
        local_changes = $status.Count
        staged = @($status | Where-Object { $_ -match '^[MADRCU][ MDADRCU]' -and $_ -notmatch '^ [MD]' }).Count
        modified = @($status | Where-Object { $_ -match '^ M|^M ' }).Count
        deleted = @($status | Where-Object { $_ -match '^ D|^D ' }).Count
        untracked = @($status | Where-Object { $_ -match '^\?\?' }).Count
    }
    runtime = @{
        canonical_python = $canonicalPython
        canonical_python_exists = (Test-Path -LiteralPath $canonicalPython)
        cabina_contract_exists = (Test-Path -LiteralPath $contractPath)
        mcp_config_exists = (Test-Path -LiteralPath $mcpPath)
        env_local_exists = (Test-Path -LiteralPath (Join-Path $Root '.env.local'))
        env_local_read = $false
    }
    commands = @($commandsToCheck | ForEach-Object { Get-CommandStatus -Name $_ })
    recommended_next = @(
        'ceo-command-index',
        'ceo-agent-map',
        'ceo-mcp-status',
        'archive-reconciliation-pass'
    )
    frontera = @{
        no_external = $true
        no_secret_read = $true
        no_live = $true
        no_write = $true
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 8
}

