param(
    [string] $StateRoot,
    [string] $QueueFile,
    [string] $FailedFile,
    [string] $InvalidLog
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
if ([string]::IsNullOrWhiteSpace($QueueFile)) { $QueueFile = $state.QueueFile }
if ([string]::IsNullOrWhiteSpace($FailedFile)) { $FailedFile = $state.FailedFile }
if ([string]::IsNullOrWhiteSpace($InvalidLog)) { $InvalidLog = $state.InvalidLog }

Ensure-CeoFile -Path $QueueFile
Ensure-CeoFile -Path $FailedFile
Ensure-CeoFile -Path $InvalidLog

$lines = @(Get-CeoJsonlLines -Path $QueueFile)
$valid = @()
$invalidCount = 0

foreach ($line in $lines) {
    $tempEvent = New-CeoSuiteTempFile -StateRoot $state.StateRoot -Prefix "bus-event"
    try {
        $line | Set-Content -LiteralPath $tempEvent -Encoding UTF8
        $result = Test-CeoEventFile -EventFile $tempEvent -StateRoot $state.StateRoot
        if ($result.Status -eq "VALID_EVENT") {
            $valid += $line
        }
        else {
            Add-CeoJsonlLine -Path $FailedFile -Line $line
            Add-Content -LiteralPath $InvalidLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] INVALID_IN_BUS reason=$($result.Status)" -Encoding UTF8
            $invalidCount++
        }
    }
    finally {
        Remove-Item -LiteralPath $tempEvent -ErrorAction SilentlyContinue
    }
}

Set-Content -LiteralPath $QueueFile -Value $valid -Encoding UTF8

if ($invalidCount -eq 0) {
    Write-Output "BUS_VALID"
    exit 0
}

Write-Output "BUS_INVALID:$invalidCount"
exit 40
