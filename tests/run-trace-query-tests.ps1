Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "trace-intelligence\tests"
}
$caseRoot = Join-Path $testRoot ("query-" + [guid]::NewGuid().ToString())
$store = Join-Path $caseRoot "event-store"
$traceRoot = Join-Path $caseRoot "trace-intelligence"

$published = (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G3_QUERY_TEST" -Payload '{"action":"observe"}' -EventStoreRoot $store) | ConvertFrom-Json
& (Join-Path $root "tools\ceo-event-dispatcher.ps1") -EventStoreRoot $store | Out-Null
& (Join-Path $root "tools\ceo-trace-indexer.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -Rebuild | Out-Null

$query = (& (Join-Path $root "tools\ceo-trace-query.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -Status "COMPLETED" -OutputJson) | ConvertFrom-Json
if ([int]$query.result_count -lt 1) { throw "TRACE_QUERY_NO_RESULTS" }

[ordered]@{
    status = "PASS"
    query_id = $query.query_id
    result_count = [int]$query.result_count
} | ConvertTo-Json -Depth 6
