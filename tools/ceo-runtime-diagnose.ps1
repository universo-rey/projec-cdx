param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$signals = @()
$dataFile = $env:SDU_DASHBOARD_OUTPUT
if ([string]::IsNullOrWhiteSpace($dataFile)) {
    $dataFile = Join-Path $state.StateRoot "dashboard\data.json"
}
$dashboardSchema = Join-Path $root "contracts\schemas\dashboard-view.schema.json"

$dashboardStatus = Test-CeoJsonFileAgainstSchema -JsonFile $dataFile -SchemaFile $dashboardSchema
$signals += [ordered]@{
    name = "dashboard-data"
    status = if ($dashboardStatus.Status -eq "VALID") { "PASS" } else { "FAIL" }
    evidence = $dashboardStatus.Status
}

$metrics = Get-CeoBusMetrics -StateRoot $state.StateRoot
$signals += [ordered]@{
    name = "bus-metrics"
    status = if ($metrics.failed -gt 0 -or $metrics.invalid -gt 0) { "WARN" } else { "PASS" }
    evidence = "queue=$($metrics.queue);processed=$($metrics.processed);failed=$($metrics.failed);invalid=$($metrics.invalid)"
}

$loopbackListening = $false
$loopbackEvidence = "listening=false"
$tcpClient = [System.Net.Sockets.TcpClient]::new()
$async = $null
try {
    $async = $tcpClient.BeginConnect("127.0.0.1", 8795, $null, $null)
    $connected = $async.AsyncWaitHandle.WaitOne(500, $false)
    if ($connected) {
        $tcpClient.EndConnect($async)
        $loopbackListening = $true
        $loopbackEvidence = "listening=true"
    }
}
catch {
    $loopbackEvidence = "listening=false"
}
finally {
    $tcpClient.Close()
    if ($null -ne $async) {
        $async.AsyncWaitHandle.Close()
    }
}
$signals += [ordered]@{
    name = "dashboard-loopback-8795"
    status = if ($loopbackListening) { "PASS" } else { "WARN" }
    evidence = $loopbackEvidence
}

$vsi = Get-Command code-insiders -ErrorAction SilentlyContinue
$signals += [ordered]@{
    name = "vsi-cli"
    status = if ($null -ne $vsi) { "PASS" } else { "WARN" }
    evidence = if ($null -ne $vsi) { "code-insiders=available" } else { "code-insiders=missing" }
}

$envCheckOutput = & (Join-Path $PSScriptRoot "ceo-environment-check.ps1") 2>&1
if ($LASTEXITCODE -eq 0) {
    try {
        $envCheck = ($envCheckOutput -join "`n") | ConvertFrom-Json
        $signals += [ordered]@{
            name = "environment-contract"
            status = if ([string] $envCheck.status -eq "STABLE") { "PASS" } else { "WARN" }
            evidence = "status=$($envCheck.status);sensitiveContentRead=false"
        }
    }
    catch {
        $signals += [ordered]@{
            name = "environment-contract"
            status = "WARN"
            evidence = "unparseable-output"
        }
    }
}
else {
    $signals += [ordered]@{
        name = "environment-contract"
        status = "FAIL"
        evidence = ($envCheckOutput -join ";")
    }
}

$failedSignals = @($signals | Where-Object { $_.status -eq "FAIL" })
$warnSignals = @($signals | Where-Object { $_.status -eq "WARN" })
$diagnosisStatus = if ($failedSignals.Count -gt 0 -or $warnSignals.Count -gt 0) { "DEGRADED" } else { "STABLE" }
$probableCause = if ($failedSignals.Count -gt 0) {
    "hard failure in " + (($failedSignals | Select-Object -First 1).name)
}
elseif ($warnSignals.Count -gt 0) {
    "warning in " + (($warnSignals | Select-Object -First 1).name)
}
else {
    "no degradation detected"
}

$payload = [ordered]@{
    diagnosisId = [guid]::NewGuid().ToString()
    diagnosedAt = (Get-Date).ToUniversalTime().ToString("o")
    scope = "repo-local-runtime"
    status = $diagnosisStatus
    probableCause = $probableCause
    signals = $signals
    recommendation = if ($diagnosisStatus -eq "STABLE") { "continue observing" } else { "inspect failing or warning signal before enabling live actions" }
    sensitiveContentDetected = $false
    liveWrite = $false
}

$event = [ordered]@{
    eventId = [guid]::NewGuid().ToString()
    traceId = [guid]::NewGuid().ToString()
    spanId = [guid]::NewGuid().ToString()
    parentSpanId = $null
    type = "RUNTIME_DIAGNOSIS"
    domain = "diagnostic"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    status = "queued"
    priority = if ($diagnosisStatus -eq "STABLE") { "medium" } else { "high" }
    schemaVersion = "v1.0"
    executionSurface = (Get-CeoExecutionSurface -AdapterId "local")
    payload = $payload
    metadata = [ordered]@{
        cabinaId = "CABINA_LOCAL"
        executionAdapterId = "ceo-execution-adapter.ps1"
        source = "ceo-runtime-diagnose"
        governance = (Get-CeoDefaultGovernance -Agent "diagnostic_agent" -Tool "ceo-runtime-diagnose.ps1" -Evidence "<RUNTIME_PATH>/diagnostics/runtime-diagnosis.jsonl" -Validator "run-integration-smoke.ps1" -StopCondition "runtime degradation not emitted as diagnosis")
    }
}

$result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_RUNTIME_DIAGNOSIS"
if ($result.ExitCode -ne 0) {
    Write-Output "RUNTIME_DIAGNOSIS_HELD:$($result.Status)"
    exit $result.ExitCode
}

Write-Output "RUNTIME_DIAGNOSIS_QUEUED:$diagnosisStatus"
exit 0
