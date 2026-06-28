Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "event-bus"
}
$store = Join-Path $testRoot ("smoke-" + [guid]::NewGuid().ToString())

$published = (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G2_SMOKE_TEST" -Payload '{"action":"dry-run"}' -EventStoreRoot $store) | ConvertFrom-Json
& (Join-Path $root "tools\ceo-event-dispatcher.ps1") -EventStoreRoot $store | Out-Null

$completedPath = Join-Path (Join-Path $store "completed") "$($published.event_id).json"
if (-not (Test-Path -LiteralPath $completedPath -PathType Leaf)) {
    throw "EVENT_NOT_COMPLETED"
}

& (Join-Path $root "tools\ceo-trace-export.ps1") -EventId $published.event_id -EventStoreRoot $store | Out-Null
$tracePath = Join-Path (Join-Path (Join-Path $store "traces") $published.event_id) "trace.json"
if (-not (Test-Path -LiteralPath $tracePath -PathType Leaf)) {
    throw "TRACE_NOT_EXPORTED"
}

[ordered]@{
    status = "PASS"
    event_id = $published.event_id
    completed = $true
    trace = $true
} | ConvertTo-Json -Depth 6
