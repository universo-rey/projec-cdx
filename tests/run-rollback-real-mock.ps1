Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$liveRoot = New-G6TestLiveRoot -Name "rollback-real"
$session = Start-G6TestLiveSession -LiveRoot $liveRoot
$action = New-G6FormalLiveAction -SessionId ([string]$session.session_id)

$rollback = (& (Join-Path $root "tools\ceo-live-rollback.ps1") -Formal -MockApply -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if (-not [bool]$rollback.rollback_validated) { throw "FORMAL_ROLLBACK_NOT_VALIDATED" }
if (-not [bool]$rollback.rollback_manual_executable) { throw "FORMAL_ROLLBACK_NOT_MANUAL_EXECUTABLE" }
if ([bool]$rollback.rollback_executed_real) { throw "FORMAL_ROLLBACK_EXECUTED_REAL" }

[ordered]@{
    status = "PASS"
    rollback_validated = [bool]$rollback.rollback_validated
    rollback_manual_executable = [bool]$rollback.rollback_manual_executable
    rollback_executed_real = [bool]$rollback.rollback_executed_real
} | ConvertTo-Json -Depth 8
