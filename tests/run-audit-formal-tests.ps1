Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$liveRoot = New-G6TestLiveRoot -Name "audit-formal"
$session = Start-G6TestLiveSession -LiveRoot $liveRoot
$action = New-G6FormalLiveAction -SessionId ([string]$session.session_id)
$actionJson = $action | ConvertTo-Json -Depth 30

& (Join-Path $root "tools\ceo-live-authorize-formal.ps1") -LiveActionJson $actionJson -LiveRoot $liveRoot | Out-Null
& (Join-Path $root "tools\ceo-live-guardrails-strict.ps1") -LiveActionJson $actionJson -LiveRoot $liveRoot | Out-Null
& (Join-Path $root "tools\ceo-live-executor-real.ps1") -LiveActionJson $actionJson -LiveRoot $liveRoot -MockApply | Out-Null
& (Join-Path $root "tools\ceo-live-rollback.ps1") -Formal -MockApply -LiveActionJson $actionJson -LiveRoot $liveRoot | Out-Null

$audit = (& (Join-Path $root "tools\ceo-live-audit.ps1") -Formal -LiveActionJson $actionJson -LiveRoot $liveRoot) | ConvertFrom-Json
if (-not [bool]$audit.audit_ready) { throw "FORMAL_AUDIT_NOT_READY" }
if (-not [bool]$audit.closure_valid) { throw "FORMAL_AUDIT_CLOSURE_INVALID" }
if (-not [bool]$audit.live_real_enabled) { throw "FORMAL_AUDIT_LIVE_REAL_NOT_ENABLED" }
if (-not [bool]$audit.accountability_ready) { throw "FORMAL_AUDIT_ACCOUNTABILITY_NOT_READY" }

[ordered]@{
    status = "PASS"
    audit_ready = [bool]$audit.audit_ready
    closure_valid = [bool]$audit.closure_valid
    live_real_enabled = [bool]$audit.live_real_enabled
    accountability_ready = [bool]$audit.accountability_ready
} | ConvertTo-Json -Depth 8
