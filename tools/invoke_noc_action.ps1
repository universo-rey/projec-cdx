param(
  [Parameter(Mandatory = $true)]
  [string]$PayloadPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PayloadPath)) {
  throw "payload file missing"
}

$payload = Get-Content -LiteralPath $PayloadPath -Raw -Encoding UTF8 | ConvertFrom-Json
$scriptPath = [string]$payload.scriptPath
if (-not (Test-Path -LiteralPath $scriptPath)) {
  throw "action script missing"
}

$actionParams = @{
  ActionId = [string]$payload.actionId
  ActionLabel = [string]$payload.actionLabel
  Risk = [string]$payload.risk
  ExecutedBy = [string]$payload.executedBy
  DecisionSource = [string]$payload.decisionSource
  PreStateJson = [string]$payload.preStateJson
}

& $scriptPath @actionParams
