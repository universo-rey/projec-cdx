param(
    [int] $MaxEvents = 5,
    [string] $StateRoot,
    [ValidateSet("local")]
    [string] $AdapterId = "local"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$adapter = Get-CeoExecutionAdapter -AdapterId $AdapterId
if ([string] $adapter.status -ne "active") {
    Write-Output "EXECUTION_ADAPTER_HELD:$AdapterId"
    exit 30
}

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$activeGovernance = Test-CeoActiveGovernancePreflight
if (-not $activeGovernance.IsValid) {
    $reason = (@($activeGovernance.Issues) -join ";")
    Add-Content -LiteralPath $state.ExecutionAdapterLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] HELD_BY_ACTIVE_GOVERNANCE reason=$reason" -Encoding UTF8
    Write-Output "EXECUTION_ADAPTER_HELD:ACTIVE_GOVERNANCE_PRECHECK:$reason"
    exit 31
}

$lines = @(Get-CeoJsonlLines -Path $state.QueueFile)

if ($lines.Count -eq 0) {
    Write-Output "QUEUE_EMPTY"
    exit 0
}

Set-Content -LiteralPath $state.QueueFile -Value @() -Encoding UTF8

$remaining = @()
$processedCount = 0
$failedCount = 0
$runtimeRouter = Join-Path $PSScriptRoot "ceo-runtime-router.ps1"

foreach ($line in $lines) {
    if ($processedCount -ge $MaxEvents) {
        $remaining += $line
        continue
    }

    $tempEvent = New-CeoSuiteTempFile -StateRoot $state.StateRoot -Prefix "execution-adapter-event"
    try {
        $line | Set-Content -LiteralPath $tempEvent -Encoding UTF8
        $validation = Test-CeoEventFile -EventFile $tempEvent -StateRoot $state.StateRoot
        if ($validation.Status -ne "VALID_EVENT") {
            Add-CeoJsonlLine -Path $state.FailedFile -Line $line
            Add-Content -LiteralPath $state.ExecutionAdapterLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] INVALID_IN_EXECUTION_ADAPTER reason=$($validation.Status)" -Encoding UTF8
            $failedCount++
            continue
        }

        $event = $line | ConvertFrom-Json
        $event = Ensure-CeoExecutionSurface -Event $event -AdapterId $AdapterId
        $policy = Get-CeoPolicyDecision -EventType $event.type -StateRoot $state.StateRoot
        if (-not $policy.allowed -or $policy.requiresApproval) {
            $event.status = "held"
            Set-CeoObjectProperty -InputObject $event -Name "policyDecision" -Value $policy
            Set-CeoObjectProperty -InputObject $event -Name "processedAt" -Value ((Get-Date).ToUniversalTime().ToString("o"))
            Add-CeoJsonlLine -Path $state.FailedFile -Line (ConvertTo-CeoJsonLine -InputObject $event)
            Add-Content -LiteralPath $state.ExecutionAdapterLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] HELD_BY_POLICY type=$($event.type) reason=$($policy.reason)" -Encoding UTF8
            $failedCount++
            continue
        }

        try {
            $started = Get-Date
            $dispatchResult = Invoke-CeoEventDispatch -Event $event -StateRoot $state.StateRoot
            $agentDecisionResult = "RUNTIME_ROUTER_SKIPPED:AGENT_DECISION"
            if ($event.type -ne "AGENT_DECISION") {
                $agentDecisionOutput = & $runtimeRouter -EventFile $tempEvent -StateRoot $state.StateRoot
                if ($LASTEXITCODE -ne 0) {
                    throw "RUNTIME_ROUTER_FAILED:$($agentDecisionOutput -join ';')"
                }
                $agentDecisionResult = ($agentDecisionOutput -join ";")
            }
            $duration = [Math]::Max(0, [int] ((Get-Date) - $started).TotalMilliseconds)
            $event.status = "done"
            Set-CeoObjectProperty -InputObject $event -Name "policyDecision" -Value $policy
            Set-CeoObjectProperty -InputObject $event -Name "dispatchResult" -Value $dispatchResult
            Set-CeoObjectProperty -InputObject $event -Name "agentDecisionResult" -Value $agentDecisionResult
            Set-CeoObjectProperty -InputObject $event -Name "processedAt" -Value ((Get-Date).ToUniversalTime().ToString("o"))
            Set-CeoObjectProperty -InputObject $event -Name "durationMs" -Value $duration
            Add-CeoJsonlLine -Path $state.ProcessedFile -Line (ConvertTo-CeoJsonLine -InputObject $event)
            $processedCount++
        }
        catch {
            $event.status = "failed"
            Set-CeoObjectProperty -InputObject $event -Name "error" -Value $_.Exception.Message
            Set-CeoObjectProperty -InputObject $event -Name "failedAt" -Value ((Get-Date).ToUniversalTime().ToString("o"))
            Add-CeoJsonlLine -Path $state.FailedFile -Line (ConvertTo-CeoJsonLine -InputObject $event)
            Add-Content -LiteralPath $state.ExecutionAdapterLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] EXECUTION_FAILED type=$($event.type) error=$($_.Exception.Message)" -Encoding UTF8
            $failedCount++
        }
    }
    finally {
        Remove-Item -LiteralPath $tempEvent -ErrorAction SilentlyContinue
    }
}

foreach ($remainingLine in $remaining) {
    Add-CeoJsonlLine -Path $state.QueueFile -Line $remainingLine
}
Write-Output "EXECUTION_ADAPTER_DONE:processed=$processedCount failed=$failedCount remaining=$($remaining.Count)"
if ($failedCount -gt 0) { exit 20 }
exit 0
