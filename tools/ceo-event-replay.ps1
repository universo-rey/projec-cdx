param(
    [string] $EventId,
    [string] $CorrelationId,
    [switch] $DryRun = $true,
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

if (-not $DryRun) {
    throw "REPLAY_IS_DRY_RUN_ONLY"
}

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot

function Find-Event {
    param([string] $Id, [string] $Corr)
    foreach ($dir in @($bus.Inbox, $bus.Processing, $bus.Completed, $bus.Failed, $bus.Dlq)) {
        foreach ($file in @(Get-ChildItem -LiteralPath $dir -Filter "*.json" -File -ErrorAction SilentlyContinue)) {
            $event = Read-CeoEventBusJson -Path $file.FullName
            if ((-not [string]::IsNullOrWhiteSpace($Id) -and [string]$event.event_id -eq $Id) -or
                (-not [string]::IsNullOrWhiteSpace($Corr) -and [string]$event.correlation_id -eq $Corr)) {
                return [PSCustomObject]@{ Event = $event; File = $file.FullName }
            }
        }
    }
    return $null
}

$found = Find-Event -Id $EventId -Corr $CorrelationId
if ($null -eq $found) {
    throw "EVENT_NOT_FOUND_FOR_REPLAY"
}

$original = $found.Event
$replayEventId = [guid]::NewGuid().ToString()
$evidencePath = Join-Path $bus.Replay "$replayEventId.replay.json"

$record = [ordered]@{
    replay_requested = $true
    dry_run = $true
    original_event_id = [string]$original.event_id
    replay_event_id = $replayEventId
    evidence_path = "<EVIDENCE_PATH>"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    original_state = [string]$original.state
}

Save-CeoEventBusJson -Path $evidencePath -InputObject $record
Write-CeoEventBusTrace -Bus $bus -EventId ([string]$original.event_id) -State "REPLAY_REQUESTED" -CorrelationId ([string]$original.correlation_id) -Message "dry-run replay requested" -Evidence @("<EVIDENCE_PATH>") | Out-Null
Write-CeoEventBusTrace -Bus $bus -EventId ([string]$original.event_id) -State "REPLAYED" -CorrelationId ([string]$original.correlation_id) -Message "dry-run replay evidence generated" -Evidence @("<EVIDENCE_PATH>") | Out-Null

$record | ConvertTo-Json -Depth 10
