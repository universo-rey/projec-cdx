param(
    [Parameter(Mandatory = $true)]
    [string] $EventFile,

    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$validation = Test-CeoEventFile -EventFile $EventFile -StateRoot $state.StateRoot
if ($validation.Status -ne "VALID_EVENT") {
    Write-Output "RUNTIME_ROUTER_REJECTED:$($validation.Status)"
    exit 30
}

$event = Get-Content -LiteralPath $EventFile -Raw | ConvertFrom-Json
$event = Ensure-CeoExecutionSurface -Event $event -AdapterId "local"
if ($event.type -eq "AGENT_DECISION") {
    Write-Output "RUNTIME_ROUTER_SKIPPED:AGENT_DECISION"
    exit 0
}

$policy = Get-CeoPolicyDecision -EventType $event.type -StateRoot $state.StateRoot
$decisionEvent = New-CeoAgentDecisionEvent -SourceEvent $event -PolicyDecision $policy
$followUpEvents = @(New-CeoFollowUpEvents -SourceEvent $event -DecisionEvent $decisionEvent -PolicyDecision $policy)
$queueResult = Add-CeoValidatedEventToQueue -Event $decisionEvent -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_AGENT_DECISION_EVENT"

if ($queueResult.ExitCode -ne 0) {
    Write-Output "AGENT_DECISION_REJECTED:$($queueResult.Status)"
    exit $queueResult.ExitCode
}

$queuedFollowUps = 0
foreach ($followUpEvent in $followUpEvents) {
    $followUpResult = Add-CeoValidatedEventToQueue -Event $followUpEvent -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_AGENT_FOLLOW_UP_EVENT"
    if ($followUpResult.ExitCode -ne 0) {
        Write-Output "AGENT_FOLLOW_UP_REJECTED:$($followUpResult.Status)"
        exit $followUpResult.ExitCode
    }
    $queuedFollowUps++
}

$memoryResult = Add-CeoChainMemoryRecord -SourceEvent $event -DecisionEvent $decisionEvent -StateRoot $state.StateRoot

Write-Output "RUNTIME_ROUTER_QUEUED:$($event.type);FOLLOW_UPS:$queuedFollowUps;MEMORY:$($memoryResult.Status)"
exit 0
