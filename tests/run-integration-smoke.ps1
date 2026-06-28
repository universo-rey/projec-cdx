Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

$root = Split-Path -Parent $PSScriptRoot
$tools = Join-Path $root "tools"
$examples = Join-Path $root "examples"
$schemas = Join-Path $root "contracts\schemas"
$testOutputRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testOutputRoot)) {
    $testOutputRoot = Join-Path ([System.IO.Path]::GetTempPath()) "sdu-test-output"
}
$stateRoot = Join-Path $testOutputRoot ("smoke-" + [guid]::NewGuid().ToString())
$dashboardOutput = $env:SDU_DASHBOARD_OUTPUT
if ([string]::IsNullOrWhiteSpace($dashboardOutput)) {
    $dashboardOutput = Join-Path $stateRoot "dashboard\data.json"
}
$pwsh = (Get-Command pwsh -ErrorAction Stop).Source

. (Join-Path $tools "ceo-suite-common.ps1")

$script:passes = 0
$script:fails = 0

function Invoke-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string] $File,
        [string[]] $Arguments = @()
    )

    $output = & $pwsh -NoProfile -ExecutionPolicy Bypass -File $File @Arguments 2>&1
    return [PSCustomObject]@{
        Output = @($output)
        Text = (@($output) -join "`n")
        ExitCode = $LASTEXITCODE
    }
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool] $Condition,
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [string] $Detail = ""
    )

    if ($Condition) {
        Write-Host "[PASS] $Name" -ForegroundColor Green
        $script:passes++
    }
    else {
        Write-Host "[FAIL] $Name $Detail" -ForegroundColor Red
        $script:fails++
    }
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]
        $Actual,
        [Parameter(Mandatory = $true)]
        $Expected,
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    Assert-True -Condition ($Actual -eq $Expected) -Name $Name -Detail "expected '$Expected' got '$Actual'"
}

try {
    $state = Initialize-CeoSuiteState -StateRoot $stateRoot
    $snsBootstrapRoot = Join-Path $testOutputRoot ("sns-bootstrap-" + [guid]::NewGuid().ToString())
    $snsBootstrap = Invoke-Tool -File (Join-Path $tools "ceo-sns-unify.ps1") -Arguments @("-StateRoot", $snsBootstrapRoot)
    Assert-True -Condition (($snsBootstrap.Text -like "*SNS_UNIFY_QUEUED:READY*") -and ($snsBootstrap.ExitCode -eq 0)) -Name "SNS root bootstraps before execution adapter" -Detail $snsBootstrap.Text

    $publish = Join-Path $tools "ceo-event-publish.ps1"
    $validPublish = Invoke-Tool -File $publish -Arguments @(
        "-Type", "RUNTIME_DRIFT",
        "-Domain", "runtime",
        "-Priority", "high",
        "-Payload", '{"runtimeStatus":"DRIFT","cabinaStatus":"READY","details":"smoke"}',
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($validPublish.Output | Select-Object -Last 1) -as [string]) -Expected "EVENT_QUEUED" -Name "valid event queued"
    Assert-Equal -Actual $validPublish.ExitCode -Expected 0 -Name "valid publish exit code"
    $queuedSourceEvents = @(Get-CeoJsonlLines -Path $state.QueueFile | ForEach-Object { $_ | ConvertFrom-Json })
    if ($queuedSourceEvents.Count -gt 0) {
        Assert-Equal -Actual ([string] $queuedSourceEvents[0].executionSurface.surfaceId) -Expected "local" -Name "published event declares local execution surface"
        Assert-Equal -Actual ([string] $queuedSourceEvents[0].executionSurface.decisionEngine) -Expected "ceo-decision-engine" -Name "published event declares decision engine"
        Assert-Equal -Actual ([string] $queuedSourceEvents[0].executionSurface.executionAdapter) -Expected "ceo-execution-adapter.ps1" -Name "published event declares execution adapter"
    }

    $invalidBypassLine = Get-Content -LiteralPath (Join-Path $examples "runtime-drift.invalid.event.json") -Raw
    $invalidBypassLine = ($invalidBypassLine | ConvertFrom-Json | ConvertTo-Json -Depth 30 -Compress)
    Add-CeoJsonlLine -Path $state.QueueFile -Line $invalidBypassLine

    $validateBus = Join-Path $tools "ceo-validate-bus.ps1"
    $busResult = Invoke-Tool -File $validateBus -Arguments @("-StateRoot", $stateRoot)
    Assert-Equal -Actual (($busResult.Output | Select-Object -Last 1) -as [string]) -Expected "BUS_INVALID:1" -Name "bus sanitizer rejects injected invalid"
    Assert-Equal -Actual $busResult.ExitCode -Expected 40 -Name "bus sanitizer fail-closed exit code"

    $metricsAfterSanitize = Get-CeoBusMetrics -StateRoot $stateRoot
    Assert-Equal -Actual $metricsAfterSanitize.queue -Expected 1 -Name "bus keeps only valid queued event"
    Assert-Equal -Actual $metricsAfterSanitize.failed -Expected 1 -Name "bus records invalid injected event"

    $executionAdapter = Join-Path $tools "ceo-execution-adapter.ps1"
    $executionAdapterResult = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "5", "-StateRoot", $stateRoot, "-AdapterId", "local")
    Assert-True -Condition (($executionAdapterResult.Text -like "*EXECUTION_ADAPTER_DONE:processed=1 failed=0 remaining=0*") -and ($executionAdapterResult.ExitCode -eq 0)) -Name "execution adapter processes only valid event" -Detail $executionAdapterResult.Text

    $metricsAfterFirstAdapter = Get-CeoBusMetrics -StateRoot $stateRoot
    Assert-Equal -Actual $metricsAfterFirstAdapter.queue -Expected 1 -Name "agent decision queued as event"
    Assert-Equal -Actual $metricsAfterFirstAdapter.processed -Expected 1 -Name "source event processed before agent decision"

    $queuedAfterFirstAdapter = @(Get-CeoJsonlLines -Path $state.QueueFile | ForEach-Object { $_ | ConvertFrom-Json })
    $queuedAgentDecisions = @($queuedAfterFirstAdapter | Where-Object { $_.type -eq "AGENT_DECISION" })
    Assert-Equal -Actual $queuedAgentDecisions.Count -Expected 1 -Name "one agent decision event queued"
    if ($queuedAgentDecisions.Count -gt 0) {
        $runtimeChain = @($queuedAgentDecisions[0].payload.agentDecisions)
        Assert-Equal -Actual ([string] $queuedAgentDecisions[0].payload.chainStatus) -Expected "COMPLETE" -Name "runtime agent chain completes"
        Assert-Equal -Actual ([string] $queuedAgentDecisions[0].payload.finalState.status) -Expected "COMPLETE" -Name "runtime final state is complete"
        Assert-Equal -Actual ([string] $queuedAgentDecisions[0].payload.conflictResolution.status) -Expected "NO_CONFLICT" -Name "runtime conflict resolution is explicit"
        Assert-Equal -Actual ([string] $queuedAgentDecisions[0].payload.execution.decisionEngine) -Expected "ceo-decision-engine" -Name "agent decision declares decision engine"
        Assert-Equal -Actual ([string] $queuedAgentDecisions[0].payload.execution.executionSurface) -Expected "local" -Name "agent decision declares local execution surface"
        Assert-Equal -Actual ([string] ($queuedAgentDecisions[0].payload.execution.executionPath -join ",")) -Expected "ceo-decision-engine,ceo-runtime-router.ps1,ceo-execution-adapter.ps1,local" -Name "agent decision declares execution path"
        Assert-Equal -Actual $runtimeChain.Count -Expected 5 -Name "runtime agent chain has five decisions"
        Assert-Equal -Actual ([string] $runtimeChain[0].agentRole) -Expected "validation_agent" -Name "runtime chain first decision is validation"
        Assert-Equal -Actual ([string] $runtimeChain[0].executionSurface) -Expected "local" -Name "runtime chain decision declares execution surface"
        Assert-Equal -Actual ([int] $runtimeChain[0].priority) -Expected 1 -Name "runtime chain exposes formal priority"
        Assert-Equal -Actual ([string] ($runtimeChain.sequence -join ",")) -Expected "1,2,3,4,5" -Name "runtime chain decisions are ordered"
    }

    $runtimeMemory = @(Get-CeoChainMemoryRecords -StateRoot $stateRoot)
    Assert-Equal -Actual $runtimeMemory.Count -Expected 1 -Name "runtime chain memory recorded by trace"
    if ($runtimeMemory.Count -gt 0) {
        Assert-Equal -Actual ([string] $runtimeMemory[0].finalState.status) -Expected "COMPLETE" -Name "runtime chain memory stores final state"
    }

    $validateAgentBus = Invoke-Tool -File $validateBus -Arguments @("-StateRoot", $stateRoot)
    Assert-Equal -Actual (($validateAgentBus.Output | Select-Object -Last 1) -as [string]) -Expected "BUS_VALID" -Name "agent decision event validates in bus"
    Assert-Equal -Actual $validateAgentBus.ExitCode -Expected 0 -Name "agent decision bus validation exit code"

    $executionAdapterAgentResult = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "5", "-StateRoot", $stateRoot, "-AdapterId", "local")
    Assert-True -Condition (($executionAdapterAgentResult.Text -like "*EXECUTION_ADAPTER_DONE:processed=1 failed=0 remaining=0*") -and ($executionAdapterAgentResult.ExitCode -eq 0)) -Name "execution adapter processes agent decision event" -Detail $executionAdapterAgentResult.Text

    $invalidPublish = Invoke-Tool -File $publish -Arguments @(
        "-Type", "RUNTIME_DRIFT",
        "-Domain", "runtime",
        "-Priority", "high",
        "-Payload", '{"runtimeStatus":"BROKEN"}',
        "-StateRoot", $stateRoot
    )
    Assert-True -Condition (($invalidPublish.Text -like "*EVENT_REJECTED:INVALID_PAYLOAD*") -and ($invalidPublish.ExitCode -eq 30)) -Name "publisher rejects invalid payload" -Detail $invalidPublish.Text

    $metricsAfterAdapter = Get-CeoBusMetrics -StateRoot $stateRoot
    Assert-Equal -Actual $metricsAfterAdapter.queue -Expected 0 -Name "queue empty after execution adapter"
    Assert-Equal -Actual $metricsAfterAdapter.processed -Expected 2 -Name "processed has source and agent decision events"
    Assert-Equal -Actual $metricsAfterAdapter.failed -Expected 2 -Name "failed records injected and publisher invalid events"
    Assert-True -Condition ($metricsAfterAdapter.invalid -ge 2) -Name "invalid log records rejected events"

    $traceExport = Join-Path $tools "ceo-trace-export.ps1"
    $exportResult = Invoke-Tool -File $traceExport -Arguments @("-StateRoot", $stateRoot)
    Assert-True -Condition (($exportResult.Text -like "*EXPORT:OK:*") -and ($exportResult.ExitCode -eq 0)) -Name "trace export generates dashboard data" -Detail $exportResult.Text

    $dataFile = $dashboardOutput
    Assert-True -Condition (Test-Path -LiteralPath $dataFile) -Name "web data exists"

    $validateJson = Join-Path $tools "ceo-validate-json.ps1"
    $dashboardData = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", $dataFile,
        "-SchemaFile", (Join-Path $schemas "dashboard-view.schema.json")
    )
    Assert-Equal -Actual (($dashboardData.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "exported dashboard data validates"

    $dashboardView = Get-Content -LiteralPath $dataFile -Raw | ConvertFrom-Json
    Assert-True -Condition (-not $dashboardView.PSObject.Properties["agentChains"]) -Name "dashboard model removes top-level agent chains"
    Assert-True -Condition (-not $dashboardView.PSObject.Properties["traceMemory"]) -Name "dashboard model removes top-level trace memory"
    Assert-True -Condition (@($dashboardView.unifiedTrace).Count -ge 1) -Name "dashboard export tracks unified trace"
    $runtimeUnifiedTrace = @($dashboardView.unifiedTrace | Where-Object { @($_.decisions).Count -ge 1 } | Select-Object -First 1)
    if ($runtimeUnifiedTrace.Count -gt 0) {
        Assert-Equal -Actual ([string] $runtimeUnifiedTrace[0].finalState.status) -Expected "COMPLETE" -Name "dashboard exposes unified final state"
        Assert-Equal -Actual ([string] $runtimeUnifiedTrace[0].decisionEngine) -Expected "ceo-decision-engine" -Name "dashboard exposes decision engine"
        Assert-Equal -Actual ([string] $runtimeUnifiedTrace[0].executionSurface) -Expected "local" -Name "dashboard exposes execution surface"
        Assert-True -Condition ("ceo-execution-adapter.ps1" -in @($runtimeUnifiedTrace[0].executionPath)) -Name "dashboard exposes execution path"
        Assert-Equal -Actual ([int] $runtimeUnifiedTrace[0].decisions[0].priority) -Expected 1 -Name "dashboard exposes unified decision priority"
        Assert-Equal -Actual ([string] $runtimeUnifiedTrace[0].decisions[0].executionSurface) -Expected "local" -Name "dashboard exposes decision execution surface"
        Assert-True -Condition (@($runtimeUnifiedTrace[0].timeline).Count -ge 3) -Name "dashboard exposes unified timeline"
        Assert-True -Condition ("ceo-decision-engine" -in @($runtimeUnifiedTrace[0].timeline.decisionEngine)) -Name "dashboard timeline exposes decision engine"
    }

    $panel = Invoke-Tool -File (Join-Path $tools "ceo-executive-panel.ps1") -Arguments @("-StateRoot", $stateRoot)
    Assert-Equal -Actual $panel.ExitCode -Expected 0 -Name "executive panel runs"

    $alert = Invoke-Tool -File (Join-Path $tools "ceo-alert-engine.ps1") -Arguments @("-StateRoot", $stateRoot)
    Assert-True -Condition (($alert.Text -like "*CRITICAL*") -and ($alert.ExitCode -eq 20)) -Name "alert engine flags invalid evidence" -Detail $alert.Text

    $followStateRoot = Join-Path $testOutputRoot ("follow-" + [guid]::NewGuid().ToString())
    $followState = Initialize-CeoSuiteState -StateRoot $followStateRoot
    $predictivePublish = Invoke-Tool -File $publish -Arguments @(
        "-Type", "PREDICTIVE_SIGNAL",
        "-Domain", "predictive",
        "-Priority", "medium",
        "-Payload", '{"signal":"INCIDENT_LIKELY","confidence":0.91,"basis":"smoke"}',
        "-StateRoot", $followStateRoot
    )
    Assert-Equal -Actual (($predictivePublish.Output | Select-Object -Last 1) -as [string]) -Expected "EVENT_QUEUED" -Name "predictive signal queued"

    $predictiveAdapter = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "5", "-StateRoot", $followStateRoot, "-AdapterId", "local")
    Assert-True -Condition (($predictiveAdapter.Text -like "*EXECUTION_ADAPTER_DONE:processed=1 failed=0 remaining=0*") -and ($predictiveAdapter.ExitCode -eq 0)) -Name "predictive source processed" -Detail $predictiveAdapter.Text

    $queuedPredictiveFollowUps = @(Get-CeoJsonlLines -Path $followState.QueueFile | ForEach-Object { $_ | ConvertFrom-Json })
    Assert-Equal -Actual $queuedPredictiveFollowUps.Count -Expected 2 -Name "predictive chain queues decision and follow-up"
    Assert-True -Condition ("AGENT_DECISION" -in @($queuedPredictiveFollowUps.type)) -Name "predictive agent decision queued"
    Assert-True -Condition ("OPTIMIZATION_COMMAND" -in @($queuedPredictiveFollowUps.type)) -Name "optimization follow-up queued"

    $predictiveDecision = @($queuedPredictiveFollowUps | Where-Object { $_.type -eq "AGENT_DECISION" } | Select-Object -First 1)
    if ($predictiveDecision.Count -gt 0) {
        $predictiveDecisions = @($predictiveDecision[0].payload.agentDecisions)
        Assert-Equal -Actual ([string] $predictiveDecision[0].payload.chainStatus) -Expected "COMPLETE" -Name "predictive chain completes"
        Assert-Equal -Actual ([string] $predictiveDecision[0].payload.finalState.status) -Expected "COMPLETE" -Name "predictive final state completes"
        Assert-True -Condition ("optimization_agent" -in @($predictiveDecisions.agentRole)) -Name "predictive chain uses optimization agent"
        Assert-Equal -Actual ([string] $predictiveDecision[0].payload.followUpEvents[0].status) -Expected "emitted" -Name "predictive follow-up marked emitted"
    }

    $validatePredictiveBus = Invoke-Tool -File $validateBus -Arguments @("-StateRoot", $followStateRoot)
    Assert-Equal -Actual (($validatePredictiveBus.Output | Select-Object -Last 1) -as [string]) -Expected "BUS_VALID" -Name "predictive follow-up bus validates"

    $predictiveAdapterSecond = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "10", "-StateRoot", $followStateRoot, "-AdapterId", "local")
    Assert-True -Condition (($predictiveAdapterSecond.Text -like "*EXECUTION_ADAPTER_DONE:processed=2 failed=0 remaining=0*") -and ($predictiveAdapterSecond.ExitCode -eq 0)) -Name "predictive decision and optimization processed" -Detail $predictiveAdapterSecond.Text

    $predictiveAdapterThird = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "10", "-StateRoot", $followStateRoot, "-AdapterId", "local")
    Assert-True -Condition (($predictiveAdapterThird.Text -like "*EXECUTION_ADAPTER_DONE:processed=1 failed=0 remaining=0*") -and ($predictiveAdapterThird.ExitCode -eq 0)) -Name "optimization agent decision processed" -Detail $predictiveAdapterThird.Text

    $followMetrics = Get-CeoBusMetrics -StateRoot $followStateRoot
    Assert-Equal -Actual $followMetrics.queue -Expected 0 -Name "follow-up queue drains"
    Assert-Equal -Actual $followMetrics.processed -Expected 4 -Name "follow-up scenario processes source decisions and command"
    Assert-Equal -Actual $followMetrics.failed -Expected 0 -Name "follow-up scenario has no failed events"
    Assert-Equal -Actual (@(Get-CeoChainMemoryRecords -StateRoot $followStateRoot).Count) -Expected 2 -Name "follow-up scenario records chain memory per trace"

    $followExport = Invoke-Tool -File $traceExport -Arguments @("-StateRoot", $followStateRoot)
    Assert-True -Condition (($followExport.Text -like "*EXPORT:OK:*") -and ($followExport.ExitCode -eq 0)) -Name "follow-up trace export runs" -Detail $followExport.Text
    $followDashboardData = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", $dataFile,
        "-SchemaFile", (Join-Path $schemas "dashboard-view.schema.json")
    )
    Assert-Equal -Actual (($followDashboardData.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "follow-up dashboard data validates"
    $followDashboardView = Get-Content -LiteralPath $dataFile -Raw | ConvertFrom-Json
    Assert-True -Condition (@($followDashboardView.unifiedTrace).Count -ge 1) -Name "follow-up dashboard tracks unified trace"
    $followUnifiedTrace = @($followDashboardView.unifiedTrace | Where-Object { @($_.chains).Count -ge 2 } | Select-Object -First 1)
    if ($followUnifiedTrace.Count -gt 0) {
        Assert-True -Condition (@($followUnifiedTrace[0].chains).Count -ge 2) -Name "follow-up unified trace consolidates multiple chains"
        Assert-True -Condition (@($followUnifiedTrace[0].memory).Count -ge 2) -Name "follow-up unified trace consolidates memory records"
        Assert-True -Condition (@($followUnifiedTrace[0].decisions).Count -ge 8) -Name "follow-up unified trace consolidates decisions"
    }

    $governanceStateRoot = Join-Path $testOutputRoot ("governance-" + [guid]::NewGuid().ToString())
    $governanceState = Initialize-CeoSuiteState -StateRoot $governanceStateRoot

    $pathSanitizerResult = Invoke-Tool -File (Join-Path $tools "ceo-path-sanitizer.ps1") -Arguments @(
        "-MaxFindings", "1",
        "-StateRoot", $governanceStateRoot
    )
    Assert-True -Condition (($pathSanitizerResult.Text -like "*PATH_SANITIZER_QUEUED:1*") -and ($pathSanitizerResult.ExitCode -eq 0)) -Name "path sanitizer agent emits sanitize required event" -Detail $pathSanitizerResult.Text

    $federationEnforcerResult = Invoke-Tool -File (Join-Path $tools "ceo-federation-enforcer.ps1") -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-True -Condition (($federationEnforcerResult.Text -like "*FEDERATION_ENFORCER_QUEUED:OK*") -and ($federationEnforcerResult.ExitCode -eq 0)) -Name "federation enforcer emits federation drift event" -Detail $federationEnforcerResult.Text

    $snsResult = Invoke-Tool -File (Join-Path $tools "ceo-sns-unify.ps1") -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-True -Condition (($snsResult.Text -like "*SNS_UNIFY_QUEUED:READY*") -and ($snsResult.ExitCode -eq 0)) -Name "SNS agent emits unified index event" -Detail $snsResult.Text

    $vsiGuardResult = Invoke-Tool -File (Join-Path $tools "ceo-vsi-execution-guard.ps1") -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-True -Condition (($vsiGuardResult.Text -like "*VSI_GUARD_QUEUED:PASS*") -and ($vsiGuardResult.ExitCode -eq 0)) -Name "VSI execution guard emits guard event" -Detail $vsiGuardResult.Text

    $controlPlaneResult = Invoke-Tool -File (Join-Path $tools "ceo-control-plane-sync.ps1") -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-True -Condition (($controlPlaneResult.Text -like "*CONTROL_PLANE_SYNC_QUEUED:READY*") -and ($controlPlaneResult.ExitCode -eq 0)) -Name "control plane agent emits sync event" -Detail $controlPlaneResult.Text
    $controlPlaneMap = Get-Content -LiteralPath $governanceState.AgileCanvasMapFile -Raw | ConvertFrom-Json
    Assert-Equal -Actual ([string] $controlPlaneMap.demoQuarantine.status) -Expected "CLEAR" -Name "control plane map has no demo quarantine drift"
    Assert-Equal -Actual ([int] $controlPlaneMap.demoQuarantine.patternsDetected) -Expected 0 -Name "control plane map demo drift count is zero"
    Assert-True -Condition ("demoQuarantine:0" -in @($controlPlaneMap.mappedSurfaces)) -Name "control plane map records demo quarantine postcheck"

    $sanitizerResult = Invoke-Tool -File (Join-Path $tools "ceo-sanitizer-scan.ps1") -Arguments @(
        "-MaxFindings", "1",
        "-StateRoot", $governanceStateRoot
    )
    Assert-True -Condition (($sanitizerResult.Text -like "*SANITIZER_SCAN_QUEUED:1*") -and ($sanitizerResult.ExitCode -eq 0)) -Name "sanitizer agent emits finding event" -Detail $sanitizerResult.Text

    $diagnosticResult = Invoke-Tool -File (Join-Path $tools "ceo-runtime-diagnose.ps1") -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-True -Condition (($diagnosticResult.Text -like "*RUNTIME_DIAGNOSIS_QUEUED:*") -and ($diagnosticResult.ExitCode -eq 0)) -Name "diagnostic agent emits runtime diagnosis" -Detail $diagnosticResult.Text

    $governanceQueued = @(Get-CeoJsonlLines -Path $governanceState.QueueFile | ForEach-Object { $_ | ConvertFrom-Json })
    Assert-True -Condition ("SANITIZE_REQUIRED" -in @($governanceQueued.type)) -Name "sanitize required enters bus"
    Assert-True -Condition ("FEDERATION_DRIFT" -in @($governanceQueued.type)) -Name "federation drift enters bus"
    Assert-True -Condition ("SNS_UNIFIED_INDEX" -in @($governanceQueued.type)) -Name "SNS unified index enters bus"
    Assert-True -Condition ("VSI_GUARD_RESULT" -in @($governanceQueued.type)) -Name "VSI guard result enters bus"
    Assert-True -Condition ("CONTROL_PLANE_SYNC" -in @($governanceQueued.type)) -Name "control plane sync enters bus"
    Assert-True -Condition ("SANITIZATION_FINDING" -in @($governanceQueued.type)) -Name "sanitization finding enters bus"
    Assert-True -Condition ("RUNTIME_DIAGNOSIS" -in @($governanceQueued.type)) -Name "runtime diagnosis enters bus"

    $governanceBus = Invoke-Tool -File $validateBus -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-Equal -Actual (($governanceBus.Output | Select-Object -Last 1) -as [string]) -Expected "BUS_VALID" -Name "governance bus validates"
    Assert-Equal -Actual $governanceBus.ExitCode -Expected 0 -Name "governance bus validation exit code"

    $governanceAdapterFirst = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "10", "-StateRoot", $governanceStateRoot, "-AdapterId", "local")
    Assert-True -Condition (($governanceAdapterFirst.Text -like "*EXECUTION_ADAPTER_DONE:processed=7 failed=0 remaining=0*") -and ($governanceAdapterFirst.ExitCode -eq 0)) -Name "governance source events processed" -Detail $governanceAdapterFirst.Text

    $governanceAfterFirst = @(Get-CeoJsonlLines -Path $governanceState.QueueFile | ForEach-Object { $_ | ConvertFrom-Json })
    Assert-Equal -Actual $governanceAfterFirst.Count -Expected 7 -Name "governance decisions queued as events"
    Assert-Equal -Actual (@($governanceAfterFirst | Where-Object { $_.type -eq "AGENT_DECISION" }).Count) -Expected 7 -Name "seven governance agent decisions queued"

    $governanceAdapterSecond = Invoke-Tool -File $executionAdapter -Arguments @("-MaxEvents", "10", "-StateRoot", $governanceStateRoot, "-AdapterId", "local")
    Assert-True -Condition (($governanceAdapterSecond.Text -like "*EXECUTION_ADAPTER_DONE:processed=7 failed=0 remaining=0*") -and ($governanceAdapterSecond.ExitCode -eq 0)) -Name "governance decision events processed" -Detail $governanceAdapterSecond.Text

    $governanceMetrics = Get-CeoBusMetrics -StateRoot $governanceStateRoot
    Assert-Equal -Actual $governanceMetrics.queue -Expected 0 -Name "governance queue drains"
    Assert-Equal -Actual $governanceMetrics.processed -Expected 14 -Name "governance scenario processes source and decision events"
    Assert-Equal -Actual $governanceMetrics.failed -Expected 0 -Name "governance scenario has no failed events"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $governanceState.PathSanitizerFile).Count -ge 1) -Name "governance records path sanitizer evidence"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $governanceState.FederationDriftFile).Count -ge 1) -Name "governance records federation evidence"
    Assert-True -Condition (Test-Path -LiteralPath $governanceState.SnsRootFile) -Name "governance records SNS root index"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $governanceState.VsiGuardFile).Count -ge 1) -Name "governance records VSI evidence"
    Assert-True -Condition (Test-Path -LiteralPath $governanceState.AgileCanvasMapFile) -Name "governance records control plane map"
    Assert-Equal -Actual ([string] $controlPlaneMap.demoQuarantine.status) -Expected "CLEAR" -Name "governance control plane map remains clear of demo drift"

    $governanceExport = Invoke-Tool -File $traceExport -Arguments @("-StateRoot", $governanceStateRoot)
    Assert-True -Condition (($governanceExport.Text -like "*EXPORT:OK:*") -and ($governanceExport.ExitCode -eq 0)) -Name "governance trace export runs" -Detail $governanceExport.Text

    $governanceDashboardData = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", $dataFile,
        "-SchemaFile", (Join-Path $schemas "dashboard-view.schema.json")
    )
    Assert-Equal -Actual (($governanceDashboardData.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "governance dashboard data validates"

    $governanceDashboardView = Get-Content -LiteralPath $dataFile -Raw | ConvertFrom-Json
    $governanceTraceTypes = @($governanceDashboardView.unifiedTrace | ForEach-Object { @($_.sourceTypes) })
    Assert-True -Condition ("SANITIZE_REQUIRED" -in $governanceTraceTypes) -Name "dashboard exposes path sanitizer trace"
    Assert-True -Condition ("FEDERATION_DRIFT" -in $governanceTraceTypes) -Name "dashboard exposes federation drift trace"
    Assert-True -Condition ("SNS_UNIFIED_INDEX" -in $governanceTraceTypes) -Name "dashboard exposes SNS unified index trace"
    Assert-True -Condition ("VSI_GUARD_RESULT" -in $governanceTraceTypes) -Name "dashboard exposes VSI guard trace"
    Assert-True -Condition ("CONTROL_PLANE_SYNC" -in $governanceTraceTypes) -Name "dashboard exposes control plane trace"
    Assert-True -Condition ("SANITIZATION_FINDING" -in $governanceTraceTypes) -Name "dashboard exposes sanitization finding trace"
    Assert-True -Condition ("RUNTIME_DIAGNOSIS" -in $governanceTraceTypes) -Name "dashboard exposes runtime diagnosis trace"
    $governanceDecisionRoles = @($governanceDashboardView.unifiedTrace | ForEach-Object { @($_.decisions.agentRole) })
    Assert-True -Condition ("path_sanitizer_agent" -in $governanceDecisionRoles) -Name "dashboard exposes path sanitizer agent decision"
    Assert-True -Condition ("federation_enforcer_agent" -in $governanceDecisionRoles) -Name "dashboard exposes federation enforcer agent decision"
    Assert-True -Condition ("sns_agent" -in $governanceDecisionRoles) -Name "dashboard exposes SNS agent decision"
    Assert-True -Condition ("vsi_execution_guard" -in $governanceDecisionRoles) -Name "dashboard exposes VSI execution guard decision"
    Assert-True -Condition ("control_plane_agent" -in $governanceDecisionRoles) -Name "dashboard exposes control plane agent decision"
    Assert-True -Condition ("sanitizer_agent" -in $governanceDecisionRoles) -Name "dashboard exposes sanitizer agent decision"
    Assert-True -Condition ("diagnostic_agent" -in $governanceDecisionRoles) -Name "dashboard exposes diagnostic agent decision"

    $activeGovernanceStateRoot = Join-Path $testOutputRoot ("active-governance-" + [guid]::NewGuid().ToString())
    $activeGovernanceResult = Invoke-Tool -File (Join-Path $tools "ceo-active-governance.ps1") -Arguments @(
        "-MaxFindings", "1",
        "-MaxEvents", "10",
        "-StateRoot", $activeGovernanceStateRoot
    )
    Assert-True -Condition (($activeGovernanceResult.Text -like "*ACTIVE_GOVERNANCE_OK*") -and ($activeGovernanceResult.ExitCode -eq 0)) -Name "active governance run completes" -Detail $activeGovernanceResult.Text

    $activeGovernanceState = Initialize-CeoSuiteState -StateRoot $activeGovernanceStateRoot
    $activeGovernanceMetrics = Get-CeoBusMetrics -StateRoot $activeGovernanceStateRoot
    Assert-Equal -Actual $activeGovernanceMetrics.queue -Expected 0 -Name "active governance queue drains"
    Assert-Equal -Actual $activeGovernanceMetrics.failed -Expected 0 -Name "active governance has no failed events"
    Assert-True -Condition ($activeGovernanceMetrics.processed -ge 4) -Name "active governance processes source and decision events"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $activeGovernanceState.PathSanitizerFile).Count -ge 1) -Name "active governance records path sanitizer evidence"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $activeGovernanceState.FederationDriftFile).Count -ge 1) -Name "active governance records federation evidence"
    Assert-True -Condition (Test-Path -LiteralPath $activeGovernanceState.SnsRootFile) -Name "active governance records SNS root index"
    Assert-True -Condition (Test-Path -LiteralPath $activeGovernanceState.CanonicalPathRewriteFile) -Name "active governance records canonical path rewrites"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $activeGovernanceState.VsiGuardFile).Count -ge 1) -Name "active governance records VSI guard evidence"
    Assert-True -Condition (Test-Path -LiteralPath $activeGovernanceState.AgileCanvasMapFile) -Name "active governance records Agile Agent Canvas map"
    $activeGovernanceCanvasMap = Get-Content -LiteralPath $activeGovernanceState.AgileCanvasMapFile -Raw | ConvertFrom-Json
    Assert-Equal -Actual ([string] $activeGovernanceCanvasMap.demoQuarantine.status) -Expected "CLEAR" -Name "active governance Canvas map has no demo quarantine drift"
    Assert-Equal -Actual ([int] $activeGovernanceCanvasMap.demoQuarantine.patternsDetected) -Expected 0 -Name "active governance Canvas demo drift count is zero"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $activeGovernanceState.SanitizationFindingFile).Count -ge 1) -Name "active governance records sanitizer evidence"
    Assert-True -Condition (@(Get-CeoJsonlLines -Path $activeGovernanceState.RuntimeDiagnosisFile).Count -ge 1) -Name "active governance records diagnostic evidence"

    $activeGovernanceDashboardData = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", $dataFile,
        "-SchemaFile", (Join-Path $schemas "dashboard-view.schema.json")
    )
    Assert-Equal -Actual (($activeGovernanceDashboardData.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "active governance dashboard data validates"
}
catch {
    Write-Host "[EXCEPTION] $($_.Exception.Message)" -ForegroundColor Red
    $script:fails++
}

Write-Host ""
Write-Host "==============================="
Write-Host "PASSED: $script:passes"
Write-Host "FAILED: $script:fails"
Write-Host "STATE_ROOT: $stateRoot"
Write-Host "==============================="

if ($script:fails -gt 0) { exit 1 }
Write-Host "INTEGRATION_SMOKE_OK" -ForegroundColor Green
exit 0
