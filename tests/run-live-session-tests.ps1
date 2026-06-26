Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$liveRoot = New-G6TestLiveRoot -Name "session"

$initial = (& (Join-Path $root "tools\ceo-live-session.ps1") -Action status -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$initial.state -ne "DISABLED") { throw "INITIAL_SESSION_NOT_DISABLED" }

$active = Start-G6TestLiveSession -LiveRoot $liveRoot
if ([string]$active.state -ne "ACTIVE") { throw "SESSION_NOT_ACTIVE" }
if (-not [bool]$active.live_real_enabled) { throw "SESSION_LIVE_REAL_NOT_ENABLED" }
if (-not [bool]$active.kill_switch_available) { throw "KILL_SWITCH_NOT_AVAILABLE" }

$shutdown = (& (Join-Path $root "tools\ceo-live-session.ps1") -Action shutdown -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$shutdown.state -ne "SHUTDOWN") { throw "SESSION_NOT_SHUTDOWN" }
if ([bool]$shutdown.live_real_enabled) { throw "SESSION_LIVE_REAL_STILL_ENABLED" }

[ordered]@{
    status = "PASS"
    initial = [string]$initial.state
    active = [string]$active.state
    shutdown = [string]$shutdown.state
} | ConvertTo-Json -Depth 6
