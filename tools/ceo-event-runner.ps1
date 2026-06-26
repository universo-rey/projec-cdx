param(
    [int] $ExecutionPasses = 1,
    [int] $MaxEvents = 10,
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
$runs = 0
$retried = 0

for ($i = 1; $i -le $ExecutionPasses; $i++) {
    foreach ($failed in @(Get-ChildItem -LiteralPath $bus.Failed -Filter "*.json" -File -ErrorAction SilentlyContinue)) {
        $event = Read-CeoEventBusJson -Path $failed.FullName
        if ([string]$event.retry.next_action -eq "retry") {
            $event.state = "REPLAY_REQUESTED"
            $target = Join-Path $bus.Inbox $failed.Name
            Save-CeoEventBusJson -Path $target -InputObject $event
            Remove-Item -LiteralPath $failed.FullName -ErrorAction SilentlyContinue
            Write-CeoEventBusTrace -Bus $bus -EventId ([string]$event.event_id) -State "REPLAY_REQUESTED" -CorrelationId ([string]$event.correlation_id) -Message "retry requested" -Evidence @($event.evidence.path) | Out-Null
            $retried++
        }
    }

    & (Join-Path $PSScriptRoot "ceo-event-dispatcher.ps1") -MaxEvents $MaxEvents -EventStoreRoot $bus.Root | Out-Null
    $runs++
}

[ordered]@{
    completed = $true
    runs = $runs
    retried = $retried
} | ConvertTo-Json -Depth 10
