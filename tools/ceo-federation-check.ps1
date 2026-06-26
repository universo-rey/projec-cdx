param(
    [string] $FederationFile,
    [string] $SchemaFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
if ([string]::IsNullOrWhiteSpace($FederationFile)) {
    $FederationFile = Join-Path $root "contracts\federation-map.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($FederationFile)) {
    $FederationFile = Join-Path $root $FederationFile
}

if ([string]::IsNullOrWhiteSpace($SchemaFile)) {
    $SchemaFile = Join-Path $root "contracts\schemas\federation-map.schema.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($SchemaFile)) {
    $SchemaFile = Join-Path $root $SchemaFile
}

$gate = Test-CeoFederationGate -FederationFile $FederationFile -SchemaFile $SchemaFile
if (-not $gate.IsValid) {
    Write-Output "FEDERATION_HELD:$(@($gate.Issues) -join ';')"
    exit 20
}

Write-Output "FEDERATION_OK"
exit 0
