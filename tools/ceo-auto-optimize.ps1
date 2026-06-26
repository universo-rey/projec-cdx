param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$metrics = Get-CeoBusMetrics -StateRoot $state.StateRoot
$recommendations = @()

if ($metrics.queue -gt 10) {
    $recommendations += "increase-local-execution-adapter-pass"
}
if ($metrics.failed -gt 3 -or $metrics.invalid -gt 3) {
    $recommendations += "inspect-failed-jsonl-before-retry"
}
if ($metrics.queue -eq 0 -and $metrics.failed -eq 0 -and $metrics.invalid -eq 0) {
    $recommendations += "no-action"
}
if ($recommendations.Count -eq 0) {
    $recommendations += "continue-observing"
}

$payload = [ordered]@{
    recommendation = ($recommendations -join ";")
    scope = "event-bus"
    sensitiveMutation = $false
}

$record = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    type = "OPTIMIZATION_COMMAND"
    payload = $payload
    metrics = $metrics
}

Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
$payload | ConvertTo-Json -Depth 10
exit 0
