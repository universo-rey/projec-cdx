Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$liveRoot = New-G6TestLiveRoot -Name "live-exec-real"
$session = Start-G6TestLiveSession -LiveRoot $liveRoot
$action = New-G6FormalLiveAction -SessionId ([string]$session.session_id)
$actionJson = $action | ConvertTo-Json -Depth 30

$blockedActionPath = Join-Path $liveRoot "blocked-real-action.json"
New-Item -ItemType Directory -Force -Path $liveRoot | Out-Null
$actionJson | Set-Content -LiteralPath $blockedActionPath -Encoding UTF8
$blockedRaw = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-live-executor-real.ps1") -LiveActionFile $blockedActionPath -LiveRoot $liveRoot
$blocked = $blockedRaw | ConvertFrom-Json
if ([string]$blocked.decision -ne "BLOCK") { throw "REAL_EXECUTOR_WITHOUT_MOCK_NOT_BLOCKED" }

$executed = (& (Join-Path $root "tools\ceo-live-executor-real.ps1") -LiveActionJson $actionJson -LiveRoot $liveRoot -MockApply) | ConvertFrom-Json
if (-not [bool]$executed.executed) { throw "REAL_EXECUTOR_NOT_EXECUTED_IN_MOCK_MODE" }
if ([string]$executed.mode -ne "LIVE_CONTROLLED_REAL") { throw "REAL_EXECUTOR_MODE_INVALID" }
if ([string]$executed.real_execution_mode -ne "MOCKED") { throw "REAL_EXECUTOR_NOT_MOCKED" }
if ([bool]$executed.changes_applied) { throw "REAL_EXECUTOR_APPLIED_CHANGES" }
if (-not [bool]$executed.pre_state_captured) { throw "PRE_STATE_NOT_CAPTURED" }
if (-not [bool]$executed.post_state_captured) { throw "POST_STATE_NOT_CAPTURED" }
if (-not [bool]$executed.accountability_recorded) { throw "ACCOUNTABILITY_NOT_RECORDED" }

[ordered]@{
    status = "PASS"
    blocked_without_mock = [string]$blocked.decision
    executed = [bool]$executed.executed
    mode = [string]$executed.mode
    changes_applied = [bool]$executed.changes_applied
} | ConvertTo-Json -Depth 8
