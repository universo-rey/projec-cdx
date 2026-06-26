param(
  [string]$ActionId = "check_alert_source",
  [string]$ActionLabel = "Revisar origen de alertas",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$root = "C:\CEO\watchdog"
$logPath = Join-Path $root "logs\action_execution.jsonl"
$summaryPath = Join-Path $root "logs\alert_source_summary.json"
$alertsPath = Join-Path $root "logs\alerts.jsonl"

function Convert-JsonSafe([string]$JsonText) {
  try { return $JsonText | ConvertFrom-Json } catch { return [pscustomobject]@{} }
}

$preState = Convert-JsonSafe $PreStateJson
$summary = $null
if (Test-Path -LiteralPath $summaryPath) {
  $summary = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
}
$alertCount = 0
if (Test-Path -LiteralPath $alertsPath) {
  $alertCount = (Get-Content -LiteralPath $alertsPath | Where-Object { $_.Trim() }).Count
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
  impact = "LOCAL_READ_AND_TRACE_ONLY"
  details = [ordered]@{
    alertCount = $alertCount
    summaryPath = $summaryPath
    sourceSummary = $summary
  }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $logPath) | Out-Null
Add-Content -LiteralPath $logPath -Value ($entry | ConvertTo-Json -Depth 12 -Compress)
$entry | ConvertTo-Json -Depth 12
