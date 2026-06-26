param(
    [int] $MaxFindings = 5,
    [int] $MaxEvents = 20,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$pwsh = (Get-Command pwsh -ErrorAction Stop).Source
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$preflight = Test-CeoActiveGovernancePreflight
if (-not $preflight.IsValid) {
    $reason = (@($preflight.Issues) -join ";")
    Add-Content -LiteralPath $state.ExecutionAdapterLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] ACTIVE_GOVERNANCE_HELD reason=$reason" -Encoding UTF8
    Write-Output "ACTIVE_GOVERNANCE_HELD:$reason"
    exit 30
}

function Invoke-ActiveGovernanceTool {
    param(
        [Parameter(Mandatory = $true)]
        [string] $File,
        [string[]] $Arguments = @(),
        [Parameter(Mandatory = $true)]
        [string] $ExpectedPrefix
    )

    $output = & $pwsh -NoProfile -ExecutionPolicy Bypass -File $File @Arguments 2>&1
    $text = (@($output) -join "`n")
    if ($LASTEXITCODE -ne 0 -or -not ($text -like "$ExpectedPrefix*")) {
        throw "ACTIVE_GOVERNANCE_STEP_FAILED:$([System.IO.Path]::GetFileName($File)):$text"
    }

    return $text
}

$results = [ordered]@{
    federation = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-federation-check.ps1") -ExpectedPrefix "FEDERATION_OK"
    environment = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-environment-check.ps1") -ExpectedPrefix "{"
    pathSanitizer = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-path-sanitizer.ps1") -Arguments @("-MaxFindings", [string] $MaxFindings, "-Rewrite", "-StateRoot", $state.StateRoot) -ExpectedPrefix "PATH_SANITIZER_QUEUED:"
    federationEnforcer = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-federation-enforcer.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "FEDERATION_ENFORCER_QUEUED:"
    sns = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-sns-unify.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "SNS_UNIFY_QUEUED:"
    vsiGuard = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-vsi-execution-guard.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "VSI_GUARD_QUEUED:"
    controlPlane = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-control-plane-sync.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "CONTROL_PLANE_SYNC_QUEUED:"
    sanitizer = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-sanitizer-scan.ps1") -Arguments @("-MaxFindings", [string] $MaxFindings, "-StateRoot", $state.StateRoot) -ExpectedPrefix "SANITIZER_SCAN_QUEUED:"
    diagnostic = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-runtime-diagnose.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "RUNTIME_DIAGNOSIS_QUEUED:"
    bus = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-validate-bus.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "{"
    adapterFirst = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-execution-adapter.ps1") -Arguments @("-MaxEvents", [string] $MaxEvents, "-StateRoot", $state.StateRoot, "-AdapterId", "local") -ExpectedPrefix "EXECUTION_ADAPTER_DONE:"
    adapterSecond = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-execution-adapter.ps1") -Arguments @("-MaxEvents", [string] $MaxEvents, "-StateRoot", $state.StateRoot, "-AdapterId", "local") -ExpectedPrefix "EXECUTION_ADAPTER_DONE:"
    export = Invoke-ActiveGovernanceTool -File (Join-Path $PSScriptRoot "ceo-trace-export.ps1") -Arguments @("-StateRoot", $state.StateRoot) -ExpectedPrefix "{"
}

$metrics = Get-CeoBusMetrics -StateRoot $state.StateRoot
[ordered]@{
    status = "ACTIVE_GOVERNANCE_OK"
    stateRoot = $state.StateRoot
    federationId = [string] $preflight.Federation.FederationId
    environmentStatus = [string] $preflight.Environment.Status
    pathSanitizerStatus = [string] $preflight.PathSanitizer.Status
    snsStatus = [string] $preflight.Sns.Status
    vsiExecutionGuardStatus = [string] $preflight.VsiExecutionGuard.Status
    sensitiveContentRead = $false
    results = $results
    metrics = [ordered]@{
        queue = [int] $metrics.queue
        processed = [int] $metrics.processed
        failed = [int] $metrics.failed
        invalid = [int] $metrics.invalid
    }
} | ConvertTo-Json -Depth 20

Write-Output "ACTIVE_GOVERNANCE_OK"
exit 0
