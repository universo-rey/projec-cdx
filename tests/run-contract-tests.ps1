Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

$root = Split-Path -Parent $PSScriptRoot
$tools = Join-Path $root "tools"
$contracts = Join-Path $root "contracts"
$schemas = Join-Path $contracts "schemas"
$examples = Join-Path $root "examples"
$testOutputRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testOutputRoot)) {
    $testOutputRoot = Join-Path ([System.IO.Path]::GetTempPath()) "sdu-test-output"
}
$stateRoot = Join-Path $testOutputRoot ("contracts-" + [guid]::NewGuid().ToString())
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
    $schemaFiles = @(Get-ChildItem -LiteralPath $schemas -Filter "*.json" -File)
    Assert-True -Condition ($schemaFiles.Count -ge 21) -Name "schema files present"

    foreach ($schemaFile in $schemaFiles) {
        $null = Get-Content -LiteralPath $schemaFile.FullName -Raw | ConvertFrom-Json
    }
    Assert-True -Condition $true -Name "schemas parse as JSON"

    $coverage = Test-CeoContractMapCoverage
    Assert-True -Condition $coverage.IsValid -Name "contract map covers envelope event types" -Detail (($coverage | ConvertTo-Json -Compress))

    $agentCoverage = Test-CeoAgentMapCoverage
    Assert-True -Condition $agentCoverage.IsValid -Name "agent map covers envelope event types" -Detail (($agentCoverage | ConvertTo-Json -Compress))

    $runtimeRoute = @(Get-CeoAgentRoute -EventType "RUNTIME_DRIFT")
    Assert-Equal -Actual $runtimeRoute.Count -Expected 5 -Name "runtime drift uses multi-agent chain"
    Assert-Equal -Actual ([string] $runtimeRoute[0].agentId) -Expected "validation_agent" -Name "runtime chain starts with validation agent"
    Assert-Equal -Actual ([string] $runtimeRoute[1].agentId) -Expected "contracts_agent" -Name "runtime chain checks contracts second"
    Assert-Equal -Actual ([string] $runtimeRoute[-1].agentId) -Expected "observability_agent" -Name "runtime chain ends with observability"

    $predictiveRoute = @(Get-CeoAgentRoute -EventType "PREDICTIVE_SIGNAL")
    Assert-True -Condition (("optimization_agent" -in @($predictiveRoute.agentId)) -and ($predictiveRoute.Count -eq 4)) -Name "predictive chain includes optimization agent"
    Assert-Equal -Actual (Get-CeoAgentPriority -AgentId "validation_agent") -Expected 1 -Name "formal priority ranks validation first"
    $sanitizationRoute = @(Get-CeoAgentRoute -EventType "SANITIZATION_FINDING")
    Assert-True -Condition (("sanitizer_agent" -in @($sanitizationRoute.agentId)) -and ($sanitizationRoute.Count -eq 5)) -Name "sanitization finding uses sanitizer chain"
    $diagnosisRoute = @(Get-CeoAgentRoute -EventType "RUNTIME_DIAGNOSIS")
    Assert-True -Condition (("diagnostic_agent" -in @($diagnosisRoute.agentId)) -and ($diagnosisRoute.Count -eq 5)) -Name "runtime diagnosis uses diagnostic chain"
    $pathRoute = @(Get-CeoAgentRoute -EventType "SANITIZE_REQUIRED")
    Assert-True -Condition (("path_sanitizer_agent" -in @($pathRoute.agentId)) -and ($pathRoute.Count -eq 5)) -Name "sanitize required uses path sanitizer chain"
    $federationRoute = @(Get-CeoAgentRoute -EventType "FEDERATION_DRIFT")
    Assert-True -Condition (("federation_enforcer_agent" -in @($federationRoute.agentId)) -and ($federationRoute.Count -eq 5)) -Name "federation drift uses enforcer chain"
    $snsRoute = @(Get-CeoAgentRoute -EventType "SNS_UNIFIED_INDEX")
    Assert-True -Condition (("sns_agent" -in @($snsRoute.agentId)) -and ($snsRoute.Count -eq 5)) -Name "SNS unified index uses SNS chain"
    $vsiRoute = @(Get-CeoAgentRoute -EventType "VSI_GUARD_RESULT")
    Assert-True -Condition (("vsi_execution_guard" -in @($vsiRoute.agentId)) -and ($vsiRoute.Count -eq 5)) -Name "VSI guard result uses VSI execution guard chain"
    $controlPlaneRoute = @(Get-CeoAgentRoute -EventType "CONTROL_PLANE_SYNC")
    Assert-True -Condition (("control_plane_agent" -in @($controlPlaneRoute.agentId)) -and ($controlPlaneRoute.Count -eq 5)) -Name "control plane sync uses control plane chain"

    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-runtime-router.ps1")) -Name "runtime router tool exists"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-execution-adapter.ps1")) -Name "execution adapter tool exists"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-path-sanitizer.ps1")) -Name "path sanitizer tool exists"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-federation-enforcer.ps1")) -Name "federation enforcer tool exists"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-sns-unify.ps1")) -Name "SNS unify tool exists"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-vsi-execution-guard.ps1")) -Name "VSI execution guard tool exists"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-control-plane-sync.ps1")) -Name "control plane sync tool exists"
    $localAdapter = Get-CeoExecutionAdapter -AdapterId "local"
    Assert-Equal -Actual ([string] $localAdapter.status) -Expected "active" -Name "local execution adapter active"
    Assert-Equal -Actual ([string] $localAdapter.executionSurface) -Expected "local" -Name "local adapter declares execution surface"
    $codexAdapter = Get-CeoExecutionAdapter -AdapterId "codex"
    Assert-Equal -Actual ([string] $codexAdapter.status) -Expected "placeholder" -Name "codex adapter stays placeholder"
    Assert-Equal -Actual ([string] $codexAdapter.mode) -Expected "read-only-review" -Name "codex adapter is read-only review"
    $cloudAdapter = Get-CeoExecutionAdapter -AdapterId "cloud"
    Assert-Equal -Actual ([string] $cloudAdapter.status) -Expected "placeholder" -Name "cloud adapter stays placeholder"
    $executionSurface = Get-CeoExecutionSurface -AdapterId "local"
    Assert-Equal -Actual ([string] $executionSurface.decisionEngine) -Expected "ceo-decision-engine" -Name "execution surface declares decision engine"
    Assert-Equal -Actual ([string] $executionSurface.executionAdapter) -Expected "ceo-execution-adapter.ps1" -Name "execution surface declares execution adapter"
    Assert-Equal -Actual ([string] ($executionSurface.executionPath -join ",")) -Expected "ceo-decision-engine,ceo-runtime-router.ps1,ceo-execution-adapter.ps1,local" -Name "execution surface declares execution path"

    $conflictProbe = Test-CeoAgentDecisionConflict -Decisions @(
        [PSCustomObject]@{ sequence = 1; decisionType = "hold"; result = "HELD:policy" },
        [PSCustomObject]@{ sequence = 1; decisionType = "dispatch"; result = "BUS_EVENT_ONLY:RUNTIME_DRIFT" }
    )
    Assert-True -Condition $conflictProbe.HasConflict -Name "agent decision conflict detector blocks incompatible decisions"
    $conflictResolution = Resolve-CeoAgentDecisionOutcome -Decisions @(
        [PSCustomObject]@{ sequence = 1; priority = 1; agentRole = "validation_agent"; decisionType = "validate"; result = "HELD:policy" },
        [PSCustomObject]@{ sequence = 1; priority = 4; agentRole = "bus_agent"; decisionType = "dispatch"; result = "BUS_EVENT_ONLY:RUNTIME_DRIFT" }
    ) -PolicyDecision ([PSCustomObject]@{ allowed = $true; requiresApproval = $false; action = "dispatch"; reason = "contract probe" }) -ChainStatus "CONFLICT" -Conflict $conflictProbe
    Assert-Equal -Actual ([string] $conflictResolution.finalState.status) -Expected "CONFLICT_HELD" -Name "conflict resolution holds fail-closed"
    Assert-Equal -Actual ([string] $conflictResolution.conflictResolution.selectedAgentRole) -Expected "validation_agent" -Name "conflict resolution uses formal priority"

    $validateJson = Join-Path $tools "ceo-validate-json.ps1"
    $policyResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $examples "policy-decision.valid.json"),
        "-SchemaFile", (Join-Path $schemas "policy-decision.payload.schema.json")
    )
    Assert-Equal -Actual (($policyResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "policy decision schema validates"
    Assert-Equal -Actual $policyResult.ExitCode -Expected 0 -Name "policy decision validator exit code"

    $traceResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $examples "trace-node.valid.json"),
        "-SchemaFile", (Join-Path $schemas "trace-node.schema.json")
    )
    Assert-Equal -Actual (($traceResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "trace node schema validates"

    $federationResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $contracts "federation-map.json"),
        "-SchemaFile", (Join-Path $schemas "federation-map.schema.json")
    )
    Assert-Equal -Actual (($federationResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "federation map schema validates"

    $environmentResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $contracts "environment-contract.json"),
        "-SchemaFile", (Join-Path $schemas "environment-contract.schema.json")
    )
    Assert-Equal -Actual (($environmentResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "environment contract schema validates"

    $federationCheck = Invoke-Tool -File (Join-Path $tools "ceo-federation-check.ps1")
    Assert-Equal -Actual (($federationCheck.Output | Select-Object -Last 1) -as [string]) -Expected "FEDERATION_OK" -Name "federation check passes"

    $environmentCheck = Invoke-Tool -File (Join-Path $tools "ceo-environment-check.ps1")
    Assert-Equal -Actual $environmentCheck.ExitCode -Expected 0 -Name "environment check runs without reading secret values"

    $snsBootstrap = Invoke-Tool -File (Join-Path $tools "ceo-sns-unify.ps1") -Arguments @("-StateRoot", $stateRoot)
    Assert-True -Condition (($snsBootstrap.Text -like "*SNS_UNIFY_QUEUED:READY*") -and ($snsBootstrap.ExitCode -eq 0)) -Name "SNS root bootstrap runs" -Detail $snsBootstrap.Text
    $validateJson = Join-Path $tools "ceo-validate-json.ps1"
    $snsRootResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $root "SYSTEM_NERVOUS_INDEX.json"),
        "-SchemaFile", (Join-Path $schemas "system-nervous-index.schema.json")
    )
    Assert-Equal -Actual (($snsRootResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "SNS root schema validates"
    $snsGate = Test-CeoSnsGate
    Assert-True -Condition $snsGate.IsValid -Name "SNS gate enforces all agents in root index" -Detail (($snsGate | ConvertTo-Json -Compress))
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $root "CEO_CONTROL_PLANE.code-workspace")) -Name "VSI control plane workspace exists"
    Assert-True -Condition ((Get-Content -LiteralPath (Join-Path $root ".vscode\tasks.json") -Raw) -match "CEO Final: System Coherence Close") -Name "VSI tasks expose system coherence runner"

    $activeGovernancePreflight = Test-CeoActiveGovernancePreflight
    Assert-True -Condition $activeGovernancePreflight.IsValid -Name "active governance preflight passes"
    Assert-Equal -Actual ([string] $activeGovernancePreflight.PathSanitizer.Status) -Expected "PATH_SANITIZER_PASS" -Name "active governance path sanitizer preflight passes"
    Assert-Equal -Actual ([string] $activeGovernancePreflight.Sns.Status) -Expected "SNS_GATE_READY" -Name "active governance SNS preflight passes"
    Assert-Equal -Actual ([string] $activeGovernancePreflight.VsiExecutionGuard.Status) -Expected "VSI_CONTEXT_VALID" -Name "active governance VSI guard preflight passes"
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $tools "ceo-active-governance.ps1")) -Name "active governance tool exists"

    $previousOpenAiKey = $env:OPENAI_API_KEY
    try {
        $env:OPENAI_API_KEY = "fake-test-value-not-secret"
        $blockedEnvironmentGate = Test-CeoEnvironmentGate
        Assert-True -Condition (-not $blockedEnvironmentGate.IsValid) -Name "environment gate blocks forbidden env presence"

        $blockedStateRoot = Join-Path $testOutputRoot ("blocked-env-" + [guid]::NewGuid().ToString())
        $blockedAdapter = Invoke-Tool -File (Join-Path $tools "ceo-execution-adapter.ps1") -Arguments @("-StateRoot", $blockedStateRoot)
        Assert-True -Condition (($blockedAdapter.Text -like "*EXECUTION_ADAPTER_HELD:ACTIVE_GOVERNANCE_PRECHECK:*") -and ($blockedAdapter.ExitCode -eq 31)) -Name "execution adapter blocks before execution when environment gate fails" -Detail $blockedAdapter.Text
    }
    finally {
        if ($null -eq $previousOpenAiKey) {
            Remove-Item Env:\OPENAI_API_KEY -ErrorAction SilentlyContinue
        }
        else {
            $env:OPENAI_API_KEY = $previousOpenAiKey
        }
    }

    $dashboardResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $examples "dashboard-view.valid.json"),
        "-SchemaFile", (Join-Path $schemas "dashboard-view.schema.json")
    )
    Assert-Equal -Actual (($dashboardResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "dashboard view schema validates"

    $agentPayloadResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $examples "agent-decision.valid.event.json"),
        "-SchemaFile", (Join-Path $schemas "event-envelope.schema.json")
    )
    Assert-Equal -Actual (($agentPayloadResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "agent decision envelope validates"

    $sanitizationEventResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $examples "sanitization-finding.valid.event.json"),
        "-SchemaFile", (Join-Path $schemas "event-envelope.schema.json")
    )
    Assert-Equal -Actual (($sanitizationEventResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "sanitization finding envelope validates"

    $diagnosisEventResult = Invoke-Tool -File $validateJson -Arguments @(
        "-JsonFile", (Join-Path $examples "runtime-diagnosis.valid.event.json"),
        "-SchemaFile", (Join-Path $schemas "event-envelope.schema.json")
    )
    Assert-Equal -Actual (($diagnosisEventResult.Output | Select-Object -Last 1) -as [string]) -Expected "VALID" -Name "runtime diagnosis envelope validates"

    $validateEvent = Join-Path $tools "ceo-validate-event.ps1"
    $validEvent = Invoke-Tool -File $validateEvent -Arguments @(
        "-EventFile", (Join-Path $examples "runtime-drift.valid.event.json"),
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($validEvent.Output | Select-Object -Last 1) -as [string]) -Expected "VALID_EVENT" -Name "valid runtime event accepted"
    Assert-Equal -Actual $validEvent.ExitCode -Expected 0 -Name "valid runtime event exit code"

    $invalidEvent = Invoke-Tool -File $validateEvent -Arguments @(
        "-EventFile", (Join-Path $examples "runtime-drift.invalid.event.json"),
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($invalidEvent.Output | Select-Object -Last 1) -as [string]) -Expected "INVALID_PAYLOAD" -Name "invalid runtime payload rejected"
    Assert-Equal -Actual $invalidEvent.ExitCode -Expected 13 -Name "invalid runtime payload exit code"

    $agentEvent = Invoke-Tool -File $validateEvent -Arguments @(
        "-EventFile", (Join-Path $examples "agent-decision.valid.event.json"),
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($agentEvent.Output | Select-Object -Last 1) -as [string]) -Expected "VALID_EVENT" -Name "agent decision event accepted"
    Assert-Equal -Actual $agentEvent.ExitCode -Expected 0 -Name "agent decision event exit code"

    $sanitizationEvent = Invoke-Tool -File $validateEvent -Arguments @(
        "-EventFile", (Join-Path $examples "sanitization-finding.valid.event.json"),
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($sanitizationEvent.Output | Select-Object -Last 1) -as [string]) -Expected "VALID_EVENT" -Name "sanitization finding event accepted"

    $diagnosisEvent = Invoke-Tool -File $validateEvent -Arguments @(
        "-EventFile", (Join-Path $examples "runtime-diagnosis.valid.event.json"),
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($diagnosisEvent.Output | Select-Object -Last 1) -as [string]) -Expected "VALID_EVENT" -Name "runtime diagnosis event accepted"

    $disciplineProbe = Get-Content -LiteralPath (Join-Path $examples "runtime-drift.valid.event.json") -Raw | ConvertFrom-Json
    $disciplineProbe.metadata.governance.agent = "missing_agent"
    $disciplineProbeFile = New-CeoSuiteTempFile -StateRoot $stateRoot -Prefix "discipline-probe"
    $disciplineProbe | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $disciplineProbeFile -Encoding UTF8
    $disciplineResult = Invoke-Tool -File $validateEvent -Arguments @(
        "-EventFile", $disciplineProbeFile,
        "-StateRoot", $stateRoot
    )
    Assert-Equal -Actual (($disciplineResult.Output | Select-Object -Last 1) -as [string]) -Expected "INVALID_EXECUTION_DISCIPLINE" -Name "execution discipline blocks unknown governance agent"
    Assert-Equal -Actual $disciplineResult.ExitCode -Expected 15 -Name "execution discipline exit code"
}
catch {
    Write-Host "[EXCEPTION] $($_.Exception.Message)" -ForegroundColor Red
    $script:fails++
}

Write-Host ""
Write-Host "==============================="
Write-Host "PASSED: $script:passes"
Write-Host "FAILED: $script:fails"
Write-Host "==============================="

if ($script:fails -gt 0) { exit 1 }
exit 0
