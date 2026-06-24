param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $EventFile,
    [switch] $Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$errors = @()
$warnings = @()
$schema = "event.schema.json"

if (-not (Test-Path -LiteralPath $EventFile -PathType Leaf)) {
    $errors += "EVENT_FILE_NOT_FOUND"
}

$raw = ""
$event = $null
if ($errors.Count -eq 0) {
    $raw = Get-Content -LiteralPath $EventFile -Raw
    try {
        $event = $raw | ConvertFrom-Json
    }
    catch {
        $errors += "INVALID_JSON:$($_.Exception.Message)"
    }
}

if ($errors.Count -eq 0) {
    $forbidden = @(Test-CeoEventBusForbiddenReferences -Text $raw)
    foreach ($hit in $forbidden) {
        $errors += "FORBIDDEN_REFERENCE:$hit"
    }

    $required = @("event_id", "event_type", "version", "timestamp", "producer", "correlation_id", "causation_id", "priority", "risk", "policy", "payload", "evidence", "state", "retry")
    foreach ($name in $required) {
        if (-not $event.PSObject.Properties[$name]) {
            $errors += "MISSING_FIELD:$name"
        }
    }

    if ($event.PSObject.Properties["state"] -and ([string]$event.state) -notin (Get-CeoEventBusValidStates)) {
        $errors += "INVALID_STATE:$($event.state)"
    }

    if ($event.PSObject.Properties["policy"]) {
        foreach ($name in @("requires_owner_gate", "allows_write", "allows_live", "allows_delete", "dry_run_required")) {
            if (-not $event.policy.PSObject.Properties[$name]) {
                $errors += "MISSING_POLICY_FIELD:$name"
            }
        }
    }

    if ($event.PSObject.Properties["evidence"]) {
        if (-not $event.evidence.PSObject.Properties["required"]) {
            $errors += "MISSING_EVIDENCE_FIELD:required"
        }
        elseif ([bool]$event.evidence.required -ne $true) {
            $errors += "EVIDENCE_REQUIRED_NOT_TRUE"
        }
        if (-not $event.evidence.PSObject.Properties["path"]) {
            $errors += "MISSING_EVIDENCE_FIELD:path"
        }
    }
}

$result = [ordered]@{
    valid = ($errors.Count -eq 0)
    schema = $schema
    warnings = @($warnings)
    errors = @($errors)
}

$result | ConvertTo-Json -Depth 10
if ($errors.Count -eq 0) { exit 0 }
exit 20
