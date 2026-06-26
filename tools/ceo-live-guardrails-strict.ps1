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
$session = Get-CeoLiveSessionStatus -LiveRoot $runtime.Root
$policy = Get-CeoEventBusProperty -InputObject $action -Name "policy" -Default ([PSCustomObject]@{})
$rollback = Get-CeoEventBusProperty -InputObject $action -Name "rollback" -Default ([PSCustomObject]@{})
$evidence = Get-CeoEventBusProperty -InputObject $action -Name "evidence" -Default ([PSCustomObject]@{})
$approvals = Get-CeoEventBusProperty -InputObject $action -Name "approvals" -Default ([PSCustomObject]@{})
$passed = @()
$failed = @()

if (Test-CeoLiveSessionActive -Session $session) { $passed += "live_session_active" } else { $failed += "live_session_not_active" }
if ([string]$action.environment -eq "LIVE_CONTROLLED") { $passed += "environment_live_controlled" } else { $failed += "environment_not_live_controlled" }
if ([string]$action.mode -eq "LIVE_CONTROLLED_REAL") { $passed += "mode_live_controlled_real" } else { $failed += "mode_not_live_controlled_real" }
if ([bool](Get-CeoEventBusProperty -InputObject $rollback -Name "required" -Default $false) -eq $true -and -not [string]::IsNullOrWhiteSpace([string](Get-CeoEventBusProperty -InputObject $rollback -Name "compensating_action" -Default ""))) { $passed += "rollback_present" } else { $failed += "rollback_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $evidence -Name "required" -Default $false) -eq $true) { $passed += "evidence_required" } else { $failed += "evidence_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "formal_authorization" -Default $false) -eq $true) { $passed += "formal_authorization_policy" } else { $failed += "formal_authorization_policy_missing" }
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "allow_live_real" -Default $false) -eq $true) { $passed += "allow_live_real_policy" } else { $failed += "allow_live_real_policy_missing" }
if (-not [bool](Get-CeoEventBusProperty -InputObject $policy -Name "external" -Default $false)) { $passed += "external_write_blocked" } else { $failed += "external_write_requested" }
if (-not [bool](Get-CeoEventBusProperty -InputObject $policy -Name "delete" -Default $false)) { $passed += "delete_blocked" } else { $failed += "delete_requested" }
if ([string](Get-CeoEventBusProperty -InputObject $approvals -Name "approval_status" -Default "") -eq "COMPLETE") { $passed += "multi_actor_complete" } else { $failed += "multi_actor_incomplete" }
if (Test-CeoSanitizedTarget -Target ([string]$action.target)) { $passed += "target_sanitized" } else { $failed += "target_not_sanitized" }

$doc = [ordered]@{
    guardrail_id = [guid]::NewGuid().ToString()
    live_action_id = [string]$action.live_action_id
    strict_guardrails_ok = ($failed.Count -eq 0)
    guardrails_passed = @($passed)
    guardrails_failed = @($failed)
    live_real_enabled = ($failed.Count -eq 0)
    external_write_enabled = $false
    kill_switch_available = [bool](Get-CeoEventBusProperty -InputObject $session -Name "kill_switch_available" -Default $false)
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Preflight "$($action.live_action_id).strict-guardrails.json") -InputObject $doc
$doc | ConvertTo-Json -Depth 10
if ($failed.Count -gt 0) { exit 40 }
exit 0
