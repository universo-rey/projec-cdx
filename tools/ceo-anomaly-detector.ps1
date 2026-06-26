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
if (-not (Test-Path -LiteralPath $trace.AnomalyConfigFile -PathType Leaf)) {
    $defaultConfig = [ordered]@{
        retry_loop_threshold = 3
        dlq_threshold = 0
        policy_block_threshold = 5
        processing_stuck_threshold = 0
    }
    Save-CeoEventBusJson -Path $trace.AnomalyConfigFile -InputObject $defaultConfig
}

$config = Read-CeoEventBusJson -Path $trace.AnomalyConfigFile
$index = Read-CeoEventBusJson -Path $trace.IndexFile
$events = @()
if ($index.PSObject.Properties["events"]) {
    $events = @($index.events)
}

$anomalies = @()
function New-Anomaly {
    param(
        [string] $Type,
        [string] $Severity,
        [array] $EventIds,
        [array] $CorrelationIds,
        [string] $Recommendation
    )
    return [ordered]@{
        anomaly_id = [guid]::NewGuid().ToString()
        detected_at = (Get-Date).ToUniversalTime().ToString("o")
        type = $Type
        severity = $Severity
        event_ids = @($EventIds)
        correlation_ids = @($CorrelationIds)
        evidence_path = "<EVIDENCE_PATH>"
        recommendation = $Recommendation
    }
}

$retryEvents = @($events | Where-Object { [int]$_.retry_attempt -ge [int]$config.retry_loop_threshold })
if ($retryEvents.Count -gt 0) {
    $anomalies += New-Anomaly -Type "RETRY_LOOP" -Severity "HIGH" -EventIds @($retryEvents.event_id) -CorrelationIds @($retryEvents.correlation_id | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -Recommendation "inspect retry threshold and worker outcome"
}

$dlqCount = [int](Get-CeoEventBusProperty -InputObject $index.dlq_summary -Name "count" -Default 0)
if ($dlqCount -gt [int]$config.dlq_threshold) {
    $dlqEvents = @($events | Where-Object { [string]$_.location -eq "dlq" })
    $anomalies += New-Anomaly -Type "DLQ_BUILDUP" -Severity "HIGH" -EventIds @($dlqEvents.event_id) -CorrelationIds @($dlqEvents.correlation_id | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -Recommendation "review dlq events before retry"
}

$policyBlocks = [int](Get-CeoEventBusProperty -InputObject $index.policy_summary -Name "blocks" -Default 0)
if ($policyBlocks -gt [int]$config.policy_block_threshold) {
    $anomalies += New-Anomaly -Type "POLICY_BLOCK_SPIKE" -Severity "MEDIUM" -EventIds @() -CorrelationIds @() -Recommendation "review policy gate volume"
}

$processingCount = [int](Get-CeoEventBusProperty -InputObject $index.queue_summary -Name "processing" -Default 0)
if ($processingCount -gt [int]$config.processing_stuck_threshold) {
    $processingEvents = @($events | Where-Object { [string]$_.location -eq "processing" })
    $anomalies += New-Anomaly -Type "PROCESSING_STUCK" -Severity "HIGH" -EventIds @($processingEvents.event_id) -CorrelationIds @($processingEvents.correlation_id | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -Recommendation "inspect processing queue transition"
}

$doc = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    anomalies = @($anomalies)
}
Save-CeoEventBusJson -Path $trace.AnomaliesFile -InputObject $doc

[ordered]@{
    anomalies_detected = $anomalies.Count
    high = @($anomalies | Where-Object { [string]$_["severity"] -eq "HIGH" }).Count
    critical = @($anomalies | Where-Object { [string]$_["severity"] -eq "CRITICAL" }).Count
    anomalies_path = "<RUNTIME_PATH>"
    warnings = @()
} | ConvertTo-Json -Depth 10
