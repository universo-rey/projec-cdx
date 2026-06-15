param(
  [string]$Root = "C:\Users\enzo1\PROJEC CDX",
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

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
  Add-Check "root_exists" "FAIL" "No existe la raiz esperada."
} else {
  Add-Check "root_exists" "PASS" "Raiz encontrada."
}

$requiredFiles = @(
  "README.md",
  "MAPA_MAESTRO.md",
  "AGENTS.md",
  "operativa\START_HERE.md",
  "operativa\CONTROL.md",
  "operativa\CURRENT.md",
  "operativa\NEXT.md",
  "operativa\BLOCKERS.md",
  "operativa\TRACE.md",
  "operativa\MANIFESTS.md",
  "operativa\RETENCION.md",
  "playbooks\00-preflight-gobernado.md",
  "playbooks\01-iniciar-delta.md",
  "playbooks\02-ejecutar-delta.md",
  "playbooks\03-cerrar-delta.md",
  "playbooks\04-validar-delta.md",
  "playbooks\05-promover-aprendizaje.md",
  "playbooks\06-dataverse-gobernado.md",
  "dataverse\GATE.md",
  "workbooks\EXCEL_AL_FRENTE.md",
  "tools\validate_proj_cdx_workbench.ps1"
)

foreach ($relative in $requiredFiles) {
  $path = Join-Path $Root $relative
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    Add-Check "required_file:$relative" "PASS" "OK"
  } else {
    Add-Check "required_file:$relative" "FAIL" "Falta archivo requerido."
  }
}

$visibleDirs = Get-ChildItem -LiteralPath $Root -Directory -Force |
  Where-Object { $_.Name -notin @("node_modules") }

foreach ($dir in $visibleDirs) {
  $readme = Join-Path $dir.FullName "README.md"
  $map = Join-Path $dir.FullName "MAPA.md"
  if (Test-Path -LiteralPath $readme -PathType Leaf) {
    Add-Check "dir_readme:$($dir.Name)" "PASS" "README presente."
  } else {
    Add-Check "dir_readme:$($dir.Name)" "OBSERVED" "Carpeta visible sin README."
  }
  if (Test-Path -LiteralPath $map -PathType Leaf) {
    Add-Check "dir_map:$($dir.Name)" "PASS" "MAPA presente."
  } else {
    Add-Check "dir_map:$($dir.Name)" "OBSERVED" "Carpeta visible sin MAPA."
  }
}

$markdownFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Include "*.md" -Force |
  Where-Object { $_.FullName -notlike "*\node_modules\*" }

$linkPattern = [regex]'\]\((C:/Users/enzo1/[^)]+)\)'
foreach ($file in $markdownFiles) {
  $text = Get-Content -LiteralPath $file.FullName -Raw
  foreach ($match in $linkPattern.Matches($text)) {
    $raw = $match.Groups[1].Value
    $decoded = [uri]::UnescapeDataString($raw).Replace("/", "\")
    if (Test-Path -LiteralPath $decoded) {
      Add-Check "link:$($file.Name)" "PASS" $raw
    } else {
      Add-Check "link:$($file.Name)" "FAIL" "Link roto: $raw"
    }
  }
}

$xlsxFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter "*.xlsx" -Force |
  Where-Object { $_.FullName -notlike "*\node_modules\*" }
foreach ($xlsx in $xlsxFiles) {
  try {
    $stream = [System.IO.File]::OpenRead($xlsx.FullName)
    try {
      $bytes = New-Object byte[] 4
      [void]$stream.Read($bytes, 0, 4)
      $signature = [System.Text.Encoding]::ASCII.GetString($bytes)
      if ($signature.StartsWith("PK")) {
        Add-Check "xlsx:$($xlsx.Name)" "PASS" "ZIP valido."
      } else {
        Add-Check "xlsx:$($xlsx.Name)" "FAIL" "Firma XLSX invalida."
      }
    } finally {
      $stream.Dispose()
    }
  } catch {
    Add-Check "xlsx:$($xlsx.Name)" "FAIL" $_.Exception.Message
  }
}

$formulaFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter "formula_errors.ndjson" -Force |
  Where-Object { $_.FullName -notlike "*\node_modules\*" }
foreach ($formula in $formulaFiles) {
  $content = Get-Content -LiteralPath $formula.FullName -Raw
  if ([string]::IsNullOrWhiteSpace($content) -or $content -match "matched 0 entries") {
    Add-Check "formula_errors:$($formula.Directory.Name)" "PASS" "Sin errores."
  } else {
    Add-Check "formula_errors:$($formula.Directory.Name)" "OBSERVED" "Archivo no vacio; revisar contenido."
  }
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
