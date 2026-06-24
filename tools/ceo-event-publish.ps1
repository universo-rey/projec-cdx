param(
    [Parameter(Mandatory = $true)]
    [string] $Type,

    [string] $Domain = "runtime",

    [ValidateSet("low", "medium", "high", "critical")]
    [string] $Priority = "medium",

    [string] $Payload = "{}",
    [string] $CabinaId = "CABINA_LOCAL",
    [Alias("WorkerId")]
    [string] $ExecutionAdapterId = "ceo-execution-adapter.ps1",
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot

try {
    $payloadObj = $Payload | ConvertFrom-Json
}
catch {
    Add-Content -LiteralPath $state.InvalidLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] INVALID_PAYLOAD_JSON type=$Type error=$($_.Exception.Message)" -Encoding UTF8
    Write-Output "EVENT_REJECTED:INVALID_PAYLOAD_JSON"
    exit 30
}

$event = [ordered]@{
    eventId = [guid]::NewGuid().ToString()
    traceId = [guid]::NewGuid().ToString()
    spanId = [guid]::NewGuid().ToString()
    parentSpanId = $null
    type = $Type
    domain = $Domain
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    status = "queued"
    priority = $Priority
    schemaVersion = "v1.0"
    executionSurface = (Get-CeoExecutionSurface -AdapterId "local")
    payload = $payloadObj
    metadata = [ordered]@{
        cabinaId = $CabinaId
        executionAdapterId = $ExecutionAdapterId
        source = "ceo-event-publish"
        governance = (Get-CeoDefaultGovernance -Agent "bus_agent" -Tool "ceo-event-publish.ps1" -Evidence "<RUNTIME_PATH>/bus/queue.jsonl" -Validator "ceo-validate-event.ps1")
    }
}

$tempEvent = New-CeoSuiteTempFile -StateRoot $state.StateRoot -Prefix "publish-event"
try {
    $event | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $tempEvent -Encoding UTF8
    $result = Test-CeoEventFile -EventFile $tempEvent -StateRoot $state.StateRoot
    $line = ConvertTo-CeoJsonLine -InputObject $event

    if ($result.Status -eq "VALID_EVENT") {
        Add-CeoJsonlLine -Path $state.QueueFile -Line $line
        Write-Output "EVENT_QUEUED"
        exit 0
    }

    Add-CeoJsonlLine -Path $state.FailedFile -Line $line
    Add-Content -LiteralPath $state.InvalidLog -Value "[$((Get-Date).ToUniversalTime().ToString('o'))] INVALID_EVENT type=$Type reason=$($result.Status)" -Encoding UTF8
    Write-Output "EVENT_REJECTED:$($result.Status)"
    exit 30
}
finally {
    Remove-Item -LiteralPath $tempEvent -ErrorAction SilentlyContinue
}
