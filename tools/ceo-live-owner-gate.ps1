param(
    [string] $LiveActionFile,
    [string] $LiveActionJson,
    [string[]] $ApproveRole = @(),
    [switch] $Reject,
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
$required = @(Get-CeoRequiredLiveOwnerRoles)
$approvals = @()
foreach ($role in $ApproveRole) {
    if ($role -in $required) {
        $approvals += [ordered]@{
            role = $role
            approved = (-not $Reject)
            approved_at = (Get-Date).ToUniversalTime().ToString("o")
        }
    }
}
$approvedRoles = @($approvals | Where-Object { [bool]$_["approved"] } | ForEach-Object { [string]$_["role"] } | Select-Object -Unique)
$missingRoles = @($required | Where-Object { $_ -notin $approvedRoles })
$complete = ($missingRoles.Count -eq 0)
$status = if ($Reject) { "REJECTED" } elseif ($complete) { "COMPLETE" } else { "PENDING" }
$approval = [ordered]@{
    approval_id = [guid]::NewGuid().ToString()
    live_action_id = $liveActionId
    required_roles = $required
    approvals = @($approvals)
    approval_status = $status
    approved_at = $(if ($complete -and -not $Reject) { (Get-Date).ToUniversalTime().ToString("o") } else { $null })
    evidence_path = "<EVIDENCE_PATH>"
}
Save-CeoEventBusJson -Path (Join-Path $runtime.Approvals "$liveActionId.approval.json") -InputObject $approval
$approval | ConvertTo-Json -Depth 10
