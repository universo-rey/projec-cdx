Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) { $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests" }
$liveRoot = Join-Path $testRoot ("audit-" + [guid]::NewGuid().ToString())
$action = [ordered]@{
    live_action_id = [guid]::NewGuid().ToString(); action_id = [guid]::NewGuid().ToString(); event_id = [guid]::NewGuid().ToString()
    environment = "LIVE_CONTROLLED"; action_type = "LOCAL_EVIDENCE_WRITE"; requested_at = (Get-Date).ToUniversalTime().ToString("o"); requested_by = "test"; source = "audit"; risk = "HIGH"; mode = "LIVE_CONTROLLED_SIMULATED"; target = "<SANITIZED_TARGET>"
    policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
    rollback = [ordered]@{ required = $true; strategy = "dry-run"; compensating_action = "manual-review" }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    approvals = [ordered]@{ approval_status = "COMPLETE"; approvals = @(); required_roles = @("OWNER_OPERATIONAL", "OWNER_CONTROL") }
    trace = [ordered]@{ trace_id = [guid]::NewGuid().ToString() }
}
& (Join-Path $root "tools\ceo-live-authorize.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot | Out-Null
& (Join-Path $root "tools\ceo-live-preflight.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot | Out-Null
& (Join-Path $root "tools\ceo-live-executor.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot | Out-Null
& (Join-Path $root "tools\ceo-live-rollback.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot | Out-Null
$audit = (& (Join-Path $root "tools\ceo-live-audit.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if (-not $audit.audit_ready) { throw "AUDIT_NOT_READY" }
if (-not $audit.closure_valid) { throw "AUDIT_CLOSURE_INVALID" }
if ([bool]$audit.live_real_enabled) { throw "AUDIT_LIVE_REAL_ENABLED" }
[ordered]@{ status = "PASS"; audit_ready = [bool]$audit.audit_ready; closure_valid = [bool]$audit.closure_valid } | ConvertTo-Json -Depth 6
