Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$liveRoot = New-G6TestLiveRoot -Name "multi-actor"
$action = New-G6FormalLiveAction

$complete = (& (Join-Path $root "tools\ceo-live-owner-gate.ps1") -Formal -LiveActionJson ($action | ConvertTo-Json -Depth 30) -ApproveRole OWNER_OPERATIONAL,OWNER_CONTROL,DIRECCION -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$complete.approval_status -ne "COMPLETE") { throw "FORMAL_MULTI_ACTOR_NOT_COMPLETE" }
if (@($complete.required_roles).Count -ne 3) { throw "FORMAL_ROLE_COUNT_INVALID" }

$pending = (& (Join-Path $root "tools\ceo-live-owner-gate.ps1") -Formal -LiveActionJson ($action | ConvertTo-Json -Depth 30) -ApproveRole OWNER_OPERATIONAL,OWNER_CONTROL -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$pending.approval_status -ne "PENDING") { throw "FORMAL_MULTI_ACTOR_MISSING_ROLE_NOT_PENDING" }

[ordered]@{
    status = "PASS"
    complete = [string]$complete.approval_status
    pending = [string]$pending.approval_status
    roles = @($complete.required_roles)
} | ConvertTo-Json -Depth 8
