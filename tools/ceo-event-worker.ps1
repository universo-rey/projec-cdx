param(
    [Parameter(Mandatory = $true)]
    [string] $EventFile,
    [ValidateSet("validation_worker", "policy_worker", "trace_worker", "evidence_worker", "replay_worker", "self_heal_worker")]
    [string] $WorkerType = "validation_worker",
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
$event = Read-CeoEventBusJson -Path $EventFile
$eventId = [string]$event.event_id
$correlationId = [string]$event.correlation_id
$policyFile = Join-Path $bus.State "$eventId.policy.json"

if (-not (Test-Path -LiteralPath $policyFile -PathType Leaf)) {
    throw "POLICY_DECISION_REQUIRED:$eventId"
}

$policy = Read-CeoEventBusJson -Path $policyFile
if ($policy.decision -ne "ALLOW") {
    throw "POLICY_NOT_ALLOWED:$($policy.decision)"
}

$event.state = "PROCESSING"
Save-CeoEventBusJson -Path $EventFile -InputObject $event
Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "PROCESSING" -CorrelationId $correlationId -PolicyDecision "ALLOW" -Message "worker started:$WorkerType" -Evidence @($event.evidence.path) | Out-Null

$payload = Get-CeoEventBusProperty -InputObject $event -Name "payload" -Default ([PSCustomObject]@{})
$forceFailure = [bool](Get-CeoEventBusProperty -InputObject $payload -Name "force_failure" -Default $false)

if ($forceFailure) {
    $event.retry.attempt = [int]$event.retry.attempt + 1
    $event.retry.last_error = "forced_failure"
    if ([int]$event.retry.attempt -lt [int]$event.retry.max_attempts) {
        $event.state = "FAILED_RETRYABLE"
        $event.retry.next_action = "retry"
        $target = Join-Path $bus.Failed "$eventId.json"
        Save-CeoEventBusJson -Path $target -InputObject $event
        Remove-Item -LiteralPath $EventFile -ErrorAction SilentlyContinue
        Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "FAILED_RETRYABLE" -CorrelationId $correlationId -PolicyDecision "ALLOW" -Message "retryable failure" -Evidence @($event.evidence.path) | Out-Null
        [ordered]@{
            event_id = $eventId
            result = "WARN"
            state = "FAILED_RETRYABLE"
            retry = $event.retry
        } | ConvertTo-Json -Depth 10
        exit 0
    }

    $event.state = "DLQ"
    $event.retry.next_action = "dlq"
    $target = Join-Path $bus.Dlq "$eventId.json"
    Save-CeoEventBusJson -Path $target -InputObject $event
    Remove-Item -LiteralPath $EventFile -ErrorAction SilentlyContinue
    Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "DLQ" -CorrelationId $correlationId -PolicyDecision "ALLOW" -Message "final failure moved to dlq" -Evidence @($event.evidence.path) | Out-Null
    [ordered]@{
        event_id = $eventId
        result = "FAIL"
        state = "DLQ"
        retry = $event.retry
    } | ConvertTo-Json -Depth 10
    exit 0
}

$event.state = "COMPLETED"
$event.retry.next_action = "none"
$targetPath = Join-Path $bus.Completed "$eventId.json"
Save-CeoEventBusJson -Path $targetPath -InputObject $event
Remove-Item -LiteralPath $EventFile -ErrorAction SilentlyContinue

$result = [ordered]@{
    event_id = $eventId
    state = "COMPLETED"
    result = "OK"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    worker = $WorkerType
    evidence = $event.evidence
    error = $null
}
Save-CeoEventBusJson -Path (Join-Path $bus.Evidence "$eventId.result.json") -InputObject $result
Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "COMPLETED" -CorrelationId $correlationId -PolicyDecision "ALLOW" -Message "worker completed:$WorkerType" -Evidence @($event.evidence.path) | Out-Null

$result | ConvertTo-Json -Depth 10
