Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$registerPath = Join-Path $root "operativa\accountability\live-actions-register.json"
if (-not (Test-Path -LiteralPath $registerPath -PathType Leaf)) { throw "ACCOUNTABILITY_REGISTER_MISSING" }

$register = Get-Content -LiteralPath $registerPath -Raw | ConvertFrom-Json
if ([string]$register.state -ne "FORMAL_LIVE_ENABLEMENT") { throw "ACCOUNTABILITY_REGISTER_STATE_INVALID" }
if (-not [bool]$register.live_real_enabled) { throw "ACCOUNTABILITY_REGISTER_LIVE_REAL_NOT_ENABLED" }
if ([bool]$register.external_write_enabled) { throw "ACCOUNTABILITY_REGISTER_EXTERNAL_WRITE_ENABLED" }
if (@($register.required_roles).Count -ne 3) { throw "ACCOUNTABILITY_REGISTER_ROLE_COUNT_INVALID" }

$liveRoot = New-G6TestLiveRoot -Name "accountability"
$session = Start-G6TestLiveSession -LiveRoot $liveRoot
$action = New-G6FormalLiveAction -SessionId ([string]$session.session_id)
& (Join-Path $root "tools\ceo-live-executor-real.ps1") -LiveActionJson ($action | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot -MockApply | Out-Null

$logPath = Join-Path (Join-Path $liveRoot "accountability") "live-actions.jsonl"
if (-not (Test-Path -LiteralPath $logPath -PathType Leaf)) { throw "ACCOUNTABILITY_RUNTIME_LOG_MISSING" }
$records = @(Get-Content -LiteralPath $logPath)
if ($records.Count -lt 1) { throw "ACCOUNTABILITY_RUNTIME_LOG_EMPTY" }

[ordered]@{
    status = "PASS"
    register = [string]$register.register_id
    runtime_records = $records.Count
} | ConvertTo-Json -Depth 8
