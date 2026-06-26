param(
    [int] $MaxFindings = 5,
    [switch] $Rewrite,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$scanId = "path-scan-$([guid]::NewGuid())"
$now = (Get-Date).ToUniversalTime().ToString("o")
$gate = Test-CeoPathSanitizerGate -StateRoot $state.StateRoot
$canonicalMap = Get-CeoCanonicalRootMap

function New-PathFinding {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Category,
        [Parameter(Mandatory = $true)]
        [string] $Severity,
        [Parameter(Mandatory = $true)]
        [string] $Status,
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [Parameter(Mandatory = $true)]
        [string] $Evidence,
        [Parameter(Mandatory = $true)]
        [string] $Reason,
        [Parameter(Mandatory = $true)]
        [string] $Recommendation,
        [Parameter(Mandatory = $true)]
        [string] $ResolutionStatus
    )

    return [ordered]@{
        findingId = [guid]::NewGuid().ToString()
        scanId = $scanId
        scannedAt = $now
        repoId = "project-cdx"
        repoPath = $root
        severity = $Severity
        category = $Category
        status = $Status
        path = $Path
        evidence = $Evidence
        reason = $Reason
        recommendation = $Recommendation
        resolutionStatus = $ResolutionStatus
        sensitiveContentDetected = $false
        liveWrite = $false
    }
}

$findings = @()
foreach ($signal in @($gate.Signals)) {
    $status = [string] $signal.status
    if ($status -eq "PASS") {
        continue
    }

    $name = [string] $signal.name
    $category = switch ($name) {
        "repo-root-drive" { "drive-root" }
        "state-root-drive" { "drive-root" }
        "state-root" { "root-drift" }
        "junction-root" { "junction" }
        "federation-canonical" { "root-drift" }
        "active-canonical-duplicates" { "duplicate-root" }
        default { "root-drift" }
    }
    $severity = if ($status -eq "BLOCK") { "critical" } else { "info" }
    $findingStatus = if ($status -eq "BLOCK") { "blocked" } else { "observed" }
    $resolutionStatus = if ($status -eq "BLOCK") { "blocked-by-path-guard" } else { "observed" }
    $recommendation = if ($status -eq "BLOCK") { "hold execution and reconcile federation/environment roots before processing events" } else { "keep junction declared in federation-map and continue observing" }

    $findings += New-PathFinding `
        -Category $category `
        -Severity $severity `
        -Status $findingStatus `
        -Path ([string] $signal.evidence) `
        -Evidence $name `
        -Reason "path sanitizer signal $name returned $status" `
        -Recommendation $recommendation `
        -ResolutionStatus $resolutionStatus
}

if ($findings.Count -eq 0) {
    $findings += New-PathFinding `
        -Category "no-finding" `
        -Severity "info" `
        -Status "observed" `
        -Path "." `
        -Evidence "path-sanitizer-gate" `
        -Reason "no unsafe roots, D: drive usage, undeclared junctions or federation root drift detected" `
        -Recommendation "continue operating from the canonical repo root" `
        -ResolutionStatus "observed"
}

$rewriteInputs = @(
    [ordered]@{ pathType = "canonical-root"; inputPath = [string] $canonicalMap.CanonicalRoot },
    [ordered]@{ pathType = "physical-alias"; inputPath = if ($canonicalMap.PhysicalAlias) { [string] $canonicalMap.PhysicalAlias } else { [string] $canonicalMap.CanonicalRoot } },
    [ordered]@{ pathType = "state-root"; inputPath = [string] $state.StateRoot },
    [ordered]@{ pathType = "sns-root"; inputPath = [string] $state.SnsRootFile },
    [ordered]@{ pathType = "control-plane-map"; inputPath = [string] $state.AgileCanvasMapFile }
)
$rewrites = @()
foreach ($rewriteInput in $rewriteInputs) {
    $inputPath = [string] (Get-CeoObjectPropertyValue -InputObject $rewriteInput -Name "inputPath" -Default "")
    $canonicalPath = ConvertTo-CeoCanonicalPathString -Path $inputPath
    $rewrites += [ordered]@{
        pathType = [string] (Get-CeoObjectPropertyValue -InputObject $rewriteInput -Name "pathType" -Default "unknown")
        inputPath = $inputPath
        canonicalPath = $canonicalPath
        changed = (-not $inputPath.Equals($canonicalPath, [System.StringComparison]::OrdinalIgnoreCase))
        action = if ($Rewrite) { "applied-local-canonical-reference" } else { "proposed" }
    }
}
$rewriteDoc = [ordered]@{
    schemaVersion = "v1.0"
    rewriteId = [guid]::NewGuid().ToString()
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    mode = if ($Rewrite) { "rewrite" } else { "proposal" }
    repoId = "project-cdx"
    canonicalRoot = [string] $canonicalMap.CanonicalRoot
    physicalAlias = if ($canonicalMap.PhysicalAlias) { [string] $canonicalMap.PhysicalAlias } else { $null }
    rewrites = $rewrites
    policy = [ordered]@{
        destructive = $false
        liveWrite = $false
        secretAccess = $false
        movedFiles = $false
    }
}
if ($Rewrite) {
    $rewriteDoc | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $state.CanonicalPathRewriteFile -Encoding UTF8
}

$queued = 0
foreach ($finding in @($findings | Select-Object -First $MaxFindings)) {
    $event = [ordered]@{
        eventId = [guid]::NewGuid().ToString()
        traceId = [guid]::NewGuid().ToString()
        spanId = [guid]::NewGuid().ToString()
        parentSpanId = $null
        type = "SANITIZE_REQUIRED"
        domain = "governance"
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        status = "queued"
        priority = if ([string] $finding.severity -eq "critical") { "critical" } else { "medium" }
        schemaVersion = "v1.0"
        executionSurface = (Get-CeoExecutionSurface -AdapterId "local")
        payload = $finding
        metadata = [ordered]@{
            cabinaId = "CABINA_LOCAL"
            executionAdapterId = "ceo-execution-adapter.ps1"
            source = "ceo-path-sanitizer"
            governance = (Get-CeoDefaultGovernance -Agent "path_sanitizer_agent" -Tool "ceo-path-sanitizer.ps1" -Evidence "<RUNTIME_PATH>/sanitization/path-sanitizer.jsonl" -Validator "run-integration-smoke.ps1" -StopCondition "unsafe root executes without SANITIZE_REQUIRED")
        }
    }

    $result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_SANITIZE_REQUIRED"
    if ($result.ExitCode -ne 0) {
        Write-Output "PATH_SANITIZER_HELD:$($result.Status)"
        exit $result.ExitCode
    }
    $queued++
}

if (-not $gate.IsValid) {
    Write-Output "PATH_SANITIZER_HELD:$(@($gate.Issues) -join ';')"
    exit 30
}

Write-Output "PATH_SANITIZER_QUEUED:$queued"
exit 0
