Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "trace-intelligence\tests"
}
$caseRoot = Join-Path $testRoot ("replay-" + [guid]::NewGuid().ToString())
$store = Join-Path $caseRoot "event-store"
$traceRoot = Join-Path $caseRoot "trace-intelligence"

$published = (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G3_REPLAY_TEST" -Payload '{"action":"observe"}' -EventStoreRoot $store) | ConvertFrom-Json
& (Join-Path $root "tools\ceo-event-dispatcher.ps1") -EventStoreRoot $store | Out-Null
& (Join-Path $root "tools\ceo-trace-indexer.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -Rebuild | Out-Null

$result = (& (Join-Path $root "tools\ceo-replay-control.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -EventId $published.event_id) | ConvertFrom-Json
if (-not $result.replay_control_ready) { throw "REPLAY_CONTROL_NOT_READY" }
if (-not $result.dry_run_only) { throw "REPLAY_CONTROL_NOT_DRY_RUN" }

[ordered]@{
    status = "PASS"
    replayable_events = [int]$result.replayable_events
    dry_run_only = [bool]$result.dry_run_only
} | ConvertTo-Json -Depth 6
