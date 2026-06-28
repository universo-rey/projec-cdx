param(
  [string]$Root = ".agents\codex"
)

$ErrorActionPreference = "Stop"

$agentsJson = Join-Path $Root "agents.json"
$levelsYaml = Join-Path $Root "agents\LEVELS.yaml"
$agentsIndex = Join-Path $Root "AGENTS_INDEX.csv"
$matrixIndex = Join-Path $Root "matrices\MATRIX_INDEX.csv"
$capabilityMatrix = Join-Path $Root "matrices\CAPABILITY_MATRIX.csv"
$recipeIndex = Join-Path $Root "recipes\RECIPE_INDEX.csv"
$toolIndex = Join-Path $Root "tools\TOOL_INDEX.csv"
$workpaperIndex = Join-Path $Root "workpapers\WORKPAPER_INDEX.csv"
$agentWorkpapersMatrix = Join-Path $Root "matrices\AGENT_WORKPAPERS_MATRIX.csv"

$requiredFiles = @(
  $agentsJson,
  $levelsYaml,
  $agentsIndex,
  $matrixIndex,
  $capabilityMatrix,
  $recipeIndex,
  $toolIndex,
  $workpaperIndex,
  $agentWorkpapersMatrix
)

$missingRequired = @($requiredFiles | Where-Object { -not (Test-Path -LiteralPath $_) })
$data = Get-Content -LiteralPath $agentsJson -Raw | ConvertFrom-Json
$agents = @($data.agents)
$levels = @($data.agent_levels)
$homeMissing = @($agents | Where-Object { -not (Test-Path -LiteralPath $_.home_path) } | ForEach-Object { $_.id })
$rootFlatProfiles = @(Get-ChildItem -LiteralPath (Join-Path $Root "agents") -File -Filter "*.md" | Where-Object { $_.Name -ne "README.md" -and $_.Name -notlike "SOURCE_*" })

$levelIds = @($levels | ForEach-Object { $_.id })
$agentLevelMissing = @($agents | Where-Object { -not $_.level_id -or $_.level_id -notin $levelIds } | ForEach-Object { $_.id })
$requiredWorkpaperFiles = @(
  "README.md",
  "CURRENT_WORKPAPER.md",
  "SURFACE_ROUTING.csv",
  "EVIDENCE_LOG.csv",
  "DECISION_LOG.csv",
  "OPEN_ITEMS.csv",
  "VALIDATION_LOG.csv"
)
$workpaperPathMissing = @()
$missingWorkpaperArtifacts = @()
foreach ($agent in $agents) {
  $workpapersPathProperty = $agent.PSObject.Properties["workpapers_path"]
  $workpapersPath = if ($workpapersPathProperty) { [string]$workpapersPathProperty.Value } else { "" }
  if ([string]::IsNullOrWhiteSpace($workpapersPath)) {
    $workpaperPathMissing += $agent.id
    continue
  }
  if (-not (Test-Path -LiteralPath $workpapersPath -PathType Container)) {
    $missingWorkpaperArtifacts += $workpapersPath
    continue
  }
  foreach ($fileName in $requiredWorkpaperFiles) {
    $candidate = Join-Path $workpapersPath $fileName
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
      $missingWorkpaperArtifacts += $candidate
    }
  }
}
$missingSublevelArtifacts = @()
foreach ($level in $levels) {
  $expected = @(
    (Join-Path $level.folder "README.md"),
    (Join-Path $level.folder "CAPABILITIES.csv"),
    (Join-Path $level.folder "READING_MAP.csv"),
    (Join-Path $level.folder "HANDOFFS.csv")
  )
  foreach ($item in $expected) {
    if (-not (Test-Path -LiteralPath $item)) {
      $missingSublevelArtifacts += $item
    }
  }
}

$secretPatterns = @(
  "sk-[A-Za-z0-9_-]{20,}",
  "OPENAI_API_KEY\s*=",
  "BEGIN [A-Z ]*PRIVATE KEY",
  "password\s*=",
  "secret\s*="
)
$scanFiles = @(
  Get-ChildItem -LiteralPath $Root -Recurse -File -Include "*.md","*.csv","*.json","*.yaml","*.yml","*.ps1" |
    Where-Object { $_.FullName -notmatch "\\readbacks\\.*RAW" }
)
$secretHits = @()
foreach ($file in $scanFiles) {
  foreach ($pattern in $secretPatterns) {
    $hits = Select-String -LiteralPath $file.FullName -Pattern $pattern -CaseSensitive -ErrorAction SilentlyContinue
    foreach ($hit in $hits) {
      $secretHits += [pscustomobject]@{ path = $file.FullName; line = $hit.LineNumber; pattern = $pattern }
    }
  }
}

$status = "PASS"
if ($missingRequired.Count -gt 0 -or $homeMissing.Count -gt 0 -or $rootFlatProfiles.Count -gt 0 -or $agentLevelMissing.Count -gt 0 -or $workpaperPathMissing.Count -gt 0 -or $missingWorkpaperArtifacts.Count -gt 0 -or $missingSublevelArtifacts.Count -gt 0 -or $secretHits.Count -gt 0) {
  $status = "FAIL"
}

[pscustomobject]@{
  status = $status
  root = $Root
  agent_count = $agents.Count
  level_count = $levels.Count
  missing_required_files = $missingRequired
  missing_home_paths = $homeMissing
  flat_profiles_at_root = @($rootFlatProfiles | ForEach-Object { $_.FullName })
  agents_without_valid_level = $agentLevelMissing
  agents_without_workpaper_path = $workpaperPathMissing
  missing_workpaper_artifacts = $missingWorkpaperArtifacts
  missing_sublevel_artifacts = $missingSublevelArtifacts
  secret_hit_count = $secretHits.Count
  secret_hits = $secretHits
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
