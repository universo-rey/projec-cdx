param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot

function Get-JsonIndexCount {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [PSCustomObject]@{ Count = 0; Status = "MISSING" }
    }

    try {
        $doc = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        if ($doc.PSObject.Properties["count"]) {
            return [PSCustomObject]@{ Count = [int] $doc.count; Status = "READY" }
        }
        if ($doc.PSObject.Properties["items"]) {
            return [PSCustomObject]@{ Count = @($doc.items).Count; Status = "READY" }
        }
        return [PSCustomObject]@{ Count = @($doc.PSObject.Properties).Count; Status = "READY" }
    }
    catch {
        return [PSCustomObject]@{ Count = 0; Status = "DEGRADED" }
    }
}

function Get-LocalNervousRootCount {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [PSCustomObject]@{ Count = 0; Status = "MISSING" }
    }

    try {
        $line = @(Get-Content -LiteralPath $Path | Where-Object { $_ -match "^\s*roots:\s*(\d+)" } | Select-Object -First 1)
        if ($line.Count -eq 0) {
            return [PSCustomObject]@{ Count = 0; Status = "DEGRADED" }
        }
        $count = [int] ([regex]::Match([string] $line[0], "(\d+)").Value)
        return [PSCustomObject]@{ Count = $count; Status = "READY" }
    }
    catch {
        return [PSCustomObject]@{ Count = 0; Status = "DEGRADED" }
    }
}

$rootIndexPath = Join-Path $root "index.json"
$operativaIndexPath = Join-Path $root "operativa\index.json"
$localNervousPath = Join-Path $root ".cabina\SDU_RUNTIME_ROOT\05_CONFIG\local-nervous-index.v1.yaml"
$workspacePath = Join-Path $root "CEO_CONTROL_PLANE.code-workspace"
$tasksPath = Join-Path $root ".vscode\tasks.json"
$canvasRoot = Join-Path $root ".agileagentcanvas-context"
$rootIndex = Get-JsonIndexCount -Path $rootIndexPath
$operativaIndex = Get-JsonIndexCount -Path $operativaIndexPath
$localNervous = Get-LocalNervousRootCount -Path $localNervousPath
$canonicalMap = Get-CeoCanonicalRootMap
$federation = Get-Content -LiteralPath (Join-Path $root "contracts\federation-map.json") -Raw | ConvertFrom-Json
$agentMap = Get-CeoAgentMap
$contractMap = Get-CeoContractMap
$physicalAliasPath = if ($canonicalMap.PhysicalAlias) { [string] $canonicalMap.PhysicalAlias } else { [string] $canonicalMap.CanonicalRoot }

$sources = @(
    [ordered]@{ name = "index.json"; path = "index.json"; count = [int] $rootIndex.Count; status = [string] $rootIndex.Status },
    [ordered]@{ name = "operativa/index.json"; path = "operativa\index.json"; count = [int] $operativaIndex.Count; status = [string] $operativaIndex.Status },
    [ordered]@{ name = "local-nervous-index"; path = ".cabina\SDU_RUNTIME_ROOT\05_CONFIG\local-nervous-index.v1.yaml"; count = [int] $localNervous.Count; status = [string] $localNervous.Status }
)
$issues = @($sources | Where-Object { [string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "status" -Default "") -ne "READY" } | ForEach-Object {
    "$((Get-CeoObjectPropertyValue -InputObject $_ -Name "name" -Default "source")):$((Get-CeoObjectPropertyValue -InputObject $_ -Name "status" -Default "UNKNOWN"))"
})
$status = if ($issues.Count -eq 0) { "READY" } else { "DEGRADED" }

$payload = [ordered]@{
    snsId = [guid]::NewGuid().ToString()
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    sourceOfTruth = "system-nervous-index"
    sources = $sources
    rootIndexCount = [int] $rootIndex.Count
    operativaIndexCount = [int] $operativaIndex.Count
    localNervousRoots = [int] $localNervous.Count
    status = $status
    issues = @($issues)
    outputPath = "SYSTEM_NERVOUS_INDEX.json"
    sensitiveContentDetected = $false
    liveWrite = $false
}

$paths = @(
    [ordered]@{ pathType = "canonical-root"; path = [string] $canonicalMap.CanonicalRoot; canonicalPath = [string] $canonicalMap.CanonicalRoot; status = "READY" },
    [ordered]@{ pathType = "physical-alias"; path = $physicalAliasPath; canonicalPath = (ConvertTo-CeoCanonicalPathString -Path $physicalAliasPath); status = if ($canonicalMap.PhysicalAlias) { "ALIAS_REWRITTEN" } else { "READY" } },
    [ordered]@{ pathType = "root-index"; path = "index.json"; canonicalPath = (Join-Path $root "index.json"); status = [string] $rootIndex.Status },
    [ordered]@{ pathType = "operativa-index"; path = "operativa\index.json"; canonicalPath = (Join-Path $root "operativa\index.json"); status = [string] $operativaIndex.Status },
    [ordered]@{ pathType = "local-nervous-index"; path = ".cabina\SDU_RUNTIME_ROOT\05_CONFIG\local-nervous-index.v1.yaml"; canonicalPath = (Join-Path $root ".cabina\SDU_RUNTIME_ROOT\05_CONFIG\local-nervous-index.v1.yaml"); status = [string] $localNervous.Status },
    [ordered]@{ pathType = "vsi-workspace"; path = "CEO_CONTROL_PLANE.code-workspace"; canonicalPath = $workspacePath; status = if (Test-Path -LiteralPath $workspacePath) { "READY" } else { "HELD" } },
    [ordered]@{ pathType = "vsi-tasks"; path = ".vscode\tasks.json"; canonicalPath = $tasksPath; status = if (Test-Path -LiteralPath $tasksPath) { "READY" } else { "HELD" } },
    [ordered]@{ pathType = "agile-agent-canvas"; path = ".agileagentcanvas-context"; canonicalPath = $canvasRoot; status = if (Test-Path -LiteralPath $canvasRoot) { "READY" } else { "HELD" } }
)
$agents = @()
foreach ($agentProperty in @($agentMap.agents.PSObject.Properties)) {
    $agent = $agentProperty.Value
    $agents += [ordered]@{
        agentId = [string] $agent.agentId
        owner = [string] $agent.owner
        surface = [string] $agent.surface
        tool = [string] $agent.tool
        evidence = [string] $agent.evidence
        validator = [string] $agent.validator
        stopCondition = [string] $agent.stopCondition
        status = "ACTIVE"
    }
}
$routes = @()
foreach ($routeName in @($agentMap.routes.PSObject.Properties.Name)) {
    $routes += [ordered]@{
        eventType = [string] $routeName
        chainId = (Get-CeoAgentRouteChainId -EventType $routeName)
        agents = @((Get-CeoAgentRoute -EventType $routeName) | ForEach-Object { [string] $_.agentId })
    }
}
$canvasWorkflows = @("vision.json", "bmm", "cis", "discovery", "planning", "solutioning", "testing")
$canvasStatus = if (Test-Path -LiteralPath $canvasRoot) { "READY" } else { "HELD" }
$vsiStatus = if ((Test-Path -LiteralPath $workspacePath) -and (Test-Path -LiteralPath $tasksPath)) { "READY" } else { "HELD" }
$dependencies = @(
    [ordered]@{ from = "VS Code Insiders"; to = "SYSTEM_NERVOUS_INDEX.json"; type = "requires"; status = if (Test-Path -LiteralPath $state.SnsRootFile) { "READY" } else { "HELD" } },
    [ordered]@{ from = "VS Code Insiders"; to = "Agile Agent Canvas"; type = "controls"; status = if (Test-Path -LiteralPath $canvasRoot) { "READY" } else { "HELD" } },
    [ordered]@{ from = "Active Governance Runner"; to = "SYSTEM_NERVOUS_INDEX.json"; type = "preflight"; status = "READY" },
    [ordered]@{ from = "Runtime Router"; to = "contracts\agent-map.json"; type = "routes"; status = "READY" },
    [ordered]@{ from = "Dashboard"; to = "<RUNTIME_PATH>\dashboard\data.json"; type = "observes"; status = "READY" }
)

$unifiedIndex = [ordered]@{
    schemaVersion = "v1.0"
    sourceOfTruth = "SYSTEM_NERVOUS_INDEX"
    generatedAt = $payload.generatedAt
    repoId = "project-cdx"
    canonicalRoot = [string] $canonicalMap.CanonicalRoot
    federationId = [string] $federation.federationId
    sources = $sources
    paths = $paths
    agents = $agents
    routes = $routes
    vsiControlPlane = [ordered]@{
        workspace = "CEO_CONTROL_PLANE.code-workspace"
        tasks = ".vscode\tasks.json"
        status = $vsiStatus
    }
    agileAgentCanvas = [ordered]@{
        root = ".agileagentcanvas-context"
        workflows = $canvasWorkflows
        status = $canvasStatus
    }
    dependencies = $dependencies
    policy = [ordered]@{
        failClosed = $true
        liveWrite = $false
        secretAccess = $false
        requiredForExecution = $true
    }
}
$unifiedIndex | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $state.SnsRootFile -Encoding UTF8

$event = [ordered]@{
    eventId = [guid]::NewGuid().ToString()
    traceId = [guid]::NewGuid().ToString()
    spanId = [guid]::NewGuid().ToString()
    parentSpanId = $null
    type = "SNS_UNIFIED_INDEX"
    domain = "governance"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    status = "queued"
    priority = if ($status -eq "READY") { "medium" } else { "high" }
    schemaVersion = "v1.0"
    executionSurface = (Get-CeoExecutionSurface -AdapterId "local")
    payload = $payload
    metadata = [ordered]@{
        cabinaId = "CABINA_LOCAL"
        executionAdapterId = "ceo-execution-adapter.ps1"
        source = "ceo-sns-unify"
        governance = (Get-CeoDefaultGovernance -Agent "sns_agent" -Tool "ceo-sns-unify.ps1" -Evidence "SYSTEM_NERVOUS_INDEX.json" -Validator "run-integration-smoke.ps1" -StopCondition "fragmented index used after SNS unification failure")
    }
}

$result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_SNS_UNIFIED_INDEX"
if ($result.ExitCode -ne 0) {
    Write-Output "SNS_UNIFY_HELD:$($result.Status)"
    exit $result.ExitCode
}

Write-Output "SNS_UNIFY_QUEUED:$status"
exit 0
