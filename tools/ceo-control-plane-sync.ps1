param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$canvasRoot = Join-Path $root ".agileagentcanvas-context"
$workspacePath = Join-Path $root "CEO_CONTROL_PLANE.code-workspace"
$tasksPath = Join-Path $root ".vscode\tasks.json"
$snsPath = Join-Path $root "SYSTEM_NERVOUS_INDEX.json"
$workflows = @()
$demoPatterns = @(
    "TaskFlow Pro",
    "taskflow",
    "@taskflow",
    "taskflowpro.com",
    "DATABASE_URL",
    "secrets.",
    "docker push",
    "aws ecs update-service"
)

function Get-CeoCanvasDemoDrift {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    $item = Get-Item -LiteralPath $Path
    $files = if ($item.PSIsContainer) {
        @(Get-ChildItem -LiteralPath $Path -Recurse -File -Filter "*.json" -ErrorAction SilentlyContinue)
    }
    else {
        @($item)
    }

    $matches = foreach ($file in $files) {
        Select-String -LiteralPath $file.FullName -Pattern $demoPatterns -SimpleMatch -ErrorAction SilentlyContinue
    }

    return @($matches)
}

foreach ($name in @("vision.json", "bmm", "cis", "discovery", "planning", "solutioning", "testing")) {
    $path = Join-Path $canvasRoot $name
    if (Test-Path -LiteralPath $path) {
        $count = if ((Get-Item -LiteralPath $path).PSIsContainer) {
            @(Get-ChildItem -LiteralPath $path -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
        }
        else {
            1
        }
        $demoDrift = @(Get-CeoCanvasDemoDrift -Path $path)
        $status = if ($count -le 0) { "DEGRADED" } elseif ($demoDrift.Count -gt 0) { "DEGRADED" } else { "READY" }
    }
    else {
        $status = "MISSING"
    }

    $workflows += [ordered]@{
        name = $name
        path = ".agileagentcanvas-context\$name"
        status = $status
    }
}

$canvasDemoDrift = @(Get-CeoCanvasDemoDrift -Path $canvasRoot)
$missing = @($workflows | Where-Object { [string] (Get-CeoObjectPropertyValue -InputObject $_ -Name "status" -Default "") -ne "READY" })
$controlPlaneMissing = (-not (Test-Path -LiteralPath $canvasRoot)) -or (-not (Test-Path -LiteralPath $workspacePath)) -or (-not (Test-Path -LiteralPath $snsPath))
$status = if ($controlPlaneMissing) { "HELD" } elseif ($canvasDemoDrift.Count -gt 0) { "HELD" } elseif ($missing.Count -gt 0) { "DEGRADED" } else { "READY" }
$agentMap = Get-CeoAgentMap
$contractMap = Get-CeoContractMap
$mappedSurfaces = @(
    "agents:$(@($agentMap.agents.PSObject.Properties.Name).Count)",
    "routes:$(@($agentMap.routes.PSObject.Properties.Name).Count)",
    "payloadSchemas:$(@($contractMap.payloadSchemas.PSObject.Properties.Name).Count)",
    "sns:SYSTEM_NERVOUS_INDEX.json",
    "vsi:CEO_CONTROL_PLANE.code-workspace",
    "runtime:tools\ceo-active-governance.ps1",
    "dashboard:<RUNTIME_PATH>\dashboard\data.json",
    "canvas:.agileagentcanvas-context",
    "demoQuarantine:$($canvasDemoDrift.Count)"
)
$dependencies = @(
    [ordered]@{ from = "VS Code Insiders"; to = "SYSTEM_NERVOUS_INDEX.json"; type = "requires"; status = if (Test-Path -LiteralPath $snsPath) { "READY" } else { "HELD" } },
    [ordered]@{ from = "VS Code Insiders"; to = "Agile Agent Canvas"; type = "controls"; status = if (Test-Path -LiteralPath $canvasRoot) { "READY" } else { "HELD" } },
    [ordered]@{ from = "Agile Agent Canvas"; to = "contracts\agent-map.json"; type = "maps"; status = "READY" },
    [ordered]@{ from = "Active Governance Runner"; to = "tools\ceo-active-governance.ps1"; type = "executes"; status = "READY" },
    [ordered]@{ from = "Dashboard"; to = "<RUNTIME_PATH>\dashboard\data.json"; type = "observes"; status = "READY" }
)
$orchestrationWorkflows = @(
    "CEO Final: Sync SNS",
    "CEO Final: Path Rewrite",
    "CEO Final: Control Plane Sync",
    "CEO Final: Active Governance"
)

$map = [ordered]@{
    schemaVersion = "v1.0"
    syncedAt = (Get-Date).ToUniversalTime().ToString("o")
    canvasRoot = ".agileagentcanvas-context"
    workspacePath = "CEO_CONTROL_PLANE.code-workspace"
    snsPath = "SYSTEM_NERVOUS_INDEX.json"
    agents = @($agentMap.agents.PSObject.Properties.Name)
    routes = @($agentMap.routes.PSObject.Properties.Name)
    contracts = @($contractMap.payloadSchemas.PSObject.Properties.Name)
    workflows = $workflows
    dependencies = $dependencies
    orchestrationWorkflows = $orchestrationWorkflows
    mappedSurfaces = $mappedSurfaces
    demoQuarantine = [ordered]@{
        status = if ($canvasDemoDrift.Count -eq 0) { "CLEAR" } else { "DEMO_CONTENT_DRIFT" }
        patternsDetected = $canvasDemoDrift.Count
        requiredAction = if ($canvasDemoDrift.Count -eq 0) { "none" } else { "replace demo canvas artifacts with PROJEC CDX governed local context" }
    }
    policy = [ordered]@{
        liveWrite = $false
        secretAccess = $false
        authority = "repo-local-control-plane"
    }
}
$map | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $state.AgileCanvasMapFile -Encoding UTF8

$payload = [ordered]@{
    syncId = [guid]::NewGuid().ToString()
    syncedAt = $map.syncedAt
    status = $status
    canvasRoot = ".agileagentcanvas-context"
    workspacePath = "CEO_CONTROL_PLANE.code-workspace"
    snsPath = "SYSTEM_NERVOUS_INDEX.json"
    workflows = $workflows
    dependencies = $dependencies
    orchestrationWorkflows = $orchestrationWorkflows
    mappedSurfaces = $mappedSurfaces
    recommendation = if ($status -eq "READY") { "use Agile Agent Canvas map as local control-plane view" } elseif ($canvasDemoDrift.Count -gt 0) { "hold Agile Agent Canvas until demo drift is removed or explicitly quarantined" } else { "hold or inspect missing canvas workflows before treating control plane as complete" }
    sensitiveContentDetected = $false
    liveWrite = $false
}

$event = [ordered]@{
    eventId = [guid]::NewGuid().ToString()
    traceId = [guid]::NewGuid().ToString()
    spanId = [guid]::NewGuid().ToString()
    parentSpanId = $null
    type = "CONTROL_PLANE_SYNC"
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
        source = "ceo-control-plane-sync"
        governance = (Get-CeoDefaultGovernance -Agent "control_plane_agent" -Tool "ceo-control-plane-sync.ps1" -Evidence "<RUNTIME_PATH>/control-plane/agile-agent-canvas-map.json" -Validator "run-integration-smoke.ps1" -StopCondition "control plane map missing or stale after sync")
    }
}

$result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_CONTROL_PLANE_SYNC"
if ($result.ExitCode -ne 0) {
    Write-Output "CONTROL_PLANE_SYNC_HELD:$($result.Status)"
    exit $result.ExitCode
}

if ($status -eq "HELD") {
    if ($canvasDemoDrift.Count -gt 0) {
        Write-Output "CONTROL_PLANE_SYNC_HELD:demo-content-drift=$($canvasDemoDrift.Count)"
    }
    else {
        Write-Output "CONTROL_PLANE_SYNC_HELD:canvas-root-missing"
    }
    exit 30
}

Write-Output "CONTROL_PLANE_SYNC_QUEUED:$status"
exit 0
