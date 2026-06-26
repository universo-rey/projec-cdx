param(
    [switch] $RunTests
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

Write-Host "CEO final suite is installed repo-scoped." -ForegroundColor Cyan
Write-Host "Root: $root"
Write-Host "State: <RUNTIME_PATH>"
Write-Host ""
Write-Host "Core commands:" -ForegroundColor Yellow
Write-Host "  .\tools\ceo-event-publish.ps1 -Type RUNTIME_DRIFT -Domain runtime -Priority high -Payload '{""runtimeStatus"":""DRIFT"",""cabinaStatus"":""READY"",""details"":""manual""}'"
Write-Host "  .\tools\ceo-validate-bus.ps1"
Write-Host "  .\tools\ceo-event-worker.ps1"
Write-Host "  .\tools\ceo-trace-export.ps1"
Write-Host ""

if ($RunTests) {
    & (Join-Path $root "tests\run-contract-tests.ps1")
    & (Join-Path $root "tests\run-integration-smoke.ps1")
}
