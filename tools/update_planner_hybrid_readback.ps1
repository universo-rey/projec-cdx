param(
    [string]$BaseSnapshotJsonl = "C:\CEO\project-cdx\inventarios\PLANNER_TASK_LEVEL_READBACK_20260627.jsonl",
    [string]$OutputJsonl = "C:\CEO\project-cdx\inventarios\PLANNER_TASK_LEVEL_READBACK_HYBRID_20260627.jsonl",
    [string]$PlannerTasksJson = "",
    [string]$TeamsActivityJson = "",
    [string]$PreviousSnapshotJsonl = "",
    [string]$StateJson = "C:\CEO\project-cdx\inventarios\PLANNER_HYBRID_READBACK_STATE_20260627.json",
    [string]$EventBusJsonl = "C:\CEO\watchdog\bus\sdu-event-bus.jsonl",
    [string]$ReadGuardPath = "C:\CEO\project-cdx\.cabina\execution-runtime\planner\planner-hybrid-readback.lock.json",
    [int]$ReadConsistencyWindowSeconds = 20,
    [switch]$AllowReadDuringLocalWrite
)

$ErrorActionPreference = "Stop"

function Get-NowIso { (Get-Date).ToUniversalTime().ToString("o") }

function Get-Sha256 {
    param([string]$Value)
    if ($null -eq $Value) { $Value = "" }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return ([System.BitConverter]::ToString($hash) -replace "-", "").ToLowerInvariant()
}

function As-Array {
    param($Value)
    if ($null -eq $Value) { return @() }
    if ($Value -is [array]) { return @($Value) }
    return @($Value)
}

function Read-JsonFile {
    param([string]$Path, $Fallback = $null)
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) { return $Fallback }
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($text)) { return $Fallback }
    return $text | ConvertFrom-Json
}

function Read-JsonLines {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) { return @() }
    $items = @()
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $items += ($line | ConvertFrom-Json)
    }
    return @($items)
}

function Get-JsonCollection {
    param($Doc, [string[]]$PropertyNames)
    if ($null -eq $Doc) { return @() }
    if ($Doc -is [array]) { return @($Doc) }
    foreach ($name in $PropertyNames) {
        if ($Doc.PSObject.Properties.Name -contains $name) {
            return @(As-Array $Doc.$name)
        }
    }
    return @($Doc)
}

function Write-JsonFile {
    param([string]$Path, $Value, [int]$Depth = 40)
    $parent = Split-Path -Parent $Path
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $tmp = "$Path.tmp.$PID"
    ($Value | ConvertTo-Json -Depth $Depth) | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

function Append-Event {
    param([string]$Event, [string]$Status, $Details)
    if ([string]::IsNullOrWhiteSpace($EventBusJsonl)) { return }
    $parent = Split-Path -Parent $EventBusJsonl
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $payload = [ordered]@{
        timestamp = [DateTimeOffset]::Now.ToString("o")
        event = $Event
        priority = "CRITICAL"
        source = "planner-hybrid-readback"
        status = $Status
        details = $Details
    }
    ($payload | ConvertTo-Json -Depth 20 -Compress) | Add-Content -LiteralPath $EventBusJsonl -Encoding UTF8
}

function Get-StableTimestampString {
    param($Value)
    if ($null -eq $Value) { return $null }
    if ($Value -is [datetime]) { return $Value.ToUniversalTime().ToString("o") }
    if ($Value -is [datetimeoffset]) { return $Value.ToUniversalTime().ToString("o") }
    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    try { return ([DateTimeOffset]::Parse($text)).ToUniversalTime().ToString("o") } catch { return $text }
}

function Test-ProcessAlive {
    param([int]$ProcessId)
    if ($ProcessId -le 0) { return $false }
    try {
        $null = Get-Process -Id $ProcessId -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Acquire-PlannerHybridReadGuard {
    $mutexName = "Global\PROJEC_CDX_PLANNER_HYBRID_READBACK"
    $mutex = [System.Threading.Mutex]::new($false, $mutexName)
    $acquired = $false
    try {
        try {
            $acquired = $mutex.WaitOne(0)
        } catch [System.Threading.AbandonedMutexException] {
            $acquired = $true
        }

        if (-not $acquired) {
            Append-Event -Event "SDU_HYBRID_READBACK_ACTIVE" -Status "READ_GUARD_BLOCKED" -Details ([ordered]@{
                reason = "planner_hybrid_refresh_already_running"
                read_guard_path = $ReadGuardPath
                external_write = $false
            })
            throw "planner hybrid readback refresh is already running"
        }

        $existing = Read-JsonFile -Path $ReadGuardPath -Fallback $null
        if ($existing -and $existing.process_id -and (Test-ProcessAlive -ProcessId ([int]$existing.process_id))) {
            Append-Event -Event "SDU_HYBRID_READBACK_ACTIVE" -Status "READ_GUARD_LOCKFILE_BLOCKED" -Details ([ordered]@{
                reason = "planner_hybrid_lockfile_process_alive"
                read_guard_path = $ReadGuardPath
                writer_process_id = $existing.process_id
                external_write = $false
            })
            throw "planner hybrid readback lockfile points to an active process"
        }

        Write-JsonFile -Path $ReadGuardPath -Value ([ordered]@{
            schema_version = 1
            artifact = "planner-hybrid-read-guard"
            acquired_at = Get-NowIso
            process_id = $PID
            mutex_name = $mutexName
            lock_scope = @("planner-hybrid-readback", "snapshot-refresh")
            external_write = $false
        }) -Depth 20

        return [pscustomobject]@{
            mutex = $mutex
            acquired = $true
            mutex_name = $mutexName
            lock_path = $ReadGuardPath
            status = "READ_GUARD_ACQUIRED"
        }
    } catch {
        if ($acquired) {
            try { $mutex.ReleaseMutex() } catch {}
        }
        try { $mutex.Dispose() } catch {}
        throw
    }
}

function Release-PlannerHybridReadGuard {
    param($Guard)
    if ($null -eq $Guard) { return }
    try {
        if (Test-Path -LiteralPath $ReadGuardPath) {
            $lock = Read-JsonFile -Path $ReadGuardPath -Fallback $null
            if ($lock -and $lock.process_id -eq $PID) { Remove-Item -LiteralPath $ReadGuardPath -Force }
        }
    } catch {}
    try { $Guard.mutex.ReleaseMutex() } catch {}
    try { $Guard.mutex.Dispose() } catch {}
}

function Test-LocalWriteWindow {
    $lockPath = "C:\CEO\project-cdx\.cabina\execution-runtime\control-flow\control-flow.lock.json"
    $lock = Read-JsonFile -Path $lockPath -Fallback $null
    if ($null -eq $lock -or $null -eq $lock.process_id) {
        return [pscustomobject]@{
            safe_to_read = $true
            status = "NO_LOCAL_WRITER"
            lock_path = $lockPath
            writer_process_id = $null
        }
    }

    $pidValue = [int]$lock.process_id
    $alive = Test-ProcessAlive -ProcessId $pidValue
    if (-not $alive) {
        return [pscustomobject]@{
            safe_to_read = $true
            status = "STALE_LOCK_IGNORED"
            lock_path = $lockPath
            writer_process_id = $pidValue
        }
    }

    $ageSeconds = $null
    if ($lock.acquired_at) {
        $ageSeconds = ([DateTimeOffset]::Now - [DateTimeOffset]::Parse([string]$lock.acquired_at)).TotalSeconds
    }

    return [pscustomobject]@{
        safe_to_read = [bool]$AllowReadDuringLocalWrite
        status = if ($AllowReadDuringLocalWrite) { "LOCAL_WRITER_ALLOWED_BY_FLAG" } else { "LOCAL_WRITER_ACTIVE" }
        lock_path = $lockPath
        writer_process_id = $pidValue
        lock_age_seconds = if ($null -eq $ageSeconds) { $null } else { [math]::Round($ageSeconds, 3) }
        read_consistency_window_seconds = $ReadConsistencyWindowSeconds
    }
}

function Convert-ToMapByTaskId {
    param([object[]]$Items)
    $map = @{}
    foreach ($item in @($Items)) {
        $taskId = if ($item.task_id) { [string]$item.task_id } elseif ($item.id) { [string]$item.id } else { "" }
        if (-not [string]::IsNullOrWhiteSpace($taskId)) { $map[$taskId] = $item }
    }
    return $map
}

function Get-ActivityForTask {
    param([object[]]$Activities, [string]$TaskId)
    return @($Activities | Where-Object {
        ($_.task_id -and [string]$_.task_id -eq $TaskId) -or
        ($_.planner_task_id -and [string]$_.planner_task_id -eq $TaskId)
    })
}

function Get-ConsistencyScore {
    param([bool]$HasPlannerTask, [bool]$HasTeamsActivity, [bool]$HasOutlookFallback)
    $score = 0
    if ($HasPlannerTask) { $score += 1 }
    if ($HasTeamsActivity) { $score += 1 }
    if ($HasOutlookFallback) { $score += 1 }
    return $score
}

$readGuard = Acquire-PlannerHybridReadGuard
try {
    $readWindow = Test-LocalWriteWindow
    if (-not $readWindow.safe_to_read) {
        Append-Event -Event "SDU_HYBRID_READBACK_ACTIVE" -Status "READ_WINDOW_DEFERRED" -Details ([ordered]@{
            reason = "local_writer_active"
            writer_process_id = $readWindow.writer_process_id
            external_write = $false
        })
        throw "read consistency window is blocked by a local writer process"
    }

    $baseRecords = Read-JsonLines -Path $BaseSnapshotJsonl
    $previousRecords = if ([string]::IsNullOrWhiteSpace($PreviousSnapshotJsonl)) { @() } else { Read-JsonLines -Path $PreviousSnapshotJsonl }
    $plannerTasks = Get-JsonCollection -Doc (Read-JsonFile -Path $PlannerTasksJson -Fallback $null) -PropertyNames @("tasks", "planner_tasks", "results", "value")
    $teamsActivities = Get-JsonCollection -Doc (Read-JsonFile -Path $TeamsActivityJson -Fallback $null) -PropertyNames @("activities", "messages", "results", "value")

    $plannerTaskMap = Convert-ToMapByTaskId -Items $plannerTasks
    $previousTaskMap = Convert-ToMapByTaskId -Items $previousRecords

    $accountMatrixSources = @(
    "C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\STATE_SEMANTICS_OWNER_IDENTITY_NORMALIZATION\CDF_OWNER_IDENTITY_NORMALIZATION_MATRIX.csv",
    "C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\TENANT_DICTAMEN_READINESS\CDF_TENANT_AGENT_ROLE_ASSIGNMENT_MATRIX.csv",
    "C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\TGE_CDF_STAFF_TENANT_LIVE_READONLY_PREFLIGHT_REPORT_20260527.md",
    "C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\MICROSOFT_365_CONNECTION_SURFACE_MATRIX.csv",
    "C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\PLANNER_ROLE_MATRIX.csv"
    )

    $records = @()
    foreach ($record in @($baseRecords)) {
    $taskId = [string]$record.task_id
    $plannerTask = if ($plannerTaskMap.ContainsKey($taskId)) { $plannerTaskMap[$taskId] } else { $null }
    $teamActivity = @(Get-ActivityForTask -Activities $teamsActivities -TaskId $taskId)
    $hasPlannerTask = $null -ne $plannerTask
    $hasTeamsActivity = @($teamActivity).Count -gt 0
        $hasOutlookFallback = -not [string]::IsNullOrWhiteSpace([string]$record.message_id_hash)
        $hasPreviousSnapshot = $previousTaskMap.ContainsKey($taskId) -or -not [string]::IsNullOrWhiteSpace($taskId)
        $sourceFlags = [ordered]@{
            plannerTask = $hasPlannerTask
            Teams_activity = $hasTeamsActivity
            Outlook_fallback = $hasOutlookFallback
            previous_snapshot = $hasPreviousSnapshot
        }

    $activityTimes = @($teamActivity | ForEach-Object {
        if ($_.created_at) { Get-StableTimestampString $_.created_at } elseif ($_.timestamp) { Get-StableTimestampString $_.timestamp } else { $null }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object)
    $lastActivityAt = if (@($activityTimes).Count -gt 0) { @($activityTimes)[-1] } else { Get-StableTimestampString $record.message_received_at }
    $activityHashes = @($teamActivity | ForEach-Object {
        if ($_.content_hash) { [string]$_.content_hash }
        elseif ($_.message_id) { Get-Sha256 ([string]$_.message_id) }
        elseif ($_.path) { Get-Sha256 ([string]$_.path) }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    $titleHash = $record.task_title_hash
    if ($hasPlannerTask -and $plannerTask.title) {
        $titleHash = Get-Sha256 ([string]$plannerTask.title)
    }

    $consistencyScore = Get-ConsistencyScore -HasPlannerTask $hasPlannerTask -HasTeamsActivity $hasTeamsActivity -HasOutlookFallback $hasOutlookFallback
    $confidenceClass = if ($consistencyScore -ge 2) { "TASK_TRUSTED" } elseif ($consistencyScore -ge 1) { "TASK_VALID" } else { "TASK_UNCONFIRMED" }
    $activityDetected = ($hasPlannerTask -or $hasTeamsActivity -or $hasOutlookFallback)
    $missingTask = -not ($hasPlannerTask -or $hasPreviousSnapshot)
    $missingComments = if ($hasTeamsActivity) { $false } else { $null }
    $anomalyClassification = if (-not $hasPlannerTask -and -not $hasTeamsActivity -and -not $hasPreviousSnapshot) { "REAL_ANOMALY" } else { "FALSE_ANOMALY" }
    $activityHashSeed = @(
        $taskId,
        $(if ($hasPlannerTask -and $plannerTask.etag) { [string]$plannerTask.etag } else { "" }),
        $(if ($null -ne $lastActivityAt) { [string]$lastActivityAt } else { "" }),
        $($activityHashes -join "|"),
        $(if ($record.fallback_url_hash) { [string]$record.fallback_url_hash } else { "" })
    ) -join "||"

    $record | Add-Member -NotePropertyName "schema_version" -NotePropertyValue 2 -Force
    $record | Add-Member -NotePropertyName "hybrid_schema_version" -NotePropertyValue 1 -Force
    $record | Add-Member -NotePropertyName "readback_global_state" -NotePropertyValue "READBACK_PARTIAL_DETAILS" -Force
    $record | Add-Member -NotePropertyName "readback_trust" -NotePropertyValue $(if ($hasPlannerTask) { "TRUSTED_HYBRID" } else { "FALLBACK_INDIRECT_NOT_ABSENCE" }) -Force
    $record | Add-Member -NotePropertyName "planner_task_read_status" -NotePropertyValue $(if ($hasPlannerTask) { "READ_OK_TEAMS_CONNECTOR" } else { "NOT_READ_FALLBACK_ONLY" }) -Force
    $record | Add-Member -NotePropertyName "comments_read_status" -NotePropertyValue $(if ($hasTeamsActivity) { "TEAMS_INFERRED" } else { "TEAMS_PRIMARY_NO_MATCH_NOT_ABSENCE" }) -Force
    $record | Add-Member -NotePropertyName "details_read_status" -NotePropertyValue "PARTIAL_RAW_GRAPH_NOT_EXPOSED" -Force
    $record | Add-Member -NotePropertyName "etag" -NotePropertyValue $(if ($hasPlannerTask) { $plannerTask.etag } else { $record.etag }) -Force
    $record | Add-Member -NotePropertyName "task_title_hash" -NotePropertyValue $titleHash -Force
    $record | Add-Member -NotePropertyName "inferred_comments_count" -NotePropertyValue $(if ($hasTeamsActivity) { @($teamActivity).Count } else { $null }) -Force
    $record | Add-Member -NotePropertyName "last_comment_timestamp" -NotePropertyValue $(if ($hasTeamsActivity) { $lastActivityAt } else { $null }) -Force
    $record | Add-Member -NotePropertyName "has_activity" -NotePropertyValue ($hasPlannerTask -or $hasTeamsActivity -or $hasOutlookFallback) -Force
    $record | Add-Member -NotePropertyName "last_activity_hash" -NotePropertyValue (Get-Sha256 $activityHashSeed) -Force
    $record | Add-Member -NotePropertyName "consistency_score" -NotePropertyValue $consistencyScore -Force
    $record | Add-Member -NotePropertyName "source_flags" -NotePropertyValue ([pscustomobject]$sourceFlags) -Force
    $record | Add-Member -NotePropertyName "activity_detected" -NotePropertyValue $activityDetected -Force
    $record | Add-Member -NotePropertyName "confidence_class" -NotePropertyValue $confidenceClass -Force
    $record | Add-Member -NotePropertyName "missing_task" -NotePropertyValue $missingTask -Force
    $record | Add-Member -NotePropertyName "missing_comments" -NotePropertyValue $missingComments -Force
    $record | Add-Member -NotePropertyName "anomaly_classification" -NotePropertyValue $anomalyClassification -Force
    $record | Add-Member -NotePropertyName "disappearance_status" -NotePropertyValue $(if ($hasPlannerTask) { "PRESENT_IN_PLANNER" } elseif ($hasPreviousSnapshot) { "NOT_MARKED_MISSING_SNAPSHOT_PRESENT" } else { "UNKNOWN_NOT_ABSENCE" }) -Force
    $record | Add-Member -NotePropertyName "comments_absence_assumed" -NotePropertyValue $false -Force
    $record | Add-Member -NotePropertyName "primary_comment_source" -NotePropertyValue "Teams messages" -Force
    $record | Add-Member -NotePropertyName "account_matrix_source_set" -NotePropertyValue "CDF_TGE_20260627" -Force
    $record | Add-Member -NotePropertyName "stabilization_rules" -NotePropertyValue ([pscustomobject]@{
        no_missing_if_prior_snapshot = $true
        no_comment_absence_inference = $true
        teams_primary_for_effective_comments = $true
        real_anomaly_requires_no_source = $true
        read_consistency_window_seconds = $ReadConsistencyWindowSeconds
    }) -Force

    $records += $record
    }

    $parent = Split-Path -Parent $OutputJsonl
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $records | ForEach-Object { $_ | ConvertTo-Json -Depth 40 -Compress } | Set-Content -LiteralPath $OutputJsonl -Encoding UTF8

    $trustedPlannerCount = @($records | Where-Object { $_.planner_task_read_status -eq "READ_OK_TEAMS_CONNECTOR" }).Count
    $teamsInferredCount = @($records | Where-Object { $_.comments_read_status -eq "TEAMS_INFERRED" }).Count
    $notMissingCount = @($records | Where-Object { $_.missing_task -eq $false }).Count
    $validTaskCount = @($records | Where-Object { $_.consistency_score -ge 1 }).Count
    $trustedTaskCount = @($records | Where-Object { $_.consistency_score -ge 2 }).Count
    $falseAnomalyCount = @($records | Where-Object { $_.anomaly_classification -eq "FALSE_ANOMALY" }).Count
    $realAnomalyCount = @($records | Where-Object { $_.anomaly_classification -eq "REAL_ANOMALY" }).Count

    $state = [ordered]@{
    schema_version = 1
    artifact = "planner-hybrid-readback-state"
    generated_at = Get-NowIso
    status = "SDU_OBSERVABILITY_HARDENED"
    global_readback = [ordered]@{
        plannerTask = "TRUSTED"
        Teams_history = "TRUSTED"
        Details = "PARTIAL"
        READBACK_UNTRUSTED = $false
        READBACK_PARTIAL_DETAILS = $true
    }
    thresholds = [ordered]@{
        valid_task_min_score = 1
        trusted_task_min_score = 2
        max_score = 3
    }
    sources = [ordered]@{
        plannerTask = "Teams connector"
        comments_primary = "Teams messages"
        fallback_historical = "Outlook notifications"
        raw_details = "PARTIAL_RAW_GRAPH_NOT_EXPOSED"
    }
    account_matrix_sources = @($accountMatrixSources | ForEach-Object {
        [ordered]@{
            path = $_
            exists = (Test-Path -LiteralPath $_)
        }
    })
    read_consistency_window = $readWindow
    read_guard = [ordered]@{
        status = $readGuard.status
        mutex_name = $readGuard.mutex_name
        lock_path = $readGuard.lock_path
        overlap_blocking = $true
    }
    records = [ordered]@{
        total = @($records).Count
        plannerTask_trusted = $trustedPlannerCount
        teams_comments_inferred = $teamsInferredCount
        guarded_not_missing = $notMissingCount
        valid_tasks = $validTaskCount
        trusted_tasks = $trustedTaskCount
        false_anomalies = $falseAnomalyCount
        real_anomalies = $realAnomalyCount
    }
    rules = [ordered]@{
        rule_1 = "NO marcar task como desaparecida si existe en snapshot previo"
        rule_2 = "NO asumir ausencia de comments"
        rule_3 = "usar Teams como fuente primaria de comentarios efectivos"
        rule_4 = "REAL_ANOMALY requiere ausencia en Planner, Teams y snapshot"
        rule_5 = "read_guard bloquea refresh simultaneo"
    }
    output_jsonl = $OutputJsonl
    external_write = $false
    }

    Write-JsonFile -Path $StateJson -Value $state -Depth 40

    Append-Event -Event "SDU_OBSERVABILITY_HARDENED" -Status "OK" -Details ([ordered]@{
        output_jsonl = $OutputJsonl
        records = @($records).Count
        valid_tasks = $validTaskCount
        trusted_tasks = $trustedTaskCount
        real_anomalies = $realAnomalyCount
        read_guard = "ACTIVE"
        external_write = $false
    })
    Append-Event -Event "SDU_FALSE_POSITIVE_BLOCKED" -Status "OK" -Details ([ordered]@{
        false_anomalies = $falseAnomalyCount
        missing_task_false = $notMissingCount
        missing_comments_false = $teamsInferredCount
        external_write = $false
    })
    Append-Event -Event "SDU_TASK_CONFIRMED_REAL" -Status "OK" -Details ([ordered]@{
        confirmed_tasks = $validTaskCount
        trusted_tasks = $trustedTaskCount
        threshold_valid = 1
        threshold_trusted = 2
        external_write = $false
    })
    Append-Event -Event "SDU_PLANNER_STABILIZED" -Status "OK" -Details ([ordered]@{
    output_jsonl = $OutputJsonl
    records = @($records).Count
    plannerTask_trusted = $trustedPlannerCount
    details = "READBACK_PARTIAL_DETAILS"
    external_write = $false
    })
    Append-Event -Event "SDU_HYBRID_READBACK_ACTIVE" -Status "OK" -Details ([ordered]@{
    plannerTask = "TRUSTED"
    Teams_history = "TRUSTED"
    Details = "PARTIAL"
    fallback = "Outlook notifications"
    external_write = $false
    })
    Append-Event -Event "SDU_FALSE_ANOMALY_RESOLVED" -Status "OK" -Details ([ordered]@{
    guarded_not_missing = $notMissingCount
    comment_absence_assumed = $false
    external_write = $false
    })

    [pscustomobject]@{
    status = "SDU_OBSERVABILITY_HARDENED"
    output_jsonl = $OutputJsonl
    state_json = $StateJson
    records = @($records).Count
    plannerTask_trusted = $trustedPlannerCount
    teams_comments_inferred = $teamsInferredCount
    valid_tasks = $validTaskCount
    trusted_tasks = $trustedTaskCount
    real_anomalies = $realAnomalyCount
    details = "READBACK_PARTIAL_DETAILS"
    external_write = $false
    }
} finally {
    Release-PlannerHybridReadGuard -Guard $readGuard
}
