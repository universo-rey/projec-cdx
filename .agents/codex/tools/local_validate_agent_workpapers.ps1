param(
  [string]$Root = ".agents\codex"
)

$ErrorActionPreference = "Stop"

function Read-CsvSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing CSV: $Path"
  }
  @(Import-Csv -LiteralPath $Path)
}

function Resolve-CabinaPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $Path
  }
  $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
  $repoRoot = Split-Path -Parent (Split-Path -Parent $resolvedRoot)
  $normalized = $Path -replace "/", "\"
  if ($normalized.StartsWith(".agents\codex", [System.StringComparison]::OrdinalIgnoreCase)) {
    $suffix = $normalized.Substring(".agents\codex".Length).TrimStart("\")
    return Join-Path $Root $suffix
  }
  if ($normalized.StartsWith("C:\Users\enzo1\Documents\GitHub\cabina-universal-d", [System.StringComparison]::OrdinalIgnoreCase)) {
    $suffix = $normalized.Substring("C:\Users\enzo1\Documents\GitHub\cabina-universal-d".Length).TrimStart("\")
    return Join-Path $repoRoot $suffix
  }
  return $Path
}

$agentsJson = Join-Path $Root "agents.json"
$workpapersRoot = Join-Path $Root "workpapers"
$workpaperIndex = Join-Path $workpapersRoot "WORKPAPER_INDEX.csv"
$agentWorkpapersMatrix = Join-Path $Root "matrices\AGENT_WORKPAPERS_MATRIX.csv"
$requiredFiles = @(
  "README.md",
  "CURRENT_WORKPAPER.md",
  "SURFACE_ROUTING.csv",
  "EVIDENCE_LOG.csv",
  "DECISION_LOG.csv",
  "OPEN_ITEMS.csv",
  "VALIDATION_LOG.csv"
)

$errors = New-Object System.Collections.Generic.List[string]

foreach ($path in @($agentsJson, $workpapersRoot, $workpaperIndex, $agentWorkpapersMatrix)) {
  if (-not (Test-Path -LiteralPath $path)) {
    $errors.Add("Missing required workpaper artifact: $path")
  }
}

if ($errors.Count -eq 0) {
  $agentData = Get-Content -LiteralPath $agentsJson -Raw | ConvertFrom-Json
  $agents = @($agentData.agents)
  $matrixRows = Read-CsvSafe -Path $agentWorkpapersMatrix
  $indexRows = Read-CsvSafe -Path $workpaperIndex
  $matrixByAgent = @{}
  $indexByAgent = @{}
  foreach ($row in $matrixRows) { $matrixByAgent[$row.agent_id] = $row }
  foreach ($row in $indexRows) { $indexByAgent[$row.agent_id] = $row }

  foreach ($agent in $agents) {
    $workpapersPathProperty = $agent.PSObject.Properties["workpapers_path"]
    $workpapersPath = if ($workpapersPathProperty) { Resolve-CabinaPath ([string]$workpapersPathProperty.Value) } else { "" }
    if ([string]::IsNullOrWhiteSpace($workpapersPath)) {
      $errors.Add("Agent lacks workpapers_path: $($agent.id)")
      continue
    }
    if (-not $matrixByAgent.ContainsKey($agent.id)) {
      $errors.Add("Agent missing from AGENT_WORKPAPERS_MATRIX: $($agent.id)")
    }
    if (-not $indexByAgent.ContainsKey($agent.id)) {
      $errors.Add("Agent missing from WORKPAPER_INDEX: $($agent.id)")
    }
    if (-not (Test-Path -LiteralPath $workpapersPath -PathType Container)) {
      $errors.Add("Workpaper folder missing for $($agent.id): $workpapersPath")
      continue
    }
    foreach ($fileName in $requiredFiles) {
      $candidate = Join-Path $workpapersPath $fileName
      if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        $errors.Add("Workpaper file missing for $($agent.id): $candidate")
      }
    }
  }

  foreach ($row in $matrixRows) {
    foreach ($column in @("status","primary_surface","purpose","required_matrices","required_recipes","required_tools","required_validators","evidence_policy","validator","stop_condition")) {
      $property = $row.PSObject.Properties[$column]
      $value = if ($property) { [string]$property.Value } else { "" }
      if ([string]::IsNullOrWhiteSpace($value)) {
        $errors.Add("Workpaper matrix row for $($row.agent_id) missing $column")
      }
    }
  }

  foreach ($row in $indexRows) {
    foreach ($column in @("status","last_updated","primary_surface","purpose","owner_agent","required_matrices","required_recipes","required_tools","required_validators","evidence_policy","stop_condition")) {
      $property = $row.PSObject.Properties[$column]
      $value = if ($property) { [string]$property.Value } else { "" }
      if ([string]::IsNullOrWhiteSpace($value)) {
        $errors.Add("Workpaper index row for $($row.agent_id) missing $column")
      }
    }
  }
}

$secretPatterns = @(
  "sk-[A-Za-z0-9_-]{20,}",
  "OPENAI_API_KEY\s*=",
  "BEGIN [A-Z ]*PRIVATE KEY",
  "password\s*=",
  "secret\s*=",
  "token\s*="
)
$secretHits = @()
if (Test-Path -LiteralPath $workpapersRoot) {
  $scanFiles = @(
    Get-ChildItem -LiteralPath $workpapersRoot -Recurse -File -Include "*.md","*.csv","*.json","*.yaml","*.yml","*.ps1"
  )
  foreach ($file in $scanFiles) {
    foreach ($pattern in $secretPatterns) {
      $hits = Select-String -LiteralPath $file.FullName -Pattern $pattern -CaseSensitive -ErrorAction SilentlyContinue
      foreach ($hit in $hits) {
        $secretHits += [pscustomobject]@{ path = $file.FullName; line = $hit.LineNumber; pattern = $pattern }
      }
    }
  }
}
if ($secretHits.Count -gt 0) {
  $errors.Add("Secret-like hits detected in workpapers: $($secretHits.Count)")
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
[pscustomobject]@{
  status = $status
  root = $Root
  workpapers_root = $workpapersRoot
  error_count = $errors.Count
  errors = $errors
  secret_hit_count = $secretHits.Count
  secret_hits = $secretHits
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
