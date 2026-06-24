param(
    [string] $StateRoot,
    [string] $OutputFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = $env:SDU_DASHBOARD_OUTPUT
}
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = Join-Path $state.StateRoot "dashboard\data.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputFile)) {
    $OutputFile = Join-Path $root $OutputFile
}

$outputRoot = [System.IO.Path]::GetFullPath($OutputFile)
if (-not $outputRoot.StartsWith(([System.IO.Path]::GetFullPath($root)), [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "OUTPUT_OUTSIDE_REPO:$OutputFile"
}

function Convert-EventLines {
    param(
        [string[]] $Lines,
        [string] $Source
    )

    $items = @()
    foreach ($line in $Lines) {
        try {
            $event = $line | ConvertFrom-Json
            $event | Add-Member -NotePropertyName busSource -NotePropertyValue $Source -Force
            $items += $event
        }
        catch {
            $items += [PSCustomObject]@{
                type = "UNPARSEABLE"
                status = "failed"
                busSource = $Source
                error = $_.Exception.Message
            }
        }
    }
    return $items
}

function Get-CeoDashboardPropertyValue {
    param(
        $InputObject,
        [Parameter(Mandatory = $true)]
        [string] $Name,
        $Default = $null
    )

    if ($null -eq $InputObject) {
        return $Default
    }

    return (Get-CeoObjectPropertyValue -InputObject $InputObject -Name $Name -Default $Default)
}

function Get-CeoDashboardExecutionMetadata {
    param(
        $Event = $null,
        $Payload = $null
    )

    $defaultSurface = Get-CeoExecutionSurface
    $surface = Get-CeoDashboardPropertyValue -InputObject $Event -Name "executionSurface" -Default $defaultSurface
    $execution = Get-CeoDashboardPropertyValue -InputObject $Payload -Name "execution" -Default $null

    $defaultDecisionEngine = [string] (Get-CeoDashboardPropertyValue -InputObject $defaultSurface -Name "decisionEngine" -Default "ceo-decision-engine")
    $defaultRuntimeRouter = [string] (Get-CeoDashboardPropertyValue -InputObject $defaultSurface -Name "runtimeRouter" -Default "ceo-runtime-router.ps1")
    $defaultExecutionAdapter = [string] (Get-CeoDashboardPropertyValue -InputObject $defaultSurface -Name "executionAdapter" -Default "ceo-execution-adapter.ps1")
    $defaultExecutionSurface = [string] (Get-CeoDashboardPropertyValue -InputObject $defaultSurface -Name "surfaceId" -Default "local")
    $defaultExecutionPath = @(Get-CeoDashboardPropertyValue -InputObject $defaultSurface -Name "executionPath" -Default @($defaultDecisionEngine, $defaultRuntimeRouter, $defaultExecutionAdapter, $defaultExecutionSurface))

    $decisionEngine = [string] (Get-CeoDashboardPropertyValue -InputObject $execution -Name "decisionEngine" -Default (Get-CeoDashboardPropertyValue -InputObject $surface -Name "decisionEngine" -Default $defaultDecisionEngine))
    $runtimeRouter = [string] (Get-CeoDashboardPropertyValue -InputObject $execution -Name "runtimeRouter" -Default (Get-CeoDashboardPropertyValue -InputObject $surface -Name "runtimeRouter" -Default $defaultRuntimeRouter))
    $executionAdapter = [string] (Get-CeoDashboardPropertyValue -InputObject $execution -Name "executionAdapter" -Default (Get-CeoDashboardPropertyValue -InputObject $surface -Name "executionAdapter" -Default $defaultExecutionAdapter))
    $executionSurface = [string] (Get-CeoDashboardPropertyValue -InputObject $execution -Name "executionSurface" -Default (Get-CeoDashboardPropertyValue -InputObject $surface -Name "surfaceId" -Default $defaultExecutionSurface))
    $executionPath = @(Get-CeoDashboardPropertyValue -InputObject $execution -Name "executionPath" -Default (Get-CeoDashboardPropertyValue -InputObject $surface -Name "executionPath" -Default $defaultExecutionPath))
    if ($executionPath.Count -eq 0) {
        $executionPath = @($decisionEngine, $runtimeRouter, $executionAdapter, $executionSurface)
    }
    $adapterMode = [string] (Get-CeoDashboardPropertyValue -InputObject $execution -Name "adapterMode" -Default (Get-CeoDashboardPropertyValue -InputObject $surface -Name "mode" -Default "local-only"))

    return [ordered]@{
        decisionEngine = $decisionEngine
        runtimeRouter = $runtimeRouter
        executionAdapter = $executionAdapter
        executionSurface = $executionSurface
        executionPath = $executionPath
        adapterMode = $adapterMode
    }
}

function Set-CeoTraceExecutionMetadata {
    param(
        [Parameter(Mandatory = $true)]
        $Trace,
        [Parameter(Mandatory = $true)]
        $Execution
    )

    foreach ($name in @("decisionEngine", "runtimeRouter", "executionAdapter", "executionSurface")) {
        $current = [string] (Get-CeoObjectPropertyValue -InputObject $Trace -Name $name -Default "UNKNOWN")
        $next = [string] (Get-CeoObjectPropertyValue -InputObject $Execution -Name $name -Default "UNKNOWN")
        if ([string]::IsNullOrWhiteSpace($current) -or $current -eq "UNKNOWN") {
            Set-CeoObjectProperty -InputObject $Trace -Name $name -Value $next
        }
    }

    $currentPath = @(Get-CeoObjectPropertyValue -InputObject $Trace -Name "executionPath" -Default @())
    if ($currentPath.Count -eq 0) {
        Set-CeoObjectProperty -InputObject $Trace -Name "executionPath" -Value @(Get-CeoObjectPropertyValue -InputObject $Execution -Name "executionPath" -Default @())
    }
}

function Convert-AgentChains {
    param(
        [array] $Events,
        [array] $MemoryRecords
    )

    $memoryByKey = @{}
    foreach ($memory in @($MemoryRecords)) {
        $key = [string] (Get-CeoObjectPropertyValue -InputObject $memory -Name "memoryKey" -Default "")
        if (-not [string]::IsNullOrWhiteSpace($key)) {
            $memoryByKey[$key] = $memory
        }
    }

    $chains = @()
    foreach ($event in @($Events)) {
        try {
            if ([string] (Get-CeoObjectPropertyValue -InputObject $event -Name "type" -Default "") -ne "AGENT_DECISION") {
                continue
            }
            $payload = Get-CeoObjectPropertyValue -InputObject $event -Name "payload" -Default $null
            if ($null -eq $payload -or -not $payload.PSObject.Properties["agentDecisions"]) {
                continue
            }
            if (-not $payload.PSObject.Properties["chainId"] -or -not $payload.PSObject.Properties["chainStatus"]) {
                continue
            }
            if (-not $payload.PSObject.Properties["finalState"] -or -not $payload.PSObject.Properties["conflictResolution"] -or -not $payload.PSObject.Properties["chainMemoryRef"]) {
                continue
            }

            $execution = Get-CeoDashboardExecutionMetadata -Event $event -Payload $payload
            $decisions = @()
            foreach ($decision in @($payload.agentDecisions | Sort-Object sequence)) {
                $decisions += [ordered]@{
                    sequence = [int] (Get-CeoObjectPropertyValue -InputObject $decision -Name "sequence" -Default 1)
                    priority = [int] (Get-CeoObjectPropertyValue -InputObject $decision -Name "priority" -Default 99)
                    agentId = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "agentId" -Default "UNKNOWN")
                    agentRole = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "agentRole" -Default "UNKNOWN")
                    decisionType = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "decisionType" -Default "UNKNOWN")
                    executionSurface = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "executionSurface" -Default (Get-CeoObjectPropertyValue -InputObject $execution -Name "executionSurface" -Default "local"))
                    result = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "result" -Default "UNKNOWN")
                    timestamp = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "timestamp" -Default "")
                    validator = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "validator" -Default "UNKNOWN")
                    stopCondition = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "stopCondition" -Default "UNKNOWN")
                    holdReason = (Get-CeoObjectPropertyValue -InputObject $decision -Name "holdReason" -Default $null)
                }
            }

            $memoryKey = [string] (Get-CeoObjectPropertyValue -InputObject (Get-CeoObjectPropertyValue -InputObject $payload -Name "chainMemoryRef" -Default ([PSCustomObject]@{})) -Name "memoryKey" -Default "")
            $memoryRecord = if ($memoryByKey.ContainsKey($memoryKey)) { $memoryByKey[$memoryKey] } else { $null }
            $memoryRecordedAt = if ($null -ne $memoryRecord) { Get-CeoObjectPropertyValue -InputObject $memoryRecord -Name "recordedAt" -Default $null } else { $null }

            $chains += [ordered]@{
                traceId = [string] (Get-CeoObjectPropertyValue -InputObject $payload -Name "sourceTraceId" -Default (Get-CeoObjectPropertyValue -InputObject $event -Name "traceId" -Default ""))
                sourceEventId = [string] (Get-CeoObjectPropertyValue -InputObject $payload -Name "sourceEventId" -Default "")
                sourceType = [string] (Get-CeoObjectPropertyValue -InputObject $payload -Name "sourceType" -Default "UNKNOWN")
                chainId = [string] (Get-CeoObjectPropertyValue -InputObject $payload -Name "chainId" -Default "UNKNOWN")
                chainStatus = [string] (Get-CeoObjectPropertyValue -InputObject $payload -Name "chainStatus" -Default "UNKNOWN")
                conflict = [bool] (Get-CeoObjectPropertyValue -InputObject $payload -Name "conflict" -Default $false)
                conflictReason = (Get-CeoObjectPropertyValue -InputObject $payload -Name "conflictReason" -Default $null)
                priorityRule = [string] (Get-CeoObjectPropertyValue -InputObject $payload -Name "priorityRule" -Default (Get-CeoAgentPriorityRule))
                execution = $execution
                conflictResolution = (Get-CeoObjectPropertyValue -InputObject $payload -Name "conflictResolution" -Default ([PSCustomObject]@{}))
                finalState = (Get-CeoObjectPropertyValue -InputObject $payload -Name "finalState" -Default ([PSCustomObject]@{}))
                memory = [ordered]@{
                    memoryKey = $memoryKey
                    recordedAt = $memoryRecordedAt
                }
                decisions = $decisions
                followUpEvents = @(Get-CeoObjectPropertyValue -InputObject $payload -Name "followUpEvents" -Default @())
            }
        }
        catch {
        }
    }

    return @($chains | Sort-Object sourceType, traceId)
}

function Convert-UnifiedTrace {
    param(
        [array] $Events,
        [array] $AgentChains,
        [array] $MemoryRecords
    )

    $traceMap = @{}

    foreach ($event in @($Events)) {
        $traceId = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "traceId" -Default "")
        if ([string]::IsNullOrWhiteSpace($traceId)) {
            continue
        }
        if (-not $traceMap.ContainsKey($traceId)) {
            $traceMap[$traceId] = [ordered]@{
                traceId = $traceId
                sourceTypes = @()
                eventCount = 0
                conflict = $false
                decisionEngine = "UNKNOWN"
                runtimeRouter = "UNKNOWN"
                executionAdapter = "UNKNOWN"
                executionSurface = "UNKNOWN"
                executionPath = @()
                priorityRule = (Get-CeoAgentPriorityRule)
                finalState = [ordered]@{
                    status = "UNKNOWN"
                    result = "UNKNOWN"
                    reason = "no agent final state recorded"
                    selectedAgentRole = $null
                    selectedDecisionType = $null
                    selectedPriority = $null
                    stopCondition = "trace has no agent decision"
                }
                conflictResolution = [ordered]@{
                    status = "UNKNOWN"
                    strategy = "none"
                    resolved = $false
                    reason = "no conflict resolution recorded"
                    priorityRule = (Get-CeoAgentPriorityRule)
                    selectedAgentRole = $null
                    selectedDecisionType = $null
                    blockedFollowUps = $false
                }
                chains = @()
                decisions = @()
                memory = @()
                timeline = @()
            }
        }

        $type = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "type" -Default "UNKNOWN")
        $execution = Get-CeoDashboardExecutionMetadata -Event $event
        Set-CeoTraceExecutionMetadata -Trace $traceMap[$traceId] -Execution $execution
        if ($type -notin @($traceMap[$traceId].sourceTypes)) {
            $traceMap[$traceId].sourceTypes += $type
        }
        $traceMap[$traceId].eventCount++
        $traceMap[$traceId].timeline += [ordered]@{
            timestamp = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "timestamp" -Default "")
            itemType = "event"
            label = $type
            eventId = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "eventId" -Default "")
            status = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "status" -Default "UNKNOWN")
            busSource = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "busSource" -Default "")
            spanId = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "spanId" -Default "")
            parentSpanId = (Get-CeoObjectPropertyValue -InputObject $event -Name "parentSpanId" -Default $null)
            sequence = $null
            priority = $null
            agentRole = $null
            decisionType = $null
            decisionEngine = [string] $execution.decisionEngine
            runtimeRouter = [string] $execution.runtimeRouter
            executionAdapter = [string] $execution.executionAdapter
            executionSurface = [string] $execution.executionSurface
            executionPath = @($execution.executionPath)
            result = [string] (Get-CeoObjectPropertyValue -InputObject $event -Name "dispatchResult" -Default (Get-CeoObjectPropertyValue -InputObject $event -Name "agentDecisionResult" -Default ""))
        }
    }

    foreach ($chain in @($AgentChains)) {
        $traceId = [string] (Get-CeoObjectPropertyValue -InputObject $chain -Name "traceId" -Default "")
        if ([string]::IsNullOrWhiteSpace($traceId)) {
            continue
        }
        if (-not $traceMap.ContainsKey($traceId)) {
            $traceMap[$traceId] = [ordered]@{
                traceId = $traceId
                sourceTypes = @()
                eventCount = 0
                conflict = $false
                decisionEngine = "UNKNOWN"
                runtimeRouter = "UNKNOWN"
                executionAdapter = "UNKNOWN"
                executionSurface = "UNKNOWN"
                executionPath = @()
                priorityRule = (Get-CeoAgentPriorityRule)
                finalState = [ordered]@{}
                conflictResolution = [ordered]@{}
                chains = @()
                decisions = @()
                memory = @()
                timeline = @()
            }
        }

        $sourceType = [string] (Get-CeoObjectPropertyValue -InputObject $chain -Name "sourceType" -Default "UNKNOWN")
        $execution = Get-CeoObjectPropertyValue -InputObject $chain -Name "execution" -Default (Get-CeoDashboardExecutionMetadata)
        Set-CeoTraceExecutionMetadata -Trace $traceMap[$traceId] -Execution $execution
        if ($sourceType -notin @($traceMap[$traceId].sourceTypes)) {
            $traceMap[$traceId].sourceTypes += $sourceType
        }
        $traceMap[$traceId].chains += $chain
        $traceMap[$traceId].conflict = ([bool] $traceMap[$traceId].conflict -or [bool] (Get-CeoObjectPropertyValue -InputObject $chain -Name "conflict" -Default $false))
        $traceMap[$traceId].priorityRule = [string] (Get-CeoObjectPropertyValue -InputObject $chain -Name "priorityRule" -Default $traceMap[$traceId].priorityRule)
        $traceMap[$traceId].finalState = (Get-CeoObjectPropertyValue -InputObject $chain -Name "finalState" -Default $traceMap[$traceId].finalState)
        $traceMap[$traceId].conflictResolution = (Get-CeoObjectPropertyValue -InputObject $chain -Name "conflictResolution" -Default $traceMap[$traceId].conflictResolution)

        foreach ($decision in @(Get-CeoObjectPropertyValue -InputObject $chain -Name "decisions" -Default @())) {
            $decisionRecord = [ordered]@{
                chainId = [string] (Get-CeoObjectPropertyValue -InputObject $chain -Name "chainId" -Default "")
                sourceType = $sourceType
                sequence = [int] (Get-CeoObjectPropertyValue -InputObject $decision -Name "sequence" -Default 0)
                priority = [int] (Get-CeoObjectPropertyValue -InputObject $decision -Name "priority" -Default 99)
                agentId = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "agentId" -Default "")
                agentRole = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "agentRole" -Default "")
                decisionType = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "decisionType" -Default "")
                executionSurface = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "executionSurface" -Default (Get-CeoObjectPropertyValue -InputObject $execution -Name "executionSurface" -Default "local"))
                result = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "result" -Default "")
                timestamp = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "timestamp" -Default "")
                validator = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "validator" -Default "")
                stopCondition = [string] (Get-CeoObjectPropertyValue -InputObject $decision -Name "stopCondition" -Default "")
                holdReason = (Get-CeoObjectPropertyValue -InputObject $decision -Name "holdReason" -Default $null)
            }
            $traceMap[$traceId].decisions += $decisionRecord
            $traceMap[$traceId].timeline += [ordered]@{
                timestamp = $decisionRecord.timestamp
                itemType = "decision"
                label = $decisionRecord.agentRole
                eventId = [string] (Get-CeoObjectPropertyValue -InputObject $chain -Name "sourceEventId" -Default "")
                status = [string] (Get-CeoObjectPropertyValue -InputObject $chain -Name "chainStatus" -Default "")
                busSource = "agent-chain"
                spanId = ""
                parentSpanId = $null
                sequence = $decisionRecord.sequence
                priority = $decisionRecord.priority
                agentRole = $decisionRecord.agentRole
                decisionType = $decisionRecord.decisionType
                decisionEngine = [string] (Get-CeoObjectPropertyValue -InputObject $execution -Name "decisionEngine" -Default "UNKNOWN")
                runtimeRouter = [string] (Get-CeoObjectPropertyValue -InputObject $execution -Name "runtimeRouter" -Default "UNKNOWN")
                executionAdapter = [string] (Get-CeoObjectPropertyValue -InputObject $execution -Name "executionAdapter" -Default "UNKNOWN")
                executionSurface = $decisionRecord.executionSurface
                executionPath = @(Get-CeoObjectPropertyValue -InputObject $execution -Name "executionPath" -Default @())
                result = $decisionRecord.result
            }
        }
    }

    foreach ($memory in @($MemoryRecords)) {
        $traceId = [string] (Get-CeoObjectPropertyValue -InputObject $memory -Name "traceId" -Default "")
        if ([string]::IsNullOrWhiteSpace($traceId) -or -not $traceMap.ContainsKey($traceId)) {
            continue
        }
        $execution = [ordered]@{
            decisionEngine = [string] (Get-CeoObjectPropertyValue -InputObject $traceMap[$traceId] -Name "decisionEngine" -Default "UNKNOWN")
            runtimeRouter = [string] (Get-CeoObjectPropertyValue -InputObject $traceMap[$traceId] -Name "runtimeRouter" -Default "UNKNOWN")
            executionAdapter = [string] (Get-CeoObjectPropertyValue -InputObject $traceMap[$traceId] -Name "executionAdapter" -Default "UNKNOWN")
            executionSurface = [string] (Get-CeoObjectPropertyValue -InputObject $traceMap[$traceId] -Name "executionSurface" -Default "UNKNOWN")
            executionPath = @(Get-CeoObjectPropertyValue -InputObject $traceMap[$traceId] -Name "executionPath" -Default @())
        }
        $traceMap[$traceId].memory += $memory
        $traceMap[$traceId].timeline += [ordered]@{
            timestamp = [string] (Get-CeoObjectPropertyValue -InputObject $memory -Name "recordedAt" -Default "")
            itemType = "memory"
            label = "chain-memory"
            eventId = [string] (Get-CeoObjectPropertyValue -InputObject $memory -Name "memoryId" -Default "")
            status = [string] (Get-CeoObjectPropertyValue -InputObject $memory -Name "chainStatus" -Default "")
            busSource = "trace-memory"
            spanId = ""
            parentSpanId = $null
            sequence = $null
            priority = $null
            agentRole = $null
            decisionType = "record-memory"
            decisionEngine = [string] $execution.decisionEngine
            runtimeRouter = [string] $execution.runtimeRouter
            executionAdapter = [string] $execution.executionAdapter
            executionSurface = [string] $execution.executionSurface
            executionPath = @($execution.executionPath)
            result = [string] (Get-CeoObjectPropertyValue -InputObject (Get-CeoObjectPropertyValue -InputObject $memory -Name "finalState" -Default ([PSCustomObject]@{})) -Name "status" -Default "")
        }
    }

    $items = @()
    foreach ($key in @($traceMap.Keys)) {
        $trace = $traceMap[$key]
        $trace.decisions = @($trace.decisions | Sort-Object @{ Expression = { [string] $_.chainId } }, sequence, priority)
        $trace.timeline = @($trace.timeline | Sort-Object timestamp, itemType)
        $items += [PSCustomObject] $trace
    }

    return @($items | Sort-Object @{
        Expression = {
            $last = @($_.timeline | ForEach-Object { [string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "timestamp" -Default "") } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object | Select-Object -Last 1)
            if ($last.Count -gt 0) { [string] $last[0] } else { "" }
        }
    }, traceId)
}

$queueLines = @(Get-CeoJsonlLines -Path $state.QueueFile)
$processedLines = @(Get-CeoJsonlLines -Path $state.ProcessedFile)
$failedLines = @(Get-CeoJsonlLines -Path $state.FailedFile)
$invalidLines = @(Get-CeoJsonlLines -Path $state.InvalidLog)
$processedIds = @{}

foreach ($line in $processedLines) {
    try {
        $event = $line | ConvertFrom-Json
        if ($event.PSObject.Properties["eventId"]) {
            $processedIds[[string] $event.eventId] = $true
        }
    }
    catch {
    }
}

$unresolvedFailedLines = @()
foreach ($line in $failedLines) {
    try {
        $event = $line | ConvertFrom-Json
        if ($event.PSObject.Properties["eventId"] -and $processedIds.ContainsKey([string] $event.eventId)) {
            continue
        }
    }
    catch {
    }
    $unresolvedFailedLines += $line
}

$events = @()
$events += Convert-EventLines -Lines $queueLines -Source "queue"
$events += Convert-EventLines -Lines $processedLines -Source "processed"
$events += Convert-EventLines -Lines $unresolvedFailedLines -Source "failed"
$traceMemory = @(Get-CeoChainMemoryRecords -StateRoot $state.StateRoot)
$agentChains = @(Convert-AgentChains -Events $events -MemoryRecords $traceMemory)
$unifiedTrace = @(Convert-UnifiedTrace -Events $events -AgentChains $agentChains -MemoryRecords $traceMemory)

$view = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    metrics = [ordered]@{
        queue = $queueLines.Count
        processed = $processedLines.Count
        failed = $unresolvedFailedLines.Count
        invalid = $invalidLines.Count
    }
    events = @($events | Sort-Object timestamp)
    unifiedTrace = $unifiedTrace
}

$dir = Split-Path -Parent $OutputFile
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$view | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $OutputFile -Encoding UTF8
Write-Output "EXPORT:OK:$($events.Count)"
exit 0
