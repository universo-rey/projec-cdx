Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) { $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests" }
$liveRoot = Join-Path $testRoot ("auth-" + [guid]::NewGuid().ToString())

function New-LiveAction {
    param([string]$Environment = "LIVE_CONTROLLED", [string]$Mode = "LIVE_CONTROLLED_SIMULATED", [string]$ApprovalStatus = "PENDING", [bool]$Rollback = $true, [bool]$Evidence = $true, [string]$Target = "<SANITIZED_TARGET>")
    return [ordered]@{
        live_action_id = [guid]::NewGuid().ToString()
        action_id = [guid]::NewGuid().ToString()
        event_id = [guid]::NewGuid().ToString()
        environment = $Environment
        action_type = "LOCAL_EVIDENCE_WRITE"
        requested_at = (Get-Date).ToUniversalTime().ToString("o")
        requested_by = "test"
        source = "run-live-authorization-tests"
        risk = "HIGH"
        mode = $Mode
        target = $Target
        policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
        rollback = [ordered]@{ required = $Rollback; strategy = "dry-run"; compensating_action = "manual-review" }
        evidence = [ordered]@{ required = $Evidence; path = "<EVIDENCE_PATH>" }
        approvals = [ordered]@{ approval_status = $ApprovalStatus; approvals = @(); required_roles = @("OWNER_OPERATIONAL", "OWNER_CONTROL") }
        trace = [ordered]@{ trace_id = [guid]::NewGuid().ToString() }
    }
}

$pending = New-LiveAction
$pendingAuth = (& (Join-Path $root "tools\ceo-live-authorize.ps1") -LiveActionJson ($pending | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$pendingAuth.decision -ne "MULTI_OWNER_PENDING") { throw "PENDING_NOT_DETECTED" }

$complete = New-LiveAction -ApprovalStatus "COMPLETE"
$completeAuth = (& (Join-Path $root "tools\ceo-live-authorize.ps1") -LiveActionJson ($complete | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$completeAuth.decision -ne "ALLOW_LIVE_SIMULATED") { throw "SIMULATION_NOT_ALLOWED" }

$noRollback = New-LiveAction -Rollback $false
$noRollbackPath = Join-Path $liveRoot "no-rollback-action.json"
New-Item -ItemType Directory -Force -Path $liveRoot | Out-Null
$noRollback | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $noRollbackPath -Encoding UTF8
$blockedRaw = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-live-authorize.ps1") -LiveActionFile $noRollbackPath -LiveRoot $liveRoot
$blocked = $blockedRaw | ConvertFrom-Json
if ([string]$blocked.decision -ne "BLOCK") { throw "MISSING_ROLLBACK_NOT_BLOCKED" }

[ordered]@{
    status = "PASS"
    pending = [string]$pendingAuth.decision
    allowed = [string]$completeAuth.decision
    blocked = [string]$blocked.decision
} | ConvertTo-Json -Depth 6
