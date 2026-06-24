param(
    [string] $ActionFile,
    [string] $ActionJson,
    [string] $AuthorizationFile,
    [string] $AuthorizationId,
    [switch] $Apply,
    [string] $ActionRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Read-ActionInput {
    if (-not [string]::IsNullOrWhiteSpace($ActionFile)) {
        return (Get-Content -LiteralPath $ActionFile -Raw | ConvertFrom-Json)
    }
    if (-not [string]::IsNullOrWhiteSpace($ActionJson)) {
        return ($ActionJson | ConvertFrom-Json)
    }
    throw "ACTION_REQUIRED"
}

$runtime = Initialize-CeoActionRuntimeState -ActionRoot $ActionRoot -StateRoot $StateRoot
if ($Apply) {
    throw "G4_EXECUTOR_IS_DRY_RUN_ONLY"
}

$action = Read-ActionInput
if ([string]::IsNullOrWhiteSpace($AuthorizationFile)) {
    if ([string]::IsNullOrWhiteSpace($AuthorizationId)) {
        throw "AUTHORIZATION_REQUIRED"
    }
    $AuthorizationFile = Join-Path $runtime.Authorizations "$AuthorizationId.authorization.json"
}
if (-not (Test-Path -LiteralPath $AuthorizationFile -PathType Leaf)) {
    throw "AUTHORIZATION_NOT_FOUND"
}

$authorization = Read-CeoEventBusJson -Path $AuthorizationFile
$authorized = [bool](Get-CeoEventBusProperty -InputObject $authorization -Name "authorized" -Default $false)
if (-not $authorized -and [string]$authorization.decision -eq "HOLD_OWNER") {
    $approvalPath = Join-Path $runtime.Approvals "$($authorization.authorization_id).approval.json"
    if (Test-Path -LiteralPath $approvalPath -PathType Leaf) {
        $approval = Read-CeoEventBusJson -Path $approvalPath
        $authorized = [bool](Get-CeoEventBusProperty -InputObject $approval -Name "approved" -Default $false)
    }
}

$executionId = [guid]::NewGuid().ToString()
$status = if ($authorized) { "EXECUTED_DRY_RUN" } else { "BLOCKED" }
$execution = [ordered]@{
    execution_id = $executionId
    action_id = [string]$action.action_id
    authorization_id = [string]$authorization.authorization_id
    authorized = $authorized
    dry_run = $true
    status = $status
    evidence_path = "<EVIDENCE_PATH>"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}
$result = [ordered]@{
    result_id = [guid]::NewGuid().ToString()
    execution_id = $executionId
    action_id = [string]$action.action_id
    status = $(if ($authorized) { "DRY_RUN_RECORDED" } else { "BLOCKED" })
    side_effects = $false
    evidence_path = "<EVIDENCE_PATH>"
    summary = $(if ($authorized) { "action dry-run recorded" } else { "action blocked before execution" })
}

Save-CeoEventBusJson -Path (Join-Path $runtime.Executions "$executionId.execution.json") -InputObject $execution
Save-CeoEventBusJson -Path (Join-Path $runtime.Results "$executionId.result.json") -InputObject $result
Save-CeoEventBusJson -Path (Join-Path $runtime.Evidence "$executionId.evidence.json") -InputObject ([ordered]@{
    execution_id = $executionId
    action_id = [string]$action.action_id
    authorized = $authorized
    dry_run = $true
    side_effects = $false
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
})

[ordered]@{
    execution_adapter_ready = $true
    execution_id = $executionId
    action_id = [string]$action.action_id
    authorized = $authorized
    dry_run = $true
    status = $status
    evidence_path = "<EVIDENCE_PATH>"
} | ConvertTo-Json -Depth 10
if (-not $authorized) { exit 40 }
exit 0
