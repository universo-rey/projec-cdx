param(
    [int] $MaxFindings = 10,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$root = Get-CeoSuiteRoot
$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$scanId = "scan-$([guid]::NewGuid())"
$now = (Get-Date).ToUniversalTime().ToString("o")

$excludedDirs = @(
    ".git",
    ".venv",
    "node_modules",
    ".pytest_cache",
    "<TEST_OUTPUT_PATH>",
    "<RUNTIME_GRAPH_PATH>",
    "<BACKUP_PATH>"
)

function Test-ExcludedPath {
    param([string] $RelativePath)
    $normalizedRelativePath = $RelativePath.Replace("/", "\")
    foreach ($excluded in $excludedDirs) {
        if ($normalizedRelativePath -eq $excluded -or $normalizedRelativePath.StartsWith("$excluded\", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

$findings = @()
$files = @(Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $relative = [System.IO.Path]::GetRelativePath($root, $_.FullName)
    if (-not (Test-ExcludedPath -RelativePath $relative)) {
        [PSCustomObject]@{
            FullName = $_.FullName
            Relative = $relative
            Name = $_.Name
            Extension = $_.Extension
        }
    }
})

foreach ($file in $files) {
    if ($file.Name -in @("ceo-event-worker.ps1", "ceo-agent-dispatcher.ps1")) {
        $findings += [ordered]@{
            findingId = [guid]::NewGuid().ToString()
            scanId = $scanId
            scannedAt = $now
            repoId = "project-cdx"
            repoPath = $root
            severity = "warning"
            category = "legacy"
            status = "held"
            path = [string] $file.Relative
            evidence = "legacy-wrapper-filename"
            reason = "legacy compatibility wrapper remains present after runtime decoupling"
            recommendation = "keep inactive or remove only under explicit deletion gate"
            resolutionStatus = "held-for-explicit-delete-gate"
            resolution = "active execution is resolved through ceo-execution-adapter.ps1 and ceo-runtime-router.ps1; wrapper removal requires explicit delete gate"
            sensitiveContentDetected = $false
            liveWrite = $false
        }
    }
}

$scanExtensions = @(".ps1", ".md", ".json", ".html")
foreach ($file in @($files | Where-Object { $_.Extension -in $scanExtensions } | Select-Object -First 200)) {
    if ($findings.Count -ge $MaxFindings) {
        break
    }
    if ($file.Name -like ".env*") {
        continue
    }

    $text = ""
    try {
        $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
    }
    catch {
        continue
    }

    foreach ($token in @("workerId", "WORKER_DONE", "ceo-event-worker.ps1", "ceo-agent-dispatcher.ps1")) {
        if ($findings.Count -ge $MaxFindings) {
            break
        }
        if ($text -match [regex]::Escape($token)) {
            $findings += [ordered]@{
                findingId = [guid]::NewGuid().ToString()
                scanId = $scanId
                scannedAt = $now
                repoId = "project-cdx"
                repoPath = $root
                severity = "warning"
                category = "legacy"
                status = "held"
                path = [string] $file.Relative
                evidence = "legacy-token:$token"
                reason = "legacy runtime naming token detected in repo-scoped source"
                recommendation = "route through execution adapter/runtime router naming"
                resolutionStatus = "held-for-explicit-delete-gate"
                resolution = "legacy token is recorded as governed compatibility or documentation drift; active runtime path remains adapter/router only"
                sensitiveContentDetected = $false
                liveWrite = $false
            }
        }
    }
}

if ($findings.Count -eq 0) {
    $findings += [ordered]@{
        findingId = [guid]::NewGuid().ToString()
        scanId = $scanId
        scannedAt = $now
        repoId = "project-cdx"
        repoPath = $root
        severity = "info"
        category = "no-finding"
        status = "observed"
        path = ""
        evidence = "repo-scoped-scan"
        reason = "no legacy patterns detected"
        recommendation = "continue observing"
        resolutionStatus = "observed"
        resolution = "no remediation required"
        sensitiveContentDetected = $false
        liveWrite = $false
    }
}

$queued = 0
foreach ($finding in @($findings | Select-Object -First $MaxFindings)) {
    $event = [ordered]@{
        eventId = [guid]::NewGuid().ToString()
        traceId = [guid]::NewGuid().ToString()
        spanId = [guid]::NewGuid().ToString()
        parentSpanId = $null
        type = "SANITIZATION_FINDING"
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
            source = "ceo-sanitizer-scan"
            governance = (Get-CeoDefaultGovernance -Agent "sanitizer_agent" -Tool "ceo-sanitizer-scan.ps1" -Evidence "<RUNTIME_PATH>/sanitization/findings.jsonl" -Validator "run-integration-smoke.ps1" -StopCondition "legacy executes without finding")
        }
    }

    $result = Add-CeoValidatedEventToQueue -Event $event -StateRoot $state.StateRoot -RejectReasonPrefix "INVALID_SANITIZATION_FINDING"
    if ($result.ExitCode -ne 0) {
        Write-Output "SANITIZER_HELD:$($result.Status)"
        exit $result.ExitCode
    }
    $queued++
}

Write-Output "SANITIZER_SCAN_QUEUED:$queued"
exit 0
