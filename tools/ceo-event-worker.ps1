param(
    [int] $MaxEvents = 5,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$adapter = Join-Path $PSScriptRoot "ceo-execution-adapter.ps1"
$output = & $adapter -MaxEvents $MaxEvents -StateRoot $StateRoot -AdapterId "local"
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Output $output
    exit $exitCode
}

$text = ($output -join ";")
$text = $text -replace "^EXECUTION_ADAPTER_DONE:", "WORKER_DONE:"
Write-Output $text
exit 0
