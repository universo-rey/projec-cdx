param(
  [string]$ActionId = "G3_FORCE_SYNC",
  [string]$ActionLabel = "Forzar sincronización",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$gate = "C:\CEO\governance\agents\sdu-gate-agent.ps1"
$watchdog = "C:\CEO\watchdog\watchdog.ps1"

& $gate
& $watchdog

[ordered]@{
  actionId = $ActionId
  actionLabel = $ActionLabel
  result = "SUCCESS"
  impact = "LOCAL_WATCHDOG_SYNC_THROUGH_SDU_GATE"
  timestamp = (Get-Date).ToString("o")
  executedBy = $ExecutedBy
  decisionSource = $DecisionSource
  runtimeMutation = $true
  externalWrites = $false
} | ConvertTo-Json -Depth 8
