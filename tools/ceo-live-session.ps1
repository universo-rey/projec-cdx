param(
    [ValidateSet("status", "start", "shutdown")]
    [string] $Action = "status",
    [string] $SessionId,
    [string] $Owner = "OWNER_CONTROL",
    [string] $Reason = "formal-live-governed-session",
    [string] $LiveRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$runtime = Initialize-CeoLiveOperationsState -LiveRoot $LiveRoot -StateRoot $StateRoot

if ($Action -eq "status") {
    Get-CeoLiveSessionStatus -LiveRoot $runtime.Root | ConvertTo-Json -Depth 10
    exit 0
}

if ($Action -eq "start") {
    if ([string]::IsNullOrWhiteSpace($SessionId)) {
        $SessionId = [guid]::NewGuid().ToString()
    }

    $session = [ordered]@{
        session_id = $SessionId
        state = "ACTIVE"
        live_real_enabled = $true
        live_mode = "CONTROLLED"
        owner = $Owner
        reason = $Reason
        kill_switch_available = $true
        started_at = (Get-Date).ToUniversalTime().ToString("o")
        shutdown_at = $null
    }
    Save-CeoEventBusJson -Path $runtime.SessionState -InputObject $session
    Save-CeoEventBusJson -Path (Join-Path $runtime.Sessions "$SessionId.session.json") -InputObject $session
    $session | ConvertTo-Json -Depth 10
    exit 0
}

$current = Get-CeoLiveSessionStatus -LiveRoot $runtime.Root
$sessionIdToClose = if ([string]::IsNullOrWhiteSpace($SessionId)) { [string]$current.session_id } else { $SessionId }
$session = [ordered]@{
    session_id = $sessionIdToClose
    state = "SHUTDOWN"
    live_real_enabled = $false
    live_mode = "CONTROLLED"
    owner = $Owner
    reason = $Reason
    kill_switch_available = $true
    started_at = $(if ($current.PSObject.Properties["started_at"]) { $current.started_at } else { $null })
    shutdown_at = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path $runtime.SessionState -InputObject $session
if (-not [string]::IsNullOrWhiteSpace($sessionIdToClose)) {
    Save-CeoEventBusJson -Path (Join-Path $runtime.Sessions "$sessionIdToClose.session.json") -InputObject $session
}
$session | ConvertTo-Json -Depth 10
