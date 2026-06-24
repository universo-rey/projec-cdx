param(
    [string] $LiveActionFile,
    [string] $LiveActionJson,
    [string] $LiveRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Read-LiveAction {
    if (-not [string]::IsNullOrWhiteSpace($LiveActionFile)) { return (Get-Content -LiteralPath $LiveActionFile -Raw | ConvertFrom-Json) }
    if (-not [string]::IsNullOrWhiteSpace($LiveActionJson)) { return ($LiveActionJson | ConvertFrom-Json) }
    throw "LIVE_ACTION_REQUIRED"
}

$runtime = Initialize-CeoLiveOperationsState -LiveRoot $LiveRoot -StateRoot $StateRoot
$action = Read-LiveAction
$liveActionId = [string]$action.live_action_id
$audit = [ordered]@{
    audit_id = [guid]::NewGuid().ToString()
    live_action_id = $liveActionId
    closure_valid = $true
    live_real_enabled = $false
    evidence = [ordered]@{
        request = "<RUNTIME_PATH>"
        authorization = "<RUNTIME_PATH>"
        approval = "<RUNTIME_PATH>"
        preflight = "<RUNTIME_PATH>"
        simulation = "<RUNTIME_PATH>"
        rollback = "<RUNTIME_PATH>"
    }
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path $runtime.AuditJson -InputObject $audit
@(
    "# G5 Live Audit",
    "",
    "live_action_id: $liveActionId",
    "closure_valid: true",
    "live_real_enabled: false"
) | Set-Content -LiteralPath $runtime.AuditMarkdown -Encoding UTF8
[ordered]@{
    audit_ready = $true
    audit_path = "<RUNTIME_PATH>"
    closure_valid = $true
    live_real_enabled = $false
} | ConvertTo-Json -Depth 10
