Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) { $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests" }
$store = Join-Path $testRoot ("policy-" + [guid]::NewGuid().ToString()) "event-store"
$event = [ordered]@{
    event_id = [guid]::NewGuid().ToString(); event_type = "LIVE_ACTION_REQUEST"; version = "G5.0"; timestamp = (Get-Date).ToUniversalTime().ToString("o"); producer = "live-policy-test"; correlation_id = [guid]::NewGuid().ToString(); causation_id = $null; priority = "high"; risk = "high"; state = "PERSISTED"
    policy = [ordered]@{ requires_owner_gate = $true; allows_write = $false; allows_live = $false; allows_delete = $false; dry_run_required = $true }
    payload = [ordered]@{ action_type = "LOCAL_EVIDENCE_WRITE"; mode = "LIVE_CONTROLLED_REAL"; environment = "LIVE_CONTROLLED"; external = $true; rollback = [ordered]@{ required = $true }; approvals = [ordered]@{ approval_status = "COMPLETE" } }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    retry = [ordered]@{ attempt = 0; max_attempts = 3; last_error = $null; next_action = "none" }
}
$eventPath = Join-Path (Split-Path -Parent $store) "event.json"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $eventPath) | Out-Null
$event | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $eventPath -Encoding UTF8
$raw = & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-policy-engine.ps1") -EventFile $eventPath -EventStoreRoot $store
$decision = $raw | ConvertFrom-Json
if ([string]$decision.decision -ne "BLOCK") { throw "LIVE_POLICY_DID_NOT_BLOCK" }
[ordered]@{ status = "PASS"; decision = [string]$decision.decision; reason = [string]$decision.reason } | ConvertTo-Json -Depth 6
