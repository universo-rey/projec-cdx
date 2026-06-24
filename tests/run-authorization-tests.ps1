Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "actions\tests"
}
$caseRoot = Join-Path $testRoot ("authorization-" + [guid]::NewGuid().ToString())
$actionRoot = Join-Path $caseRoot "actions"
New-Item -ItemType Directory -Force -Path $caseRoot | Out-Null

function New-ActionDoc {
    param(
        [string] $ActionType,
        [string] $Risk,
        [bool] $OwnerGate = $false
    )
    return [ordered]@{
        action_id = [guid]::NewGuid().ToString()
        event_id = [guid]::NewGuid().ToString()
        action_type = $ActionType
        risk = $Risk
        requires_owner_gate = $OwnerGate
        mode = "DRY_RUN"
        policy = [ordered]@{ live_write = $false; external = $false; delete = $false; dry_run_required = $true }
        evidence = [ordered]@{ required = $true; path = "<EVIDENCE_PATH>" }
    }
}

$low = New-ActionDoc -ActionType "NOOP" -Risk "LOW"
$lowAuth = (& (Join-Path $root "tools\ceo-action-authorize.ps1") -ActionJson ($low | ConvertTo-Json -Depth 20) -ActionRoot $actionRoot) | ConvertFrom-Json
if ([string]$lowAuth.decision -ne "ALLOW") { throw "LOW_ACTION_NOT_ALLOWED" }

$high = New-ActionDoc -ActionType "REPLAY_DRY_RUN" -Risk "HIGH" -OwnerGate $true
$highAuth = (& (Join-Path $root "tools\ceo-action-authorize.ps1") -ActionJson ($high | ConvertTo-Json -Depth 20) -ActionRoot $actionRoot) | ConvertFrom-Json
if ([string]$highAuth.decision -ne "HOLD_OWNER") { throw "HIGH_ACTION_NOT_HELD" }

$unknown = New-ActionDoc -ActionType "UNKNOWN_ACTION" -Risk "LOW"
$unknownRaw = & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-action-authorize.ps1") -ActionJson ($unknown | ConvertTo-Json -Depth 20) -ActionRoot $actionRoot
$unknownAuth = $unknownRaw | ConvertFrom-Json
if ([string]$unknownAuth.decision -ne "BLOCK") { throw "UNKNOWN_ACTION_NOT_BLOCKED" }

[ordered]@{
    status = "PASS"
    allow = [string]$lowAuth.decision
    hold_owner = [string]$highAuth.decision
    block = [string]$unknownAuth.decision
} | ConvertTo-Json -Depth 6
