param(
    [string] $EventId,
    [string] $CorrelationId,
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
$replayable = @($events | Where-Object { [string]$_.location -in @("completed", "failed", "dlq") })
$dryRunResult = $null
if (-not [string]::IsNullOrWhiteSpace($EventId) -or -not [string]::IsNullOrWhiteSpace($CorrelationId)) {
    $dryRunResult = (& (Join-Path $PSScriptRoot "ceo-event-replay.ps1") -EventId $EventId -CorrelationId $CorrelationId -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot -DryRun) | ConvertFrom-Json
}

$view = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    dry_run_only = $true
    replayable_events = @($replayable)
    dry_run_result = $dryRunResult
}
Save-CeoEventBusJson -Path $trace.ReplayControlFile -InputObject $view

$md = @(
    "# G3 Replay Control",
    "",
    "dry_run_only: true",
    "replayable_events: $($replayable.Count)"
)
$md | Set-Content -LiteralPath $trace.ReplayControlMarkdownFile -Encoding UTF8

[ordered]@{
    replay_control_ready = $true
    dry_run_only = $true
    replayable_events = $replayable.Count
    view_path = "<RUNTIME_PATH>"
} | ConvertTo-Json -Depth 10
