param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $EventFile,

    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$result = Test-CeoEventFile -EventFile $EventFile -StateRoot $StateRoot
Write-Output $result.Status
exit $result.ExitCode
