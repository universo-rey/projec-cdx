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
$passed = @()
$failed = @()
$envEntry = Get-CeoEnvironmentRegistryEntry -Environment ([string]$action.environment)
if ($null -ne $envEntry) { $passed += "environment_valid" } else { $failed += "environment_unknown" }
if ($null -ne $envEntry -and [string]$action.mode -in @($envEntry.allowed_modes)) { $passed += "mode_allowed" } else { $failed += "mode_not_allowed" }
if ([string]$action.mode -ne "LIVE_CONTROLLED_REAL") { $passed += "live_real_disabled" } else { $failed += "live_real_requested" }
if ([bool]$action.rollback.required -eq $true -and -not [string]::IsNullOrWhiteSpace([string]$action.rollback.compensating_action)) { $passed += "rollback_present" } else { $failed += "rollback_missing" }
if ([bool]$action.evidence.required -eq $true) { $passed += "evidence_required" } else { $failed += "evidence_missing" }
if (-not [bool]$action.policy.live_write -and -not [bool]$action.policy.external -and -not [bool]$action.policy.delete) { $passed += "policy_strict" } else { $failed += "policy_not_strict" }
if (Test-CeoSanitizedTarget -Target ([string]$action.target)) { $passed += "target_sanitized" } else { $failed += "target_not_sanitized" }
$forbiddenSurfacePattern = ("web" + "/") + "|" + ("out" + "puts/") + "|" + ("graphify" + "-out") + "|push|pull request|pr"
if ([string]$action.target -notmatch $forbiddenSurfacePattern) { $passed += "no_forbidden_surface" } else { $failed += "forbidden_surface" }
$approvalStatus = [string]$action.approvals.approval_status
if ($null -ne $envEntry -and [bool]$envEntry.requires_multi_approval) {
    if ($approvalStatus -eq "COMPLETE") { $passed += "multi_owner_complete" } else { $failed += "multi_owner_incomplete" }
}

$doc = [ordered]@{
    preflight_id = [guid]::NewGuid().ToString()
    live_action_id = [string]$action.live_action_id
    preflight_ok = ($failed.Count -eq 0)
    guardrails_passed = @($passed)
    guardrails_failed = @($failed)
    live_real_enabled = $false
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Preflight "$($action.live_action_id).preflight.json") -InputObject $doc
$doc | ConvertTo-Json -Depth 10
if ($failed.Count -gt 0) { exit 40 }
exit 0
