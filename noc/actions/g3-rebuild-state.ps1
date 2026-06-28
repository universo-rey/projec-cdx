param(
  [string]$ActionId = "G3_REBUILD_STATE",
  [string]$ActionLabel = "Rebuild state",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$gate = "C:\CEO\governance\agents\sdu-gate-agent.ps1"
$builder = "C:\CEO\governance\state\sdu-build-system-state.ps1"

& $gate
& $builder

[ordered]@{
  actionId = $ActionId
  actionLabel = $ActionLabel
  result = "SUCCESS"
  impact = "LOCAL_STATE_REBUILD_THROUGH_SDU_GATE"
  timestamp = (Get-Date).ToString("o")
  executedBy = $ExecutedBy
  decisionSource = $DecisionSource
  runtimeMutation = $true
  externalWrites = $false
} | ConvertTo-Json -Depth 8
