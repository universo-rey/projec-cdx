Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "trace-intelligence\tests"
}
$caseRoot = Join-Path $testRoot ("dashboard-" + [guid]::NewGuid().ToString())
$store = Join-Path $caseRoot "event-store"
$traceRoot = Join-Path $caseRoot "trace-intelligence"

$published = (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G3_DASHBOARD_TEST" -Payload '{"action":"observe"}' -EventStoreRoot $store) | ConvertFrom-Json
& (Join-Path $root "tools\ceo-event-dispatcher.ps1") -EventStoreRoot $store | Out-Null
& (Join-Path $root "tools\ceo-trace-indexer.ps1") -EventStoreRoot $store -TraceRoot $traceRoot -Rebuild | Out-Null

$dashboard = (& (Join-Path $root "tools\ceo-trace-dashboard.ps1") -EventStoreRoot $store -TraceRoot $traceRoot) | ConvertFrom-Json
if (-not $dashboard.dashboard_generated) { throw "DASHBOARD_NOT_GENERATED" }
if (-not (Test-Path -LiteralPath (Join-Path $traceRoot "dashboard\dashboard-state.json") -PathType Leaf)) { throw "DASHBOARD_STATE_MISSING" }
if (-not (Test-Path -LiteralPath (Join-Path $traceRoot "dashboard\dashboard.md") -PathType Leaf)) { throw "DASHBOARD_MD_MISSING" }

[ordered]@{
    status = "PASS"
    health = [string]$dashboard.health
    event_id = $published.event_id
} | ConvertTo-Json -Depth 6
