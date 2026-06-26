Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "event-bus"
}
$store = Join-Path $testRoot ("contract-" + [guid]::NewGuid().ToString())

$jsonValidation = & (Join-Path $root "tools\ceo-validate-json.ps1") -Path "contracts"
$jsonResult = $jsonValidation | ConvertFrom-Json
if (-not $jsonResult.valid) {
    throw "CONTRACT_JSON_INVALID"
}

$publishedRaw = & (Join-Path $root "tools\ceo-event-publish.ps1") -Type "G2_CONTRACT_TEST" -Payload '{"action":"dry-run"}' -EventStoreRoot $store
$published = $publishedRaw | ConvertFrom-Json
if (-not $published.published -or $published.state -ne "PERSISTED") {
    throw "PUBLISH_CONTRACT_FAILED"
}

$eventPath = Join-Path (Join-Path $store "inbox") "$($published.event_id).json"
$validationRaw = & (Join-Path $root "tools\ceo-validate-event.ps1") -EventFile $eventPath
$validation = $validationRaw | ConvertFrom-Json
if (-not $validation.valid) {
    throw "EVENT_CONTRACT_INVALID"
}

[ordered]@{
    status = "PASS"
    checked = @("contracts", "event.schema.json", "publisher")
    event_id = $published.event_id
} | ConvertTo-Json -Depth 6
