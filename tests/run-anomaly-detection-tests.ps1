Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "trace-intelligence\tests"
}
$caseRoot = Join-Path $testRoot ("anomaly-" + [guid]::NewGuid().ToString())
$store = Join-Path $caseRoot "event-store"
$traceRoot = Join-Path $caseRoot "trace-intelligence"
$completed = Join-Path $store "completed"
New-Item -ItemType Directory -Force -Path $completed | Out-Null

$eventId = [guid]::NewGuid().ToString()
$event = [ordered]@{
    event_id = $eventId
    event_type = "G3_RETRY_LOOP_TEST"
    version = "1.0"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    producer = "trace-intelligence-test"
    correlation_id = [guid]::NewGuid().ToString()
    causation_id = $null
    priority = "high"
    risk = "high"
    policy = [ordered]@{
        requires_owner_gate = $false
        allows_write = $false
        allows_live = $false
        allows_delete = $false
        dry_run_required = $true
    }
    payload = [ordered]@{ action = "synthetic" }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    state = "COMPLETED"
    retry = [ordered]@{ attempt = 4; max_attempts = 5; last_error = "synthetic"; next_action = "none" }
}
$event | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $completed "$eventId.json") -Encoding UTF8

& (Join-Path $root "tools\ceo-trace-indexer.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -Rebuild | Out-Null
$result = (& (Join-Path $root "tools\ceo-anomaly-detector.ps1") -EventStoreRoot $store -TraceRoot $traceRoot) | ConvertFrom-Json
if ([int]$result.anomalies_detected -lt 1) { throw "ANOMALY_NOT_DETECTED" }

[ordered]@{
    status = "PASS"
    anomalies_detected = [int]$result.anomalies_detected
    high = [int]$result.high
} | ConvertTo-Json -Depth 6
