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
    if (-not [string]::IsNullOrWhiteSpace($LiveActionFile)) {
        return (Get-Content -LiteralPath $LiveActionFile -Raw | ConvertFrom-Json)
    }
    if (-not [string]::IsNullOrWhiteSpace($LiveActionJson)) {
        return ($LiveActionJson | ConvertFrom-Json)
    }
    throw "LIVE_ACTION_REQUIRED"
}

$runtime = Initialize-CeoLiveOperationsState -LiveRoot $LiveRoot -StateRoot $StateRoot
$action = Read-LiveAction
$liveActionId = [string](Get-CeoEventBusProperty -InputObject $action -Name "live_action_id" -Default "")
if ([string]::IsNullOrWhiteSpace($liveActionId)) { throw "LIVE_ACTION_ID_REQUIRED" }

$environment = [string](Get-CeoEventBusProperty -InputObject $action -Name "environment" -Default "")
$mode = [string](Get-CeoEventBusProperty -InputObject $action -Name "mode" -Default "")
$actionType = [string](Get-CeoEventBusProperty -InputObject $action -Name "action_type" -Default "")
$target = [string](Get-CeoEventBusProperty -InputObject $action -Name "target" -Default "")
$policy = Get-CeoEventBusProperty -InputObject $action -Name "policy" -Default ([PSCustomObject]@{})
$rollback = Get-CeoEventBusProperty -InputObject $action -Name "rollback" -Default ([PSCustomObject]@{})
$evidence = Get-CeoEventBusProperty -InputObject $action -Name "evidence" -Default ([PSCustomObject]@{})
$approvals = Get-CeoEventBusProperty -InputObject $action -Name "approvals" -Default ([PSCustomObject]@{})

$envEntry = Get-CeoEnvironmentRegistryEntry -Environment $environment
$actionEntry = Get-CeoActionRegistryEntry -ActionType $actionType
$reasons = @()
$decision = "BLOCK"
$ownerRequired = $false
$multiRequired = $false

if ($null -eq $envEntry) { $reasons += "unknown_environment" }
else {
    $ownerRequired = [bool]$envEntry.requires_owner_gate
    $multiRequired = [bool]$envEntry.requires_multi_approval
    if ([bool]$envEntry.external_write_allowed) { $reasons += "external_write_allowed_true" }
    if ($mode -notin @($envEntry.allowed_modes)) { $reasons += "mode_not_allowed:$mode" }
}
if ($null -eq $actionEntry) { $reasons += "unknown_action_type:$actionType" }
if ($mode -eq "LIVE_CONTROLLED_REAL") { $reasons += "live_controlled_real_blocked" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "live_write" -Default $false)) { $reasons += "policy_live_write_true" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "external" -Default $false)) { $reasons += "policy_external_true" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "delete" -Default $false)) { $reasons += "policy_delete_true" }
if ([bool](Get-CeoEventBusProperty -InputObject $rollback -Name "required" -Default $false) -ne $true) { $reasons += "rollback_required_missing" }
if ([string]::IsNullOrWhiteSpace([string](Get-CeoEventBusProperty -InputObject $rollback -Name "compensating_action" -Default ""))) { $reasons += "compensating_action_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $evidence -Name "required" -Default $false) -ne $true) { $reasons += "evidence_required_false" }
if (-not (Test-CeoSanitizedTarget -Target $target)) { $reasons += "target_not_sanitized" }

$approvalStatus = [string](Get-CeoEventBusProperty -InputObject $approvals -Name "approval_status" -Default "PENDING")
if ($reasons.Count -eq 0) {
    if ($multiRequired -and $approvalStatus -ne "COMPLETE") {
        $decision = "MULTI_OWNER_PENDING"
        $reasons += "multi_owner_approval_required"
    }
    elseif ($ownerRequired -and $approvalStatus -ne "COMPLETE") {
        $decision = "HOLD_OWNER"
        $reasons += "owner_gate_required"
    }
    else {
        $decision = "ALLOW_LIVE_SIMULATED"
        $reasons += "simulation_allowed_no_live_real"
    }
}

$authorization = [ordered]@{
    authorization_id = [guid]::NewGuid().ToString()
    live_action_id = $liveActionId
    authorized = ($decision -eq "ALLOW_LIVE_SIMULATED")
    decision = $decision
    live_real_enabled = $false
    external_write_enabled = $false
    reason = ($reasons -join ";")
    requires_rollback = $true
    requires_multi_approval = $multiRequired
    evidence_path = "<EVIDENCE_PATH>"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Requests "$liveActionId.live-action.json") -InputObject $action
Save-CeoEventBusJson -Path (Join-Path $runtime.State "$liveActionId.authorization.json") -InputObject $authorization
$authorization | ConvertTo-Json -Depth 12
if ($decision -eq "BLOCK") { exit 40 }
exit 0
