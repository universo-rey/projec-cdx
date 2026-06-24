param(
    [string] $LiveActionFile,
    [string] $LiveActionJson,
    [string] $LiveRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Read-LiveAction {
    if (-not [string]::IsNullOrWhiteSpace($LiveActionFile)) { return (Get-Content -LiteralPath $LiveActionFile -Raw | ConvertFrom-Json) }
    if (-not [string]::IsNullOrWhiteSpace($LiveActionJson)) { return ($LiveActionJson | ConvertFrom-Json) }
    throw "LIVE_ACTION_REQUIRED"
}

$runtime = Initialize-CeoLiveOperationsState -LiveRoot $LiveRoot -StateRoot $StateRoot
$action = Read-LiveAction
$rollback = Get-CeoEventBusProperty -InputObject $action -Name "rollback" -Default ([PSCustomObject]@{})
$valid = ([bool](Get-CeoEventBusProperty -InputObject $rollback -Name "required" -Default $false) -eq $true -and -not [string]::IsNullOrWhiteSpace([string](Get-CeoEventBusProperty -InputObject $rollback -Name "compensating_action" -Default "")))
$doc = [ordered]@{
    rollback_id = [guid]::NewGuid().ToString()
    live_action_id = [string]$action.live_action_id
    required = $true
    strategy = [string](Get-CeoEventBusProperty -InputObject $rollback -Name "strategy" -Default "dry-run-compensating-action")
    compensating_action = [string](Get-CeoEventBusProperty -InputObject $rollback -Name "compensating_action" -Default "manual-review")
    validated = $valid
    rollback_executed_real = $false
    evidence_path = "<EVIDENCE_PATH>"
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Rollback "$($action.live_action_id).rollback.json") -InputObject $doc
[ordered]@{
    rollback_required = $true
    rollback_validated = $valid
    rollback_executed_real = $false
    rollback_evidence_path = "<EVIDENCE_PATH>"
} | ConvertTo-Json -Depth 10
if (-not $valid) { exit 40 }
exit 0
