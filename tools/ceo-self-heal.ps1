param(
    [string] $EventFile,
    [string] $TraceId,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot

if (-not [string]::IsNullOrWhiteSpace($EventFile)) {
    $validation = Test-CeoEventFile -EventFile $EventFile -StateRoot $state.StateRoot
    if ($validation.Status -ne "VALID_EVENT") {
        Write-Output "SELF_HEAL_REJECTED:$($validation.Status)"
        exit 30
    }

    $event = Get-Content -LiteralPath $EventFile -Raw | ConvertFrom-Json
    if ($event.type -ne "SELF_HEAL_COMMAND") {
        Write-Output "SELF_HEAL_REJECTED:WRONG_EVENT_TYPE"
        exit 31
    }

    $decision = Get-CeoPolicyDecision -EventType $event.type -StateRoot $state.StateRoot
    if (-not $decision.allowed -or $decision.requiresApproval) {
        Write-Output "SELF_HEAL_HELD_BY_POLICY"
        exit 40
    }

    $TraceId = $event.payload.targetTraceId
}

if ([string]::IsNullOrWhiteSpace($TraceId)) {
    Write-Output "SELF_HEAL_REJECTED:TRACE_REQUIRED"
    exit 32
}

$record = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    traceId = $TraceId
    action = "local-noop"
    sensitiveMutation = $false
    evidence = "<RUNTIME_PATH>/watch/events/dispatch.jsonl"
}

Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
Write-Output "SELF_HEAL_OK:LOCAL_NOOP"
exit 0
