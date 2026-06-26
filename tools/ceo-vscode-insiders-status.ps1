param(
    [switch] $Json
)

$CanonicalRoot = 'C:\CEO\project-cdx'
$PhysicalAlias = 'C:\Users\enzo1\PROJEC CDX'
$ScriptRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Root = if (Test-Path -LiteralPath $CanonicalRoot) { $CanonicalRoot } else { $ScriptRoot }
$settingsPath = Join-Path $Root '.vscode\settings.json'
$tasksPath = Join-Path $Root '.vscode\tasks.json'
$mcpPath = Join-Path $Root '.cursor\mcp.json'
$codeCommands = @(Get-Command code-insiders -All -ErrorAction SilentlyContinue)

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

$taskLabels = @()
if ((Test-JsonFile -Path $tasksPath) -eq 'ok') {
    $tasks = Get-Content -LiteralPath $tasksPath -Raw | ConvertFrom-Json
    $taskLabels = @($tasks.tasks | ForEach-Object { $_.label })
}

$payload = [PSCustomObject]@{
    command = 'ceo-vscode-insiders-status'
    root = $Root
    identity = @{
        canonical_root = $CanonicalRoot
        physical_alias = $PhysicalAlias
        script_root = $ScriptRoot
        effective_root = $Root
        physical_alias_policy = 'TARGET_ONLY_NOT_WORKSPACE'
        workspace_policy = 'OPEN_CANONICAL_ENTRY_ONLY'
    }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    code_insiders = @{
        resolves = ($codeCommands.Count -gt 0)
        count = $codeCommands.Count
        first_path = if ($codeCommands.Count -gt 0) { $codeCommands[0].Source } else { $null }
    }
    local_config = @{
        settings = Test-JsonFile -Path $settingsPath
        tasks = Test-JsonFile -Path $tasksPath
        mcp = Test-JsonFile -Path $mcpPath
        settings_path = '.vscode/settings.json'
        tasks_path = '.vscode/tasks.json'
        mcp_path = '.cursor/mcp.json'
    }
    task_count = $taskLabels.Count
    task_labels = $taskLabels
    terminal = @{
        canonical_cwd = 'C:\CEO\project-cdx'
        default_profile = 'CEO PowerShell'
        no_profile = $true
    }
    ruido_reducido = @(
        '.git',
        '.venv',
        'node_modules',
        '.cache',
        'operativa/archive',
        'work/backups'
    )
    frontera = @{
        no_live = $true
        no_secret_read = $true
        no_mcp_execution = $true
        no_push = $true
        no_pr = $true
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 8
}
