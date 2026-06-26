param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$guard = Test-CeoVsiExecutionContext
$payload = [ordered]@{
    guardId = [guid]::NewGuid().ToString()
    checkedAt = (Get-Date).ToUniversalTime().ToString("o")
    status = if ($guard.IsValid) { "PASS" } else { "HELD" }
    signals = @($guard.Signals | ForEach-Object {
        [ordered]@{
            name = [string] $_.name
            status = [string] $_.status
            evidence = [string] $_.evidence
        }
    })
    requiredContext = $root
    recommendation = if ($guard.IsValid) { "continue operating through VS Code Insiders anchored in the repo" } else { "hold execution and reopen the canonical root in VS Code Insiders" }
    sensitiveContentDetected = $false
    liveWrite = $false
}

$event = [ordered]@{
    eventId = [guid]::NewGuid().ToString()
    traceId = [guid]::NewGuid().ToString()
    spanId = [guid]::NewGuid().ToString()
    parentSpanId = $null
    type = "VSI_GUARD_RESULT"
    domain = "ide"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    status = "queued"
    priority = if ($guard.IsValid) { "medium" } else { "critical" }
    schemaVersion = "v1.0"
    executionSurface = (Get-CeoExecutionSurface -AdapterId "local")
    payload = $payload
    metadata = [ordered]@{
        cabinaId = "CABINA_LOCAL"
        executionAdapterId = "ceo-execution-adapter.ps1"
        source = "ceo-vsi-execution-guard"
        governance = (Get-CeoDefaultGovernance -Agent "vsi_execution_guard" -Tool "ceo-vsi-execution-guard.ps1" -Evidence "<RUNTIME_PATH>/vsi/vsi-guard.jsonl" -Validator "run-integration-smoke.ps1" -StopCondition "execution continues outside valid VSI context")
    }
}

$result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_VSI_GUARD_RESULT"
if ($result.ExitCode -ne 0) {
    Write-Output "VSI_GUARD_HELD:$($result.Status)"
    exit $result.ExitCode
}

if (-not $guard.IsValid) {
    Write-Output "VSI_GUARD_HELD:$(@($guard.Issues) -join ';')"
    exit 30
}

Write-Output "VSI_GUARD_QUEUED:PASS"
exit 0
