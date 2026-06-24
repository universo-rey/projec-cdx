param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$processed = @(Get-CeoJsonlLines -Path $state.ProcessedFile | ForEach-Object { $_ | ConvertFrom-Json })
$failed = @(Get-CeoJsonlLines -Path $state.FailedFile | ForEach-Object { $_ | ConvertFrom-Json })

$recentProcessed = @($processed | Select-Object -Last 20)
$recentFailed = @($failed | Select-Object -Last 20)
$slow = @($recentProcessed | Where-Object { $_.PSObject.Properties["durationMs"] -and $_.durationMs -gt 200 })

if (($recentProcessed.Count + $recentFailed.Count) -eq 0) {
    $signal = "NO_DATA"
    $confidence = 0.0
    $basis = "no processed or failed events"
}
elseif ($recentFailed.Count -ge 3) {
    $signal = "INCIDENT_LIKELY"
    $confidence = 0.82
    $basis = "three or more recent failed or rejected events"
}
elseif ($slow.Count -ge 5) {
    $signal = "PERFORMANCE_DEGRADING"
    $confidence = 0.68
    $basis = "five or more recent events above 200ms"
}
else {
    $signal = "STABLE"
    $confidence = 0.74
    $basis = "recent event bus activity inside local thresholds"
}

$payload = [ordered]@{
    signal = $signal
    confidence = $confidence
    basis = $basis
}

$record = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    type = "PREDICTIVE_SIGNAL"
    payload = $payload
    sensitiveMutation = $false
}

Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
$payload | ConvertTo-Json -Depth 10
exit 0
