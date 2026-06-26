Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "actions\tests"
}
$caseRoot = Join-Path $testRoot ("owner-" + [guid]::NewGuid().ToString())
$actionRoot = Join-Path $caseRoot "actions"

$action = [ordered]@{
    action_id = [guid]::NewGuid().ToString()
    event_id = [guid]::NewGuid().ToString()
    action_type = "REPLAY_DRY_RUN"
    risk = "HIGH"
    requires_owner_gate = $true
    mode = "DRY_RUN"
    policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
}

$auth = (& (Join-Path $root "tools\ceo-action-authorize.ps1") -ActionJson ($action | ConvertTo-Json -Depth 20) -ActionRoot $actionRoot) | ConvertFrom-Json
if ([string]$auth.decision -ne "HOLD_OWNER") { throw "OWNER_GATE_NOT_REQUIRED" }

$approval = (& (Join-Path $root "tools\ceo-owner-approval.ps1") -AuthorizationId $auth.authorization_id -Approve -Owner "LOCAL_OWNER" -ActionRoot $actionRoot) | ConvertFrom-Json
if (-not $approval.approved) { throw "OWNER_APPROVAL_NOT_RECORDED" }

[ordered]@{
    status = "PASS"
    authorization_id = [string]$auth.authorization_id
    approved = [bool]$approval.approved
} | ConvertTo-Json -Depth 6
