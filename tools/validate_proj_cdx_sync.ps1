param(
  [string]$Root = "C:/CEO/project-cdx",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

$result = [ordered]@{
  root = $Root
  status = "PASS"
  checked_at = (Get-Date).ToString("s")
  checks = @()
}

function Add-Check {
  param(
    [string]$Name,
    [string]$Status,
    [string]$Detail
  )
  $script:result.checks += [ordered]@{
    name = $Name
    status = $Status
    detail = $Detail
  }
  if ($Status -eq "FAIL") {
    $script:result.status = "FAIL"
  } elseif ($Status -eq "OBSERVED" -and $script:result.status -ne "FAIL") {
    $script:result.status = "OBSERVED"
  }
}

function Test-Link {
  param([string]$RawPath)
  $decoded = [uri]::UnescapeDataString($RawPath).Replace("/", "\")
  return Test-Path -LiteralPath $decoded
}

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
  Add-Check "root_exists" "FAIL" "No existe la raiz esperada."
}

$requiredVisible = @(
  "README.md",
  "MAPA_MAESTRO.md",
  "operativa\CONTROL.md",
  "operativa\TRACE.md",
  "dataverse\README.md",
  "dataverse\MAPA.md",
  "dataverse\GATE.md",
  "dataverse\REGISTRO_BLOQUEOS.md",
  "dataverse\PLAN_SEGUNDA_PASADA.md",
  "dataverse\READBACK_EXCEL_BLOCKER_FRONTIER.md",
  "workbooks\README.md",
  "workbooks\MAPA.md",
  "workbooks\EXCEL_AL_FRENTE.md",
  "outputs\README.md",
  "outputs\MAPA.md",
  "outputs\dataverse_blocker_frontier_20260614\README.md",
  "hitos\README.md",
  "hitos\MAPA.md",
  "playbooks\07-dataverse-fronteras.md",
  "patrones\README.md",
  "procesos\README.md",
  "procesos\sincronizacion-tiempo-real.md",
  "patrones\sincronizacion-tiempo-real.md"
)

foreach ($relative in $requiredVisible) {
  $path = Join-Path $Root $relative
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    Add-Check "required:$relative" "PASS" "OK"
  } else {
    Add-Check "required:$relative" "FAIL" "Falta archivo requerido."
  }
}

$readme = Get-Content -LiteralPath (Join-Path $Root "README.md") -Raw
$mapa = Get-Content -LiteralPath (Join-Path $Root "MAPA_MAESTRO.md") -Raw
$excelAlFrente = Get-Content -LiteralPath (Join-Path $Root "workbooks\EXCEL_AL_FRENTE.md") -Raw
$outputsReadme = Get-Content -LiteralPath (Join-Path $Root "outputs\README.md") -Raw
$hitosReadme = Get-Content -LiteralPath (Join-Path $Root "hitos\README.md") -Raw

foreach ($label in @("tracker.xlsx", "control_operativo.xlsx", "inicio.xlsx")) {
  if ($excelAlFrente -match [regex]::Escape($label)) {
    Add-Check "excel_declared:$label" "PASS" "Fuentes vivas declaradas."
  } else {
    Add-Check "excel_declared:$label" "FAIL" "Falta declarar fuente viva."
  }
}

foreach ($label in @("Dataverse", "TRACKER", "control_operativo")) {
  if ($readme -match [regex]::Escape($label) -or $mapa -match [regex]::Escape($label)) {
    Add-Check "root_mentions:$label" "PASS" "Presente en raiz o mapa."
  } else {
    Add-Check "root_mentions:$label" "OBSERVED" "No encontrado en raiz o mapa."
  }
}

foreach ($label in @("tracker_general_20260613", "tracker_workbook_20260613", "control_operativo_20260615")) {
  if ($outputsReadme -match [regex]::Escape($label)) {
    Add-Check "output_declared:$label" "PASS" "Corrida declarada."
  } else {
    Add-Check "output_declared:$label" "FAIL" "Falta declarar corrida."
  }
}

foreach ($label in @("20260615-cierre-workbench-v1", "20260615-patrones-procesos-v1", "20260615-hilo-origen-v1")) {
  if ($hitosReadme -match [regex]::Escape($label)) {
    Add-Check "hito_declared:$label" "PASS" "Hito declarado."
  } else {
    Add-Check "hito_declared:$label" "FAIL" "Falta declarar hito."
  }
}

$linkChecks = @(
  @{ file = "README.md"; pattern = "C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx" },
  @{ file = "README.md"; pattern = "C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx" },
  @{ file = "MAPA_MAESTRO.md"; pattern = "C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx" },
  @{ file = "MAPA_MAESTRO.md"; pattern = "C:/Users/enzo1/PROJEC%20CDX/outputs/tracker_general_20260613" },
  @{ file = "workbooks/EXCEL_AL_FRENTE.md"; pattern = "C:/Users/enzo1/PROJEC%20CDX/outputs/tracker_workbook_20260613/tracker_workbook.xlsx" }
)

foreach ($check in $linkChecks) {
  $text = Get-Content -LiteralPath (Join-Path $Root $check.file) -Raw
  if ($text -match [regex]::Escape($check.pattern)) {
    Add-Check "link:$($check.file)" "PASS" $check.pattern
  } else {
    Add-Check "link:$($check.file)" "FAIL" "Falta enlace: $($check.pattern)"
  }
}

$dataverseGate = Get-Content -LiteralPath (Join-Path $Root "dataverse\GATE.md") -Raw
if ($dataverseGate -match "live" -and $dataverseGate -match "rollback" -and $dataverseGate -match "postcheck") {
  Add-Check "dataverse_gate" "PASS" "Gate live definido."
} else {
  Add-Check "dataverse_gate" "FAIL" "Gate Dataverse incompleto."
}

$dataverseReadback = Get-Content -LiteralPath (Join-Path $Root "dataverse\READBACK_EXCEL_BLOCKER_FRONTIER.md") -Raw
if ($dataverseReadback -match "metadata-only" -and $dataverseReadback -match "live rows" -and $dataverseReadback -match "bloque") {
  Add-Check "dataverse_readback" "PASS" "Readback local presente."
} else {
  Add-Check "dataverse_readback" "OBSERVED" "Readback necesita revision semantica."
}

$trackerWorkbook = Join-Path $Root "workbooks\tracker.xlsx"
if (Test-Path -LiteralPath $trackerWorkbook -PathType Leaf) {
  Add-Check "tracker_source" "PASS" "tracker.xlsx existe."
} else {
  Add-Check "tracker_source" "FAIL" "tracker.xlsx no existe."
}

$syncFiles = @(
  "patrones\sincronizacion-tiempo-real.md",
  "procesos\sincronizacion-tiempo-real.md",
  "playbooks\07-dataverse-fronteras.md",
  "dataverse\REGISTRO_BLOQUEOS.md",
  "tools\validate_proj_cdx_sync.ps1"
)
foreach ($relative in $syncFiles) {
  if (Test-Path -LiteralPath (Join-Path $Root $relative) -PathType Leaf) {
    Add-Check "sync_file:$relative" "PASS" "OK"
  } else {
    Add-Check "sync_file:$relative" "FAIL" "Falta archivo de sincronia."
  }
}

$trackerOutputs = Get-ChildItem -LiteralPath (Join-Path $Root "outputs") -Directory -Filter "tracker*" -ErrorAction SilentlyContinue
if ($trackerOutputs.Count -ge 2) {
  Add-Check "tracker_outputs_count" "PASS" "Existen corridas tracker."
} else {
  Add-Check "tracker_outputs_count" "OBSERVED" "Pocas corridas tracker."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  "STATUS: $($result.status)"
  foreach ($check in $result.checks) {
    "$($check.status) | $($check.name) | $($check.detail)"
  }
}

if ($result.status -eq "FAIL") {
  exit 1
}
