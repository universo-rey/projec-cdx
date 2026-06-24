Set-StrictMode -Version Latest

function Get-CeoSuiteRoot {
    if ($PSScriptRoot) {
        return (Split-Path -Parent $PSScriptRoot)
    }

    return (Get-Location).Path
}

function Resolve-CeoSuitePath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-CeoSuiteRoot) $Path))
}

function Get-CeoSuiteStateRoot {
    param(
        [string] $StateRoot
    )

    $candidate = $StateRoot
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $candidate = $env:CEO_SUITE_STATE_ROOT
    }
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $candidate = $env:SDU_RUNTIME_ROOT
    }
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $candidate = Join-Path ([System.IO.Path]::GetTempPath()) "sdu-runtime"
    }

    $resolved = Resolve-CeoSuitePath -Path $candidate
    $repoRoot = [System.IO.Path]::GetFullPath((Get-CeoSuiteRoot))

    if (-not $resolved.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "STATE_ROOT_OUTSIDE_REPO:$resolved"
    }

    return $resolved
}

function Ensure-CeoFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $dir = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType File -Force -Path $Path | Out-Null
    }
}

function Initialize-CeoSuiteState {
    param(
        [string] $StateRoot
    )

    $state = Get-CeoSuiteStateRoot -StateRoot $StateRoot
    $bus = Join-Path $state "bus"
    $policy = Join-Path $state "policy"
    $watch = Join-Path $state "watch"
    $agents = Join-Path $state "agents"
    $sanitization = Join-Path $state "sanitization"
    $diagnostics = Join-Path $state "diagnostics"
    $federation = Join-Path $state "federation"
    $sns = Join-Path $state "sns"
    $vsi = Join-Path $state "vsi"
    $controlPlane = Join-Path $state "control-plane"
    $tmp = Join-Path $state "tmp"

    foreach ($dir in @($state, $bus, $policy, $agents, $sanitization, $diagnostics, $federation, $sns, $vsi, $controlPlane, (Join-Path $watch "alerts"), (Join-Path $watch "events"), $tmp)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }

    $paths = [PSCustomObject]@{
        StateRoot = $state
        BusRoot = $bus
        PolicyRoot = $policy
        WatchRoot = $watch
        AgentRoot = $agents
        SanitizationRoot = $sanitization
        DiagnosticsRoot = $diagnostics
        FederationRoot = $federation
        SnsRoot = $sns
        VsiRoot = $vsi
        ControlPlaneRoot = $controlPlane
        TmpRoot = $tmp
        QueueFile = Join-Path $bus "queue.jsonl"
        ProcessedFile = Join-Path $bus "processed.jsonl"
        FailedFile = Join-Path $bus "failed.jsonl"
        InvalidLog = Join-Path $bus "invalid-events.log"
        ExecutionAdapterLog = Join-Path $bus "execution-adapter.log"
        WorkerLog = Join-Path $bus "execution-adapter.log"
        PolicyFile = Join-Path $policy "policy.json"
        AlertFile = Join-Path (Join-Path $watch "alerts") "alerts.jsonl"
        DispatchFile = Join-Path (Join-Path $watch "events") "dispatch.jsonl"
        ChainMemoryFile = Join-Path $agents "chain-memory.jsonl"
        SanitizationFindingFile = Join-Path $sanitization "findings.jsonl"
        PathSanitizerFile = Join-Path $sanitization "path-sanitizer.jsonl"
        RuntimeDiagnosisFile = Join-Path $diagnostics "runtime-diagnosis.jsonl"
        FederationDriftFile = Join-Path $federation "federation-drift.jsonl"
        CanonicalPathRewriteFile = Join-Path $sanitization "canonical-path-rewrites.json"
        SnsRootFile = Join-Path (Get-CeoSuiteRoot) "SYSTEM_NERVOUS_INDEX.json"
        SnsUnifiedFile = Join-Path $sns "system-nervous-index.json"
        SnsEventFile = Join-Path $sns "system-nervous-index.jsonl"
        VsiGuardFile = Join-Path $vsi "vsi-guard.jsonl"
        ControlPlaneSyncFile = Join-Path $controlPlane "control-plane-sync.jsonl"
        AgileCanvasMapFile = Join-Path $controlPlane "agile-agent-canvas-map.json"
        PanelDir = Join-Path (Join-Path $watch "events") "panel"
    }

    foreach ($file in @($paths.QueueFile, $paths.ProcessedFile, $paths.FailedFile, $paths.InvalidLog, $paths.ExecutionAdapterLog, $paths.AlertFile, $paths.DispatchFile, $paths.ChainMemoryFile, $paths.SanitizationFindingFile, $paths.PathSanitizerFile, $paths.RuntimeDiagnosisFile, $paths.FederationDriftFile, $paths.SnsEventFile, $paths.VsiGuardFile, $paths.ControlPlaneSyncFile)) {
        Ensure-CeoFile -Path $file
    }

    if (-not (Test-Path -LiteralPath $paths.PolicyFile)) {
        $policyDoc = [ordered]@{
            version = "1.0"
            defaultMode = "ACTIVE_GOVERNED_EXECUTION_BY_DEFAULT"
            policies = [ordered]@{
                RUNTIME_DRIFT = [ordered]@{
                    allowed = $true
                    action = "dispatch"
                    requiresApproval = $false
                    reason = "local runtime drift can be dispatched without sensitive mutation"
                }
                VSCODE_DRIFT = [ordered]@{
                    allowed = $true
                    action = "dispatch"
                    requiresApproval = $false
                    reason = "local IDE drift is observability only"
                }
                ALERT_RAISED = [ordered]@{
                    allowed = $true
                    action = "alert"
                    requiresApproval = $false
                    reason = "alert writes only local evidence"
                }
                SELF_HEAL_COMMAND = [ordered]@{
                    allowed = $true
                    action = "retry-local"
                    requiresApproval = $false
                    reason = "self-heal is limited to local noop/retry evidence"
                }
                PREDICTIVE_SIGNAL = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "predictive engine emits local signal only"
                }
                OPTIMIZATION_COMMAND = [ordered]@{
                    allowed = $true
                    action = "recommend"
                    requiresApproval = $false
                    reason = "optimization engine emits recommendation only"
                }
                POLICY_DECISION = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "policy decision is local evidence"
                }
                AGENT_DECISION = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "agent decisions are local evidence events"
                }
                SANITIZATION_FINDING = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "sanitization findings are local evidence events"
                }
                RUNTIME_DIAGNOSIS = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "runtime diagnosis is local evidence only"
                }
                SANITIZE_REQUIRED = [ordered]@{
                    allowed = $true
                    action = "hold-or-observe"
                    requiresApproval = $false
                    reason = "path sanitizer emits local evidence and blocks unsafe roots fail-closed"
                }
                FEDERATION_DRIFT = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "federation drift is local governance evidence only"
                }
                SNS_UNIFIED_INDEX = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "system nervous index export is local evidence only"
                }
                VSI_GUARD_RESULT = [ordered]@{
                    allowed = $true
                    action = "guard"
                    requiresApproval = $false
                    reason = "VS Code Insiders guard validates local execution context"
                }
                CONTROL_PLANE_SYNC = [ordered]@{
                    allowed = $true
                    action = "observe"
                    requiresApproval = $false
                    reason = "Agile Agent Canvas sync is local control-plane evidence only"
                }
                UNKNOWN_EVENT = [ordered]@{
                    allowed = $false
                    action = "hold"
                    requiresApproval = $true
                    reason = "unknown event types are held fail-closed"
                }
            }
        }

        $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
    }
    else {
        $policyDoc = Get-Content -LiteralPath $paths.PolicyFile -Raw | ConvertFrom-Json
        if (-not $policyDoc.policies.PSObject.Properties["AGENT_DECISION"]) {
            $agentDecisionPolicy = [PSCustomObject]@{
                allowed = $true
                action = "observe"
                requiresApproval = $false
                reason = "agent decisions are local evidence events"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "AGENT_DECISION" -NotePropertyValue $agentDecisionPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["SANITIZATION_FINDING"]) {
            $sanitizationPolicy = [PSCustomObject]@{
                allowed = $true
                action = "observe"
                requiresApproval = $false
                reason = "sanitization findings are local evidence events"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "SANITIZATION_FINDING" -NotePropertyValue $sanitizationPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["RUNTIME_DIAGNOSIS"]) {
            $diagnosisPolicy = [PSCustomObject]@{
                allowed = $true
                action = "observe"
                requiresApproval = $false
                reason = "runtime diagnosis is local evidence only"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "RUNTIME_DIAGNOSIS" -NotePropertyValue $diagnosisPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["SANITIZE_REQUIRED"]) {
            $sanitizeRequiredPolicy = [PSCustomObject]@{
                allowed = $true
                action = "hold-or-observe"
                requiresApproval = $false
                reason = "path sanitizer emits local evidence and blocks unsafe roots fail-closed"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "SANITIZE_REQUIRED" -NotePropertyValue $sanitizeRequiredPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["FEDERATION_DRIFT"]) {
            $federationDriftPolicy = [PSCustomObject]@{
                allowed = $true
                action = "observe"
                requiresApproval = $false
                reason = "federation drift is local governance evidence only"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "FEDERATION_DRIFT" -NotePropertyValue $federationDriftPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["SNS_UNIFIED_INDEX"]) {
            $snsUnifiedPolicy = [PSCustomObject]@{
                allowed = $true
                action = "observe"
                requiresApproval = $false
                reason = "system nervous index export is local evidence only"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "SNS_UNIFIED_INDEX" -NotePropertyValue $snsUnifiedPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["VSI_GUARD_RESULT"]) {
            $vsiGuardPolicy = [PSCustomObject]@{
                allowed = $true
                action = "guard"
                requiresApproval = $false
                reason = "VS Code Insiders guard validates local execution context"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "VSI_GUARD_RESULT" -NotePropertyValue $vsiGuardPolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
        if (-not $policyDoc.policies.PSObject.Properties["CONTROL_PLANE_SYNC"]) {
            $controlPlanePolicy = [PSCustomObject]@{
                allowed = $true
                action = "observe"
                requiresApproval = $false
                reason = "Agile Agent Canvas sync is local control-plane evidence only"
            }
            $policyDoc.policies | Add-Member -NotePropertyName "CONTROL_PLANE_SYNC" -NotePropertyValue $controlPlanePolicy
            $policyDoc | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $paths.PolicyFile -Encoding UTF8
        }
    }

    return $paths
}

function New-CeoSuiteTempFile {
    param(
        [string] $StateRoot,
        [string] $Prefix = "tmp"
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    return (Join-Path $state.TmpRoot ("$Prefix-$([guid]::NewGuid()).json"))
}

function Get-CeoJsonlLines {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    return @(Get-Content -LiteralPath $Path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Add-CeoJsonlLine {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [Parameter(Mandatory = $true)]
        [string] $Line
    )

    Ensure-CeoFile -Path $Path
    Add-Content -LiteralPath $Path -Value $Line -Encoding UTF8
}

function ConvertTo-CeoJsonLine {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    return ($InputObject | ConvertTo-Json -Depth 30 -Compress)
}

function Set-CeoObjectProperty {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject,
        [Parameter(Mandatory = $true)]
        [string] $Name,
    $Value
)

    if ($InputObject -is [System.Collections.IDictionary]) {
        $InputObject[$Name] = $Value
        return
    }

    if ($InputObject.PSObject.Properties[$Name]) {
        $InputObject.$Name = $Value
    }
    else {
        $InputObject | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

function Get-CeoObjectPropertyValue {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject,
        [Parameter(Mandatory = $true)]
        [string] $Name,
    $Default = $null
)

    if ($null -ne $InputObject -and $InputObject -is [System.Collections.IDictionary] -and $InputObject.Contains($Name)) {
        return $InputObject[$Name]
    }

    if ($null -ne $InputObject -and $InputObject.PSObject.Properties[$Name]) {
        return $InputObject.$Name
    }

    return $Default
}

function Get-CeoContractMap {
    $root = Get-CeoSuiteRoot
    $mapFile = Join-Path $root "contracts\contract-map.json"
    if (-not (Test-Path -LiteralPath $mapFile)) {
        throw "CONTRACT_MAP_NOT_FOUND:$mapFile"
    }

    return (Get-Content -LiteralPath $mapFile -Raw | ConvertFrom-Json)
}

function Get-CeoAgentMap {
    $root = Get-CeoSuiteRoot
    $mapFile = Join-Path $root "contracts\agent-map.json"
    if (-not (Test-Path -LiteralPath $mapFile)) {
        throw "AGENT_MAP_NOT_FOUND:$mapFile"
    }

    return (Get-Content -LiteralPath $mapFile -Raw | ConvertFrom-Json)
}

function Get-CeoAgentRoute {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType
    )

    $map = Get-CeoAgentMap
    $routeProp = $map.routes.PSObject.Properties[$EventType]
    if (-not $routeProp) {
        return @()
    }

    $routeValue = $routeProp.Value
    $rawChain = @()
    if ($routeValue -is [array]) {
        $rawChain = @($routeValue)
    }
    elseif ($routeValue.PSObject.Properties["chain"]) {
        $rawChain = @($routeValue.chain)
    }
    elseif ($routeValue.PSObject.Properties["agentId"]) {
        $rawChain = @($routeValue)
    }
    else {
        return @()
    }

    $sequence = 0
    $normalized = @()
    foreach ($entry in $rawChain) {
        $sequence++
        if ($entry -is [string]) {
            $normalized += [PSCustomObject]@{
                sequence = $sequence
                agentId = [string] $entry
                decisionType = "route"
                priority = (Get-CeoAgentPriority -AgentId ([string] $entry) -DefaultPriority $sequence)
            }
            continue
        }

        $entrySequence = Get-CeoObjectPropertyValue -InputObject $entry -Name "sequence" -Default $sequence
        $entryAgentId = Get-CeoObjectPropertyValue -InputObject $entry -Name "agentId" -Default ""
        $entryDecisionType = Get-CeoObjectPropertyValue -InputObject $entry -Name "decisionType" -Default "route"
        $entryPriority = Get-CeoObjectPropertyValue -InputObject $entry -Name "priority" -Default (Get-CeoAgentPriority -AgentId ([string] $entryAgentId) -DefaultPriority ([int] $entrySequence))

        $normalized += [PSCustomObject]@{
            sequence = [int] $entrySequence
            agentId = [string] $entryAgentId
            decisionType = [string] $entryDecisionType
            priority = [int] $entryPriority
        }
    }

    return @($normalized | Sort-Object sequence)
}

function Get-CeoAgentRouteChainId {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType
    )

    $map = Get-CeoAgentMap
    $routeProp = $map.routes.PSObject.Properties[$EventType]
    if (-not $routeProp) {
        return "missing-route"
    }

    $routeValue = $routeProp.Value
    if ($routeValue -isnot [array] -and $routeValue.PSObject.Properties["chainId"]) {
        return [string] $routeValue.chainId
    }

    return "$($EventType.ToLowerInvariant())-legacy-chain"
}

function Get-CeoAgentFollowUpSpecs {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType
    )

    $map = Get-CeoAgentMap
    $routeProp = $map.routes.PSObject.Properties[$EventType]
    if (-not $routeProp) {
        return @()
    }

    $routeValue = $routeProp.Value
    if ($routeValue -isnot [array] -and $routeValue.PSObject.Properties["followUpEvents"]) {
        return @($routeValue.followUpEvents)
    }

    return @()
}

function Get-CeoAgentPriorityRule {
    $map = Get-CeoAgentMap
    if ($map.PSObject.Properties["priorityModel"] -and $map.priorityModel.PSObject.Properties["rule"]) {
        return [string] $map.priorityModel.rule
    }

    return "lower-number-wins; sequence tie-breaker; fail-closed on hold or conflict"
}

function Get-CeoAgentPriority {
    param(
        [Parameter(Mandatory = $true)]
        [string] $AgentId,
        [int] $DefaultPriority = 99
    )

    $map = Get-CeoAgentMap
    if ($map.PSObject.Properties["priorityModel"] -and $map.priorityModel.PSObject.Properties["agentPriority"]) {
        $priorityProp = $map.priorityModel.agentPriority.PSObject.Properties[$AgentId]
        if ($priorityProp) {
            return [int] $priorityProp.Value
        }
    }

    return $DefaultPriority
}

function Get-CeoAgentDefinition {
    param(
        [Parameter(Mandatory = $true)]
        [string] $AgentId
    )

    $map = Get-CeoAgentMap
    $agentProp = $map.agents.PSObject.Properties[$AgentId]
    if (-not $agentProp) {
        throw "AGENT_NOT_FOUND:$AgentId"
    }

    return $agentProp.Value
}

function Get-CeoEnvelopeEventTypes {
    $root = Get-CeoSuiteRoot
    $schemaFile = Join-Path $root "contracts\schemas\event-envelope.schema.json"
    if (-not (Test-Path -LiteralPath $schemaFile)) {
        throw "ENVELOPE_SCHEMA_NOT_FOUND:$schemaFile"
    }

    $schema = Get-Content -LiteralPath $schemaFile -Raw | ConvertFrom-Json
    return @($schema.properties.type.enum)
}

function Test-CeoContractMapCoverage {
    $map = Get-CeoContractMap
    $eventTypes = @(Get-CeoEnvelopeEventTypes)
    $payloadNames = @($map.payloadSchemas.PSObject.Properties.Name)
    $root = Get-CeoSuiteRoot
    $missing = @($eventTypes | Where-Object { $_ -notin $payloadNames })
    $extra = @($payloadNames | Where-Object { $_ -notin $eventTypes })
    $missingFiles = @()

    foreach ($name in $payloadNames) {
        $relative = $map.payloadSchemas.PSObject.Properties[$name].Value
        $path = Resolve-CeoSuitePath -Path $relative
        if (-not $path.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            $missingFiles += "${name}:OUTSIDE_REPO:$relative"
        }
        elseif (-not (Test-Path -LiteralPath $path)) {
            $missingFiles += "${name}:$relative"
        }
    }

    return [PSCustomObject]@{
        IsValid = (($missing.Count -eq 0) -and ($extra.Count -eq 0) -and ($missingFiles.Count -eq 0))
        MissingTypes = $missing
        ExtraTypes = $extra
        MissingFiles = $missingFiles
    }
}

function Test-CeoAgentMapCoverage {
    $eventTypes = @(Get-CeoEnvelopeEventTypes)
    $map = Get-CeoAgentMap
    $routes = @($map.routes.PSObject.Properties.Name)
    $agents = @($map.agents.PSObject.Properties.Name)
    $missingRoutes = @($eventTypes | Where-Object { $_ -notin $routes })
    $missingAgents = @()
    $routeIssues = @()
    $agentIssues = @()

    foreach ($route in $routes) {
        $seenSequences = @{}
        foreach ($item in @(Get-CeoAgentRoute -EventType $route)) {
            if ([string]::IsNullOrWhiteSpace([string] $item.agentId)) {
                $routeIssues += "${route}:missing-agentId"
                continue
            }
            if ($item.agentId -notin $agents) {
                $missingAgents += "${route}:$($item.agentId)"
            }
            if ($item.sequence -lt 1) {
                $routeIssues += "${route}:invalid-sequence:$($item.sequence)"
            }
            if ($seenSequences.ContainsKey([int] $item.sequence)) {
                $routeIssues += "${route}:duplicate-sequence:$($item.sequence)"
            }
            else {
                $seenSequences[[int] $item.sequence] = $true
            }
            if ([string]::IsNullOrWhiteSpace([string] $item.decisionType)) {
                $routeIssues += "${route}:missing-decisionType:$($item.agentId)"
            }
        }
    }

    foreach ($agentName in $agents) {
        $agent = $map.agents.PSObject.Properties[$agentName].Value
        $agentIssues += Test-CeoAgentDiscipline -Agent $agent -Prefix "agent-map:$agentName"
    }

    return [PSCustomObject]@{
        IsValid = (($missingRoutes.Count -eq 0) -and ($missingAgents.Count -eq 0) -and ($routeIssues.Count -eq 0) -and ($agentIssues.Count -eq 0))
        MissingRoutes = $missingRoutes
        MissingAgents = $missingAgents
        RouteIssues = $routeIssues
        AgentIssues = $agentIssues
    }
}

function Test-CeoJsonFileAgainstSchema {
    param(
        [Parameter(Mandatory = $true)]
        [string] $JsonFile,
        [Parameter(Mandatory = $true)]
        [string] $SchemaFile
    )

    if (-not (Test-Path -LiteralPath $JsonFile)) {
        return [PSCustomObject]@{ Status = "JSON_NOT_FOUND"; ExitCode = 2 }
    }
    if (-not (Test-Path -LiteralPath $SchemaFile)) {
        return [PSCustomObject]@{ Status = "SCHEMA_NOT_FOUND"; ExitCode = 3 }
    }

    try {
        $raw = Get-Content -LiteralPath $JsonFile -Raw
        if (-not ($raw | Test-Json)) {
            return [PSCustomObject]@{ Status = "INVALID_JSON"; ExitCode = 4 }
        }
        if ($raw | Test-Json -SchemaFile $SchemaFile) {
            return [PSCustomObject]@{ Status = "VALID"; ExitCode = 0 }
        }

        return [PSCustomObject]@{ Status = "INVALID"; ExitCode = 1 }
    }
    catch {
        return [PSCustomObject]@{ Status = "INVALID"; ExitCode = 1; Error = $_.Exception.Message }
    }
}

function Test-CeoEventFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventFile,
        [string] $StateRoot
    )

    $root = Get-CeoSuiteRoot
    $envelopeSchema = Join-Path $root "contracts\schemas\event-envelope.schema.json"
    $mapFile = Join-Path $root "contracts\contract-map.json"

    if (-not (Test-Path -LiteralPath $EventFile)) {
        return [PSCustomObject]@{ Status = "EVENT_NOT_FOUND"; ExitCode = 8 }
    }
    if (-not (Test-Path -LiteralPath $envelopeSchema)) {
        return [PSCustomObject]@{ Status = "ENVELOPE_SCHEMA_NOT_FOUND"; ExitCode = 10 }
    }
    if (-not (Test-Path -LiteralPath $mapFile)) {
        return [PSCustomObject]@{ Status = "CONTRACT_MAP_NOT_FOUND"; ExitCode = 11 }
    }

    try {
        $eventRaw = Get-Content -LiteralPath $EventFile -Raw
        if (-not ($eventRaw | Test-Json)) {
            return [PSCustomObject]@{ Status = "INVALID_JSON"; ExitCode = 9 }
        }

        $eventObj = $eventRaw | ConvertFrom-Json
        if (-not ($eventRaw | Test-Json -SchemaFile $envelopeSchema)) {
            return [PSCustomObject]@{ Status = "INVALID_ENVELOPE"; ExitCode = 10 }
        }

        $typeProp = $eventObj.PSObject.Properties["type"]
        if (-not $typeProp) {
            return [PSCustomObject]@{ Status = "INVALID_ENVELOPE"; ExitCode = 10 }
        }

        $eventType = [string] $typeProp.Value
        $discipline = Test-CeoExecutionDiscipline -Event $eventObj
        if (-not $discipline.IsValid) {
            return [PSCustomObject]@{ Status = "INVALID_EXECUTION_DISCIPLINE"; ExitCode = 15; EventType = $eventType; Issues = @($discipline.Issues) }
        }

        $map = Get-Content -LiteralPath $mapFile -Raw | ConvertFrom-Json
        $schemaProp = $map.payloadSchemas.PSObject.Properties[$eventType]
        if (-not $schemaProp) {
            return [PSCustomObject]@{ Status = "NO_PAYLOAD_SCHEMA_FOR_TYPE"; ExitCode = 11; EventType = $eventType }
        }

        $payloadSchema = Resolve-CeoSuitePath -Path ([string] $schemaProp.Value)
        if (-not (Test-Path -LiteralPath $payloadSchema)) {
            return [PSCustomObject]@{ Status = "PAYLOAD_SCHEMA_NOT_FOUND"; ExitCode = 12; EventType = $eventType }
        }

        $tempPayload = New-CeoSuiteTempFile -StateRoot $StateRoot -Prefix "payload"
        try {
            $eventObj.payload | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $tempPayload -Encoding UTF8
            $payloadResult = Test-CeoJsonFileAgainstSchema -JsonFile $tempPayload -SchemaFile $payloadSchema
            if ($payloadResult.Status -eq "VALID") {
                return [PSCustomObject]@{ Status = "VALID_EVENT"; ExitCode = 0; EventType = $eventType }
            }

            return [PSCustomObject]@{ Status = "INVALID_PAYLOAD"; ExitCode = 13; EventType = $eventType }
        }
        finally {
            Remove-Item -LiteralPath $tempPayload -ErrorAction SilentlyContinue
        }
    }
    catch {
        return [PSCustomObject]@{ Status = "INVALID_EVENT_ERROR"; ExitCode = 14; Error = $_.Exception.Message }
    }
}

function Get-CeoDefaultGovernance {
    param(
        [string] $Agent = "bus_agent",
        [string] $Tool = "ceo-event-publish.ps1",
        [string] $Evidence = "<RUNTIME_PATH>/bus/queue.jsonl",
        [string] $Validator = "ceo-validate-event.ps1",
        [string] $StopCondition = "invalid event rejected fail-closed",
        [string] $Recipe = "agentes-atomicos-algoritmicos-en-waves"
    )

    return [ordered]@{
        agent = $Agent
        skill = "repo-agent-tool-governance"
        recipe = $Recipe
        tool = $Tool
        evidence = $Evidence
        validator = $Validator
        stopCondition = $StopCondition
        authorityLevel = "local-only"
    }
}

function Test-CeoGovernanceObject {
    param(
        [Parameter(Mandatory = $true)]
        $Governance,
        [string] $Prefix = "governance"
    )

    $issues = @()
    foreach ($field in @("agent", "skill", "recipe", "tool", "evidence", "validator", "stopCondition")) {
        $value = [string] (Get-CeoObjectPropertyValue -InputObject $Governance -Name $field -Default "")
        if ([string]::IsNullOrWhiteSpace($value)) {
            $issues += "${Prefix}:missing-$field"
        }
    }

    return @($issues)
}

function Test-CeoAgentDiscipline {
    param(
        [Parameter(Mandatory = $true)]
        $Agent,
        [string] $Prefix = "agent"
    )

    $issues = @()
    foreach ($field in @("agentId", "owner", "surface", "skill", "recipe", "tool", "evidence", "validator", "stopCondition")) {
        $value = [string] (Get-CeoObjectPropertyValue -InputObject $Agent -Name $field -Default "")
        if ([string]::IsNullOrWhiteSpace($value)) {
            $issues += "${Prefix}:missing-$field"
        }
    }

    foreach ($field in @("allowedActions", "blockedActions")) {
        $value = @(Get-CeoObjectPropertyValue -InputObject $Agent -Name $field -Default @())
        if ($value.Count -eq 0) {
            $issues += "${Prefix}:missing-$field"
        }
    }

    return @($issues)
}

function Test-CeoExecutionDiscipline {
    param(
        [Parameter(Mandatory = $true)]
        $Event
    )

    $issues = @()
    $metadata = Get-CeoObjectPropertyValue -InputObject $Event -Name "metadata" -Default $null
    $governance = Get-CeoObjectPropertyValue -InputObject $metadata -Name "governance" -Default $null
    $issues += Test-CeoGovernanceObject -Governance $governance -Prefix "event-governance"

    $governanceAgentId = [string] (Get-CeoObjectPropertyValue -InputObject $governance -Name "agent" -Default "")
    if (-not [string]::IsNullOrWhiteSpace($governanceAgentId)) {
        try {
            $governanceAgent = Get-CeoAgentDefinition -AgentId $governanceAgentId
            $issues += Test-CeoAgentDiscipline -Agent $governanceAgent -Prefix "event-agent:$governanceAgentId"
        }
        catch {
            $issues += "event-governance:unknown-agent:$governanceAgentId"
        }
    }

    $executionSurface = Get-CeoObjectPropertyValue -InputObject $Event -Name "executionSurface" -Default $null
    if ($null -eq $executionSurface) {
        $issues += "executionSurface:missing"
    }
    else {
        if ([bool] (Get-CeoObjectPropertyValue -InputObject $executionSurface -Name "liveWrite" -Default $true)) {
            $issues += "executionSurface:liveWrite-not-false"
        }
        if ([bool] (Get-CeoObjectPropertyValue -InputObject $executionSurface -Name "secretAccess" -Default $true)) {
            $issues += "executionSurface:secretAccess-not-false"
        }
    }

    $eventType = [string] (Get-CeoObjectPropertyValue -InputObject $Event -Name "type" -Default "")
    $route = @(Get-CeoAgentRoute -EventType $eventType)
    if ($route.Count -eq 0) {
        $issues += "route:missing:$eventType"
    }

    foreach ($routeItem in $route) {
        $agentId = [string] (Get-CeoObjectPropertyValue -InputObject $routeItem -Name "agentId" -Default "")
        if ([string]::IsNullOrWhiteSpace($agentId)) {
            $issues += "route:missing-agentId:$eventType"
            continue
        }
        try {
            $agent = Get-CeoAgentDefinition -AgentId $agentId
            $issues += Test-CeoAgentDiscipline -Agent $agent -Prefix "route-agent:${eventType}:$agentId"
        }
        catch {
            $issues += "route:unknown-agent:${eventType}:$agentId"
        }
    }

    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        Issues = @($issues)
    }
}

function Test-CeoEnvironmentGate {
    param(
        [string] $ContractFile,
        [string] $SchemaFile
    )

    $root = Get-CeoSuiteRoot
    if ([string]::IsNullOrWhiteSpace($ContractFile)) {
        $ContractFile = Join-Path $root "contracts\environment-contract.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($ContractFile)) {
        $ContractFile = Join-Path $root $ContractFile
    }

    if ([string]::IsNullOrWhiteSpace($SchemaFile)) {
        $SchemaFile = Join-Path $root "contracts\schemas\environment-contract.schema.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($SchemaFile)) {
        $SchemaFile = Join-Path $root $SchemaFile
    }

    $issues = @()
    $schemaResult = Test-CeoJsonFileAgainstSchema -JsonFile $ContractFile -SchemaFile $SchemaFile
    if ($schemaResult.Status -ne "VALID") {
        $issues += "environment-contract:schema:$($schemaResult.Status)"
        return [PSCustomObject]@{
            IsValid = $false
            Status = "DEGRADED"
            ContractId = ""
            Signals = @()
            Issues = @($issues)
            SensitiveContentRead = $false
        }
    }

    $contract = Get-Content -LiteralPath $ContractFile -Raw | ConvertFrom-Json
    $signals = @()
    $processEnv = [Environment]::GetEnvironmentVariables("Process")
    $repoRoot = [System.IO.Path]::GetFullPath($root)

    foreach ($variable in @($contract.requiredVariables)) {
        $name = [string] $variable.name
        $present = $processEnv.Contains($name)
        $status = "PASS"
        $evidence = "presence=$present"

        if ([bool] $variable.required -and -not $present) {
            $status = "FAIL"
            $issues += "required-env-missing:$name"
        }
        elseif ($name -eq "CEO_SUITE_STATE_ROOT" -and $present) {
            $candidate = [string] $processEnv[$name]
            try {
                $resolved = Resolve-CeoSuitePath -Path $candidate
                if (-not $resolved.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $status = "FAIL"
                    $evidence = "presence=true;repoScoped=false"
                    $issues += "env-outside-repo:$name"
                }
                else {
                    $evidence = "presence=true;repoScoped=true"
                }
            }
            catch {
                $status = "FAIL"
                $evidence = "presence=true;resolve=failed"
                $issues += "env-resolve-failed:$name"
            }
        }

        $signals += [ordered]@{
            name = "env:$name"
            status = $status
            evidence = $evidence
        }
    }

    foreach ($name in @($contract.forbiddenVariables)) {
        $present = $processEnv.Contains([string] $name)
        if ($present) {
            $issues += "forbidden-env-present:$name"
        }
        $signals += [ordered]@{
            name = "forbidden-env:$name"
            status = if ($present) { "FAIL" } else { "PASS" }
            evidence = "presence=$present;value=not-read"
        }
    }

    $status = if ($issues.Count -gt 0) { "DEGRADED" } else { "STABLE" }
    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        Status = $status
        ContractId = [string] $contract.contractId
        Signals = @($signals)
        Issues = @($issues)
        SensitiveContentRead = $false
    }
}

function Test-CeoFederationGate {
    param(
        [string] $FederationFile,
        [string] $SchemaFile
    )

    $root = Get-CeoSuiteRoot
    if ([string]::IsNullOrWhiteSpace($FederationFile)) {
        $FederationFile = Join-Path $root "contracts\federation-map.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($FederationFile)) {
        $FederationFile = Join-Path $root $FederationFile
    }

    if ([string]::IsNullOrWhiteSpace($SchemaFile)) {
        $SchemaFile = Join-Path $root "contracts\schemas\federation-map.schema.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($SchemaFile)) {
        $SchemaFile = Join-Path $root $SchemaFile
    }

    $issues = @()
    $schemaResult = Test-CeoJsonFileAgainstSchema -JsonFile $FederationFile -SchemaFile $SchemaFile
    if ($schemaResult.Status -ne "VALID") {
        $issues += "federation-map:schema:$($schemaResult.Status)"
        return [PSCustomObject]@{
            IsValid = $false
            FederationId = ""
            Issues = @($issues)
        }
    }

    $map = Get-Content -LiteralPath $FederationFile -Raw | ConvertFrom-Json
    $activeCanonical = @{}
    $repoRoot = [System.IO.Path]::GetFullPath($root)
    $hasCoreRepo = $false

    foreach ($repo in @($map.repos)) {
        if ([string] $repo.status -ne "active") {
            continue
        }

        $canonical = [string] $repo.canonicalPath
        if ($activeCanonical.ContainsKey($canonical)) {
            $issues += "duplicate-active-canonical:$canonical"
        }
        else {
            $activeCanonical[$canonical] = $true
        }

        if ([string] $repo.repoId -eq "project-cdx") {
            $hasCoreRepo = $true
            $resolvedCanonical = [System.IO.Path]::GetFullPath($canonical)
            if (-not $resolvedCanonical.Equals($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $issues += "core-repo-canonical-mismatch:$canonical"
            }
        }

        foreach ($contract in @($repo.contracts)) {
            $contractPath = Resolve-CeoSuitePath -Path ([string] $contract)
            if (-not $contractPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $issues += "contract-outside-repo:$contract"
            }
            elseif (-not (Test-Path -LiteralPath $contractPath)) {
                $issues += "contract-missing:$contract"
            }
        }

        $environmentContract = [string] (Get-CeoObjectPropertyValue -InputObject $repo -Name "environmentContract" -Default "")
        if ([string]::IsNullOrWhiteSpace($environmentContract)) {
            $issues += "environment-contract-missing:$($repo.repoId)"
        }
        else {
            $environmentContractPath = Resolve-CeoSuitePath -Path $environmentContract
            if (-not $environmentContractPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $issues += "environment-contract-outside-repo:$environmentContract"
            }
            elseif (-not (Test-Path -LiteralPath $environmentContractPath)) {
                $issues += "environment-contract-not-found:$environmentContract"
            }
        }
    }

    if (-not $hasCoreRepo) {
        $issues += "active-core-repo-missing:project-cdx"
    }

    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        FederationId = [string] $map.federationId
        Issues = @($issues)
    }
}

function Test-CeoPathSanitizerGate {
    param(
        [string] $StateRoot
    )

    $root = [System.IO.Path]::GetFullPath((Get-CeoSuiteRoot))
    $issues = @()
    $signals = @()

    $rootDrive = [System.IO.Path]::GetPathRoot($root)
    if ($rootDrive -and $rootDrive.Equals("D:\", [System.StringComparison]::OrdinalIgnoreCase)) {
        $issues += "repo-root-on-disallowed-drive:$root"
        $signals += [PSCustomObject]@{ name = "repo-root-drive"; status = "BLOCK"; evidence = $root }
    }
    else {
        $signals += [PSCustomObject]@{ name = "repo-root-drive"; status = "PASS"; evidence = $root }
    }

    try {
        $resolvedState = Get-CeoSuiteStateRoot -StateRoot $StateRoot
        $stateDrive = [System.IO.Path]::GetPathRoot($resolvedState)
        if ($stateDrive -and $stateDrive.Equals("D:\", [System.StringComparison]::OrdinalIgnoreCase)) {
            $issues += "state-root-on-disallowed-drive:$resolvedState"
            $signals += [PSCustomObject]@{ name = "state-root-drive"; status = "BLOCK"; evidence = $resolvedState }
        }
        else {
            $signals += [PSCustomObject]@{ name = "state-root-drive"; status = "PASS"; evidence = $resolvedState }
        }
    }
    catch {
        $issues += $_.Exception.Message
        $signals += [PSCustomObject]@{ name = "state-root"; status = "BLOCK"; evidence = $_.Exception.Message }
    }

    $rootItem = Get-Item -LiteralPath $root -Force
    $isJunction = (($rootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
    $federationFile = Join-Path $root "contracts\federation-map.json"
    $junctionDeclared = $false
    $canonicalMatch = $false
    $duplicateDetected = $false
    $activeCanonicals = @{}

    if (Test-Path -LiteralPath $federationFile) {
        $federation = Get-Content -LiteralPath $federationFile -Raw | ConvertFrom-Json
        foreach ($repo in @($federation.repos)) {
            if ([string] $repo.status -ne "active") {
                continue
            }

            $canonical = [string] $repo.canonicalPath
            if ($activeCanonicals.ContainsKey($canonical)) {
                $duplicateDetected = $true
                $issues += "duplicate-active-canonical:$canonical"
            }
            else {
                $activeCanonicals[$canonical] = $true
            }

            $canonicalDrive = [System.IO.Path]::GetPathRoot($canonical)
            if ($canonicalDrive -and $canonicalDrive.Equals("D:\", [System.StringComparison]::OrdinalIgnoreCase)) {
                $issues += "federation-canonical-on-disallowed-drive:$canonical"
            }

            if ([string] $repo.repoId -eq "project-cdx") {
                $canonicalMatch = ([System.IO.Path]::GetFullPath($canonical)).Equals($root, [System.StringComparison]::OrdinalIgnoreCase)
                $physicalAlias = [string] (Get-CeoObjectPropertyValue -InputObject $repo -Name "physicalAlias" -Default "")
                $junctionDeclared = ($isJunction -and -not [string]::IsNullOrWhiteSpace($physicalAlias))
                if (-not $canonicalMatch) {
                    $issues += "project-cdx-canonical-mismatch:$canonical"
                }
            }
        }
    }
    else {
        $issues += "federation-map-not-found"
    }

    $junctionStatus = if ($isJunction -and -not $junctionDeclared) { "BLOCK" } elseif ($isJunction) { "OBSERVED" } else { "PASS" }
    if ($isJunction -and -not $junctionDeclared) {
        $issues += "undeclared-junction-root:$root"
    }
    $signals += [PSCustomObject]@{ name = "junction-root"; status = $junctionStatus; evidence = $root }
    $signals += [PSCustomObject]@{ name = "federation-canonical"; status = if ($canonicalMatch) { "PASS" } else { "BLOCK" }; evidence = $root }
    $signals += [PSCustomObject]@{ name = "active-canonical-duplicates"; status = if ($duplicateDetected) { "BLOCK" } else { "PASS" }; evidence = "$($activeCanonicals.Count)" }

    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        Status = if ($issues.Count -eq 0) { "PATH_SANITIZER_PASS" } else { "SANITIZE_REQUIRED" }
        Issues = @($issues)
        Signals = @($signals)
    }
}

function Get-CeoCanonicalRootMap {
    $root = [System.IO.Path]::GetFullPath((Get-CeoSuiteRoot))
    $canonicalRoot = $root
    $physicalAlias = $null
    $federationFile = Join-Path $root "contracts\federation-map.json"

    if (Test-Path -LiteralPath $federationFile) {
        try {
            $federation = Get-Content -LiteralPath $federationFile -Raw | ConvertFrom-Json
            $coreRepo = @($federation.repos | Where-Object { [string] $_.repoId -eq "project-cdx" } | Select-Object -First 1)
            if ($coreRepo.Count -gt 0) {
                $canonicalRoot = [System.IO.Path]::GetFullPath([string] $coreRepo[0].canonicalPath)
                $physicalAliasValue = [string] (Get-CeoObjectPropertyValue -InputObject $coreRepo[0] -Name "physicalAlias" -Default "")
                if (-not [string]::IsNullOrWhiteSpace($physicalAliasValue)) {
                    $physicalAlias = [System.IO.Path]::GetFullPath($physicalAliasValue)
                }
            }
        }
        catch {
        }
    }

    $aliases = @($root)
    if ($physicalAlias) {
        $aliases += $physicalAlias
    }
    $aliases = @($aliases | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

    return [PSCustomObject]@{
        RepoId = "project-cdx"
        CanonicalRoot = $canonicalRoot
        PhysicalAlias = $physicalAlias
        Aliases = @($aliases)
    }
}

function ConvertTo-CeoCanonicalPathString {
    param(
        [string] $Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Path
    }

    $map = Get-CeoCanonicalRootMap
    $candidate = $Path.Replace("/", "\")
    foreach ($alias in @($map.Aliases)) {
        $normalizedAlias = ([string] $alias).Replace("/", "\")
        if ($candidate.Equals($normalizedAlias, [System.StringComparison]::OrdinalIgnoreCase)) {
            return [string] $map.CanonicalRoot
        }
        if ($candidate.StartsWith("$normalizedAlias\", [System.StringComparison]::OrdinalIgnoreCase)) {
            return "$($map.CanonicalRoot)$($candidate.Substring($normalizedAlias.Length))"
        }
    }

    return $candidate
}

function Test-CeoSnsGate {
    param(
        [string] $SnsFile,
        [string] $SchemaFile
    )

    $root = [System.IO.Path]::GetFullPath((Get-CeoSuiteRoot))
    if ([string]::IsNullOrWhiteSpace($SnsFile)) {
        $SnsFile = Join-Path $root "SYSTEM_NERVOUS_INDEX.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($SnsFile)) {
        $SnsFile = Join-Path $root $SnsFile
    }

    if ([string]::IsNullOrWhiteSpace($SchemaFile)) {
        $SchemaFile = Join-Path $root "contracts\schemas\system-nervous-index.schema.json"
    }
    elseif (-not [System.IO.Path]::IsPathRooted($SchemaFile)) {
        $SchemaFile = Join-Path $root $SchemaFile
    }

    $issues = @()
    if (-not (Test-Path -LiteralPath $SnsFile)) {
        $issues += "sns-root-file-missing:SYSTEM_NERVOUS_INDEX.json"
        return [PSCustomObject]@{ IsValid = $false; Status = "SNS_GATE_HELD"; SnsFile = $SnsFile; Issues = @($issues) }
    }

    $schemaResult = Test-CeoJsonFileAgainstSchema -JsonFile $SnsFile -SchemaFile $SchemaFile
    if ($schemaResult.Status -ne "VALID") {
        $issues += "sns-root-schema:$($schemaResult.Status)"
        return [PSCustomObject]@{ IsValid = $false; Status = "SNS_GATE_HELD"; SnsFile = $SnsFile; Issues = @($issues) }
    }

    $sns = Get-Content -LiteralPath $SnsFile -Raw | ConvertFrom-Json
    $agentMap = Get-CeoAgentMap
    $canonicalRoot = ConvertTo-CeoCanonicalPathString -Path ([string] $sns.canonicalRoot)
    if (-not $canonicalRoot.Equals($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $issues += "sns-canonical-root-mismatch:$canonicalRoot"
    }

    $snsAgents = @($sns.agents | ForEach-Object { [string] $_.agentId })
    foreach ($agentName in @($agentMap.agents.PSObject.Properties.Name)) {
        if ($agentName -notin $snsAgents) {
            $issues += "agent-missing-from-sns:$agentName"
        }
    }

    foreach ($routeName in @($agentMap.routes.PSObject.Properties.Name)) {
        foreach ($routeEntry in @(Get-CeoAgentRoute -EventType $routeName)) {
            if ([string] $routeEntry.agentId -notin $snsAgents) {
                $issues += "route-agent-missing-from-sns:${routeName}:$($routeEntry.agentId)"
            }
        }
    }

    foreach ($pathEntry in @($sns.paths)) {
        $canonicalPath = [string] (Get-CeoObjectPropertyValue -InputObject $pathEntry -Name "canonicalPath" -Default "")
        if ([string]::IsNullOrWhiteSpace($canonicalPath)) {
            $issues += "sns-path-empty:$((Get-CeoObjectPropertyValue -InputObject $pathEntry -Name "pathType" -Default "unknown"))"
            continue
        }
        $resolvedPath = ConvertTo-CeoCanonicalPathString -Path $canonicalPath
        if ([System.IO.Path]::IsPathRooted($resolvedPath) -and -not $resolvedPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            $issues += "sns-path-outside-canonical-root:$resolvedPath"
        }
    }

    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        Status = if ($issues.Count -eq 0) { "SNS_GATE_READY" } else { "SNS_GATE_HELD" }
        SnsFile = $SnsFile
        Issues = @($issues)
    }
}

function Test-CeoVsiExecutionContext {
    $root = [System.IO.Path]::GetFullPath((Get-CeoSuiteRoot))
    $current = [System.IO.Path]::GetFullPath((Get-Location).Path)
    $frontdoor = Join-Path $root ".cabina\SDU_RUNTIME_ROOT\00_START_HERE\CAPABILITY_FRONTDOOR.md"
    $workspaceFile = Join-Path $root "CEO_CONTROL_PLANE.code-workspace"
    $tasksFile = Join-Path $root ".vscode\tasks.json"
    $canvasRoot = Join-Path $root ".agileagentcanvas-context"
    $issues = @()
    $signals = @()

    if ($current.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $signals += [PSCustomObject]@{ name = "current-location"; status = "PASS"; evidence = $current }
    }
    else {
        $issues += "current-location-outside-repo:$current"
        $signals += [PSCustomObject]@{ name = "current-location"; status = "BLOCK"; evidence = $current }
    }

    $codeInsiders = Get-Command code-insiders -ErrorAction SilentlyContinue
    if ($codeInsiders) {
        $signals += [PSCustomObject]@{ name = "code-insiders-cli"; status = "PASS"; evidence = [string] $codeInsiders.Source }
    }
    else {
        $issues += "code-insiders-cli-not-found"
        $signals += [PSCustomObject]@{ name = "code-insiders-cli"; status = "BLOCK"; evidence = "not-found" }
    }

    if (Test-Path -LiteralPath $frontdoor) {
        $signals += [PSCustomObject]@{ name = "capability-frontdoor"; status = "PASS"; evidence = $frontdoor }
    }
    else {
        $issues += "capability-frontdoor-not-found"
        $signals += [PSCustomObject]@{ name = "capability-frontdoor"; status = "BLOCK"; evidence = $frontdoor }
    }

    if (Test-Path -LiteralPath $workspaceFile) {
        $signals += [PSCustomObject]@{ name = "vsi-control-plane-workspace"; status = "PASS"; evidence = $workspaceFile }
    }
    else {
        $issues += "vsi-control-plane-workspace-not-found"
        $signals += [PSCustomObject]@{ name = "vsi-control-plane-workspace"; status = "BLOCK"; evidence = $workspaceFile }
    }

    if (Test-Path -LiteralPath $tasksFile) {
        $signals += [PSCustomObject]@{ name = "vsi-governance-tasks"; status = "PASS"; evidence = $tasksFile }
    }
    else {
        $issues += "vsi-governance-tasks-not-found"
        $signals += [PSCustomObject]@{ name = "vsi-governance-tasks"; status = "BLOCK"; evidence = $tasksFile }
    }

    if (Test-Path -LiteralPath $canvasRoot) {
        $signals += [PSCustomObject]@{ name = "agile-agent-canvas"; status = "PASS"; evidence = $canvasRoot }
    }
    else {
        $issues += "agile-agent-canvas-not-found"
        $signals += [PSCustomObject]@{ name = "agile-agent-canvas"; status = "BLOCK"; evidence = $canvasRoot }
    }

    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        Status = if ($issues.Count -eq 0) { "VSI_CONTEXT_VALID" } else { "VSI_CONTEXT_HELD" }
        Issues = @($issues)
        Signals = @($signals)
    }
}

function Test-CeoActiveGovernancePreflight {
    $federation = Test-CeoFederationGate
    $environment = Test-CeoEnvironmentGate
    $pathSanitizer = Test-CeoPathSanitizerGate
    $sns = Test-CeoSnsGate
    $vsi = Test-CeoVsiExecutionContext
    $issues = @()
    if (-not $federation.IsValid) {
        $issues += @($federation.Issues)
    }
    if (-not $environment.IsValid) {
        $issues += @($environment.Issues)
    }
    if (-not $pathSanitizer.IsValid) {
        $issues += @($pathSanitizer.Issues)
    }
    if (-not $sns.IsValid) {
        $issues += @($sns.Issues)
    }
    if (-not $vsi.IsValid) {
        $issues += @($vsi.Issues)
    }

    return [PSCustomObject]@{
        IsValid = ($issues.Count -eq 0)
        Status = if ($issues.Count -eq 0) { "ACTIVE_GOVERNANCE_READY" } else { "ACTIVE_GOVERNANCE_HELD" }
        Federation = $federation
        Environment = $environment
        PathSanitizer = $pathSanitizer
        Sns = $sns
        VsiExecutionGuard = $vsi
        Issues = @($issues)
    }
}

function Get-CeoExecutionAdapter {
    param(
        [string] $AdapterId = "local"
    )

    $root = Get-CeoSuiteRoot
    $adapterFile = Join-Path $root (Join-Path "adapters" (Join-Path $AdapterId "adapter.json"))
    if (-not (Test-Path -LiteralPath $adapterFile)) {
        throw "EXECUTION_ADAPTER_NOT_FOUND:$AdapterId"
    }

    return (Get-Content -LiteralPath $adapterFile -Raw | ConvertFrom-Json)
}

function Get-CeoExecutionSurface {
    param(
        [string] $AdapterId = "local",
        [string] $DecisionEngine = "ceo-decision-engine",
        [string] $RuntimeRouter = "ceo-runtime-router.ps1",
        [string] $ExecutionAdapter = "ceo-execution-adapter.ps1"
    )

    $adapter = Get-CeoExecutionAdapter -AdapterId $AdapterId
    return [ordered]@{
        surfaceId = [string] $adapter.executionSurface
        adapterId = [string] $adapter.adapterId
        decisionEngine = $DecisionEngine
        runtimeRouter = $RuntimeRouter
        executionAdapter = $ExecutionAdapter
        executionPath = @($DecisionEngine, $RuntimeRouter, $ExecutionAdapter, [string] $adapter.adapterId)
        mode = [string] $adapter.mode
        liveWrite = $false
        secretAccess = $false
    }
}

function Ensure-CeoExecutionSurface {
    param(
        [Parameter(Mandatory = $true)]
        $Event,
        [string] $AdapterId = "local"
    )

    if (-not $Event.PSObject.Properties["executionSurface"]) {
        Set-CeoObjectProperty -InputObject $Event -Name "executionSurface" -Value (Get-CeoExecutionSurface -AdapterId $AdapterId)
    }

    return $Event
}

function Get-CeoAgentDecisionResult {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DecisionType,
        [Parameter(Mandatory = $true)]
        [string] $EventType,
        [Parameter(Mandatory = $true)]
        $PolicyDecision
    )

    if (-not $PolicyDecision.allowed -or $PolicyDecision.requiresApproval) {
        return "HELD:$($PolicyDecision.action)"
    }

    switch ($DecisionType) {
        "validate" { return "VALIDATED:$EventType" }
        "contract-check" { return "CONTRACT_OK:$EventType" }
        "policy-gate" { return "POLICY_OK:$($EventType):$($PolicyDecision.action)" }
        "route" { return "ROUTED:$($EventType):$($PolicyDecision.action)" }
        "dispatch" { return "BUS_EVENT_ONLY:$EventType" }
        "observe" { return "OBSERVED:$EventType" }
        "record-evidence" { return "EVIDENCE_READY:$EventType" }
        "diagnose" { return "DIAGNOSED:$EventType" }
        "recommend" { return "RECOMMENDED:$EventType" }
        "sanitize-path" { return "PATH_SANITIZED:$EventType" }
        "enforce-federation" { return "FEDERATION_ENFORCED:$EventType" }
        "unify-sns" { return "SNS_UNIFIED:$EventType" }
        "guard-vsi" { return "VSI_GUARDED:$EventType" }
        "sync-control-plane" { return "CONTROL_PLANE_SYNCED:$EventType" }
        "follow-up" { return "FOLLOW_UP_PLANNED:$EventType" }
        default { return "DECISION:$($DecisionType):$($EventType)" }
    }
}

function Test-CeoAgentDecisionConflict {
    param(
        [Parameter(Mandatory = $true)]
        [array] $Decisions
    )

    $issues = @()
    $seenSequences = @{}

    foreach ($decision in @($Decisions)) {
        $sequence = [int] (Get-CeoObjectPropertyValue -InputObject $decision -Name "sequence" -Default 0)
        if ($sequence -lt 1) {
            $issues += "invalid-sequence:$sequence"
        }
        elseif ($seenSequences.ContainsKey($sequence)) {
            $issues += "duplicate-sequence:$sequence"
        }
        else {
            $seenSequences[$sequence] = $true
        }
    }

    $held = @($Decisions | Where-Object { ([string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "result" -Default "")) -match "HELD|HOLD|BLOCK|REJECT" })
    $activeAfterHold = @($Decisions | Where-Object {
        $decisionType = [string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "decisionType" -Default "")
        $result = [string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "result" -Default "")
        ($decisionType -in @("dispatch", "follow-up", "execute", "recommend")) -and ($result -notmatch "HELD|HOLD|BLOCK|REJECT")
    })
    if ($held.Count -gt 0 -and $activeAfterHold.Count -gt 0) {
        $issues += "active-decision-after-hold"
    }

    return [PSCustomObject]@{
        HasConflict = ($issues.Count -gt 0)
        Reasons = @($issues)
    }
}

function Resolve-CeoAgentDecisionOutcome {
    param(
        [Parameter(Mandatory = $true)]
        [array] $Decisions,
        [Parameter(Mandatory = $true)]
        $PolicyDecision,
        [Parameter(Mandatory = $true)]
        [string] $ChainStatus,
        [Parameter(Mandatory = $true)]
        $Conflict
    )

    $priorityRule = Get-CeoAgentPriorityRule
    $ordered = @($Decisions | Sort-Object @{ Expression = { [int] (Get-CeoObjectPropertyValue -InputObject $_ -Name "priority" -Default 99) } }, @{ Expression = { [int] (Get-CeoObjectPropertyValue -InputObject $_ -Name "sequence" -Default 99) } }, @{ Expression = { [string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "agentRole" -Default "") } })
    $lastBySequence = @($Decisions | Sort-Object @{ Expression = { [int] (Get-CeoObjectPropertyValue -InputObject $_ -Name "sequence" -Default 0) } } | Select-Object -Last 1)
    $selected = if ($ordered.Count -gt 0) { $ordered[0] } else { $null }
    $finalSelected = if ($lastBySequence.Count -gt 0) { $lastBySequence[0] } else { $selected }

    if ($ChainStatus -eq "NO_ROUTE") {
        return [ordered]@{
            conflictResolution = [ordered]@{
                status = "NO_ROUTE"
                strategy = "fail-closed"
                resolved = $true
                reason = "missing agent route"
                priorityRule = $priorityRule
                selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $selected -Name "agentRole" -Default $null)
                selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $selected -Name "decisionType" -Default $null)
                blockedFollowUps = $true
            }
            finalState = [ordered]@{
                status = "NO_ROUTE"
                result = "HOLD"
                reason = "missing agent route"
                selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $selected -Name "agentRole" -Default $null)
                selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $selected -Name "decisionType" -Default $null)
                selectedPriority = (Get-CeoObjectPropertyValue -InputObject $selected -Name "priority" -Default $null)
                stopCondition = "missing agent route"
            }
        }
    }

    if (-not $PolicyDecision.allowed -or $PolicyDecision.requiresApproval) {
        return [ordered]@{
            conflictResolution = [ordered]@{
                status = "POLICY_HELD"
                strategy = "policy-gate"
                resolved = $true
                reason = [string] $PolicyDecision.reason
                priorityRule = $priorityRule
                selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $selected -Name "agentRole" -Default $null)
                selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $selected -Name "decisionType" -Default $null)
                blockedFollowUps = $true
            }
            finalState = [ordered]@{
                status = "HOLD"
                result = "HOLD"
                reason = [string] $PolicyDecision.reason
                selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $selected -Name "agentRole" -Default $null)
                selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $selected -Name "decisionType" -Default $null)
                selectedPriority = (Get-CeoObjectPropertyValue -InputObject $selected -Name "priority" -Default $null)
                stopCondition = "policy gate hold"
            }
        }
    }

    if ([bool] $Conflict.HasConflict) {
        $reason = [string] (@($Conflict.Reasons) -join ";")
        return [ordered]@{
            conflictResolution = [ordered]@{
                status = "RESOLVED_FAIL_CLOSED"
                strategy = "agent-priority-then-sequence"
                resolved = $true
                reason = $reason
                priorityRule = $priorityRule
                selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $selected -Name "agentRole" -Default $null)
                selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $selected -Name "decisionType" -Default $null)
                blockedFollowUps = $true
            }
            finalState = [ordered]@{
                status = "CONFLICT_HELD"
                result = "HOLD"
                reason = "conflict resolved fail-closed:$reason"
                selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $selected -Name "agentRole" -Default $null)
                selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $selected -Name "decisionType" -Default $null)
                selectedPriority = (Get-CeoObjectPropertyValue -InputObject $selected -Name "priority" -Default $null)
                stopCondition = "conflict resolved fail-closed"
            }
        }
    }

    return [ordered]@{
        conflictResolution = [ordered]@{
            status = "NO_CONFLICT"
            strategy = "agent-priority-then-sequence"
            resolved = $true
            reason = "chain completed without incompatible decisions"
            priorityRule = $priorityRule
            selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $finalSelected -Name "agentRole" -Default $null)
            selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $finalSelected -Name "decisionType" -Default $null)
            blockedFollowUps = $false
        }
        finalState = [ordered]@{
            status = "COMPLETE"
            result = "ALLOW"
            reason = "chain completed without incompatible decisions"
            selectedAgentRole = (Get-CeoObjectPropertyValue -InputObject $finalSelected -Name "agentRole" -Default $null)
            selectedDecisionType = (Get-CeoObjectPropertyValue -InputObject $finalSelected -Name "decisionType" -Default $null)
            selectedPriority = (Get-CeoObjectPropertyValue -InputObject $finalSelected -Name "priority" -Default $null)
            stopCondition = "invalid event rejected fail-closed"
        }
    }
}

function New-CeoAgentFollowUpPlan {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType,
        [Parameter(Mandatory = $true)]
        [string] $Status,
        [string] $Reason
    )

    $plan = @()
    foreach ($spec in @(Get-CeoAgentFollowUpSpecs -EventType $EventType)) {
        $plan += [ordered]@{
            type = [string] (Get-CeoObjectPropertyValue -InputObject $spec -Name "type" -Default "")
            condition = [string] (Get-CeoObjectPropertyValue -InputObject $spec -Name "condition" -Default "always")
            priority = [string] (Get-CeoObjectPropertyValue -InputObject $spec -Name "priority" -Default "medium")
            decisionType = [string] (Get-CeoObjectPropertyValue -InputObject $spec -Name "decisionType" -Default "follow-up")
            status = $Status
            reason = $Reason
            emittedEventId = $null
        }
    }

    return @($plan)
}

function New-CeoAgentDecisionPayload {
    param(
        [Parameter(Mandatory = $true)]
        $SourceEvent,
        [Parameter(Mandatory = $true)]
        $PolicyDecision
    )

    $route = @(Get-CeoAgentRoute -EventType ([string] $SourceEvent.type))
    $chainId = Get-CeoAgentRouteChainId -EventType ([string] $SourceEvent.type)
    $executionSurface = Get-CeoObjectPropertyValue -InputObject $SourceEvent -Name "executionSurface" -Default (Get-CeoExecutionSurface)
    $now = (Get-Date).ToUniversalTime().ToString("o")
    $decisions = @()
    $parentSpanId = [string] $SourceEvent.spanId
    $holdReason = if (-not $PolicyDecision.allowed -or $PolicyDecision.requiresApproval) { [string] $PolicyDecision.reason } else { $null }

    foreach ($routeItem in $route) {
        $agent = Get-CeoAgentDefinition -AgentId ([string] $routeItem.agentId)
        $decisionSpanId = [guid]::NewGuid().ToString()
        $decisionResult = Get-CeoAgentDecisionResult -DecisionType ([string] $routeItem.decisionType) -EventType ([string] $SourceEvent.type) -PolicyDecision $PolicyDecision
        $decisions += [ordered]@{
            agentId = [string] $agent.agentId
            agentRole = [string] $routeItem.agentId
            sequence = [int] $routeItem.sequence
            priority = [int] $routeItem.priority
            decisionType = [string] $routeItem.decisionType
            executionSurface = [string] $executionSurface.surfaceId
            traceId = [string] $SourceEvent.traceId
            spanId = $decisionSpanId
            parentSpanId = $parentSpanId
            timestamp = $now
            result = $decisionResult
            tool = [string] $agent.tool
            evidence = [string] $agent.evidence
            validator = [string] $agent.validator
            stopCondition = [string] $agent.stopCondition
            holdReason = $holdReason
        }
        $parentSpanId = $decisionSpanId
    }

    if ($decisions.Count -eq 0) {
        $fallbackSpanId = [guid]::NewGuid().ToString()
        $decisions += [ordered]@{
            agentId = "orchestrator_agent"
            agentRole = "orchestrator_agent"
            sequence = 1
            priority = 1
            decisionType = "hold"
            executionSurface = [string] $executionSurface.surfaceId
            traceId = [string] $SourceEvent.traceId
            spanId = $fallbackSpanId
            parentSpanId = [string] $SourceEvent.spanId
            timestamp = $now
            result = "NO_ROUTE:$($SourceEvent.type)"
            tool = "ceo-runtime-router.ps1"
            evidence = "<RUNTIME_PATH>/bus/failed.jsonl"
            validator = "ceo-validate-event.ps1"
            stopCondition = "missing agent route"
            holdReason = "missing agent route"
        }
    }

    $conflict = Test-CeoAgentDecisionConflict -Decisions $decisions
    $chainStatus = if ($route.Count -eq 0) { "NO_ROUTE" } elseif ($conflict.HasConflict) { "CONFLICT" } elseif (-not $PolicyDecision.allowed -or $PolicyDecision.requiresApproval) { "HELD" } else { "COMPLETE" }
    $outcome = Resolve-CeoAgentDecisionOutcome -Decisions $decisions -PolicyDecision $PolicyDecision -ChainStatus $chainStatus -Conflict $conflict
    $result = switch ($chainStatus) {
        "NO_ROUTE" { "AGENT_DECISION_NO_ROUTE" }
        "CONFLICT" { "AGENT_DECISION_CONFLICT" }
        "HELD" { "AGENT_DECISION_HELD" }
        default { "AGENT_DECISION_CREATED" }
    }
    $followUpStatus = if ($chainStatus -eq "COMPLETE") { "planned" } else { "blocked" }
    $followUpReason = if ($chainStatus -eq "COMPLETE") { $null } else { $chainStatus }

    return [ordered]@{
        sourceEventId = [string] $SourceEvent.eventId
        sourceTraceId = [string] $SourceEvent.traceId
        sourceSpanId = [string] $SourceEvent.spanId
        sourceParentSpanId = (Get-CeoObjectPropertyValue -InputObject $SourceEvent -Name "parentSpanId" -Default $null)
        sourceType = [string] $SourceEvent.type
        chainId = $chainId
        chainStatus = $chainStatus
        result = $result
        execution = [ordered]@{
            decisionEngine = [string] $executionSurface.decisionEngine
            runtimeRouter = [string] $executionSurface.runtimeRouter
            executionAdapter = [string] $executionSurface.executionAdapter
            executionSurface = [string] $executionSurface.surfaceId
            executionPath = @($executionSurface.executionPath)
            adapterMode = [string] $executionSurface.mode
            liveWrite = [bool] $executionSurface.liveWrite
            secretAccess = [bool] $executionSurface.secretAccess
        }
        priorityRule = (Get-CeoAgentPriorityRule)
        policy = [ordered]@{
            allowed = [bool] $PolicyDecision.allowed
            action = [string] $PolicyDecision.action
            requiresApproval = [bool] $PolicyDecision.requiresApproval
            reason = [string] $PolicyDecision.reason
        }
        conflict = [bool] $conflict.HasConflict
        conflictReason = if ($conflict.HasConflict) { [string] (@($conflict.Reasons) -join ";") } else { $null }
        conflictResolution = $outcome.conflictResolution
        finalState = $outcome.finalState
        chainMemoryRef = [ordered]@{
            memoryKey = "$($SourceEvent.traceId):$($SourceEvent.eventId):$chainId"
            memoryFile = "<RUNTIME_PATH>/agents/chain-memory.jsonl"
        }
        followUpEvents = @(New-CeoAgentFollowUpPlan -EventType ([string] $SourceEvent.type) -Status $followUpStatus -Reason $followUpReason)
        agentDecisions = $decisions
    }
}

function New-CeoAgentDecisionEvent {
    param(
        [Parameter(Mandatory = $true)]
        $SourceEvent,
        [Parameter(Mandatory = $true)]
        $PolicyDecision
    )

    $payload = New-CeoAgentDecisionPayload -SourceEvent $SourceEvent -PolicyDecision $PolicyDecision
    $executionSurface = Get-CeoObjectPropertyValue -InputObject $SourceEvent -Name "executionSurface" -Default (Get-CeoExecutionSurface)

    return [ordered]@{
        eventId = [guid]::NewGuid().ToString()
        traceId = [string] $SourceEvent.traceId
        spanId = [guid]::NewGuid().ToString()
        parentSpanId = [string] $SourceEvent.spanId
        type = "AGENT_DECISION"
        domain = "agents"
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        status = "queued"
        priority = "medium"
        schemaVersion = "v1.0"
        executionSurface = $executionSurface
        payload = $payload
        metadata = [ordered]@{
            cabinaId = [string] $SourceEvent.metadata.cabinaId
            executionAdapterId = [string] (Get-CeoObjectPropertyValue -InputObject $executionSurface -Name "executionAdapter" -Default "ceo-execution-adapter.ps1")
            source = "ceo-runtime-router"
            governance = (Get-CeoDefaultGovernance -Agent "orchestrator_agent" -Tool "ceo-runtime-router.ps1" -Evidence "<RUNTIME_PATH>/bus/queue.jsonl" -Validator "ceo-validate-event.ps1")
        }
    }
}

function Get-CeoDomainForEventType {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType
    )

    switch ($EventType) {
        "RUNTIME_DRIFT" { return "runtime" }
        "VSCODE_DRIFT" { return "ide" }
        "ALERT_RAISED" { return "observability" }
        "SELF_HEAL_COMMAND" { return "healing" }
        "PREDICTIVE_SIGNAL" { return "predictive" }
        "OPTIMIZATION_COMMAND" { return "optimization" }
        "POLICY_DECISION" { return "policy" }
        "AGENT_DECISION" { return "agents" }
        "SANITIZATION_FINDING" { return "governance" }
        "RUNTIME_DIAGNOSIS" { return "diagnostic" }
        "SANITIZE_REQUIRED" { return "governance" }
        "FEDERATION_DRIFT" { return "governance" }
        "SNS_UNIFIED_INDEX" { return "governance" }
        "VSI_GUARD_RESULT" { return "ide" }
        "CONTROL_PLANE_SYNC" { return "governance" }
        default { return "event-bus" }
    }
}

function Test-CeoFollowUpCondition {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Condition,
        [Parameter(Mandatory = $true)]
        $SourceEvent
    )

    switch ($Condition) {
        "always" { return $true }
        "signal-not-stable" {
            if ([string] $SourceEvent.type -ne "PREDICTIVE_SIGNAL") {
                return $false
            }
            $signal = [string] (Get-CeoObjectPropertyValue -InputObject $SourceEvent.payload -Name "signal" -Default "NO_DATA")
            return ($signal -notin @("STABLE", "NO_DATA"))
        }
        default { return $false }
    }
}

function New-CeoFollowUpPayload {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType,
        [Parameter(Mandatory = $true)]
        $SourceEvent
    )

    switch ($EventType) {
        "OPTIMIZATION_COMMAND" {
            $signal = [string] (Get-CeoObjectPropertyValue -InputObject $SourceEvent.payload -Name "signal" -Default "NO_DATA")
            return [ordered]@{
                recommendation = "inspect-predictive-signal:$signal"
                scope = "event-bus"
                sensitiveMutation = $false
            }
        }
        default {
            return $null
        }
    }
}

function New-CeoFollowUpEvents {
    param(
        [Parameter(Mandatory = $true)]
        $SourceEvent,
        [Parameter(Mandatory = $true)]
        $DecisionEvent,
        [Parameter(Mandatory = $true)]
        $PolicyDecision
    )

    $events = @()
    $plans = @(Get-CeoObjectPropertyValue -InputObject $DecisionEvent.payload -Name "followUpEvents" -Default @())
    if ($plans.Count -eq 0) {
        return @()
    }

    if ([string] $SourceEvent.type -eq "AGENT_DECISION" -or [string] $DecisionEvent.payload.chainStatus -ne "COMPLETE" -or [bool] $DecisionEvent.payload.conflict -or -not $PolicyDecision.allowed -or $PolicyDecision.requiresApproval) {
        foreach ($plan in $plans) {
            Set-CeoObjectProperty -InputObject $plan -Name "status" -Value "blocked"
            Set-CeoObjectProperty -InputObject $plan -Name "reason" -Value "policy-or-chain-block"
            Set-CeoObjectProperty -InputObject $plan -Name "emittedEventId" -Value $null
        }
        return @()
    }

    foreach ($plan in $plans) {
        $condition = [string] (Get-CeoObjectPropertyValue -InputObject $plan -Name "condition" -Default "always")
        if (-not (Test-CeoFollowUpCondition -Condition $condition -SourceEvent $SourceEvent)) {
            Set-CeoObjectProperty -InputObject $plan -Name "status" -Value "skipped"
            Set-CeoObjectProperty -InputObject $plan -Name "reason" -Value "condition-not-met"
            Set-CeoObjectProperty -InputObject $plan -Name "emittedEventId" -Value $null
            continue
        }

        $eventType = [string] (Get-CeoObjectPropertyValue -InputObject $plan -Name "type" -Default "")
        $payload = New-CeoFollowUpPayload -EventType $eventType -SourceEvent $SourceEvent
        if ($null -eq $payload) {
            Set-CeoObjectProperty -InputObject $plan -Name "status" -Value "blocked"
            Set-CeoObjectProperty -InputObject $plan -Name "reason" -Value "unsupported-follow-up-type"
            Set-CeoObjectProperty -InputObject $plan -Name "emittedEventId" -Value $null
            continue
        }

        $eventId = [guid]::NewGuid().ToString()
        Set-CeoObjectProperty -InputObject $plan -Name "status" -Value "emitted"
        Set-CeoObjectProperty -InputObject $plan -Name "reason" -Value $null
        Set-CeoObjectProperty -InputObject $plan -Name "emittedEventId" -Value $eventId

        $events += [ordered]@{
            eventId = $eventId
            traceId = [string] $SourceEvent.traceId
            spanId = [guid]::NewGuid().ToString()
            parentSpanId = [string] $DecisionEvent.spanId
            type = $eventType
            domain = (Get-CeoDomainForEventType -EventType $eventType)
            timestamp = (Get-Date).ToUniversalTime().ToString("o")
            status = "queued"
            priority = [string] (Get-CeoObjectPropertyValue -InputObject $plan -Name "priority" -Default "medium")
            schemaVersion = "v1.0"
            executionSurface = (Get-CeoObjectPropertyValue -InputObject $SourceEvent -Name "executionSurface" -Default (Get-CeoExecutionSurface))
            payload = $payload
            metadata = [ordered]@{
                cabinaId = [string] $SourceEvent.metadata.cabinaId
                executionAdapterId = [string] (Get-CeoObjectPropertyValue -InputObject (Get-CeoObjectPropertyValue -InputObject $SourceEvent -Name "executionSurface" -Default (Get-CeoExecutionSurface)) -Name "executionAdapter" -Default "ceo-execution-adapter.ps1")
                source = "ceo-runtime-router"
                governance = (Get-CeoDefaultGovernance -Agent "orchestrator_agent" -Tool "ceo-runtime-router.ps1" -Evidence "<RUNTIME_PATH>/bus/queue.jsonl" -Validator "ceo-validate-event.ps1" -StopCondition "invalid follow-up rejected fail-closed")
            }
        }
    }

    return @($events)
}

function Add-CeoChainMemoryRecord {
    param(
        [Parameter(Mandatory = $true)]
        $SourceEvent,
        [Parameter(Mandatory = $true)]
        $DecisionEvent,
        [string] $StateRoot
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    $payload = $DecisionEvent.payload
    $record = [ordered]@{
        memoryId = [guid]::NewGuid().ToString()
        recordedAt = (Get-Date).ToUniversalTime().ToString("o")
        memoryKey = [string] $payload.chainMemoryRef.memoryKey
        traceId = [string] $SourceEvent.traceId
        sourceEventId = [string] $SourceEvent.eventId
        decisionEventId = [string] $DecisionEvent.eventId
        sourceType = [string] $SourceEvent.type
        chainId = [string] $payload.chainId
        chainStatus = [string] $payload.chainStatus
        priorityRule = [string] $payload.priorityRule
        conflict = [bool] $payload.conflict
        conflictReason = (Get-CeoObjectPropertyValue -InputObject $payload -Name "conflictReason" -Default $null)
        conflictResolution = $payload.conflictResolution
        finalState = $payload.finalState
        decisions = @($payload.agentDecisions | Sort-Object sequence | ForEach-Object {
            [ordered]@{
                sequence = [int] $_.sequence
                priority = [int] $_.priority
                agentRole = [string] $_.agentRole
                decisionType = [string] $_.decisionType
                result = [string] $_.result
                holdReason = (Get-CeoObjectPropertyValue -InputObject $_ -Name "holdReason" -Default $null)
            }
        })
        followUpEvents = @(Get-CeoObjectPropertyValue -InputObject $payload -Name "followUpEvents" -Default @())
    }

    Add-CeoJsonlLine -Path $state.ChainMemoryFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
    return [PSCustomObject]@{
        Status = "CHAIN_MEMORY_RECORDED"
        MemoryKey = [string] $payload.chainMemoryRef.memoryKey
        Path = $state.ChainMemoryFile
    }
}

function Get-CeoChainMemoryRecords {
    param(
        [string] $StateRoot
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    $records = @()
    foreach ($line in @(Get-CeoJsonlLines -Path $state.ChainMemoryFile)) {
        try {
            $records += ($line | ConvertFrom-Json)
        }
        catch {
        }
    }

    return @($records)
}

function Add-CeoValidatedEventToQueue {
    param(
        [Parameter(Mandatory = $true)]
        $Event,
        [string] $StateRoot,
        [string] $RejectReasonPrefix = "INVALID_GENERATED_EVENT"
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    $tempEvent = New-CeoSuiteTempFile -StateRoot $state.StateRoot -Prefix "generated-event"
    try {
        $Event | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $tempEvent -Encoding UTF8
        $validation = Test-CeoEventFile -EventFile $tempEvent -StateRoot $state.StateRoot
        $line = ConvertTo-CeoJsonLine -InputObject $Event
        if ($validation.Status -eq "VALID_EVENT") {
            Add-CeoJsonlLine -Path $state.QueueFile -Line $line
            return [PSCustomObject]@{ Status = "EVENT_QUEUED"; ExitCode = 0; EventType = $Event.type }
        }

        Add-CeoJsonlLine -Path $state.FailedFile -Line $line
        Add-Content -LiteralPath $state.InvalidLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] $RejectReasonPrefix type=$($Event.type) reason=$($validation.Status)" -Encoding UTF8
        return [PSCustomObject]@{ Status = "EVENT_REJECTED:$($validation.Status)"; ExitCode = 30; EventType = $Event.type }
    }
    finally {
        Remove-Item -LiteralPath $tempEvent -ErrorAction SilentlyContinue
    }
}

function Get-CeoPolicyDecision {
    param(
        [Parameter(Mandatory = $true)]
        [string] $EventType,
        [string] $StateRoot
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    $policy = Get-Content -LiteralPath $state.PolicyFile -Raw | ConvertFrom-Json
    $rule = $policy.policies.PSObject.Properties[$EventType]
    if ($rule) {
        $value = $rule.Value
    }
    else {
        $value = $policy.policies.UNKNOWN_EVENT
    }

    return [PSCustomObject]@{
        eventType = $EventType
        allowed = [bool] $value.allowed
        action = [string] $value.action
        requiresApproval = [bool] $value.requiresApproval
        reason = [string] $value.reason
    }
}

function Invoke-CeoEventDispatch {
    param(
        [Parameter(Mandatory = $true)]
        $Event,
        [string] $StateRoot
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    $record = [ordered]@{
        dispatchedAt = (Get-Date).ToUniversalTime().ToString("o")
        eventId = $Event.eventId
        traceId = $Event.traceId
        type = $Event.type
        action = "local-evidence-only"
    }

    switch ([string] $Event.type) {
        "ALERT_RAISED" {
            Add-CeoJsonlLine -Path $state.AlertFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:ALERT_RAISED"
        }
        "SELF_HEAL_COMMAND" {
            $record["action"] = "self-heal-local-noop"
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:SELF_HEAL_COMMAND"
        }
        "PREDICTIVE_SIGNAL" {
            $record["action"] = "predictive-observe"
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:PREDICTIVE_SIGNAL"
        }
        "OPTIMIZATION_COMMAND" {
            $record["action"] = "optimization-recommend"
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:OPTIMIZATION_COMMAND"
        }
        "POLICY_DECISION" {
            $record["action"] = "policy-observe"
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:POLICY_DECISION"
        }
        "AGENT_DECISION" {
            $record["action"] = "agent-decision-observe"
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:AGENT_DECISION"
        }
        "SANITIZATION_FINDING" {
            $record["action"] = "sanitization-finding-observe"
            Add-CeoJsonlLine -Path $state.SanitizationFindingFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:SANITIZATION_FINDING"
        }
        "RUNTIME_DIAGNOSIS" {
            $record["action"] = "runtime-diagnosis-observe"
            Add-CeoJsonlLine -Path $state.RuntimeDiagnosisFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:RUNTIME_DIAGNOSIS"
        }
        "SANITIZE_REQUIRED" {
            $record["action"] = "path-sanitizer-observe"
            Add-CeoJsonlLine -Path $state.PathSanitizerFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:SANITIZE_REQUIRED"
        }
        "FEDERATION_DRIFT" {
            $record["action"] = "federation-drift-observe"
            Add-CeoJsonlLine -Path $state.FederationDriftFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:FEDERATION_DRIFT"
        }
        "SNS_UNIFIED_INDEX" {
            $record["action"] = "sns-unified-index-observe"
            Add-CeoJsonlLine -Path $state.SnsEventFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:SNS_UNIFIED_INDEX"
        }
        "VSI_GUARD_RESULT" {
            $record["action"] = "vsi-guard-observe"
            Add-CeoJsonlLine -Path $state.VsiGuardFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:VSI_GUARD_RESULT"
        }
        "CONTROL_PLANE_SYNC" {
            $record["action"] = "control-plane-sync-observe"
            Add-CeoJsonlLine -Path $state.ControlPlaneSyncFile -Line (ConvertTo-CeoJsonLine -InputObject $Event.payload)
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:CONTROL_PLANE_SYNC"
        }
        default {
            Add-CeoJsonlLine -Path $state.DispatchFile -Line (ConvertTo-CeoJsonLine -InputObject $record)
            return "DISPATCHED:$($Event.type)"
        }
    }
}

function Get-CeoBusMetrics {
    param(
        [string] $StateRoot
    )

    $state = Initialize-CeoSuiteState -StateRoot $StateRoot
    $queue = @(Get-CeoJsonlLines -Path $state.QueueFile)
    $processed = @(Get-CeoJsonlLines -Path $state.ProcessedFile)
    $failedRaw = @(Get-CeoJsonlLines -Path $state.FailedFile)
    $invalid = @(Get-CeoJsonlLines -Path $state.InvalidLog)
    $processedIds = @{}

    foreach ($line in $processed) {
        try {
            $event = $line | ConvertFrom-Json
            if ($event.PSObject.Properties["eventId"]) {
                $processedIds[[string] $event.eventId] = $true
            }
        }
        catch {
        }
    }

    $failed = @()
    foreach ($line in $failedRaw) {
        try {
            $event = $line | ConvertFrom-Json
            if ($event.PSObject.Properties["eventId"] -and $processedIds.ContainsKey([string] $event.eventId)) {
                continue
            }
        }
        catch {
        }
        $failed += $line
    }

    return [PSCustomObject]@{
        queue = $queue.Count
        processed = $processed.Count
        failed = $failed.Count
        invalid = $invalid.Count
    }
}
