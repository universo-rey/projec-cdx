param(
    [Parameter(Mandatory = $true)]
    [string] $EventType,

    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$decision = Get-CeoPolicyDecision -EventType $EventType -StateRoot $StateRoot
$decision | ConvertTo-Json -Depth 10
if (-not $decision.allowed -or $decision.requiresApproval) { exit 40 }
exit 0
