Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) { $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests" }
$liveRoot = Join-Path $testRoot ("execute-" + [guid]::NewGuid().ToString())
$action = [ordered]@{
    live_action_id = [guid]::NewGuid().ToString(); action_id = [guid]::NewGuid().ToString(); event_id = [guid]::NewGuid().ToString()
    environment = "LIVE_CONTROLLED"; action_type = "LOCAL_EVIDENCE_WRITE"; requested_at = (Get-Date).ToUniversalTime().ToString("o"); requested_by = "test"; source = "execution"; risk = "HIGH"; mode = "LIVE_CONTROLLED_SIMULATED"; target = "<SANITIZED_TARGET>"
    policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
    rollback = [ordered]@{ required = $true; strategy = "dry-run"; compensating_action = "manual-review" }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    approvals = [ordered]@{ approval_status = "COMPLETE"; approvals = @(); required_roles = @("OWNER_OPERATIONAL", "OWNER_CONTROL") }
    trace = [ordered]@{ trace_id = [guid]::NewGuid().ToString() }
}
$result = (& (Join-Path $root "tools\ceo-live-executor.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if (-not $result.executed) { throw "LIVE_SIMULATION_NOT_EXECUTED" }
if ([bool]$result.live_real_enabled) { throw "LIVE_REAL_ENABLED" }
if ([bool]$result.changes_applied) { throw "CHANGES_APPLIED" }

[ordered]@{ status = "PASS"; mode = [string]$result.mode; changes_applied = [bool]$result.changes_applied } | ConvertTo-Json -Depth 6
