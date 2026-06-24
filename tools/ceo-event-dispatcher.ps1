param(
    [Parameter(Mandatory = $true)]
    [string] $EventFile,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$validation = Test-CeoEventFile -EventFile $EventFile -StateRoot $state.StateRoot
if ($validation.Status -ne "VALID_EVENT") {
    Write-Output "DISPATCH_REJECTED:$($validation.Status)"
    exit 30
}

$event = Get-Content -LiteralPath $EventFile -Raw | ConvertFrom-Json
$policy = Get-CeoPolicyDecision -EventType $event.type -StateRoot $state.StateRoot
if (-not $policy.allowed -or $policy.requiresApproval) {
    Write-Output "DISPATCH_HELD_BY_POLICY:$($policy.reason)"
    exit 40
}

$result = Invoke-CeoEventDispatch -Event $event -StateRoot $state.StateRoot
Write-Output $result
exit 0
