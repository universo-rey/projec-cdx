Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) { $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests" }
$liveRoot = Join-Path $testRoot ("owner-" + [guid]::NewGuid().ToString())
$action = [ordered]@{
    live_action_id = [guid]::NewGuid().ToString()
    action_id = [guid]::NewGuid().ToString()
    event_id = [guid]::NewGuid().ToString()
    environment = "LIVE_CONTROLLED"
    action_type = "LOCAL_EVIDENCE_WRITE"
    requested_at = (Get-Date).ToUniversalTime().ToString("o")
    requested_by = "test"
    source = "run-multi-owner-tests"
    risk = "HIGH"
    mode = "LIVE_CONTROLLED_SIMULATED"
    target = "<SANITIZED_TARGET>"
    policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
    rollback = [ordered]@{ required = $true; strategy = "dry-run"; compensating_action = "manual-review" }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    approvals = [ordered]@{ approval_status = "PENDING"; approvals = @(); required_roles = @("OWNER_OPERATIONAL", "OWNER_CONTROL") }
    trace = [ordered]@{ trace_id = [guid]::NewGuid().ToString() }
}
$approval = (& (Join-Path $root "tools\ceo-live-owner-gate.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -ApproveRole OWNER_OPERATIONAL,OWNER_CONTROL -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$approval.approval_status -ne "COMPLETE") { throw "MULTI_OWNER_NOT_COMPLETE" }

[ordered]@{
    status = "PASS"
    approval_status = [string]$approval.approval_status
    roles = @($approval.required_roles)
} | ConvertTo-Json -Depth 6
