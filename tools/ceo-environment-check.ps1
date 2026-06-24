param(
    [string] $ContractFile,
    [string] $SchemaFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
if ([string]::IsNullOrWhiteSpace($ContractFile)) {
    $ContractFile = Join-Path $root "contracts\environment-contract.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($ContractFile)) {
    $ContractFile = Join-Path $root $ContractFile
}

if ([string]::IsNullOrWhiteSpace($SchemaFile)) {
    $SchemaFile = Join-Path $root "contracts\schemas\environment-contract.schema.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($SchemaFile)) {
    $SchemaFile = Join-Path $root $SchemaFile
}

$gate = Test-CeoEnvironmentGate -ContractFile $ContractFile -SchemaFile $SchemaFile
[ordered]@{
    status = [string] $gate.Status
    contractId = [string] $gate.ContractId
    signals = @($gate.Signals)
    issues = @($gate.Issues)
    sensitiveContentRead = $false
} | ConvertTo-Json -Depth 20
if (-not $gate.IsValid) { exit 20 }
exit 0
