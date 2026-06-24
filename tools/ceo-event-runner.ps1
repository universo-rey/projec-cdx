param(
    [Alias("Workers")]
    [int] $ExecutionPasses = 1,
    [int] $MaxEvents = 5,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$executionAdapter = Join-Path $PSScriptRoot "ceo-execution-adapter.ps1"
$runs = 0

for ($i = 1; $i -le $ExecutionPasses; $i++) {
    & $executionAdapter -MaxEvents $MaxEvents -StateRoot $StateRoot -AdapterId "local"
    $runs++
}

Write-Output "EXECUTION_RUNNER_COMPLETED:$runs"
