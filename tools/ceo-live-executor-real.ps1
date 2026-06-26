param(
    [string] $LiveActionFile,
    [string] $LiveActionJson,
    [switch] $MockApply,
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
$actionJson = ConvertTo-CeoEventBusJson -InputObject $action -Depth 30

if (-not $MockApply) {
    [ordered]@{
        executed = $false
        decision = "BLOCK"
        reason = "mock_apply_required_for_codex_execution"
        live_real_enabled = $false
        changes_applied = $false
    } | ConvertTo-Json -Depth 10
    exit 40
}

$authorization = (& (Join-Path $PSScriptRoot "ceo-live-authorize-formal.ps1") -LiveActionJson $actionJson -LiveRoot $runtime.Root) | ConvertFrom-Json
if ([string]$authorization.decision -ne "ALLOW_LIVE_REAL_FORMAL") { throw "FORMAL_LIVE_ACTION_NOT_AUTHORIZED:$($authorization.decision)" }

$guardrails = (& (Join-Path $PSScriptRoot "ceo-live-guardrails-strict.ps1") -LiveActionJson $actionJson -LiveRoot $runtime.Root) | ConvertFrom-Json
if (-not [bool]$guardrails.strict_guardrails_ok) { throw "STRICT_GUARDRAILS_FAILED" }

$executionId = [guid]::NewGuid().ToString()
$execution = [ordered]@{
    execution_id = $executionId
    live_action_id = [string]$action.live_action_id
    session_id = [string]$authorization.session_id
    mode = "LIVE_CONTROLLED_REAL"
    real_execution_mode = "MOCKED"
    live_real_enabled = $true
    external_write_enabled = $false
    pre_state = [ordered]@{ captured = $true; source = "mocked-pre-state" }
    post_state = [ordered]@{ captured = $true; source = "mocked-post-state" }
    result = "MOCKED_REAL_READY"
    changes_applied = $false
    evidence_path = "<EVIDENCE_PATH>"
    rollback_plan_path = "<RUNTIME_PATH>"
    executed_at = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Executions "$executionId.live-real-execution.json") -InputObject $execution
Save-CeoEventBusJson -Path (Join-Path $runtime.Evidence "$executionId.formal-evidence.json") -InputObject ([ordered]@{ execution_id = $executionId; live_real_enabled = $true; changes_applied = $false; mocked = $true })
$accountabilityRecord = [ordered]@{
    execution_id = $executionId
    live_action_id = [string]$action.live_action_id
    session_id = [string]$authorization.session_id
    decision = "MOCKED_REAL_READY"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}
Add-Content -LiteralPath $runtime.AccountabilityLog -Encoding UTF8 -Value ($accountabilityRecord | ConvertTo-Json -Depth 10 -Compress)

[ordered]@{
    executed = $true
    mode = "LIVE_CONTROLLED_REAL"
    real_execution_mode = "MOCKED"
    live_real_enabled = $true
    changes_applied = $false
    pre_state_captured = $true
    post_state_captured = $true
    evidence_path = "<EVIDENCE_PATH>"
    accountability_recorded = $true
} | ConvertTo-Json -Depth 10
