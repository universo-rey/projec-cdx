param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$federationFile = Join-Path $root "contracts\federation-map.json"
$map = Get-Content -LiteralPath $federationFile -Raw | ConvertFrom-Json
$gate = Test-CeoFederationGate -FederationFile $federationFile
$coreRepo = @($map.repos | Where-Object { [string] $_.repoId -eq "project-cdx" } | Select-Object -First 1)
$issues = @($gate.Issues)
$duplicateDetected = (@($issues | Where-Object { $_ -like "duplicate-active-canonical:*" }).Count -gt 0)
$status = if ($gate.IsValid) { "OK" } else { "DRIFT" }

$payload = [ordered]@{
    driftId = [guid]::NewGuid().ToString()
    checkedAt = (Get-Date).ToUniversalTime().ToString("o")
    federationId = [string] $map.federationId
    repoId = "project-cdx"
    severity = if ($gate.IsValid) { "info" } else { "critical" }
    status = $status
    issues = @($issues)
    canonicalPath = if ($coreRepo.Count -gt 0) { [string] $coreRepo[0].canonicalPath } else { $root }
    physicalAlias = if ($coreRepo.Count -gt 0) { [string] (Get-CeoObjectPropertyValue -InputObject $coreRepo[0] -Name "physicalAlias" -Default $null) } else { $null }
    duplicateDetected = $duplicateDetected
    recommendation = if ($gate.IsValid) { "continue using federation-map as canonical multi-repo source" } else { "hold execution and reconcile federation-map before processing governance events" }
    sensitiveContentDetected = $false
    liveWrite = $false
}

$event = [ordered]@{
    eventId = [guid]::NewGuid().ToString()
    traceId = [guid]::NewGuid().ToString()
    spanId = [guid]::NewGuid().ToString()
    parentSpanId = $null
    type = "FEDERATION_DRIFT"
    domain = "governance"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
    status = "queued"
    priority = if ($gate.IsValid) { "medium" } else { "critical" }
    schemaVersion = "v1.0"
    executionSurface = (Get-CeoExecutionSurface -AdapterId "local")
    payload = $payload
    metadata = [ordered]@{
        cabinaId = "CABINA_LOCAL"
        executionAdapterId = "ceo-execution-adapter.ps1"
        source = "ceo-federation-enforcer"
        governance = (Get-CeoDefaultGovernance -Agent "federation_enforcer_agent" -Tool "ceo-federation-enforcer.ps1" -Evidence "<RUNTIME_PATH>/federation/federation-drift.jsonl" -Validator "run-integration-smoke.ps1" -StopCondition "federation drift executes without HOLD evidence")
    }
}

$result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_FEDERATION_DRIFT"
if ($result.ExitCode -ne 0) {
    Write-Output "FEDERATION_ENFORCER_HELD:$($result.Status)"
    exit $result.ExitCode
}

if (-not $gate.IsValid) {
    Write-Output "FEDERATION_ENFORCER_HELD:$(@($issues) -join ';')"
    exit 30
}

Write-Output "FEDERATION_ENFORCER_QUEUED:$status"
exit 0
