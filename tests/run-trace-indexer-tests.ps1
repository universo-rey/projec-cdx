Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "trace-intelligence\tests"
}
$caseRoot = Join-Path $testRoot ("indexer-" + [guid]::NewGuid().ToString())
$store = Join-Path $caseRoot "event-store"
$traceRoot = Join-Path $caseRoot "trace-intelligence"

$published = (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G3_INDEXER_TEST" -Payload '{"action":"observe"}' -EventStoreRoot $store) | ConvertFrom-Json
& (Join-Path $root "tools\ceo-event-dispatcher.ps1") -EventStoreRoot $store | Out-Null
& (Join-Path $root "tools\ceo-trace-export.ps1") -EventId $published.event_id -EventStoreRoot $store | Out-Null

$result = (& (Join-Path $root "tools\ceo-trace-indexer.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -Rebuild) | ConvertFrom-Json
if (-not $result.indexed) { throw "TRACE_INDEXER_NOT_INDEXED" }
if ([int]$result.events_indexed -lt 1) { throw "TRACE_INDEXER_EMPTY" }
if (-not (Test-Path -LiteralPath (Join-Path $traceRoot "index\trace-index.json") -PathType Leaf)) { throw "TRACE_INDEX_FILE_MISSING" }

[ordered]@{
    status = "PASS"
    event_id = $published.event_id
    events_indexed = [int]$result.events_indexed
} | ConvertTo-Json -Depth 6
