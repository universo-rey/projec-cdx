param(
  [string]$ActionId = "evaluate_cleanup",
  [string]$ActionLabel = "Evaluar limpieza controlada",
  [string]$Risk = "MEDIUM",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$root = "C:\CEO\watchdog"
$logPath = Join-Path $root "logs\action_execution.jsonl"
$recommendedPath = Join-Path $root "outbox\recommended_actions.json"
$scorePath = Join-Path $root "state\predictive_score.json"

function Convert-JsonSafe([string]$JsonText) {
  try { return $JsonText | ConvertFrom-Json } catch { return [pscustomobject]@{} }
}

$preState = Convert-JsonSafe $PreStateJson
$recommended = $null
$score = $null
if (Test-Path -LiteralPath $recommendedPath) {
  $recommended = Get-Content -LiteralPath $recommendedPath -Raw | ConvertFrom-Json
}
if (Test-Path -LiteralPath $scorePath) {
  $score = Get-Content -LiteralPath $scorePath -Raw | ConvertFrom-Json
}

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
  impact = "EVALUATION_ONLY_NO_CLEANUP_EXECUTED"
  details = [ordered]@{
    cleanupTriggered = $false
    recommendation = $recommended.recommendations[0].action
    duplicateDetected = $recommended.duplicateDetected
    score = $score.score
    sourceFiles = @($recommendedPath, $scorePath)
  }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $logPath) | Out-Null
Add-Content -LiteralPath $logPath -Value ($entry | ConvertTo-Json -Depth 12 -Compress)
$entry | ConvertTo-Json -Depth 12
