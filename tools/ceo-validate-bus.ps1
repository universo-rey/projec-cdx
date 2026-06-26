param(
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot
$errors = @()
$warnings = @()
$dirs = @("Inbox", "Processing", "Completed", "Failed", "Dlq", "Traces", "Replay", "Evidence", "State")

foreach ($name in $dirs) {
    if (-not (Test-Path -LiteralPath $bus.$name -PathType Container)) {
        $errors += "MISSING_DIR:$name"
    }
}

$eventFiles = @()
foreach ($name in @("Inbox", "Processing", "Completed", "Failed", "Dlq")) {
    $eventFiles += @(Get-ChildItem -LiteralPath $bus.$name -Filter "*.json" -File -ErrorAction SilentlyContinue)
}

foreach ($file in $eventFiles) {
    $validation = & (Join-Path $PSScriptRoot "ceo-validate-event.ps1") -EventFile $file.FullName
    $result = $validation | ConvertFrom-Json
    if (-not $result.valid) {
        $errors += "INVALID_EVENT:$($file.FullName)"
    }
}

$stateDoc = [ordered]@{
    root = "<EVENT_STORE_PATH>"
    inbox = @(Get-ChildItem -LiteralPath $bus.Inbox -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
    processing = @(Get-ChildItem -LiteralPath $bus.Processing -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
    completed = @(Get-ChildItem -LiteralPath $bus.Completed -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
    failed = @(Get-ChildItem -LiteralPath $bus.Failed -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
    dlq = @(Get-ChildItem -LiteralPath $bus.Dlq -Filter "*.json" -File -ErrorAction SilentlyContinue).Count
    traces = @(Get-ChildItem -LiteralPath $bus.Traces -File -ErrorAction SilentlyContinue).Count
    replay = @(Get-ChildItem -LiteralPath $bus.Replay -File -ErrorAction SilentlyContinue).Count
    evidence = @(Get-ChildItem -LiteralPath $bus.Evidence -File -ErrorAction SilentlyContinue).Count
    state = $(if ($errors.Count -eq 0) { "VALIDATED" } else { "FAILED_FINAL" })
}
Save-CeoEventBusJson -Path (Join-Path $bus.State "event-bus-state.json") -InputObject $stateDoc

[ordered]@{
    valid = ($errors.Count -eq 0)
    schema = "event-bus-state.schema.json"
    warnings = @($warnings)
    errors = @($errors)
    state = $stateDoc
} | ConvertTo-Json -Depth 10

if ($errors.Count -eq 0) { exit 0 }
exit 30
