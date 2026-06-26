Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) { $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests" }
$liveRoot = Join-Path $testRoot ("preflight-" + [guid]::NewGuid().ToString())
function New-LiveAction([string]$Target) {
    return [ordered]@{
        live_action_id = [guid]::NewGuid().ToString(); action_id = [guid]::NewGuid().ToString(); event_id = [guid]::NewGuid().ToString()
        environment = "LIVE_CONTROLLED"; action_type = "LOCAL_EVIDENCE_WRITE"; requested_at = (Get-Date).ToUniversalTime().ToString("o"); requested_by = "test"; source = "preflight"; risk = "HIGH"; mode = "LIVE_CONTROLLED_SIMULATED"; target = $Target
        policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
        rollback = [ordered]@{ required = $true; strategy = "dry-run"; compensating_action = "manual-review" }
        evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
        approvals = [ordered]@{ approval_status = "COMPLETE"; approvals = @(); required_roles = @("OWNER_OPERATIONAL", "OWNER_CONTROL") }
        trace = [ordered]@{ trace_id = [guid]::NewGuid().ToString() }
    }
}
$ok = New-LiveAction "<SANITIZED_TARGET>"
$okResult = (& (Join-Path $root "tools\ceo-live-preflight.ps1") -LiveActionJson ($ok | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if (-not $okResult.preflight_ok) { throw "PREFLIGHT_SHOULD_PASS" }

$bad = New-LiveAction (("web" + "/data") + ".json")
$badPath = Join-Path $liveRoot "bad-preflight-action.json"
New-Item -ItemType Directory -Force -Path $liveRoot | Out-Null
$bad | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $badPath -Encoding UTF8
$badRaw = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-live-preflight.ps1") -LiveActionFile $badPath -LiveRoot $liveRoot
$badResult = $badRaw | ConvertFrom-Json
if ($badResult.preflight_ok) { throw "PREFLIGHT_SHOULD_FAIL" }

[ordered]@{
    status = "PASS"
    ok = [bool]$okResult.preflight_ok
    blocked = (-not [bool]$badResult.preflight_ok)
} | ConvertTo-Json -Depth 6
