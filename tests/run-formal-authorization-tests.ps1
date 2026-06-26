Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "live-g6-test-helpers.ps1")

$root = Get-G6RepoRoot
$liveRoot = New-G6TestLiveRoot -Name "formal-auth"
$session = Start-G6TestLiveSession -LiveRoot $liveRoot

$complete = New-G6FormalLiveAction -SessionId ([string]$session.session_id)
$allowed = (& (Join-Path $root "tools\ceo-live-authorize-formal.ps1") -LiveActionJson ($complete | ConvertTo-Json -Depth 30) -LiveRoot $liveRoot) | ConvertFrom-Json
if ([string]$allowed.decision -ne "ALLOW_LIVE_REAL_FORMAL") { throw "FORMAL_AUTH_NOT_ALLOWED" }
if (-not [bool]$allowed.live_real_enabled) { throw "FORMAL_AUTH_LIVE_REAL_NOT_ENABLED" }

$missingRole = New-G6FormalLiveAction -SessionId ([string]$session.session_id) -MissingDireccion
$missingRolePath = Join-Path $liveRoot "missing-role-action.json"
New-Item -ItemType Directory -Force -Path $liveRoot | Out-Null
$missingRole | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $missingRolePath -Encoding UTF8
$blockedRaw = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tools\ceo-live-authorize-formal.ps1") -LiveActionFile $missingRolePath -LiveRoot $liveRoot
$blocked = $blockedRaw | ConvertFrom-Json
if ([string]$blocked.decision -ne "BLOCK") { throw "MISSING_DIRECCION_NOT_BLOCKED" }
if ([string]$blocked.reason -notmatch "DIRECCION") { throw "MISSING_DIRECCION_REASON_NOT_RECORDED" }

[ordered]@{
    status = "PASS"
    allowed = [string]$allowed.decision
    blocked = [string]$blocked.decision
} | ConvertTo-Json -Depth 8
