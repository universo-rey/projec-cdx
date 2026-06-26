param(
    [switch] $DryRun,
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$PhysicalAlias = 'C:\Users\enzo1\PROJEC CDX'
$ScriptRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$code = Get-Command code-insiders -ErrorAction SilentlyContinue | Select-Object -First 1
$args = @('--reuse-window', $Root)

$result = [PSCustomObject]@{
    command = 'ceo-vscode-insiders-open'
    root = $Root
    identity = @{
        canonical_root = $Root
        physical_alias = $PhysicalAlias
        script_root = $ScriptRoot
        physical_alias_policy = 'TARGET_ONLY_NOT_WORKSPACE'
    }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    dry_run = [bool]$DryRun
    code_insiders_resolves = [bool]$code
    executable = if ($code) { $code.Source } else { $null }
    args = $args
    executed = $false
    frontera = @{
        local_app_only = $true
        no_live = $true
        no_secret_read = $true
        no_push = $true
        no_pr = $true
    }
}

if ($code -and -not $DryRun) {
    Start-Process -FilePath $code.Source -ArgumentList $args -WindowStyle Hidden
    $result.executed = $true
}

if ($Json -or $true) {
    $result | ConvertTo-Json -Depth 6
}
