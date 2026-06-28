param(
  [string]$ActionId = "RUNTIME_DIAGNOSIS",
  [string]$ActionLabel = "Diagnostico local de runtime",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$root = "C:\CEO\watchdog"
$logPath = Join-Path $root "logs\action_execution.jsonl"
$telemetryPath = Join-Path $root "telemetry.json"
$scorePath = Join-Path $root "state\predictive_score.json"
$recommendedPath = Join-Path $root "outbox\recommended_actions.json"
$alertsPath = Join-Path $root "logs\alerts.jsonl"
$anomaliesPath = Join-Path $root "logs\anomalies.jsonl"

function Convert-JsonSafe([string]$JsonText) {
  try { return $JsonText | ConvertFrom-Json } catch { return [pscustomobject]@{} }
}

function Read-JsonSafe([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json } catch { return $null }
}

function Count-Jsonl([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return 0 }
  return (Get-Content -LiteralPath $Path | Where-Object { $_.Trim() }).Count
}

$preState = Convert-JsonSafe $PreStateJson
$telemetry = Read-JsonSafe $telemetryPath
$score = Read-JsonSafe $scorePath
$recommended = Read-JsonSafe $recommendedPath

$entry = [ordered]@{
  actionId = $ActionId
  actionLabel = $ActionLabel
  timestamp = (Get-Date).ToString("o")
  executedBy = $ExecutedBy
  decisionSource = $DecisionSource
  risk = $Risk
  result = "SUCCESS"
  preState = $preState
  postState = "UNCHANGED"
  impact = "LOCAL_RUNTIME_READ_ONLY_DIAGNOSIS"
  details = [ordered]@{
    telemetryPresent = [bool]$telemetry
    score = $score.score
    health = if ($score.effectiveHealth) { $score.effectiveHealth } else { $score.health }
    risk = $score.risk
    recommendation = if ($recommended.recommendations -and $recommended.recommendations.Count -gt 0) { $recommended.recommendations[0].action } else { $recommended.recommendation }
    alertsCount = Count-Jsonl $alertsPath
    anomaliesCount = Count-Jsonl $anomaliesPath
    sourceFiles = @($telemetryPath, $scorePath, $recommendedPath, $alertsPath, $anomaliesPath)
  }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $logPath) | Out-Null
Add-Content -LiteralPath $logPath -Value ($entry | ConvertTo-Json -Depth 12 -Compress)
$entry | ConvertTo-Json -Depth 12
