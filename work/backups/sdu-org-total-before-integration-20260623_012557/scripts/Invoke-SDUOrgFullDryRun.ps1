param()

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "SDU Full DryRun iniciado en $root"

& .\scripts\Invoke-SDUOrgPreflight.ps1
& .\scripts\Invoke-SDUAgentDiscovery.ps1
& .\scripts\Invoke-SDUOrgInventory.ps1
& .\scripts\Invoke-SDUOrgClassifyMultiAgent.ps1
& .\scripts\Invoke-SDUOrgPlan.ps1
& .\scripts\Invoke-SDUOrgValidate.ps1
& .\scripts\Invoke-SDUOrgReport.ps1

Write-Host "SDU Full DryRun completado. Ver out/org-report.md"
