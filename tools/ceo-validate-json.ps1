param(
    [Parameter(Mandatory = $true)]
    [string] $JsonFile,

    [Parameter(Mandatory = $true)]
    [string] $SchemaFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$result = Test-CeoJsonFileAgainstSchema -JsonFile $JsonFile -SchemaFile $SchemaFile
Write-Output $result.Status
exit $result.ExitCode
