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
$risk = [string](Get-CeoEventBusProperty -InputObject $action -Name "risk" -Default "")
$policy = Get-CeoEventBusProperty -InputObject $action -Name "policy" -Default ([PSCustomObject]@{})
$rollback = Get-CeoEventBusProperty -InputObject $action -Name "rollback" -Default ([PSCustomObject]@{})
$evidence = Get-CeoEventBusProperty -InputObject $action -Name "evidence" -Default ([PSCustomObject]@{})
$approvals = Get-CeoEventBusProperty -InputObject $action -Name "approvals" -Default ([PSCustomObject]@{})
$liveSession = Get-CeoEventBusProperty -InputObject $action -Name "live_session" -Default ([PSCustomObject]@{})
$session = Get-CeoLiveSessionStatus -LiveRoot $runtime.Root
$requiredRoles = @(Get-CeoRequiredFormalLiveOwnerRoles)
$approvalRows = @(Get-CeoEventBusProperty -InputObject $approvals -Name "approvals" -Default @())
$approvedRoles = @($approvalRows | Where-Object { [bool](Get-CeoEventBusProperty -InputObject $_ -Name "approved" -Default $false) } | ForEach-Object { [string](Get-CeoEventBusProperty -InputObject $_ -Name "role" -Default "") } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
$missingRoles = @($requiredRoles | Where-Object { $_ -notin $approvedRoles })
$reasons = @()

$registry = Get-CeoEnvironmentRegistry
$envEntry = Get-CeoEnvironmentRegistryEntry -Environment $environment
$actionEntry = Get-CeoActionRegistryEntry -ActionType $actionType

if (-not [bool](Get-CeoEventBusProperty -InputObject $registry -Name "live_controlled_real_enabled" -Default $false)) { $reasons += "registry_live_real_disabled" }
if ($null -eq $envEntry) { $reasons += "unknown_environment:$environment" }
else {
    if ($mode -notin @($envEntry.allowed_modes)) { $reasons += "mode_not_allowed:$mode" }
    if (-not [bool]$envEntry.requires_multi_approval) { $reasons += "multi_approval_not_required_by_environment" }
}
if ($null -eq $actionEntry) { $reasons += "unknown_action_type:$actionType" }
elseif ($mode -notin @($actionEntry.allowed_modes)) { $reasons += "action_mode_not_allowed:$mode" }
if ($environment -ne "LIVE_CONTROLLED") { $reasons += "environment_not_live_controlled" }
if ($mode -ne "LIVE_CONTROLLED_REAL") { $reasons += "mode_not_live_controlled_real" }
if (-not (Test-CeoLiveSessionActive -Session $session)) { $reasons += "live_session_not_active" }
$requestedSessionId = [string](Get-CeoEventBusProperty -InputObject $liveSession -Name "session_id" -Default "")
if (-not [string]::IsNullOrWhiteSpace($requestedSessionId) -and $requestedSessionId -ne [string]$session.session_id) { $reasons += "live_session_id_mismatch" }
if ($risk -in @("HIGH", "CRITICAL") -and $missingRoles.Count -gt 0) { $reasons += "missing_roles:$($missingRoles -join ',')" }
if ([string](Get-CeoEventBusProperty -InputObject $approvals -Name "approval_status" -Default "") -ne "COMPLETE") { $reasons += "approval_status_not_complete" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "formal_authorization" -Default $false) -ne $true) { $reasons += "formal_authorization_policy_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "allow_live_real" -Default $false) -ne $true) { $reasons += "allow_live_real_policy_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "external" -Default $false)) { $reasons += "policy_external_true" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "delete" -Default $false)) { $reasons += "policy_delete_true" }
if ([bool](Get-CeoEventBusProperty -InputObject $rollback -Name "required" -Default $false) -ne $true) { $reasons += "rollback_required_missing" }
if ([string]::IsNullOrWhiteSpace([string](Get-CeoEventBusProperty -InputObject $rollback -Name "compensating_action" -Default ""))) { $reasons += "compensating_action_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $evidence -Name "required" -Default $false) -ne $true) { $reasons += "evidence_required_false" }
if (-not (Test-CeoSanitizedTarget -Target $target)) { $reasons += "target_not_sanitized" }

$authorized = ($reasons.Count -eq 0)
$authorization = [ordered]@{
    authorization_id = [guid]::NewGuid().ToString()
    live_action_id = $liveActionId
    session_id = [string]$session.session_id
    authorized = $authorized
    decision = $(if ($authorized) { "ALLOW_LIVE_REAL_FORMAL" } else { "BLOCK" })
    live_real_enabled = $authorized
    external_write_enabled = $false
    required_roles = $requiredRoles
    approved_roles = $approvedRoles
    missing_roles = $missingRoles
    reason = $(if ($authorized) { "formal_live_authorization_complete" } else { $reasons -join ";" })
    requires_rollback = $true
    requires_audit = $true
    evidence_path = "<EVIDENCE_PATH>"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}

Save-CeoEventBusJson -Path (Join-Path $runtime.State "$liveActionId.formal-authorization.json") -InputObject $authorization
$authorization | ConvertTo-Json -Depth 12
if (-not $authorized) { exit 40 }
exit 0
