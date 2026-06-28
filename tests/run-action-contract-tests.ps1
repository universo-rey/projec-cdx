Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$result = (& (Join-Path $root "tools\ceo-validate-json.ps1") -Path "contracts") | ConvertFrom-Json
if (-not $result.valid) {
    throw "ACTION_CONTRACTS_INVALID"
}

[ordered]@{
    status = "PASS"
    checked = [int]$result.checked
} | ConvertTo-Json -Depth 6
