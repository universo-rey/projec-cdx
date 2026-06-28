Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testRoot = $env:SDU_TEST_OUTPUT
if ([string]::IsNullOrWhiteSpace($testRoot)) {
    $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "event-bus"
}
$store = Join-Path $testRoot ("policy-" + [guid]::NewGuid().ToString())

function Publish-TestEvent {
    param(
        [string] $Type,
        [string] $Payload,
        [string] $Risk = "low",
        [switch] $AllowsLive
    )

    return (& (Join-Path $root "tools\ceo-event-publish.ps1") -Type $Type -Payload $Payload -Risk $Risk -AllowsLive:$AllowsLive -EventStoreRoot $store) | ConvertFrom-Json
}

function Get-Decision {
    param([string] $EventId)
    $eventPath = Join-Path (Join-Path $store "inbox") "$EventId.json"
    $raw = & (Join-Path $root "tools\ceo-policy-engine.ps1") -EventFile $eventPath -EventStoreRoot $store
    return ($raw | ConvertFrom-Json)
}

$allow = Publish-TestEvent -Type "G2_POLICY_ALLOW" -Payload '{"action":"dry-run"}'
$allowDecision = Get-Decision -EventId $allow.event_id
if ($allowDecision.decision -ne "ALLOW") {
    throw "ALLOW_POLICY_FAILED"
}

$block = Publish-TestEvent -Type "G2_POLICY_BLOCK" -Payload '{"action":"dry-run"}' -AllowsLive
$blockDecision = Get-Decision -EventId $block.event_id
if ($blockDecision.decision -ne "BLOCK") {
    throw "BLOCK_POLICY_FAILED"
}

$hold = Publish-TestEvent -Type "G2_POLICY_HOLD" -Payload '{"action":"dry-run"}' -Risk "high"
$holdDecision = Get-Decision -EventId $hold.event_id
if ($holdDecision.decision -ne "HOLD_OWNER") {
    throw "HOLD_POLICY_FAILED"
}

[ordered]@{
    status = "PASS"
    allow = $allowDecision.decision
    block = $blockDecision.decision
    hold = $holdDecision.decision
} | ConvertTo-Json -Depth 6
