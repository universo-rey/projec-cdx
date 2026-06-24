param(
    [string] $EventStoreRoot,
    [string] $TraceRoot,
    [string] $StateRoot,
    [switch] $Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$trace = Initialize-CeoTraceIntelligenceState -TraceRoot $TraceRoot -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
if (-not (Test-Path -LiteralPath $trace.AnomaliesFile -PathType Leaf)) {
    & (Join-Path $PSScriptRoot "ceo-anomaly-detector.ps1") -EventStoreRoot $EventStoreRoot -TraceRoot $trace.Root -StateRoot $StateRoot | Out-Null
}

$anomalyDoc = Read-CeoEventBusJson -Path $trace.AnomaliesFile
$alerts = @()
foreach ($anomaly in @($anomalyDoc.anomalies)) {
    $severity = [string](Get-CeoEventBusProperty -InputObject $anomaly -Name "severity" -Default "LOW")
    $type = [string](Get-CeoEventBusProperty -InputObject $anomaly -Name "type" -Default "UNKNOWN")
    if ($type -eq "POLICY_BLOCK_SPIKE" -and $severity -eq "MEDIUM") {
        $severity = "MEDIUM"
    }
    elseif ($severity -notin (Get-CeoTraceIntelligenceSeverityValues)) {
        $severity = "LOW"
    }

    $alerts += [ordered]@{
        alert_id = [guid]::NewGuid().ToString()
        created_at = (Get-Date).ToUniversalTime().ToString("o")
        severity = $severity
        source = "ceo-anomaly-detector"
        anomaly_id = [string](Get-CeoEventBusProperty -InputObject $anomaly -Name "anomaly_id" -Default "")
        event_ids = @((Get-CeoEventBusProperty -InputObject $anomaly -Name "event_ids" -Default @()))
        status = "OPEN"
        channel = "LOCAL_JSON"
        evidence_path = "<EVIDENCE_PATH>"
    }
}

$doc = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    channels = @("LOCAL_JSON", "LOCAL_MARKDOWN", "DASHBOARD_HIGHLIGHT")
    alerts = @($alerts)
}
Save-CeoEventBusJson -Path $trace.AlertsFile -InputObject $doc

$md = @(
    "# G3 Local Alerts",
    "",
    "alert_count: $($alerts.Count)",
    "",
    "## Alerts"
)
foreach ($alert in $alerts) {
    $md += "- $($alert["severity"]) $($alert["anomaly_id"]) $($alert["status"])"
}
$md | Set-Content -LiteralPath $trace.AlertsMarkdownFile -Encoding UTF8

[ordered]@{
    alerts_generated = $true
    alert_count = $alerts.Count
    alerts_path = "<RUNTIME_PATH>"
    channels = @("LOCAL_JSON", "LOCAL_MARKDOWN", "DASHBOARD_HIGHLIGHT")
} | ConvertTo-Json -Depth 10
