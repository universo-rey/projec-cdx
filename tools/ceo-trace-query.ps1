param(
    [string] $EventId,
    [string] $CorrelationId,
    [string] $EventType,
    [string] $Status,
    [string] $PolicyDecision,
    [string] $Since,
    [string] $Until,
    [string] $Risk,
    [switch] $DlqOnly,
    [switch] $FailedOnly,
    [switch] $OutputJson,
    [switch] $OutputMarkdown,
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
$events = @()
if ($index.PSObject.Properties["events"]) {
    $events = @($index.events)
}

$results = @($events | Where-Object {
    $match = $true
    if (-not [string]::IsNullOrWhiteSpace($EventId)) { $match = $match -and ([string]$_.event_id -eq $EventId) }
    if (-not [string]::IsNullOrWhiteSpace($CorrelationId)) { $match = $match -and ([string]$_.correlation_id -eq $CorrelationId) }
    if (-not [string]::IsNullOrWhiteSpace($EventType)) { $match = $match -and ([string]$_.event_type -eq $EventType) }
    if (-not [string]::IsNullOrWhiteSpace($Status)) { $match = $match -and ([string]$_.state -eq $Status) }
    if (-not [string]::IsNullOrWhiteSpace($Risk)) { $match = $match -and ([string]$_.risk -eq $Risk) }
    if (-not [string]::IsNullOrWhiteSpace($Since)) { $match = $match -and ([string]$_.timestamp -ge $Since) }
    if (-not [string]::IsNullOrWhiteSpace($Until)) { $match = $match -and ([string]$_.timestamp -le $Until) }
    if ($DlqOnly) { $match = $match -and ([string]$_.location -eq "dlq") }
    if ($FailedOnly) { $match = $match -and ([string]$_.location -eq "failed" -or [string]$_.state -match "FAILED|DLQ") }
    if (-not [string]::IsNullOrWhiteSpace($PolicyDecision)) { $match = $match -and ([string]$_.policy_decision -eq $PolicyDecision) }
    return $match
})

$queryId = [guid]::NewGuid().ToString()
$query = [ordered]@{
    query_id = $queryId
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    filter = [ordered]@{
        event_id = $EventId
        correlation_id = $CorrelationId
        event_type = $EventType
        status = $Status
        policy_decision = $PolicyDecision
        since = $Since
        until = $Until
        risk = $Risk
        dlq_only = [bool]$DlqOnly
        failed_only = [bool]$FailedOnly
    }
    result_count = $results.Count
    results = @($results)
}

$jsonPath = Join-Path $trace.Queries "$queryId.query.json"
Save-CeoEventBusJson -Path $jsonPath -InputObject $query

if ($OutputMarkdown) {
    $mdPath = Join-Path $trace.Queries "$queryId.query.md"
    $lines = @(
        "# G3 Trace Query",
        "",
        "query_id: $queryId",
        "result_count: $($results.Count)",
        "",
        "## Results"
    )
    foreach ($item in $results) {
        $lines += "- $($item.event_id) $($item.event_type) $($item.state)"
    }
    $lines | Set-Content -LiteralPath $mdPath -Encoding UTF8
}

[ordered]@{
    query_id = $queryId
    result_count = $results.Count
    results_path = "<RUNTIME_PATH>"
    warnings = @()
} | ConvertTo-Json -Depth 12
