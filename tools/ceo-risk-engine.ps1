param(
    [string] $ActionFile,
    [string] $ActionJson,
    [string] $ActionType,
    [ValidateSet("LOW", "MEDIUM", "HIGH", "CRITICAL")]
    [string] $Risk = "LOW",
    [switch] $RequiresOwnerGate,
    [string] $ActionRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Read-ActionInput {
    if (-not [string]::IsNullOrWhiteSpace($ActionFile)) {
        return (Get-Content -LiteralPath $ActionFile -Raw | ConvertFrom-Json)
    }
    if (-not [string]::IsNullOrWhiteSpace($ActionJson)) {
        return ($ActionJson | ConvertFrom-Json)
    }

    return [PSCustomObject]@{
        action_id = [guid]::NewGuid().ToString()
        event_id = [guid]::NewGuid().ToString()
        action_type = $ActionType
        risk = $Risk
        requires_owner_gate = [bool]$RequiresOwnerGate
        mode = "DRY_RUN"
        policy = [PSCustomObject]@{
            live_write = $false
            external = $false
            delete = $false
            dry_run_required = $true
        }
        evidence = [PSCustomObject]@{
            required = $true
            path = "<EVIDENCE_PATH>"
        }
    }
}

$action = Read-ActionInput
$entry = Get-CeoActionRegistryEntry -ActionType ([string]$action.action_type)
$known = ($null -ne $entry)
$registryRisk = if ($known) { [string]$entry.risk } else { "CRITICAL" }
$effectiveRisk = Resolve-CeoActionRisk -DeclaredRisk ([string]$action.risk) -RegistryRisk $registryRisk
$ownerRequired = [bool](Get-CeoEventBusProperty -InputObject $action -Name "requires_owner_gate" -Default $false)
if ($known) {
    $ownerRequired = $ownerRequired -or [bool]$entry.requires_owner_gate
}
if ($effectiveRisk -in @("HIGH", "CRITICAL")) {
    $ownerRequired = $true
}

[ordered]@{
    risk_engine_ready = $true
    action_id = [string](Get-CeoEventBusProperty -InputObject $action -Name "action_id" -Default "")
    action_type = [string](Get-CeoEventBusProperty -InputObject $action -Name "action_type" -Default "")
    known_action = $known
    risk = $effectiveRisk
    requires_owner_gate = $ownerRequired
    default_decision = $(if ($known) { "EVALUATE" } else { "DENY" })
    evidence_path = "<EVIDENCE_PATH>"
} | ConvertTo-Json -Depth 10
