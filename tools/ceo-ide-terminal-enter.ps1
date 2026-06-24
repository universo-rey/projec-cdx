$Root = 'C:\CEO\project-cdx'
$Venv = Join-Path $Root '.venv'
$VenvScripts = Join-Path $Venv 'Scripts'

function Add-PathHead {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return
    }

    $current = @($env:PATH -split ';' | Where-Object { $_ })
    $alreadyPresent = @($current | Where-Object { $_.TrimEnd('\') -ieq $Path.TrimEnd('\') }).Count -gt 0
    if (-not $alreadyPresent) {
        $env:PATH = @($Path) + $current -join ';'
    }
}

function Get-CommandSource {
    param([string] $Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        return $command.Source
    }

    return $null
}

if (Test-Path -LiteralPath $Root) {
    Set-Location -LiteralPath $Root
}

$env:CEO_WORKSPACE = $Root
$env:CODEX_PROJECT_ROOT = $Root
$env:CODEX_WORKBENCH_ROOT = $Root
$env:CEO_RUNTIME_MODE = 'GOVERNED'
$env:CEO_TERMINAL_PROFILE = 'CEO PowerShell'
$env:PYTHONUTF8 = '1'

if (Test-Path -LiteralPath $VenvScripts) {
    $env:VIRTUAL_ENV = $Venv
    Add-PathHead -Path $VenvScripts
}

$python = Get-CommandSource -Name 'python'
$node = Get-CommandSource -Name 'node'
$codex = Get-CommandSource -Name 'codex'
$state = if ($python -and $python.StartsWith($VenvScripts, [System.StringComparison]::OrdinalIgnoreCase)) { 'READY' } else { 'WARN' }

Write-Host ("CEO GOVERNED RUNTIME: {0} | root={1}" -f $state, $Root)
Write-Host ("python={0}" -f ($(if ($python) { $python } else { 'not_found' })))
Write-Host ("node={0}" -f ($(if ($node) { $node } else { 'not_found' })))
Write-Host ("codex={0}" -f ($(if ($codex) { $codex } else { 'not_found' })))

if ($state -ne 'READY') {
    Write-Warning 'Terminal opened, but Python is not resolving from .venv. Run tools/ceo-ide-terminal-status.ps1 -Json for details.'
}
