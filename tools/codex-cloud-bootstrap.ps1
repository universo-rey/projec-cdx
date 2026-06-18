[CmdletBinding()]
param(
  [string]$RepoRoot = 'C:/Users/enzo1/Documents/GitHub/cabina-universal-d',
  [string]$MetadataRoot = 'C:/Users/enzo1/PROJEC CDX',
  [string]$WorkspaceRoot = (Get-Location).Path,
  [string]$ContractPath,
  [string]$RegistryPath,
  [string]$MaintenanceLogPath,
  [string]$Mode = 'cloud',
  [string]$Gate = 'metadata-only',
  [string]$GitCommand = 'C:/Program Files/Git/cmd/git.exe'
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

  $value = & $GitCommand -C $WorkspaceRoot @Args 2>$null
  if ($null -eq $value) { return '' }
  return (($value | Out-String).Trim())
}

function ConvertTo-PortableWindowsPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return $Path.Replace('\', '/')
}

$repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$metadataRoot = (Resolve-Path -LiteralPath $MetadataRoot).Path
$workspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
if (-not $ContractPath) { $ContractPath = Join-Path $metadataRoot 'operativa/CODEX_CLOUD_CONTRACT_20260615.md' }
if (-not $RegistryPath) { $RegistryPath = Join-Path $metadataRoot 'dataverse/REGISTRO_CODEX_CLOUD_20260615.md' }
if (-not $MaintenanceLogPath) { $MaintenanceLogPath = Join-Path $metadataRoot 'operativa/CODEX_CLOUD_MAINTENANCE_20260615.md' }

$repoRootDisplay = ConvertTo-PortableWindowsPath -Path $repoRoot
$metadataRootDisplay = ConvertTo-PortableWindowsPath -Path $metadataRoot
$workspaceRootDisplay = ConvertTo-PortableWindowsPath -Path $workspaceRoot
$contractPathDisplay = ConvertTo-PortableWindowsPath -Path $ContractPath
$registryPathDisplay = ConvertTo-PortableWindowsPath -Path $RegistryPath
$maintenanceLogPathDisplay = ConvertTo-PortableWindowsPath -Path $MaintenanceLogPath

$gitBranch = (& $GitCommand -C $workspaceRoot branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($gitBranch)) { $gitBranch = 'DETACHED' }
$gitRemote = (& $GitCommand -C $workspaceRoot remote get-url origin 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($gitRemote)) { $gitRemote = 'NO_REMOTE' }

$variables = @(
  [pscustomobject]@{ Name = 'CODEX_CLOUD_ENABLED'; Default = '1'; Meaning = 'Master switch for delegated cloud work.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_MODE'; Default = $Mode; Meaning = 'Execution mode: local, cloud, or hybrid.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_GATE'; Default = $Gate; Meaning = 'Gate contract for metadata-only or higher.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_PROFILE'; Default = 'projec-cdx'; Meaning = 'Project profile name.' },
  [pscustomobject]@{ Name = 'CODEX_REPOS_ROOT'; Default = 'C:/Users/enzo1/Documents/GitHub'; Meaning = 'Canonical local repositories root.' },
  [pscustomobject]@{ Name = 'CODEX_CABINA_REPO_ROOT'; Default = $repoRootDisplay; Meaning = 'Canonical Cabina repository root.' },
  [pscustomobject]@{ Name = 'CODEX_WORKBENCH_ROOT'; Default = $metadataRootDisplay; Meaning = 'PROJEC CDX workbench and metadata root.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_REPO_ROOT'; Default = $repoRootDisplay; Meaning = 'Canonical repo root for delegated cloud work.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_METADATA_ROOT'; Default = $metadataRootDisplay; Meaning = 'Local contract, registry, and Dataverse metadata root.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_WORKTREE'; Default = $workspaceRootDisplay; Meaning = 'Current isolated workspace path.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_BRANCH'; Default = $gitBranch; Meaning = 'Current branch for the lane.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_CONTRACT'; Default = $contractPathDisplay; Meaning = 'Contract document path.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_MAINTENANCE_LOG'; Default = $maintenanceLogPathDisplay; Meaning = 'Maintenance log path.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_DATAVERSE_REGISTRY'; Default = $registryPathDisplay; Meaning = 'Metadata-only Dataverse registry path.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_DATAVERSE_GATE'; Default = (ConvertTo-PortableWindowsPath -Path (Join-Path $metadataRoot 'dataverse/GATE.md')); Meaning = 'Dataverse gate file.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_DATAVERSE_BLOCKERS'; Default = (ConvertTo-PortableWindowsPath -Path (Join-Path $metadataRoot 'dataverse/REGISTRO_BLOQUEOS.md')); Meaning = 'Dataverse blocker registry.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_DATAVERSE_SOURCE_MAP'; Default = (ConvertTo-PortableWindowsPath -Path (Join-Path $metadataRoot 'dataverse/MAPA_CONEXIONES_DATAVERSE.md')); Meaning = 'Dataverse connection and drift map.' },
  [pscustomobject]@{ Name = 'CODEX_CLOUD_DATAVERSE_PLAN'; Default = (ConvertTo-PortableWindowsPath -Path (Join-Path $metadataRoot 'dataverse/PLAN_SEGUNDA_PASADA.md')); Meaning = 'Dataverse second-pass plan.' },
  [pscustomobject]@{ Name = 'OPENAI_MODEL'; Default = 'gpt-5.5'; Meaning = 'Optional fallback model when API mode is used.' }
)

$variableLines = ($variables | ForEach-Object {
  "- ``$($_.Name)`` | default: ``$($_.Default)`` | $($_.Meaning)"
}) -join [Environment]::NewLine

$contractTemplate = @'
# Codex Cloud Contract 20260615

## Proposito

Codex Cloud se usa para delegacion, orquestacion y trabajo repetible de varios pasos. La mesa local conserva evidencia, traza y versionado durable.

## Estado

`metadata_only_until_activation`

## Current Context

- canonical repo root: __REPO_ROOT__
- metadata/workbench root: __METADATA_ROOT__
- branch: __BRANCH__
- remote: __REMOTE__
- workspace root: __WORKTREE__
- mode: __MODE__
- gate: __GATE__
- generated at: __TIMESTAMP__

## Variables

__VARIABLES__

`OPENAI_API_KEY` queda fuera del repo. Solo se usa si existe un carril API de respaldo.

## Contrato Operativo

- Un solo lane por vez.
- Sin comandos inventados si Codex Cloud no esta configurado.
- Sin live write sin gate explicito.
- Sin mezcla entre bootstrap cloud y limpieza local.
- Dataverse se usa como hidratacion metadata-only hasta nueva orden.

## Dataverse Hydration

- `dataverse/GATE.md` fija el gate local antes de cualquier live.
- `dataverse/REGISTRO_BLOQUEOS.md` registra las fronteras y decisiones.
- `dataverse/MAPA_CONEXIONES_DATAVERSE.md` da el mapa de conexiones y drift.
- `dataverse/PLAN_SEGUNDA_PASADA.md` sirve como plan de referencia para la segunda pasada.
- `dataverse/REGISTRO_CODEX_CLOUD_20260615.md` guarda el registro local del contrato.

## Scripts

- `tools/codex-cloud-bootstrap.ps1`
- `tools/codex-cloud-maintenance.ps1`

## Stop Conditions

- `CODEX_CLOUD_ENABLED=0`
- `CODEX_CLOUD_GATE` distinto de `metadata-only` sin orden nueva
- falta `dataverse/GATE.md`
- falta `dataverse/REGISTRO_BLOQUEOS.md`
- se detecta secreto o write live
- se intenta usar este contrato como sustituto de una configuracion real de Codex Cloud

## Resultado

La configuracion queda declarada, portable y auditable. La activacion real sigue separada del contrato.
'@

$contractText = $contractTemplate.Replace('__REPO_ROOT__', $repoRootDisplay).
  Replace('__METADATA_ROOT__', $metadataRootDisplay).
  Replace('__BRANCH__', $gitBranch).
  Replace('__REMOTE__', $gitRemote).
  Replace('__WORKTREE__', $workspaceRootDisplay).
  Replace('__MODE__', $Mode).
  Replace('__GATE__', $Gate).
  Replace('__TIMESTAMP__', (Get-Date).ToString('o')).
  Replace('__VARIABLES__', $variableLines)

$registryTemplate = @'
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
- generated at: `__TIMESTAMP__`

## Dataverse Hydration

- gate file: `dataverse/GATE.md`
- blocker registry: `dataverse/REGISTRO_BLOQUEOS.md`
- source map: `dataverse/MAPA_CONEXIONES_DATAVERSE.md`
- plan: `dataverse/PLAN_SEGUNDA_PASADA.md`
- hydration_state: `pending_first_run`

## Variables Declaradas

__VARIABLE_NAMES__

## Notas

- Este registro es metadata local.
- No implica write live.
- El script de mantenimiento lo actualiza cuando exista una primera corrida.
'@

$variableNames = ($variables | ForEach-Object { "- ``$($_.Name)``" }) -join [Environment]::NewLine
$registryText = $registryTemplate.Replace('__MODE__', $Mode).
  Replace('__GATE__', $Gate).
  Replace('__TIMESTAMP__', (Get-Date).ToString('o')).
  Replace('__VARIABLE_NAMES__', $variableNames)

Write-AtomicTextFile -Path $ContractPath -Content $contractText
Write-AtomicTextFile -Path $RegistryPath -Content $registryText

[pscustomobject]@{
  ContractPath = $ContractPath
  RegistryPath = $RegistryPath
  MetadataRoot = $metadataRoot
  RepoRoot = $repoRoot
  WorkspaceRoot = $workspaceRoot
  Branch = $gitBranch
  Mode = $Mode
  Gate = $Gate
  Status = 'Prepared'
}
