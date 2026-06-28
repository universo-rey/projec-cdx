param(
  [string]$ActionId = "G3_REVALIDATE_SYSTEM",
  [string]$ActionLabel = "Revalidar sistema",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

$ErrorActionPreference = "Stop"
$gate = "C:\CEO\governance\agents\sdu-gate-agent.ps1"
$validator = "C:\CEO\governance\validators\validate-taxonomy.ps1"

& $gate
& $validator

[ordered]@{
  actionId = $ActionId
  actionLabel = $ActionLabel
  result = "SUCCESS"
  impact = "LOCAL_VALIDATION_THROUGH_SDU_GATE"
  timestamp = (Get-Date).ToString("o")
  executedBy = $ExecutedBy
  decisionSource = $DecisionSource
  runtimeMutation = $false
  externalWrites = $false
} | ConvertTo-Json -Depth 8
