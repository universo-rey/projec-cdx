param(
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Resolve-NocPath {
  $parent = Split-Path -Parent $PSScriptRoot
  $candidates = @(
    $PSScriptRoot,
    (Join-Path $PSScriptRoot "noc"),
    $parent,
    (Join-Path $parent "noc")
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

  foreach ($candidate in $candidates) {
    $build = Join-Path $candidate "build-noc-state.ps1"
    $shared = Join-Path $candidate "actions\_shared.ps1"
    if ((Test-Path -LiteralPath $build -PathType Leaf) -and (Test-Path -LiteralPath $shared -PathType Leaf)) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  throw "CRITICAL: noc path could not be resolved from $PSScriptRoot"
}

function Convert-ToBoolMap {
  param([hashtable]$Map)
  [ordered]@{
    build_script = [bool]$Map.build_script
    shared_script = [bool]$Map.shared_script
    state_path_local = [bool]$Map.state_path_local
  }
}

Write-Host "=== SDU NOC LOCAL NORMALIZATION START ===" -ForegroundColor Cyan

$nocPath = Resolve-NocPath
$buildScript = Join-Path $nocPath "build-noc-state.ps1"
$sharedScript = Join-Path $nocPath "actions\_shared.ps1"
$stateFile = Join-Path $nocPath "noc-state.json"
$resolvedNocPath = (Resolve-Path -LiteralPath $nocPath).Path
$resolvedStateParent = if (Test-Path -LiteralPath (Split-Path -Parent $stateFile)) {
  (Resolve-Path -LiteralPath (Split-Path -Parent $stateFile)).Path
} else {
  $null
}

Write-Host "[1] PRECHECK..."
$checks = @{
  build_script = Test-Path -LiteralPath $buildScript -PathType Leaf
  shared_script = Test-Path -LiteralPath $sharedScript -PathType Leaf
  state_path_local = $resolvedStateParent -eq $resolvedNocPath
}

$checkObject = Convert-ToBoolMap -Map $checks
if ($Json) {
  $checkObject | ConvertTo-Json -Depth 3
} else {
  $checkObject | Format-Table
}

if ($checks.Values -contains $false) {
  Write-Host "CRITICAL: missing local noc prerequisites" -ForegroundColor Red
  exit 1
}

Write-Host "[2] SNAPSHOT LOCAL..."
$backup = $null
if (Test-Path -LiteralPath $stateFile -PathType Leaf) {
  $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $backup = Join-Path $nocPath "noc-state.$timestamp.bak.json"
  Copy-Item -LiteralPath $stateFile -Destination $backup -Force
  Write-Host "Backup local:" $backup
}

Write-Host "[3] BUILD NOC STATE..."
try {
  $buildOutput = & $buildScript
} catch {
  Write-Host "CRITICAL: build-noc-state.ps1 failed" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  exit 1
}

Write-Host "[4] VALIDATION..."
if (-not (Test-Path -LiteralPath $stateFile -PathType Leaf)) {
  Write-Host "CRITICAL: noc-state.json not generated" -ForegroundColor Red
  exit 1
}

$state = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
$validation = [ordered]@{
  state_loaded = $null -ne $state
  has_status = -not [string]::IsNullOrWhiteSpace([string]$state.status)
  has_health = $null -ne $state.health
  has_noc = $null -ne $state.noc
  has_last_run = $null -ne $state.last_run
}

$validation | ConvertTo-Json -Depth 3

if ($validation.Values -contains $false) {
  Write-Host "CRITICAL: noc-state.json failed schema-aware validation" -ForegroundColor Red
  exit 1
}

Write-Host "[5] OBSERVABILITY..."
if ($state.PSObject.Properties.Name -contains "matches") {
  $matchCount = @($state.matches).Count
  Write-Host "Matches:" $matchCount
} else {
  Write-Host "Matches: NOT PRESENT (by design or deferred)"
}

Write-Host "Status:" $state.status
Write-Host "Health:" ($state.health | ConvertTo-Json -Compress)

Write-Host "[6] RESULT..."
Write-Host "noc-state.json actualizado en:" $stateFile -ForegroundColor Green
if ($backup) {
  Write-Host "Backup local:" $backup
}
Write-Host "normalize-all.ps1 omitido: esa accion emite bus/log fuera de ./noc." -ForegroundColor Yellow
Write-Host "=== SDU NOC LOCAL NORMALIZATION END ===" -ForegroundColor Green
