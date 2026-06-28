Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "event-bus"
}
$store = Join-Path $testRoot ("replay-" + [guid]::NewGuid().ToString())

$published = (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G2_REPLAY_TEST" -Payload '{"action":"dry-run"}' -EventStoreRoot $store) | ConvertFrom-Json
& (Join-Path $root "tools\ceo-event-dispatcher.ps1") -EventStoreRoot $store | Out-Null
$replay = (& (Join-Path $root "tools\ceo-event-replay.ps1") -EventId $published.event_id -EventStoreRoot $store) | ConvertFrom-Json

if (-not $replay.replay_requested -or -not $replay.dry_run) {
    throw "REPLAY_DRY_RUN_FAILED"
}

[ordered]@{
    status = "PASS"
    original_event_id = $replay.original_event_id
    replay_event_id = $replay.replay_event_id
    dry_run = $replay.dry_run
} | ConvertTo-Json -Depth 6
