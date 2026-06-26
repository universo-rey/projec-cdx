$Root = 'C:\CEO\project-cdx'
$Venv = Join-Path $Root '.venv'
$VenvScripts = Join-Path $Venv 'Scripts'
$SettingsPath = Join-Path $Root '.vscode\settings.json'

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

function Get-ConfiguredToolPath {
    param([string] $SettingName)

    if (-not (Test-Path -LiteralPath $SettingsPath)) {
        return $null
    }

    try {
        $settings = Get-Content -LiteralPath $SettingsPath -Raw | ConvertFrom-Json
        $property = $settings.PSObject.Properties[$SettingName]
        if ($property) {
            return [string] $property.Value
        }
    }
    catch {
        return $null
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

$codeburnConfigured = Get-ConfiguredToolPath -SettingName 'agileagentcanvas.codeburn.path'
if (-not [string]::IsNullOrWhiteSpace($codeburnConfigured)) {
    Add-PathHead -Path (Split-Path -Parent $codeburnConfigured)
}

$python = Get-CommandSource -Name 'python'
$node = Get-CommandSource -Name 'node'
$codeburn = Get-CommandSource -Name 'codeburn'
$codex = Get-CommandSource -Name 'codex'
$pythonReady = ($python -and $python.StartsWith($VenvScripts, [System.StringComparison]::OrdinalIgnoreCase))
$nodeReady = -not [string]::IsNullOrWhiteSpace($node)
$codeburnReady = -not [string]::IsNullOrWhiteSpace($codeburn)
$state = if ($pythonReady -and $nodeReady -and $codeburnReady) { 'READY' } else { 'WARN' }

Write-Host ("CEO GOVERNED RUNTIME: {0} | root={1}" -f $state, $Root)
Write-Host ("python={0}" -f ($(if ($python) { $python } else { 'not_found' })))
Write-Host ("node={0}" -f ($(if ($node) { $node } else { 'not_found' })))
Write-Host ("codeburn={0}" -f ($(if ($codeburn) { $codeburn } else { 'not_found' })))
Write-Host ("codex={0}" -f ($(if ($codex) { $codex } else { 'not_found' })))

if ($state -ne 'READY') {
    Write-Warning 'Terminal opened, but one or more governed runtime tools are not resolving. Run tools/ceo-ide-terminal-status.ps1 -Json for details.'
}
