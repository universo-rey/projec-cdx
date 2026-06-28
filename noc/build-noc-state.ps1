param(
  [string]$LastActionJson = "{}"
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "actions\_shared.ps1")

function Convert-JsonSafe([string]$JsonText) {
  try {
    if ([string]::IsNullOrWhiteSpace($JsonText)) { return [pscustomobject]@{} }
    return $JsonText | ConvertFrom-Json
  } catch {
    return [pscustomobject]@{}
  }
}

$lastAction = Convert-JsonSafe $LastActionJson
$context = [pscustomobject]@{}
if ($lastAction -and $lastAction.PSObject.Properties.Name -contains "actionId" -and $lastAction.actionId) {
  $context | Add-Member -NotePropertyName lastAction -NotePropertyValue $lastAction
}

$state = Build-NocState -Context $context
Save-NocState -State $state | Out-Null
$state | ConvertTo-Json -Depth 20
