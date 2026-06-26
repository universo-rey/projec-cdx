param(
    [string] $AuthorizationFile,
    [string] $AuthorizationId,
    [switch] $Approve,
    [string] $Owner = "LOCAL_OWNER",
    [string] $Note = "manual local approval",
    [string] $ActionRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$runtime = Initialize-CeoActionRuntimeState -ActionRoot $ActionRoot -StateRoot $StateRoot
if ([string]::IsNullOrWhiteSpace($AuthorizationFile)) {
    if ([string]::IsNullOrWhiteSpace($AuthorizationId)) {
        throw "AUTHORIZATION_ID_REQUIRED"
    }
    $AuthorizationFile = Join-Path $runtime.Authorizations "$AuthorizationId.authorization.json"
}
if (-not (Test-Path -LiteralPath $AuthorizationFile -PathType Leaf)) {
    throw "AUTHORIZATION_NOT_FOUND"
}

$authorization = Read-CeoEventBusJson -Path $AuthorizationFile
$approval = [ordered]@{
    approval_id = [guid]::NewGuid().ToString()
    authorization_id = [string]$authorization.authorization_id
    action_id = [string]$authorization.action_id
    owner = $Owner
    approved = [bool]$Approve
    mode = "LOCAL_MANUAL_APPROVAL"
    note = $Note
    evidence_path = "<EVIDENCE_PATH>"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Approvals "$($approval.authorization_id).approval.json") -InputObject $approval

[ordered]@{
    owner_gate_ready = $true
    authorization_id = [string]$authorization.authorization_id
    action_id = [string]$authorization.action_id
    approved = [bool]$Approve
    mode = "LOCAL_MANUAL_APPROVAL"
    evidence_path = "<EVIDENCE_PATH>"
} | ConvertTo-Json -Depth 10
