Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "actions\tests"
}
$caseRoot = Join-Path $testRoot ("policy-" + [guid]::NewGuid().ToString())
$store = Join-Path $caseRoot "event-store"
New-Item -ItemType Directory -Force -Path $caseRoot | Out-Null

$event = [ordered]@{
    event_id = [guid]::NewGuid().ToString()
    event_type = "ACTION_REQUEST"
    version = "G4.0"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    producer = "policy-block-test"
    correlation_id = [guid]::NewGuid().ToString()
    causation_id = $null
    priority = "high"
    risk = "high"
    state = "PERSISTED"
    policy = [ordered]@{ requires_owner_gate = $true; allows_write = $false; allows_live = $false; allows_delete = $false; dry_run_required = $true }
    payload = [ordered]@{ action_type = "UNKNOWN_ACTION"; mode = "DRY_RUN"; external = $true }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    retry = [ordered]@{ attempt = 0; max_attempts = 3; last_error = $null; next_action = "none" }
}
$eventPath = Join-Path $caseRoot "blocked-event.json"
$event | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $eventPath -Encoding UTF8

$raw = & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-policy-engine.ps1") -EventFile $eventPath -EventStoreRoot $store
$decision = $raw | ConvertFrom-Json
if ([string]$decision.decision -ne "BLOCK") { throw "POLICY_DID_NOT_BLOCK" }
if ([string]$decision.reason -notmatch "unknown_action_type|payload_external_true") { throw "POLICY_BLOCK_REASON_MISSING" }

[ordered]@{
    status = "PASS"
    decision = [string]$decision.decision
    reason = [string]$decision.reason
} | ConvertTo-Json -Depth 6
