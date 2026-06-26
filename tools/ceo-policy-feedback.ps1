param(
    [string] $EventStoreRoot,
    [string] $TraceRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$trace = Initialize-CeoTraceIntelligenceState -TraceRoot $TraceRoot -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
if (-not (Test-Path -LiteralPath $trace.AnomaliesFile -PathType Leaf)) {
    & (Join-Path $PSScriptRoot "ceo-anomaly-detector.ps1") -EventStoreRoot $EventStoreRoot -TraceRoot $trace.Root -StateRoot $StateRoot | Out-Null
}
if (-not (Test-Path -LiteralPath $trace.AlertsFile -PathType Leaf)) {
    & (Join-Path $PSScriptRoot "ceo-alert-engine.ps1") -EventStoreRoot $EventStoreRoot -TraceRoot $trace.Root -StateRoot $StateRoot | Out-Null
}

$anomalyDoc = Read-CeoEventBusJson -Path $trace.AnomaliesFile
$recommendations = @()
foreach ($anomaly in @($anomalyDoc.anomalies)) {
    $type = [string](Get-CeoEventBusProperty -InputObject $anomaly -Name "type" -Default "UNKNOWN")
    $severity = [string](Get-CeoEventBusProperty -InputObject $anomaly -Name "severity" -Default "LOW")
    $recommendations += [ordered]@{
        recommendation_id = [guid]::NewGuid().ToString()
        created_at = (Get-Date).ToUniversalTime().ToString("o")
        source = "ceo-policy-feedback"
        type = $type
        reason = "local anomaly detected"
        suggested_action = "review $type before changing policy"
        risk = $severity
        requires_owner_gate = $true
        status = "SUGGESTED"
    }
}

$doc = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    suggestion_only = $true
    recommendations = @($recommendations)
}
Save-CeoEventBusJson -Path $trace.RecommendationsFile -InputObject $doc

[ordered]@{
    recommendations_generated = $true
    recommendation_count = $recommendations.Count
    suggestion_only = $true
    path = "<RUNTIME_PATH>"
} | ConvertTo-Json -Depth 10
