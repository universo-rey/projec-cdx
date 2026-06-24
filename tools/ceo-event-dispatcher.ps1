param(
    [string] $EventFile,
    [int] $MaxEvents = 10,
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
$processed = @()
$held = @()
$failed = @()

$files = @()
if (-not [string]::IsNullOrWhiteSpace($EventFile)) {
    $files = @(Get-Item -LiteralPath $EventFile)
}
else {
    $files = @(Get-ChildItem -LiteralPath $bus.Inbox -Filter "*.json" -File | Sort-Object LastWriteTime | Select-Object -First $MaxEvents)
}

foreach ($file in $files) {
    try {
        $validation = & (Join-Path $PSScriptRoot "ceo-validate-event.ps1") -EventFile $file.FullName
        $validationObject = $validation | ConvertFrom-Json
        $event = Read-CeoEventBusJson -Path $file.FullName
        $eventId = [string]$event.event_id
        $correlationId = [string]$event.correlation_id

        if (-not $validationObject.valid) {
            $event.state = "FAILED_FINAL"
            $event.retry.last_error = "validation_failed"
            $target = Join-Path $bus.Failed "$eventId.json"
            Save-CeoEventBusJson -Path $target -InputObject $event
            Remove-Item -LiteralPath $file.FullName -ErrorAction SilentlyContinue
            Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "FAILED_FINAL" -CorrelationId $correlationId -Message "validation failed before dispatch" | Out-Null
            $failed += $eventId
            continue
        }

        $event.state = "VALIDATED"
        Save-CeoEventBusJson -Path $file.FullName -InputObject $event
        Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "VALIDATED" -CorrelationId $correlationId -Message "event validated" -Evidence @($event.evidence.path) | Out-Null

        $policyRaw = & (Join-Path $PSScriptRoot "ceo-policy-engine.ps1") -EventFile $file.FullName -EventStoreRoot $bus.Root
        $policy = $policyRaw | ConvertFrom-Json
        if ($policy.decision -ne "ALLOW") {
            $event.state = $(if ($policy.decision -eq "HOLD_OWNER") { "HOLD_OWNER" } else { "POLICY_BLOCKED" })
            Save-CeoEventBusJson -Path $file.FullName -InputObject $event
            $held += $eventId
            continue
        }

        $event.state = "DISPATCHED"
        Save-CeoEventBusJson -Path $file.FullName -InputObject $event
        Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "DISPATCHED" -CorrelationId $correlationId -PolicyDecision "ALLOW" -Message "event dispatched" -Evidence @($event.evidence.path) | Out-Null

        $processingPath = Join-Path $bus.Processing "$eventId.json"
        Move-Item -LiteralPath $file.FullName -Destination $processingPath -Force
        $workerRaw = & (Join-Path $PSScriptRoot "ceo-event-worker.ps1") -EventFile $processingPath -WorkerType "validation_worker" -EventStoreRoot $bus.Root
        $worker = $workerRaw | ConvertFrom-Json
        if ($worker.result -eq "OK") {
            $processed += $eventId
        }
        else {
            $failed += $eventId
        }
    }
    catch {
        $failed += $file.BaseName
    }
}

[ordered]@{
    dispatched = $processed.Count
    held = $held.Count
    failed = $failed.Count
    processed_event_ids = @($processed)
    held_event_ids = @($held)
    failed_event_ids = @($failed)
} | ConvertTo-Json -Depth 10

if ($failed.Count -eq 0) { exit 0 }
exit 50
