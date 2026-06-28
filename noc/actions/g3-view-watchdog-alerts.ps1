param(
  [string]$ActionId = "G3_VIEW_WATCHDOG_ALERTS",
  [string]$ActionLabel = "Ver alertas watchdog",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$gate = "C:\CEO\governance\agents\sdu-gate-agent.ps1"
$alerts = "C:\CEO\watchdog\logs\alerts.jsonl"

& $gate

$tail = @()
if (Test-Path -LiteralPath $alerts) {
  $tail = @(Get-Content -LiteralPath $alerts -Tail 20)
}

[ordered]@{
  actionId = $ActionId
  actionLabel = $ActionLabel
  result = "SUCCESS"
  impact = "LOCAL_ALERTS_READ_THROUGH_SDU_GATE"
  timestamp = (Get-Date).ToString("o")
  executedBy = $ExecutedBy
  decisionSource = $DecisionSource
  alertLines = $tail
  runtimeMutation = $false
  externalWrites = $false
} | ConvertTo-Json -Depth 8
