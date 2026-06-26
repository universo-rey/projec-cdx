param(
    [string] $EventStoreRoot,
    [string] $TraceRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$trace = Initialize-CeoTraceIntelligenceState -TraceRoot $TraceRoot -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
if (-not (Test-Path -LiteralPath $trace.IndexFile -PathType Leaf)) {
    & (Join-Path $PSScriptRoot "ceo-trace-indexer.ps1") -EventStoreRoot $EventStoreRoot -TraceRoot $trace.Root -StateRoot $StateRoot | Out-Null
}

$index = Read-CeoEventBusJson -Path $trace.IndexFile
$anomalyCount = 0
$alertCount = 0
if (Test-Path -LiteralPath $trace.AnomaliesFile -PathType Leaf) {
    $anomalyDoc = Read-CeoEventBusJson -Path $trace.AnomaliesFile
    $anomalyCount = @($anomalyDoc.anomalies).Count
}
if (Test-Path -LiteralPath $trace.AlertsFile -PathType Leaf) {
    $alertDoc = Read-CeoEventBusJson -Path $trace.AlertsFile
    $alertCount = @($alertDoc.alerts).Count
}

$dlqCount = [int](Get-CeoEventBusProperty -InputObject $index.dlq_summary -Name "count" -Default 0)
$failedCount = [int](Get-CeoEventBusProperty -InputObject $index.queue_summary -Name "failed" -Default 0)
$liveRoot = Initialize-CeoLiveOperationsState
$liveRequested = @(Get-ChildItem -LiteralPath $liveRoot.Requests -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$liveApprovals = @(Get-ChildItem -LiteralPath $liveRoot.Approvals -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$liveSimulated = @(Get-ChildItem -LiteralPath $liveRoot.Simulations -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$liveFormalApprovals = @(Get-ChildItem -LiteralPath $liveRoot.FormalApprovals -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$liveRealExecutions = @(Get-ChildItem -LiteralPath $liveRoot.Executions -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$liveRollback = @(Get-ChildItem -LiteralPath $liveRoot.Rollback -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$liveAuditReady = Test-Path -LiteralPath $liveRoot.AuditJson -PathType Leaf
$liveSession = Get-CeoLiveSessionStatus -LiveRoot $liveRoot.Root
$liveSessionActive = Test-CeoLiveSessionActive -Session $liveSession
$accountabilityRecords = 0
if (Test-Path -LiteralPath $liveRoot.AccountabilityLog -PathType Leaf) {
    $accountabilityRecords = @(Get-Content -LiteralPath $liveRoot.AccountabilityLog -ErrorAction SilentlyContinue).Count
}
$health = "OK"
if ($dlqCount -gt 0 -or $failedCount -gt 0 -or $alertCount -gt 0) {
    $health = "WARN"
}
if ($alertCount -gt 0 -and $anomalyCount -gt 0) {
    $health = "CRITICAL"
}

$state = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    health = $health
    queues = $index.queue_summary
    policy = $index.policy_summary
    failures = [ordered]@{
        failed = $failedCount
    }
    dlq = $index.dlq_summary
    replay = [ordered]@{
        dry_run_only = $true
    }
    trace_graph = [ordered]@{
        enabled = $true
        source = "<TRACE_PATH>"
    }
    anomalies = [ordered]@{
        count = $anomalyCount
    }
    alerts = [ordered]@{
        count = $alertCount
    }
    live_operations = [ordered]@{
        requested = $liveRequested
        blocked = 0
        hold_owner = 0
        multi_owner_pending = [Math]::Max(0, $liveRequested - $liveApprovals)
        simulated = $liveSimulated
        formal_approvals = $liveFormalApprovals
        real_executions = $liveRealExecutions
        rollback_validated = $liveRollback
        audit_ready = [bool]$liveAuditReady
        session_state = [string](Get-CeoEventBusProperty -InputObject $liveSession -Name "state" -Default "DISABLED")
        session_id = [string](Get-CeoEventBusProperty -InputObject $liveSession -Name "session_id" -Default "")
        live_real_enabled = [bool]$liveSessionActive
        accountability_records = $accountabilityRecords
    }
    timeline = @($index.events_by_time | Select-Object -Last 20)
}
Save-CeoEventBusJson -Path $trace.DashboardStateFile -InputObject $state

$md = @(
    "# G3 Trace Intelligence Dashboard",
    "",
    "health: $health",
    "",
    "## Queues",
    "- inbox: $($state.queues.inbox)",
    "- processing: $($state.queues.processing)",
    "- completed: $($state.queues.completed)",
    "- failed: $($state.queues.failed)",
    "- dlq: $($state.queues.dlq)",
    "",
    "## Policy",
    "- blocks: $($state.policy.blocks)",
    "",
    "## Alerts",
    "- open/local: $alertCount",
    "",
    "## Live Operations",
    "- requested: $liveRequested",
    "- multi_owner_pending: $([Math]::Max(0, $liveRequested - $liveApprovals))",
    "- simulated: $liveSimulated",
    "- formal_approvals: $liveFormalApprovals",
    "- real_executions: $liveRealExecutions",
    "- rollback_validated: $liveRollback",
    "- audit_ready: $([bool]$liveAuditReady)",
    "- session_state: $([string](Get-CeoEventBusProperty -InputObject $liveSession -Name "state" -Default "DISABLED"))",
    "- live_real_enabled: $([bool]$liveSessionActive)",
    "- accountability_records: $accountabilityRecords",
    "",
    "## Replay",
    "- dry_run_only: true",
    "",
    "## Trace Graph",
    "- enabled: true",
    "- source: <TRACE_PATH>",
    "",
    "## Recommendations",
    "- generated by ceo-policy-feedback.ps1"
)
$md | Set-Content -LiteralPath $trace.DashboardMarkdownFile -Encoding UTF8

$html = @"
<!doctype html>
<html>
<head><meta charset="utf-8"><title>G3 Trace Intelligence</title></head>
<body>
<h1>G3 Trace Intelligence Dashboard</h1>
<p>health: $health</p>
<pre>queues: inbox=$($state.queues.inbox) processing=$($state.queues.processing) completed=$($state.queues.completed) failed=$($state.queues.failed) dlq=$($state.queues.dlq)</pre>
<p>policy blocks: $($state.policy.blocks)</p>
<p>alerts: $alertCount</p>
</body>
</html>
"@
$html | Set-Content -LiteralPath $trace.DashboardHtmlFile -Encoding UTF8

[ordered]@{
    dashboard_generated = $true
    dashboard_state = "<DASHBOARD_DATA_PATH>"
    dashboard_markdown = "<RUNTIME_PATH>"
    dashboard_html = "<RUNTIME_PATH>"
    health = $health
} | ConvertTo-Json -Depth 10
