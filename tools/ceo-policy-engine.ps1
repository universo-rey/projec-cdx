param(
    [string] $EventFile,
    [string] $EventJson,
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot

if (-not [string]::IsNullOrWhiteSpace($EventFile)) {
    $raw = Get-Content -LiteralPath $EventFile -Raw
}
elseif (-not [string]::IsNullOrWhiteSpace($EventJson)) {
    $raw = $EventJson
}
else {
    throw "EVENT_REQUIRED"
}

$event = $raw | ConvertFrom-Json
$reasons = @()
$decision = "ALLOW"

$policy = Get-CeoEventBusProperty -InputObject $event -Name "policy" -Default ([PSCustomObject]@{})
$payloadText = ConvertTo-CeoEventBusJson -InputObject (Get-CeoEventBusProperty -InputObject $event -Name "payload" -Default ([PSCustomObject]@{}))
$forbidden = @(Test-CeoEventBusForbiddenReferences -Text ($raw + $payloadText))
$eventType = [string](Get-CeoEventBusProperty -InputObject $event -Name "event_type" -Default "")
$risk = [string](Get-CeoEventBusProperty -InputObject $event -Name "risk" -Default "low")
$action = [string](Get-CeoEventBusProperty -InputObject (Get-CeoEventBusProperty -InputObject $event -Name "payload" -Default ([PSCustomObject]@{})) -Name "action" -Default "")
$evidence = Get-CeoEventBusProperty -InputObject $event -Name "evidence" -Default ([PSCustomObject]@{})

if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "allows_live" -Default $false)) {
    $decision = "BLOCK"
    $reasons += "allows_live_true"
}
if ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "allows_delete" -Default $false)) {
    $decision = "BLOCK"
    $reasons += "allows_delete_true"
}
if ($forbidden.Count -gt 0) {
    $decision = "BLOCK"
    $reasons += "forbidden_reference:$($forbidden -join ',')"
}
if ($action -match "(?i)\b(push|pr|live-write)\b") {
    $decision = "BLOCK"
    $reasons += "forbidden_action:$action"
}
if ([bool](Get-CeoEventBusProperty -InputObject $evidence -Name "required" -Default $false) -ne $true) {
    $decision = "BLOCK"
    $reasons += "evidence_required_false"
}

if ($decision -ne "BLOCK") {
    if ($risk -in @("high", "critical")) {
        $decision = "HOLD_OWNER"
        $reasons += "risk_requires_owner:$risk"
    }
    elseif ([bool](Get-CeoEventBusProperty -InputObject $policy -Name "requires_owner_gate" -Default $false)) {
        $decision = "HOLD_OWNER"
        $reasons += "requires_owner_gate"
    }
    elseif ($action -match "(?i)config|secret|credential|token") {
        $decision = "HOLD_OWNER"
        $reasons += "sensitive_configuration_action"
    }
}

if ($reasons.Count -eq 0) {
    $reasons += "dry_run_evidence_runtime_isolated_no_live_no_delete_no_push_no_pr"
}

$eventId = [string](Get-CeoEventBusProperty -InputObject $event -Name "event_id" -Default "UNKNOWN")
$correlationId = [string](Get-CeoEventBusProperty -InputObject $event -Name "correlation_id" -Default "")
$record = [ordered]@{
    event_id = $eventId
    event_type = $eventType
    decision = $decision
    reason = ($reasons -join ";")
    required_evidence = $true
    policy_version = "G2_POLICY_MINIMUM"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}

Save-CeoEventBusJson -Path (Join-Path $bus.State "$eventId.policy.json") -InputObject $record
Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State $(if ($decision -eq "ALLOW") { "POLICY_ALLOWED" } elseif ($decision -eq "BLOCK") { "POLICY_BLOCKED" } else { "HOLD_OWNER" }) -CorrelationId $correlationId -PolicyDecision $decision -Message $record.reason -Evidence @($evidence.path) | Out-Null

$record | ConvertTo-Json -Depth 10
if ($decision -eq "ALLOW") { exit 0 }
exit 40
