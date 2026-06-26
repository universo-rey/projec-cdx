param(
    [string] $LiveActionFile,
    [string] $LiveActionJson,
    [string] $LiveRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Read-LiveAction {
    if (-not [string]::IsNullOrWhiteSpace($LiveActionFile)) { return (Get-Content -LiteralPath $LiveActionFile -Raw | ConvertFrom-Json) }
    if (-not [string]::IsNullOrWhiteSpace($LiveActionJson)) { return ($LiveActionJson | ConvertFrom-Json) }
    throw "LIVE_ACTION_REQUIRED"
}

$runtime = Initialize-CeoLiveOperationsState -LiveRoot $LiveRoot -StateRoot $StateRoot
$action = Read-LiveAction
if ([string]$action.mode -notin @("DRY_RUN", "LIVE_CONTROLLED_SIMULATED")) { throw "LIVE_EXECUTOR_SIMULATION_ONLY" }
$authorization = (& (Join-Path $PSScriptRoot "ceo-live-authorize.ps1") -LiveActionJson (ConvertTo-CeoEventBusJson -InputObject $action -Depth 30) -LiveRoot $runtime.Root) | ConvertFrom-Json
if ([string]$authorization.decision -ne "ALLOW_LIVE_SIMULATED") { throw "LIVE_ACTION_NOT_AUTHORIZED:$($authorization.decision)" }
$preflight = (& (Join-Path $PSScriptRoot "ceo-live-preflight.ps1") -LiveActionJson (ConvertTo-CeoEventBusJson -InputObject $action -Depth 30) -LiveRoot $runtime.Root) | ConvertFrom-Json
if (-not [bool]$preflight.preflight_ok) { throw "LIVE_PREFLIGHT_FAILED" }

$executionId = [guid]::NewGuid().ToString()
$execution = [ordered]@{
    execution_id = $executionId
    live_action_id = [string]$action.live_action_id
    mode = "LIVE_CONTROLLED_SIMULATED"
    dry_run = $true
    pre_state = [ordered]@{ captured = $true; source = "simulated" }
    post_state = [ordered]@{ captured = $true; source = "simulated" }
    result = "SIMULATED"
    changes = @()
    evidence_path = "<EVIDENCE_PATH>"
    rollback_plan_path = "<RUNTIME_PATH>"
    executed_at = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Simulations "$executionId.live-execution.json") -InputObject $execution
Save-CeoEventBusJson -Path (Join-Path $runtime.Evidence "$executionId.evidence.json") -InputObject ([ordered]@{ execution_id = $executionId; live_real_enabled = $false; changes_applied = $false })
[ordered]@{
    executed = $true
    mode = "LIVE_CONTROLLED_SIMULATED"
    live_real_enabled = $false
    changes_applied = $false
    evidence_path = "<EVIDENCE_PATH>"
} | ConvertTo-Json -Depth 10
