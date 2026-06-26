param(
    [string] $LiveActionFile,
    [string] $LiveActionJson,
    [switch] $Formal,
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
$session = Get-CeoLiveSessionStatus -LiveRoot $runtime.Root
$formalAuthorization = Test-Path -LiteralPath (Join-Path $runtime.State "$liveActionId.formal-authorization.json") -PathType Leaf
$strictGuardrails = Test-Path -LiteralPath (Join-Path $runtime.Preflight "$liveActionId.strict-guardrails.json") -PathType Leaf
$executionCount = @(Get-ChildItem -LiteralPath $runtime.Executions -Filter "*.live-real-execution.json" -File -ErrorAction SilentlyContinue | Where-Object {
    try {
        $item = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
        [string]$item.live_action_id -eq $liveActionId
    }
    catch {
        $false
    }
}).Count
$rollbackCount = @(Get-ChildItem -LiteralPath $runtime.Rollback -Filter "*.rollback.json" -File -ErrorAction SilentlyContinue | Where-Object {
    try {
        $item = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
        [string]$item.live_action_id -eq $liveActionId
    }
    catch {
        $false
    }
}).Count
$accountabilityReady = Test-Path -LiteralPath $runtime.AccountabilityLog -PathType Leaf
$formalReady = (-not $Formal) -or ($formalAuthorization -and $strictGuardrails -and $executionCount -gt 0 -and $rollbackCount -gt 0 -and $accountabilityReady)
$audit = [ordered]@{
    audit_id = [guid]::NewGuid().ToString()
    live_action_id = $liveActionId
    closure_valid = $formalReady
    formal = [bool]$Formal
    session_state = [string](Get-CeoEventBusProperty -InputObject $session -Name "state" -Default "DISABLED")
    session_id = [string](Get-CeoEventBusProperty -InputObject $session -Name "session_id" -Default "")
    live_real_enabled = [bool]($Formal -and (Test-CeoLiveSessionActive -Session $session))
    external_write_enabled = $false
    accountability_ready = [bool]$accountabilityReady
    evidence = [ordered]@{
        request = "<RUNTIME_PATH>"
        authorization = "<RUNTIME_PATH>"
        formal_authorization = "<RUNTIME_PATH>"
        approval = "<RUNTIME_PATH>"
        preflight = "<RUNTIME_PATH>"
        strict_guardrails = "<RUNTIME_PATH>"
        simulation = "<RUNTIME_PATH>"
        live_execution = "<RUNTIME_PATH>"
        rollback = "<RUNTIME_PATH>"
        accountability = "<RUNTIME_PATH>"
    }
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path $runtime.AuditJson -InputObject $audit
@(
    $(if ($Formal) { "# G6 Formal Live Audit" } else { "# G5 Live Audit" }),
    "",
    "live_action_id: $liveActionId",
    "closure_valid: $formalReady",
    "formal: $([bool]$Formal)",
    "session_state: $([string](Get-CeoEventBusProperty -InputObject $session -Name "state" -Default "DISABLED"))",
    "live_real_enabled: $([bool]($Formal -and (Test-CeoLiveSessionActive -Session $session)))",
    "accountability_ready: $([bool]$accountabilityReady)"
) | Set-Content -LiteralPath $runtime.AuditMarkdown -Encoding UTF8
[ordered]@{
    audit_ready = $true
    audit_path = "<RUNTIME_PATH>"
    closure_valid = $formalReady
    formal = [bool]$Formal
    session_state = [string](Get-CeoEventBusProperty -InputObject $session -Name "state" -Default "DISABLED")
    live_real_enabled = [bool]($Formal -and (Test-CeoLiveSessionActive -Session $session))
    accountability_ready = [bool]$accountabilityReady
} | ConvertTo-Json -Depth 10
