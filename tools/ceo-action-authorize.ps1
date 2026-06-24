param(
    [string] $ActionFile,
    [string] $ActionJson,
    [string] $ActionRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Read-ActionInput {
    if (-not [string]::IsNullOrWhiteSpace($ActionFile)) {
        return (Get-Content -LiteralPath $ActionFile -Raw | ConvertFrom-Json)
    }
    if (-not [string]::IsNullOrWhiteSpace($ActionJson)) {
        return ($ActionJson | ConvertFrom-Json)
    }
    throw "ACTION_REQUIRED"
}

$runtime = Initialize-CeoActionRuntimeState -ActionRoot $ActionRoot -StateRoot $StateRoot
$action = Read-ActionInput
$actionId = [string](Get-CeoEventBusProperty -InputObject $action -Name "action_id" -Default "")
if ([string]::IsNullOrWhiteSpace($actionId)) {
    throw "ACTION_ID_REQUIRED"
}

$actionType = [string](Get-CeoEventBusProperty -InputObject $action -Name "action_type" -Default "")
$mode = [string](Get-CeoEventBusProperty -InputObject $action -Name "mode" -Default "DRY_RUN")
$entry = Get-CeoActionRegistryEntry -ActionType $actionType
$known = ($null -ne $entry)
$riskDoc = (& (Join-Path $PSScriptRoot "ceo-risk-engine.ps1") -ActionJson (ConvertTo-CeoEventBusJson -InputObject $action -Depth 20)) | ConvertFrom-Json

$decision = "BLOCK"
$authorized = $false
$ownerGate = [bool]$riskDoc.requires_owner_gate
$reasons = @()

if (-not $known) {
    $reasons += "unknown_action"
}
else {
    $allowedModes = @($entry.allowed_modes)
    if ($mode -notin $allowedModes) {
        $reasons += "mode_not_allowed:$mode"
    }
}

$policy = Get-CeoEventBusProperty -InputObject $action -Name "policy" -Default ([PSCustomObject]@{})
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "live_write" -Default $false)) {
    $reasons += "live_write_blocked"
}
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "external" -Default $false)) {
    $reasons += "external_blocked"
}
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "delete" -Default $false)) {
    $reasons += "delete_blocked"
}
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "dry_run_required" -Default $true) -ne $true) {
    $reasons += "dry_run_required_false"
}

$evidence = Get-CeoEventBusProperty -InputObject $action -Name "evidence" -Default ([PSCustomObject]@{})
if ([bool](Get-CeoEventBusProperty -InputObject $evidence -Name "required" -Default $false) -ne $true) {
    $reasons += "evidence_required_false"
}

if ($reasons.Count -eq 0) {
    if ($ownerGate) {
        $decision = "HOLD_OWNER"
        $reasons += "owner_gate_required"
    }
    else {
        $decision = "ALLOW"
        $authorized = $true
        $reasons += "dry_run_local_action_allowed"
    }
}

$authorizationId = [guid]::NewGuid().ToString()
$authorization = [ordered]@{
    authorization_id = $authorizationId
    action_id = $actionId
    action_type = $actionType
    decision = $decision
    authorized = $authorized
    owner_gate_required = $ownerGate
    risk = [string]$riskDoc.risk
    reason = ($reasons -join ";")
    evidence_path = "<EVIDENCE_PATH>"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}

Save-CeoEventBusJson -Path (Join-Path $runtime.Requests "$actionId.action.json") -InputObject $action
Save-CeoEventBusJson -Path (Join-Path $runtime.Authorizations "$authorizationId.authorization.json") -InputObject $authorization
$authorization | ConvertTo-Json -Depth 10
if ($decision -eq "BLOCK") { exit 40 }
exit 0
