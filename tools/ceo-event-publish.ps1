param(
    [string] $EventFile,
    [string] $EventJson,
    [string] $Type = "G2_TEST_EVENT",
    [string] $Payload = "{}",
    [string] $Producer = "ceo-event-publish",
    [string] $CorrelationId,
    [string] $CausationId,
    [ValidateSet("low", "medium", "high", "critical")]
    [string] $Priority = "medium",
    [ValidateSet("low", "medium", "high", "critical")]
    [string] $Risk = "low",
    [switch] $RequiresOwnerGate,
    [switch] $AllowsWrite,
    [switch] $AllowsLive,
    [switch] $AllowsDelete,
    [switch] $NoDryRunRequired,
    [string] $EvidencePath = "<EVIDENCE_PATH>",
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot

function ConvertTo-EventObject {
    if (-not [string]::IsNullOrWhiteSpace($EventFile)) {
        return (Get-Content -LiteralPath $EventFile -Raw | ConvertFrom-Json)
    }
    if (-not [string]::IsNullOrWhiteSpace($EventJson)) {
        return ($EventJson | ConvertFrom-Json)
    }

    $payloadObject = $Payload | ConvertFrom-Json
    return [PSCustomObject]@{
        event_type = $Type
        producer = $Producer
        priority = $Priority
        risk = $Risk
        payload = $payloadObject
        policy = [PSCustomObject]@{
            requires_owner_gate = [bool]$RequiresOwnerGate
            allows_write = [bool]$AllowsWrite
            allows_live = [bool]$AllowsLive
            allows_delete = [bool]$AllowsDelete
            dry_run_required = -not [bool]$NoDryRunRequired
        }
        evidence = [PSCustomObject]@{
            required = $true
            path = $EvidencePath
        }
    }
}

$inputEvent = ConvertTo-EventObject
$eventId = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "event_id" -Default "")
if ([string]::IsNullOrWhiteSpace($eventId)) {
    $eventId = [guid]::NewGuid().ToString()
}

$correlation = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "correlation_id" -Default $CorrelationId)
if ([string]::IsNullOrWhiteSpace($correlation)) {
    $correlation = $eventId
}

$policy = Get-CeoEventBusProperty -InputObject $inputEvent -Name "policy" -Default $null
if ($null -eq $policy) {
    $policy = [PSCustomObject]@{
        requires_owner_gate = [bool]$RequiresOwnerGate
        allows_write = [bool]$AllowsWrite
        allows_live = [bool]$AllowsLive
        allows_delete = [bool]$AllowsDelete
        dry_run_required = -not [bool]$NoDryRunRequired
    }
}

$evidence = Get-CeoEventBusProperty -InputObject $inputEvent -Name "evidence" -Default $null
if ($null -eq $evidence) {
    $evidence = [PSCustomObject]@{
        required = $true
        path = $EvidencePath
    }
}

$event = [ordered]@{
    event_id = $eventId
    event_type = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "event_type" -Default (Get-CeoEventBusProperty -InputObject $inputEvent -Name "type" -Default $Type))
    version = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "version" -Default "G2.0")
    timestamp = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "timestamp" -Default (Get-Date).ToUniversalTime().ToString("o"))
    producer = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "producer" -Default $Producer)
    correlation_id = $correlation
    causation_id = (Get-CeoEventBusProperty -InputObject $inputEvent -Name "causation_id" -Default $CausationId)
    priority = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "priority" -Default $Priority)
    risk = [string](Get-CeoEventBusProperty -InputObject $inputEvent -Name "risk" -Default $Risk)
    state = "PERSISTED"
    policy = $policy
    payload = (Get-CeoEventBusProperty -InputObject $inputEvent -Name "payload" -Default ([PSCustomObject]@{}))
    evidence = $evidence
    retry = [ordered]@{
        attempt = 0
        max_attempts = 3
        last_error = $null
        next_action = "none"
    }
}

$eventPath = Join-Path $bus.Inbox "$eventId.json"
Save-CeoEventBusJson -Path $eventPath -InputObject $event
Write-CeoEventBusTrace -Bus $bus -EventId $eventId -State "PERSISTED" -CorrelationId $correlation -Message "event persisted to inbox" -Evidence @($evidence.path) | Out-Null

[ordered]@{
    published = $true
    event_id = $eventId
    state = "PERSISTED"
    path = "<EVENT_STORE_PATH>"
} | ConvertTo-Json -Depth 10
