param(
    [string] $EventStoreRoot,
    [string] $TraceRoot,
    [string] $StateRoot,
    [switch] $Rebuild,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
$trace = Initialize-CeoTraceIntelligenceState -TraceRoot $TraceRoot -EventStoreRoot $bus.Root -StateRoot $StateRoot

if ($Rebuild -and -not $DryRun -and (Test-Path -LiteralPath $trace.IndexFile -PathType Leaf)) {
    Remove-Item -LiteralPath $trace.IndexFile -Force
}

function Read-EventFiles {
    param([string] $Directory, [string] $Location)

    $items = @()
    foreach ($file in @(Get-ChildItem -LiteralPath $Directory -Filter "*.json" -File -ErrorAction SilentlyContinue)) {
        try {
            $event = Read-CeoEventBusJson -Path $file.FullName
            $items += [PSCustomObject]@{
                event = $event
                location = $Location
                file = $file.FullName
            }
        }
        catch {
        }
    }
    return @($items)
}

function Read-TraceRecords {
    $records = @()
    foreach ($file in @(Get-ChildItem -LiteralPath $bus.Traces -Filter "*.trace.jsonl" -File -ErrorAction SilentlyContinue)) {
        foreach ($line in @(Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue)) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }
            try {
                $records += ($line | ConvertFrom-Json)
            }
            catch {
            }
        }
    }
    return @($records)
}

$eventSources = @()
$eventSources += Read-EventFiles -Directory $bus.Inbox -Location "inbox"
$eventSources += Read-EventFiles -Directory $bus.Processing -Location "processing"
$eventSources += Read-EventFiles -Directory $bus.Completed -Location "completed"
$eventSources += Read-EventFiles -Directory $bus.Failed -Location "failed"
$eventSources += Read-EventFiles -Directory $bus.Dlq -Location "dlq"

$traceRecords = @(Read-TraceRecords)
$eventsById = [ordered]@{}
$eventsByType = @{}
$eventsByStatus = @{}
$eventsByCorrelation = [ordered]@{}
$eventsByTime = @()
$events = @()
$warnings = @()

foreach ($source in $eventSources) {
    $event = $source.event
    $eventId = [string](Get-CeoEventBusProperty -InputObject $event -Name "event_id" -Default "")
    if ([string]::IsNullOrWhiteSpace($eventId)) {
        $warnings += "event_without_id"
        continue
    }

    $eventType = [string](Get-CeoEventBusProperty -InputObject $event -Name "event_type" -Default "UNKNOWN")
    $state = [string](Get-CeoEventBusProperty -InputObject $event -Name "state" -Default "UNKNOWN")
    $correlationId = [string](Get-CeoEventBusProperty -InputObject $event -Name "correlation_id" -Default "")
    $timestamp = [string](Get-CeoEventBusProperty -InputObject $event -Name "timestamp" -Default "")
    $risk = [string](Get-CeoEventBusProperty -InputObject $event -Name "risk" -Default "")
    $retry = Get-CeoEventBusProperty -InputObject $event -Name "retry" -Default $null
    $retryAttempt = [int](Get-CeoEventBusProperty -InputObject $retry -Name "attempt" -Default 0)
    $eventTraceRecords = @($traceRecords | Where-Object { [string](Get-CeoEventBusProperty -InputObject $_ -Name "event_id" -Default "") -eq $eventId })
    $policyDecision = ""
    if ($eventTraceRecords.Count -gt 0) {
        $policyDecision = [string](Get-CeoEventBusProperty -InputObject ($eventTraceRecords | Select-Object -Last 1) -Name "policy_decision" -Default "")
    }

    Add-CeoTraceIntelligenceCount -Map $eventsByType -Key $eventType
    Add-CeoTraceIntelligenceCount -Map $eventsByStatus -Key $state
    if (-not [string]::IsNullOrWhiteSpace($correlationId)) {
        if (-not $eventsByCorrelation.Contains($correlationId)) {
            $eventsByCorrelation[$correlationId] = @()
        }
        $eventsByCorrelation[$correlationId] = @($eventsByCorrelation[$correlationId]) + $eventId
    }

    $record = [ordered]@{
        event_id = $eventId
        event_type = $eventType
        state = $state
        correlation_id = $correlationId
        timestamp = $timestamp
        risk = $risk
        policy_decision = $policyDecision
        retry_attempt = $retryAttempt
        location = [string]$source.location
        path = "<EVENT_STORE_PATH>"
    }
    $eventsById[$eventId] = $record
    $events += $record
    $eventsByTime += [ordered]@{
        event_id = $eventId
        timestamp = $timestamp
        state = $state
        event_type = $eventType
    }
}

$policyBlocks = @($traceRecords | Where-Object {
    [string](Get-CeoEventBusProperty -InputObject $_ -Name "policy_decision" -Default "") -match "BLOCK|DENY" -or
    [string](Get-CeoEventBusProperty -InputObject $_ -Name "state" -Default "") -eq "POLICY_BLOCKED"
}).Count

$dlqCount = @(Get-ChildItem -LiteralPath $bus.Dlq -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$processingCount = @(Get-ChildItem -LiteralPath $bus.Processing -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
$failedCount = @(Get-ChildItem -LiteralPath $bus.Failed -Filter "*.json" -File -ErrorAction SilentlyContinue).Count

$index = [ordered]@{
    index_id = [guid]::NewGuid().ToString()
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    source_event_store = "<EVENT_STORE_PATH>"
    events_by_id = $eventsById
    events_by_type = $eventsByType
    events_by_status = $eventsByStatus
    events_by_correlation = $eventsByCorrelation
    events_by_time = @($eventsByTime | Sort-Object timestamp)
    events = @($events)
    queue_summary = [ordered]@{
        inbox = @(Get-ChildItem -LiteralPath $bus.Inbox -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
        processing = $processingCount
        completed = @(Get-ChildItem -LiteralPath $bus.Completed -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
        failed = $failedCount
        dlq = $dlqCount
    }
    dlq_summary = [ordered]@{
        count = $dlqCount
    }
    policy_summary = [ordered]@{
        blocks = $policyBlocks
        trace_records = $traceRecords.Count
    }
}

if (-not $DryRun) {
    Save-CeoEventBusJson -Path $trace.IndexFile -InputObject $index
}

[ordered]@{
    indexed = $true
    dry_run = [bool]$DryRun
    index_path = "<TRACE_INDEX_PATH>"
    events_indexed = $events.Count
    dlq_count = $dlqCount
    policy_blocks = $policyBlocks
    warnings = @($warnings)
} | ConvertTo-Json -Depth 12
