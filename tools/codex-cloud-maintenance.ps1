[CmdletBinding()]
param(
  [string]$RepoRoot = 'C:\Users\enzo1\PROJEC CDX',
  [string]$WorkspaceRoot = (Get-Location).Path,
  [string]$ContractPath,
  [string]$RegistryPath,
  [string]$MaintenanceLogPath,
  [switch]$RefreshRegistry = $true
)

$ErrorActionPreference = 'Stop'

function Write-AtomicTextFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Content
  )

  $parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  $temp = Join-Path $parent ('.' + [System.IO.Path]::GetFileName($Path) + '.' + [Guid]::NewGuid().ToString('N') + '.tmp')
  try {
    [System.IO.File]::WriteAllText($temp, $Content, [System.Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temp -Destination $Path -Force
  }
  finally {
    if (Test-Path -LiteralPath $temp) {
      Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
  }
}

function Get-GitValue {
  param(
    [Parameter(Mandatory = $true)][string[]]$Args
  )

  $value = & git -C $WorkspaceRoot @Args 2>$null
  if ($null -eq $value) { return '' }
  return (($value | Out-String).Trim())
}

$repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$workspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
if (-not $ContractPath) { $ContractPath = Join-Path $repoRoot 'operativa\CODEX_CLOUD_CONTRACT_20260615.md' }
if (-not $RegistryPath) { $RegistryPath = Join-Path $repoRoot 'dataverse\REGISTRO_CODEX_CLOUD_20260615.md' }
if (-not $MaintenanceLogPath) { $MaintenanceLogPath = Join-Path $repoRoot 'operativa\CODEX_CLOUD_MAINTENANCE_20260615.md' }

$gitBranch = (git -C $workspaceRoot branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($gitBranch)) { $gitBranch = 'DETACHED' }
$gitRemote = (git -C $workspaceRoot remote get-url origin 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($gitRemote)) { $gitRemote = 'NO_REMOTE' }
$gitStatus = (git -C $workspaceRoot status --short --branch 2>$null | Out-String).TrimEnd()

$gatePath = Join-Path $repoRoot 'dataverse\GATE.md'
$blockerPath = Join-Path $repoRoot 'dataverse\REGISTRO_BLOQUEOS.md'
$sourceMapPath = Join-Path $repoRoot 'dataverse\MAPA_CONEXIONES_DATAVERSE.md'
$planPath = Join-Path $repoRoot 'dataverse\PLAN_SEGUNDA_PASADA.md'

$checks = @(
  [pscustomobject]@{ Name = 'contract'; Path = $ContractPath; Required = $true },
  [pscustomobject]@{ Name = 'registry'; Path = $RegistryPath; Required = $true },
  [pscustomobject]@{ Name = 'gate'; Path = $gatePath; Required = $true },
  [pscustomobject]@{ Name = 'blockers'; Path = $blockerPath; Required = $true },
  [pscustomobject]@{ Name = 'source_map'; Path = $sourceMapPath; Required = $false },
  [pscustomobject]@{ Name = 'plan'; Path = $planPath; Required = $false }
)

$checkLines = foreach ($check in $checks) {
  $exists = Test-Path -LiteralPath $check.Path
  $state = if ($exists) { 'PASS' } elseif ($check.Required) { 'FAIL' } else { 'WARN' }
  "- $($check.Name): $state (`"$($check.Path)`")"
}

$envNames = @(
  'CODEX_CLOUD_ENABLED',
  'CODEX_CLOUD_MODE',
  'CODEX_CLOUD_GATE',
  'CODEX_CLOUD_PROFILE',
  'CODEX_CLOUD_REPO_ROOT',
  'CODEX_CLOUD_WORKTREE',
  'CODEX_CLOUD_BRANCH',
  'CODEX_CLOUD_CONTRACT',
  'CODEX_CLOUD_MAINTENANCE_LOG',
  'CODEX_CLOUD_DATAVERSE_REGISTRY',
  'CODEX_CLOUD_DATAVERSE_GATE',
  'CODEX_CLOUD_DATAVERSE_BLOCKERS',
  'CODEX_CLOUD_DATAVERSE_SOURCE_MAP',
  'CODEX_CLOUD_DATAVERSE_PLAN',
  'OPENAI_MODEL'
)

$envLines = foreach ($name in $envNames) {
  $value = [Environment]::GetEnvironmentVariable($name)
  $state = if ([string]::IsNullOrWhiteSpace($value)) { 'missing' } else { 'present' }
  $display = if ([string]::IsNullOrWhiteSpace($value)) { '(unset)' } else { $value }
  "- ${name}: $state / $display"
}

$registryRefresh = @'
# Registro Codex Cloud 20260615

## Estado

`metadata_only`

## Identidad

- contract: `operativa/CODEX_CLOUD_CONTRACT_20260615.md`
- bootstrap: `tools/codex-cloud-bootstrap.ps1`
- maintenance: `tools/codex-cloud-maintenance.ps1`
- mode: `__MODE__`
- gate: `__GATE__`
- dataverse_write: `no`
- last_maintenance: `__TIMESTAMP__`

## Dataverse Hydration

- gate file: `dataverse/GATE.md`
- blocker registry: `dataverse/REGISTRO_BLOQUEOS.md`
- source map: `dataverse/MAPA_CONEXIONES_DATAVERSE.md`
- plan: `dataverse/PLAN_SEGUNDA_PASADA.md`
- hydration_state: `validated_metadata_only`

## Variables Declaradas

- `CODEX_CLOUD_ENABLED`
- `CODEX_CLOUD_MODE`
- `CODEX_CLOUD_GATE`
- `CODEX_CLOUD_PROFILE`
- `CODEX_CLOUD_REPO_ROOT`
- `CODEX_CLOUD_WORKTREE`
- `CODEX_CLOUD_BRANCH`
- `CODEX_CLOUD_CONTRACT`
- `CODEX_CLOUD_MAINTENANCE_LOG`
- `CODEX_CLOUD_DATAVERSE_REGISTRY`
- `CODEX_CLOUD_DATAVERSE_GATE`
- `CODEX_CLOUD_DATAVERSE_BLOCKERS`
- `CODEX_CLOUD_DATAVERSE_SOURCE_MAP`
- `CODEX_CLOUD_DATAVERSE_PLAN`

## Notas

- Este registro sigue siendo metadata local.
- No implica write live.
- Se actualiza con cada pasada de mantenimiento.
'@

$mode = [Environment]::GetEnvironmentVariable('CODEX_CLOUD_MODE')
if ([string]::IsNullOrWhiteSpace($mode)) { $mode = 'hybrid' }
$gate = [Environment]::GetEnvironmentVariable('CODEX_CLOUD_GATE')
if ([string]::IsNullOrWhiteSpace($gate)) { $gate = 'metadata-only' }

if ($RefreshRegistry) {
  Write-AtomicTextFile -Path $RegistryPath -Content ($registryRefresh.Replace('__MODE__', $mode).Replace('__GATE__', $gate).Replace('__TIMESTAMP__', (Get-Date).ToString('o')))
}

$maintenanceTemplate = @'
# Codex Cloud Maintenance 20260615

## Snapshot

- timestamp: __TIMESTAMP__
- branch: __BRANCH__
- remote: __REMOTE__
- root: __ROOT__
- mode: __MODE__
- gate: __GATE__
- git_status:
__GIT_STATUS__

## Checks

__CHECKS__

## Environment

__ENV__

## Dataverse Hydration

- gate file: `dataverse/GATE.md`
- blocker registry: `dataverse/REGISTRO_BLOQUEOS.md`
- source map: `dataverse/MAPA_CONEXIONES_DATAVERSE.md`
- registry: `dataverse/REGISTRO_CODEX_CLOUD_20260615.md`
- state: metadata-only

## Result

El contrato queda confirmado, la hidratacion local queda alineada y no se abre write live.
'@

$maintenanceText = $maintenanceTemplate.
  Replace('__TIMESTAMP__', (Get-Date).ToString('o')).
  Replace('__BRANCH__', $gitBranch).
  Replace('__REMOTE__', $gitRemote).
  Replace('__ROOT__', $repoRoot).
  Replace('__MODE__', $mode).
  Replace('__GATE__', $gate).
  Replace('__GIT_STATUS__', (($gitStatus -split [Environment]::NewLine) | ForEach-Object { "  $_" }) -join [Environment]::NewLine).
  Replace('__CHECKS__', (($checkLines | ForEach-Object { "  $_" }) -join [Environment]::NewLine)).
  Replace('__ENV__', (($envLines | ForEach-Object { "  $_" }) -join [Environment]::NewLine))

Write-AtomicTextFile -Path $MaintenanceLogPath -Content $maintenanceText

[pscustomobject]@{
  Root = $repoRoot
  WorkspaceRoot = $workspaceRoot
  Branch = $gitBranch
  Remote = $gitRemote
  ContractPath = $ContractPath
  RegistryPath = $RegistryPath
  MaintenanceLogPath = $MaintenanceLogPath
  Mode = $mode
  Gate = $gate
  Checks = $checkLines
  Environment = $envLines
  Status = 'Maintained'
}
