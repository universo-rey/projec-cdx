$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root
Write-Host "Serving SDU NOC Web from $root" -ForegroundColor Cyan
Write-Host "Open http://localhost:8080/noc-web/" -ForegroundColor Green
python -m http.server 8080
