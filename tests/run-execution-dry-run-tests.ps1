Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "actions\tests"
}
$caseRoot = Join-Path $testRoot ("execute-" + [guid]::NewGuid().ToString())
$actionRoot = Join-Path $caseRoot "actions"

$action = [ordered]@{
    action_id = [guid]::NewGuid().ToString()
    event_id = [guid]::NewGuid().ToString()
    action_type = "LOCAL_EVIDENCE_WRITE"
    risk = "MEDIUM"
    requires_owner_gate = $false
    mode = "DRY_RUN"
    policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
    evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
}
$actionJson = $action | ConvertTo-Json -Depth 20
$auth = (& (Join-Path $root "tools\ceo-action-authorize.ps1") -ActionJson $actionJson -ActionRoot $actionRoot) | ConvertFrom-Json
if ([string]$auth.decision -ne "ALLOW") { throw "ACTION_NOT_ALLOWED_FOR_DRY_RUN" }

$exec = (& (Join-Path $root "tools\ceo-action-executor.ps1") -ActionJson $actionJson -AuthorizationId $auth.authorization_id -ActionRoot $actionRoot) | ConvertFrom-Json
if (-not $exec.execution_adapter_ready) { throw "EXECUTOR_NOT_READY" }
if (-not $exec.dry_run) { throw "EXECUTOR_NOT_DRY_RUN" }
if ([string]$exec.status -ne "EXECUTED_DRY_RUN") { throw "EXECUTION_NOT_RECORDED" }

[ordered]@{
    status = "PASS"
    execution_id = [string]$exec.execution_id
    dry_run = [bool]$exec.dry_run
} | ConvertTo-Json -Depth 6
