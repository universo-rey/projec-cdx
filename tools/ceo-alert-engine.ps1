param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$metrics = Get-CeoBusMetrics -StateRoot $state.StateRoot

if ($metrics.failed -gt 0 -or $metrics.invalid -gt 0) {
    $level = "CRITICAL"
    $message = "failed_or_invalid_events_detected"
}
elseif ($metrics.queue -gt 10) {
    $level = "WARNING"
    $message = "event_backlog_high"
}
else {
    $level = "INFO"
    $message = "system_stable"
}

$alert = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    level = $level
    message = $message
    metrics = $metrics
    sensitiveMutation = $false
}

Add-CeoJsonlLine -Path $state.AlertFile -Line (ConvertTo-CeoJsonLine -InputObject $alert)
$alert | ConvertTo-Json -Depth 20
if ($level -eq "CRITICAL") { exit 20 }
exit 0
