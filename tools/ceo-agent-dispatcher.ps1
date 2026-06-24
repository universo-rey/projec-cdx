param(
    [Parameter(Mandatory = $true)]
    [string] $EventFile,

    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$router = Join-Path $PSScriptRoot "ceo-runtime-router.ps1"
$output = & $router -EventFile $EventFile -StateRoot $StateRoot
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Output $output
    exit $exitCode
}

$text = ($output -join ";")
$text = $text -replace "^RUNTIME_ROUTER_REJECTED:", "AGENT_DISPATCH_REJECTED:"
$text = $text -replace "^RUNTIME_ROUTER_SKIPPED:", "AGENT_DISPATCH_SKIPPED:"
$text = $text -replace "^RUNTIME_ROUTER_QUEUED:", "AGENT_DECISION_QUEUED:"
Write-Output $text
exit 0
