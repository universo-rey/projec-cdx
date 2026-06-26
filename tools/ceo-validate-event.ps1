param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $EventFile,
    [string] $StateRoot,
    [switch] $Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

function Test-CeoLegacyEventFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $errors = @()
    $warnings = @()
    $schema = "event.schema.json"

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        $errors += "EVENT_FILE_NOT_FOUND"
    }

    $raw = ""
    $event = $null
    if ($errors.Count -eq 0) {
        $raw = Get-Content -LiteralPath $Path -Raw
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

    return [PSCustomObject]@{
        Status = $(if ($errors.Count -eq 0) { "VALID_EVENT" } else { "INVALID_EVENT" })
        ExitCode = $(if ($errors.Count -eq 0) { 0 } else { 20 })
        Schema = $schema
        EventType = $(if ($event -and $event.PSObject.Properties["event_type"]) { [string]$event.event_type } else { $null })
        Warnings = @($warnings)
        Issues = @($errors)
    }
}

$rawProbe = if (Test-Path -LiteralPath $EventFile -PathType Leaf) { Get-Content -LiteralPath $EventFile -Raw } else { "" }
$isLegacyEvent = $false
if (-not [string]::IsNullOrWhiteSpace($rawProbe)) {
    try {
        $probe = $rawProbe | ConvertFrom-Json
        $isLegacyEvent = ($null -ne $probe.PSObject.Properties["event_id"] -and $null -ne $probe.PSObject.Properties["event_type"])
    }
    catch {
        $isLegacyEvent = $false
    }
}

$result = if ($isLegacyEvent) {
    Test-CeoLegacyEventFile -Path $EventFile
}
else {
    Test-CeoEventFile -EventFile $EventFile -StateRoot $StateRoot
}

if ($Json -or [string]::IsNullOrWhiteSpace($StateRoot)) {
    [ordered]@{
        valid = ($result.Status -eq "VALID_EVENT")
        status = [string]$result.Status
        schema = $(if ($result.PSObject.Properties["Schema"]) { [string]$result.Schema } else { "event-envelope.schema.json" })
        event_type = $(if ($result.PSObject.Properties["EventType"]) { [string]$result.EventType } else { $null })
        issues = $(if ($result.PSObject.Properties["Issues"]) { @($result.Issues) } else { @() })
        error = $(if ($result.PSObject.Properties["Error"]) { [string]$result.Error } else { $null })
    } | ConvertTo-Json -Depth 10
}
else {
    Write-Output ([string]$result.Status)
}

exit ([int]$result.ExitCode)
