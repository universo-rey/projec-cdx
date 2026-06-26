param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$RuntimeStateCommand = Join-Path $Root 'tools\ceo-runtime-state.ps1'
$SentinelCommand = Join-Path $Root 'tools\ceo-runtime-sentinel.ps1'
$SentinelReport = Join-Path $Root 'operativa\sentinel\SENTINEL_REPORT.json'
$TasksPath = Join-Path $Root '.vscode\tasks.json'

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $full = [System.IO.Path]::GetFullPath($Path)
    $prefix = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    if ($full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($prefix.Length).Replace('\', '/')
    }

    return $full
}

function Test-Json {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return [PSCustomObject]@{
            path = Get-RepoPath -Path $Path
            exists = $false
            status = 'MISSING'
            keys = @()
            last_write_time = $null
        }
    }

    try {
        $parsed = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        [PSCustomObject]@{
            path = Get-RepoPath -Path $Path
            exists = $true
            status = 'VALID'
            keys = @($parsed.PSObject.Properties.Name)
            last_write_time = (Get-Item -LiteralPath $Path).LastWriteTime.ToString('yyyy-MM-ddTHH:mm:sszzz')
        }
    }
    catch {
        [PSCustomObject]@{
            path = Get-RepoPath -Path $Path
            exists = $true
            status = 'INVALID_JSON'
            keys = @()
            last_write_time = (Get-Item -LiteralPath $Path).LastWriteTime.ToString('yyyy-MM-ddTHH:mm:sszzz')
            error = $_.Exception.Message
        }
    }
}

function Get-TaskStatus {
    param([string] $Label)

    if (-not (Test-Path -LiteralPath $TasksPath)) {
        return 'TASKS_JSON_MISSING'
    }

    try {
        $labels = @((Get-Content -LiteralPath $TasksPath -Raw | ConvertFrom-Json).tasks | ForEach-Object { $_.label })
        if ($labels -contains $Label) { return 'READY' }
        return 'MISSING'
    }
    catch {
        return 'TASKS_JSON_INVALID'
    }
}

$runtimeState = $null
$runtimeStateStatus = 'COMMAND_MISSING'
if (Test-Path -LiteralPath $RuntimeStateCommand) {
    try {
        $runtimeState = & $RuntimeStateCommand --json | ConvertFrom-Json
        $runtimeStateStatus = 'READY'
    }
    catch {
        $runtimeStateStatus = 'ERROR'
        $runtimeState = [PSCustomObject]@{ error = $_.Exception.Message }
    }
}

$telemetryCandidates = @(
    (Join-Path $Root 'telemetry.json'),
    (Join-Path $Root 'operativa\telemetry.json'),
    (Join-Path $Root 'operativa\runtime-events\telemetry.json'),
    (Join-Path $Root '.vscode\telemetry.json'),
    (Join-Path $Root 'VERSION_STATE.json')
)

$telemetryJson = @($telemetryCandidates | ForEach-Object { Test-Json -Path $_ })
$validTelemetry = @($telemetryJson | Where-Object { $_.status -eq 'VALID' })

$sentinelReportState = Test-Json -Path $SentinelReport
$sentinelSummary = $null
if ($sentinelReportState.status -eq 'VALID') {
    $report = Get-Content -LiteralPath $SentinelReport -Raw | ConvertFrom-Json
    $sentinelSummary = [PSCustomObject]@{
        status = $report.status
        drift_detected = $report.drift_detected
        report_id = $report.report_id
        created_at_utc = $report.created_at_utc
        checks = $report.checks
    }
}

$taskStatuses = @(
    [PSCustomObject]@{ label = 'CEO Command: Telemetry'; status = Get-TaskStatus -Label 'CEO Command: Telemetry' },
    [PSCustomObject]@{ label = 'CEO Command: Watchdog'; status = Get-TaskStatus -Label 'CEO Command: Watchdog' },
    [PSCustomObject]@{ label = 'CEO IDE: Telemetry Status'; status = Get-TaskStatus -Label 'CEO IDE: Telemetry Status' },
    [PSCustomObject]@{ label = 'CEO IDE: Evidence Status'; status = Get-TaskStatus -Label 'CEO IDE: Evidence Status' }
)

$runtimeSummary = if ($runtimeStateStatus -eq 'READY') {
    [PSCustomObject]@{
        mode = $runtimeState.mode
        version_actual = $runtimeState.version_actual
        baseline_version = $runtimeState.baseline_version
        branch = $runtimeState.branch
        commit = $runtimeState.commit
        dirty = $runtimeState.dirty
        status_count = @($runtimeState.status).Count
        generated_at_utc = $runtimeState.generated_at_utc
    }
}
else {
    $runtimeState
}

$warnings = @()
if (@($taskStatuses | Where-Object { $_.status -ne 'READY' }).Count -gt 0) {
    $warnings += 'Faltan tasks de evidencia o telemetria en VS Code Insiders.'
}
if ($sentinelReportState.status -ne 'VALID') {
    $warnings += 'No hay SENTINEL_REPORT.json valido para lectura pasiva.'
}
if ($validTelemetry.Count -eq 0) {
    $warnings += 'No existe telemetry.json dedicado; VERSION_STATE.json y ceo-runtime-state actuan como telemetria runtime.'
}
if ($runtimeStateStatus -ne 'READY') {
    $warnings += 'ceo-runtime-state no pudo ejecutarse en modo JSON.'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-telemetry-status'
    status = if ($runtimeStateStatus -eq 'READY' -and @($taskStatuses | Where-Object { $_.status -ne 'READY' }).Count -eq 0) { 'IDE_TELEMETRY_STATUS_READY' } else { 'IDE_TELEMETRY_STATUS_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    runtime_state_command = @{
        path = Get-RepoPath -Path $RuntimeStateCommand
        status = $runtimeStateStatus
    }
    runtime_summary = $runtimeSummary
    telemetry_json = $telemetryJson
    sentinel_command = @{
        path = Get-RepoPath -Path $SentinelCommand
        status = if (Test-Path -LiteralPath $SentinelCommand) { 'READY' } else { 'MISSING' }
    }
    sentinel_report = @{
        path = $sentinelReportState.path
        status = $sentinelReportState.status
        summary = $sentinelSummary
    }
    task_statuses = $taskStatuses
    warnings = $warnings
    policy = @{
        read_existing_reports = $true
        do_not_create_noisy_logs = $true
        use_json_outputs = $true
    }
    frontera = @{
        no_secret_read = $true
        no_live = $true
        no_mcp_execution = $true
        no_push = $true
        no_pr = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
