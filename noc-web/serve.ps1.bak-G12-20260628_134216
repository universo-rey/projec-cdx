$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root
Write-Host "Serving SDU NOC Web from $root" -ForegroundColor Cyan
Write-Host "Open http://localhost:8080/noc-web/" -ForegroundColor Green
Write-Host "Owner actions endpoint enabled at POST /execute" -ForegroundColor Yellow
python (Join-Path $PSScriptRoot "owner_actions_server.py")
