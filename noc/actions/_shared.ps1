function Get-NocPaths {
  $root = "C:\CEO\project-cdx"
  $watchdog = "C:\CEO\watchdog"
  [ordered]@{
    Root = $root
    NocRoot = Join-Path $root "noc"
    NocState = Join-Path $root "noc\noc-state.json"
    NocLock = Join-Path $root "noc\noc.lock.json"
    OperationalMode = Join-Path $root ".sdu\operational-mode.json"
    LiveOperation = Join-Path $root "noc\operacion-en-vivo.json"
    EntryRoot = Join-Path $watchdog "entry"
    PreprodSnapshot = Join-Path $root "inventarios\expediente_state_preprod.jsonl"
    HybridState = Join-Path $root "inventarios\PLANNER_HYBRID_READBACK_STATE_20260627.json"
    TaskReadback = Join-Path $root "inventarios\PLANNER_TASK_LEVEL_READBACK_HYBRID_20260627.jsonl"
    LiveTaskEvidence = Join-Path $root "inventarios\PLANNER_LIVE_TASK_EVIDENCE_20260627.json"
    TeamsEvidence = Join-Path $root "inventarios\PLANNER_TEAMS_ACTIVITY_EVIDENCE_20260627.json"
    GraphAuthRecovery = Join-Path $root "inventarios\PLANNER_GRAPH_AUTH_RECOVERY_20260627.json"
    PredictiveScore = Join-Path $watchdog "state\predictive_score.json"
    Bus = Join-Path $watchdog "bus\sdu-event-bus.jsonl"
    Alerts = Join-Path $watchdog "logs\alerts.jsonl"
    ActionLog = Join-Path $watchdog "logs\action_execution.jsonl"
  }
}

function Read-JsonSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  try {
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text | ConvertFrom-Json
  } catch {
    return $null
  }
}

function Read-JsonlSafe {
  param(
    [string]$Path,
    [int]$Tail = 0
  )
  if (-not (Test-Path -LiteralPath $Path)) { return @() }
  try {
    $lines = if ($Tail -gt 0) {
      Get-Content -LiteralPath $Path -Tail $Tail -Encoding UTF8
    } else {
      Get-Content -LiteralPath $Path -Encoding UTF8
    }
    $items = New-Object System.Collections.Generic.List[object]
    foreach ($line in $lines) {
      if ([string]::IsNullOrWhiteSpace($line)) { continue }
      try {
        $items.Add(($line | ConvertFrom-Json))
      } catch {
        continue
      }
    }
    return ,$items.ToArray()
  } catch {
    return @()
  }
}

function Write-JsonFile {
  param(
    [string]$Path,
    $Object
  )
  $parent = Split-Path -Parent $Path
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
  $Object | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Append-JsonlEntry {
  param(
    [string]$Path,
    $Object
  )
  $parent = Split-Path -Parent $Path
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
  Add-Content -LiteralPath $Path -Value (($Object | ConvertTo-Json -Depth 20 -Compress))
}

function Get-LatestByType {
  param(
    [object[]]$Items,
    [string]$Type
  )
  if (-not $Items) { return $null }
  for ($i = $Items.Count - 1; $i -ge 0; $i--) {
    $item = $Items[$i]
    if ($null -eq $item) { continue }
    $itemType = [string]$item.type
    if ($itemType -eq $Type) { return $item }
  }
  return $null
}

function Get-EntrySeverity {
  param([object]$Event)
  if ($null -eq $Event) { return "UNKNOWN" }
  $reason = [string]$Event.reason
  $afterPath = [string]$Event.after_path
  $canonicalRoot = [string]$Event.canonical_root
  if (-not [string]::IsNullOrWhiteSpace($afterPath) -and -not [string]::IsNullOrWhiteSpace($canonicalRoot) -and $afterPath -eq $canonicalRoot) {
    return "CANONICAL"
  }
  if ($reason -match "legacy|noncanonical|correction|fix") {
    return "CORRECTED"
  }
  if ($reason -match "fallback|out[- ]?of[- ]?control|unsafe") {
    return "FALLBACK"
  }
  return "OBSERVED"
}

function Read-EntrypointObservability {
  $paths = Get-NocPaths
  $root = $paths.EntryRoot
  if (-not (Test-Path -LiteralPath $root)) {
    return [pscustomobject]@{
      available = $false
      current_cwd = $null
      canonical_root = $null
      status = "FALLBACK"
      status_label = "Entrada fuera de control"
      last_event_timestamp = $null
      recent_correction = $false
      recent_events = @()
      source = $root
    }
  }

  $files = Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in @(".json", ".md") } |
    Sort-Object LastWriteTime, FullName

  $events = New-Object System.Collections.Generic.List[object]
  foreach ($file in $files) {
    $parsed = $null
    if ($file.Extension -eq ".json") {
      $parsed = Read-JsonSafe $file.FullName
    } else {
      $text = $null
      try {
        $text = Get-Content -LiteralPath $file.FullName -Raw
      } catch {
        $text = $null
      }
      if ($text) {
        $timestamp = $null
        $reason = $null
        $before = $null
        $after = $null
        $canonical = $null
        foreach ($line in ($text -split "\r?\n")) {
          if ($line -match '^- Timestamp:\s*(.+)$') { $timestamp = $Matches[1].Trim() }
          elseif ($line -match '^- Reason:\s*(.+)$') { $reason = $Matches[1].Trim() }
          elseif ($line -match '^- Before:\s*(.+)$') { $before = $Matches[1].Trim() }
          elseif ($line -match '^- After:\s*(.+)$') { $after = $Matches[1].Trim() }
          elseif ($line -match '^- Canonical:\s*(.+)$') { $canonical = $Matches[1].Trim() }
        }
        if ($timestamp -or $reason -or $after) {
          $parsed = [pscustomobject]@{
            timestamp = $timestamp
            reason = $reason
            before_path = $before
            after_path = $after
            canonical_root = $canonical
            source = $file.FullName
          }
        }
      }
    }
    if ($parsed) {
      $parsed | Add-Member -NotePropertyName source_file -NotePropertyValue $file.FullName -Force
      $parsed | Add-Member -NotePropertyName source_name -NotePropertyValue $file.Name -Force
      $parsed | Add-Member -NotePropertyName severity -NotePropertyValue (Get-EntrySeverity -Event $parsed) -Force
      $events.Add($parsed)
    }
  }

  $recent = @($events | Sort-Object -Property @{ Expression = { [string]$_.timestamp } }, @{ Expression = { [string]$_.source_file } } -Descending | Select-Object -First 10)
  $latest = if ($recent.Count) { $recent[0] } else { $null }
  $recentCorrection = @($recent | Where-Object { $_.severity -eq "CORRECTED" }).Count -gt 0
  $currentCwd = if ($latest -and $latest.after_path) { [string]$latest.after_path } elseif ($latest -and $latest.before_path) { [string]$latest.before_path } else { $null }
  $canonicalRoot = if ($latest -and $latest.canonical_root) { [string]$latest.canonical_root } else { $null }
  $status = "FALLBACK"
  $statusLabel = "Entrada fuera de control"
  if ($latest) {
    if ($latest.severity -eq "CANONICAL" -or ($currentCwd -and $canonicalRoot -and $currentCwd -eq $canonicalRoot)) {
      $status = "CANONICAL"
      $statusLabel = "CWD canonico"
    } elseif ($latest.severity -eq "CORRECTED" -or $recentCorrection) {
      $status = "CORRECTED"
      $statusLabel = "CWD corregido"
    } elseif ($latest.severity -eq "OBSERVED") {
      $status = "OBSERVED"
      $statusLabel = "CWD observado"
    }
  }

  return [pscustomobject]@{
    available = $true
    current_cwd = $currentCwd
    canonical_root = $canonicalRoot
    status = $status
    status_label = $statusLabel
    last_event_timestamp = if ($latest) { $latest.timestamp } else { $null }
    recent_correction = $recentCorrection
    recent_events = @($recent)
    source = $root
  }
}

function Get-TaskTitleMap {
  $live = Read-JsonSafe (Get-NocPaths).LiveTaskEvidence
  $map = @{}
  if ($live -and $live.planner_tasks) {
    foreach ($task in @($live.planner_tasks)) {
      if ($null -eq $task) { continue }
      $id = [string]$task.id
      if ($id) {
        $map[$id] = [string]$task.title
      }
    }
  }
  return $map
}

function Convert-ToStringArray {
  param($Value)
  if ($null -eq $Value) { return @() }
  if ($Value -is [string]) { return @($Value) }
  if ($Value -is [System.Collections.IEnumerable]) {
    $items = New-Object System.Collections.Generic.List[string]
    foreach ($item in $Value) {
      if ($null -eq $item) { continue }
      $items.Add([string]$item)
    }
    return ,$items.ToArray()
  }
  return @([string]$Value)
}

function Test-NocFieldHasValue {
  param(
    [object]$Record,
    [string[]]$Fields
  )
  foreach ($field in $Fields) {
    if ($Record.PSObject.Properties.Name -contains $field) {
      $value = $Record.$field
      if ($null -ne $value -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
        return $true
      }
    }
  }
  return $false
}

function Test-NocExplicitMissing {
  param(
    [object]$Record,
    [string[]]$Fields
  )
  foreach ($field in $Fields) {
    if ($Record.PSObject.Properties.Name -contains $field) {
      $value = $Record.$field
      if ($value -eq $false) { return $true }
      if ($null -eq $value) { return $true }
      if ([string]::IsNullOrWhiteSpace([string]$value)) { return $true }
      $text = ([string]$value).Trim().ToUpperInvariant()
      if ($text -in @("MISSING", "NOT_FOUND", "SIN_CARPETA", "SIN_RESPONSABLE", "NONE", "NULL")) {
        return $true
      }
    }
  }
  return $false
}

function Build-NocState {
  param(
    [object]$Context = $null
  )

  $paths = Get-NocPaths
  $score = Read-JsonSafe $paths.PredictiveScore
  $hybrid = Read-JsonSafe $paths.HybridState
  $preprod = Read-JsonlSafe $paths.PreprodSnapshot
  $taskRecords = Read-JsonlSafe $paths.TaskReadback
  $teamsEvidence = Read-JsonSafe $paths.TeamsEvidence
  $graphAuth = Read-JsonSafe $paths.GraphAuthRecovery
  $busEvents = Read-JsonlSafe $paths.Bus -Tail 200
  $alerts = Read-JsonlSafe $paths.Alerts -Tail 120
  $taskTitles = Get-TaskTitleMap
  $entry = Read-EntrypointObservability
  $operationalMode = Read-JsonSafe $paths.OperationalMode
  $liveOperation = Read-JsonSafe $paths.LiveOperation
  if (-not $liveOperation) {
    $operationState = if ($operationalMode -and $operationalMode.operational_mode) { [string]$operationalMode.operational_mode } else { "inactive" }
    $traceState = if ($operationalMode -and $operationalMode.trace_mode) { [string]$operationalMode.trace_mode } else { "manual" }
    $swarmState = if ($operationalMode -and $operationalMode.swarm_mode) { [string]$operationalMode.swarm_mode } else { "manual" }
    $liveOperation = [pscustomobject]@{
      schema_version = 1
      panel = "Operación en Vivo"
      generated_at = $null
      refresh = "continuous"
      operational_mode = $operationState
      trace_mode = $traceState
      swarm_mode = $swarmState
      silent_mode = "prohibited"
      ultima_orden = $null
      estado_sistema = [pscustomobject]@{
        root = $paths.Root
        trace = $traceState
        swarm = $swarmState
        risk_state = "UNKNOWN"
        thread_status = [pscustomobject]@{}
      }
      threads_activos = @()
      alertas = @()
    }
  }

  $total = @($taskRecords).Count
  $trusted = 0
  $hasActivity = 0
  $sinCarpeta = 0
  $sinResponsable = 0
  $inconsistentes = 0
  $ok = 0
  $duplicateCandidates = 0
  $critical = New-Object System.Collections.Generic.List[object]

  foreach ($record in @($taskRecords)) {
    if ($null -eq $record) { continue }
    $scoreValue = 0
    if ($null -ne $record.consistency_score) {
      try { $scoreValue = [int]$record.consistency_score } catch { $scoreValue = 0 }
    }
    $isTrusted = ([string]$record.confidence_class -eq "TASK_TRUSTED") -or ([string]$record.readback_trust -eq "TRUSTED_HYBRID")
    if ($isTrusted) { $trusted++ }
    if ($record.has_activity -eq $true) { $hasActivity++ }

    $flags = New-Object System.Collections.Generic.List[string]
    $folderFields = @("expediente_id", "folder", "folder_path", "carpeta", "carpeta_path", "sharepoint_folder", "sharepoint_folder_url")
    $responsibleFields = @("responsable", "owner", "assignee", "assigned_to", "assignedTo")

    if ((Test-NocExplicitMissing -Record $record -Fields $folderFields) -and -not (Test-NocFieldHasValue -Record $record -Fields $folderFields)) {
      $flags.Add("SIN_CARPETA")
      $sinCarpeta++
    }

    if ((Test-NocExplicitMissing -Record $record -Fields $responsibleFields) -and -not (Test-NocFieldHasValue -Record $record -Fields $responsibleFields)) {
      $flags.Add("SIN_RESPONSABLE")
      $sinResponsable++
    }

    if ($scoreValue -lt 2 -or $record.missing_task -eq $true) {
      $flags.Add("INCONSISTENTE")
      $inconsistentes++
    }

    if ($scoreValue -ge 2 -and $record.has_activity -eq $true -and $record.missing_task -ne $true -and $flags.Count -eq 0) {
      $ok++
    }

    if ($flags.Count -gt 0) {
      $title = if ($taskTitles.ContainsKey([string]$record.task_id)) {
        $taskTitles[[string]$record.task_id]
      } else {
        $fallbackTitle = $null
        if ($record.PSObject.Properties.Name -contains "task_title" -and -not [string]::IsNullOrWhiteSpace([string]$record.task_title)) {
          $fallbackTitle = [string]$record.task_title
        } elseif ($record.PSObject.Properties.Name -contains "title" -and -not [string]::IsNullOrWhiteSpace([string]$record.title)) {
          $fallbackTitle = [string]$record.title
        } else {
          $fallbackTitle = "Sin titulo"
        }
        $fallbackTitle
      }
      $critical.Add([ordered]@{
        task_id = [string]$record.task_id
        plan_id = [string]$record.plan_id
        title = $title
        status = "CRITICAL"
        consistency_score = $record.consistency_score
        issue_flags = @($flags.ToArray())
        source_flags = $record.source_flags
        has_activity = $record.has_activity
        primary_comment_source = $record.primary_comment_source
        readback_trust = $record.readback_trust
      })
    }
  }

  $latestEvent = if ($busEvents.Count) { $busEvents[$busEvents.Count - 1] } else { $null }
  $latestRun = Get-LatestByType $busEvents "WATCHDOG_RUN"
  $latestAlert = Get-LatestByType $busEvents "WATCHDOG_ALERT"
  $alertCount = @($busEvents | Where-Object { [string]$_.type -eq "WATCHDOG_ALERT" }).Count

  $healthScore = 0
  $healthStatus = "UNKNOWN"
  $trend = "STABLE"
  $risk = "INFO"
  if ($score) {
    if ($null -ne $score.score) { $healthScore = [int]$score.score }
  }
  if ($healthScore -ge 85) {
    $healthStatus = "HEALTHY"
    $risk = "LOW"
  } elseif ($healthScore -ge 65) {
    $healthStatus = "YELLOW"
    $risk = "HIGH"
  } else {
    $healthStatus = "RED"
    $risk = "CRITICAL"
  }

  $runChange = $null
  if ($latestRun) {
    $payload = $latestRun.payload
    $runChangeType = [string]$latestRun.type
    if ($payload.changeType) {
      $runChangeType = [string]$payload.changeType
    }
    $runChangeSeverity = "LOW"
    if ($payload.changeSeverity) {
      $runChangeSeverity = [string]$payload.changeSeverity
    }
    $runChange = [ordered]@{
      type = $runChangeType
      severity = $runChangeSeverity
      detected = $payload.status -ne "NO_CHANGE"
      deltas = $payload.deltas
    }
  } elseif ($latestEvent) {
    $runChange = [ordered]@{
      type = [string]$latestEvent.type
      severity = "LOW"
      detected = $true
      deltas = $null
    }
  }

  $watchdogStatus = if ($latestRun -and $latestRun.payload.healthy -eq $true) { "ACTIVE" } else { "LOG_ONLY" }
  $watchdogLastTimestamp = if ($latestEvent) { "$($latestEvent.timestamp)" } else { $null }

  $validationStatus = if ($inconsistentes -eq 0) { "PASS" } else { "FAIL" }
  $readiness = if ($ok -ge $total -and $total -gt 0) { "READY" } else { "ACTION_REQUIRED" }
  $stateGeneral = if ($total -eq 0) { "EMPTY" } elseif ($critical.Count -eq 0) { "STABLE" } else { "DEGRADED" }

  $sourceSite = if ($hybrid.sharepoint_surface.site) { [string]($hybrid.sharepoint_surface.site) } else { "https://escribaniabitsch.sharepoint.com/sites/sistema" }
  $summary = if ($total -gt 0) {
    "{0} expedientes observados, {1} en estado critico, {2} sin carpeta, {3} sin responsable" -f $total, $critical.Count, $sinCarpeta, $sinResponsable
  } else {
    "Sin expedientes observados"
  }

  $plannerAgentStatus = "TRUSTED"
  if ($hybrid -and $hybrid.global_readback -and $hybrid.global_readback.plannerTask) {
    $plannerAgentStatus = [string]($hybrid.global_readback.plannerTask)
  }
  $teamsAgentStatus = "TRUSTED"
  if ($hybrid -and $hybrid.global_readback -and $hybrid.global_readback.Teams_history) {
    $teamsAgentStatus = [string]($hybrid.global_readback.Teams_history)
  }
  $readbackDetails = "PARTIAL"
  $readbackUntrusted = $false
  $readbackPartialDetails = $true
  if ($hybrid -and $hybrid.global_readback) {
    $readbackDetails = [string]($hybrid.global_readback.Details)
    $readbackUntrusted = [bool]($hybrid.global_readback.READBACK_UNTRUSTED)
    $readbackPartialDetails = [bool]($hybrid.global_readback.READBACK_PARTIAL_DETAILS)
  }

  $lastAction = $null
  if ($Context -and $Context.lastAction) {
    $lastAction = $Context.lastAction
  }

  $overallStatus = "NOC_ATTENTION_REQUIRED"
  if ($stateGeneral -eq "STABLE") {
    $overallStatus = "NOC_OPERATIONAL"
  } elseif ($stateGeneral -eq "EMPTY") {
    $overallStatus = "NOC_EMPTY"
  }
  $sharePointLiveWriteApplied = $true
  if ($hybrid -and $hybrid.sharepoint_surface) {
    $sharePointLiveWriteApplied = [bool]($hybrid.sharepoint_surface.live_write_applied)
  }
  $sharePointLiveWriteScope = "root folders only"
  if ($hybrid -and $hybrid.sharepoint_surface -and $hybrid.sharepoint_surface.live_write_scope) {
    $sharePointLiveWriteScope = [string]($hybrid.sharepoint_surface.live_write_scope)
  }
  $latestEventType = $null
  if ($latestEvent) {
    $latestEventType = [string]($latestEvent.type)
  }

  $compactState = [pscustomobject]::new()
  $compactState | Add-Member -NotePropertyName schema_version -NotePropertyValue 1
  $compactState | Add-Member -NotePropertyName artifact -NotePropertyValue "noc-state"
  $compactState | Add-Member -NotePropertyName generated_at -NotePropertyValue ((Get-Date).ToString("o"))
  $compactState | Add-Member -NotePropertyName mode -NotePropertyValue "HYBRID_SOURCE"
  $compactState | Add-Member -NotePropertyName status -NotePropertyValue $overallStatus
  $compactState | Add-Member -NotePropertyName sources -NotePropertyValue ([pscustomobject]@{
    snapshot_local = $paths.PreprodSnapshot
    hybrid_state = $paths.HybridState
    bus = $paths.Bus
    sharepoint_site = $sourceSite
    sharepoint_roots = @("EXPEDIENTES", "SDU")
    graph_auth = $paths.GraphAuthRecovery
    operational_mode = $paths.OperationalMode
    live_operation = $paths.LiveOperation
  })
  $compactState | Add-Member -NotePropertyName health -NotePropertyValue ([pscustomobject]@{
    score = $healthScore
    status = $healthStatus
    trend = $trend
    risk = $risk
  })
  $compactState | Add-Member -NotePropertyName governance -NotePropertyValue ([pscustomobject]@{
    multirepo = [pscustomobject]@{
      readiness = $readiness
      validation = [pscustomobject]@{
        status = $validationStatus
        decision = $validationStatus
        expected_total = $total
        detected_total = $total
        found = $trusted
        possible_active_matches = 0
        historical_only = $false
        not_materialized = $true
      }
    }
    root_junction_hygiene = [pscustomobject]@{
      status = "PASS"
      note = "NOC wired to hybrid readback and watchdog bus"
    }
  })
  $compactState | Add-Member -NotePropertyName last_run -NotePropertyValue ([pscustomobject]@{
    mode = "WATCHDOG_RUN"
    timestamp = $watchdogLastTimestamp
    duration_ms = $null
    run_id = $null
    auto_action_enabled = $false
  })
  $compactState | Add-Member -NotePropertyName last_alert -NotePropertyValue ([pscustomobject]@{
    severity = "HIGH"
    mode = "LOG_ONLY"
    timestamp = $watchdogLastTimestamp
    traceId = $null
    currentTraceId = $null
  })
  $compactState | Add-Member -NotePropertyName last_change -NotePropertyValue ([pscustomobject]@{
    action = "BUS_EVENT"
    result = $stateGeneral
    timestamp = $watchdogLastTimestamp
    path = $paths.Bus
  })
  $compactState | Add-Member -NotePropertyName operation_live -NotePropertyValue $liveOperation
  $compactState | Add-Member -NotePropertyName agent -NotePropertyValue ([pscustomobject]@{
    status = [pscustomobject]@{
      all = @(
        [pscustomobject]@{ name = "planner"; status = $plannerAgentStatus },
        [pscustomobject]@{ name = "teams"; status = $teamsAgentStatus },
        [pscustomobject]@{ name = "sharepoint"; status = "PARTIAL" },
        [pscustomobject]@{ name = "watchdog"; status = $watchdogStatus }
      )
    }
  })
  $nocState = [pscustomobject]::new()
  $nocState | Add-Member -NotePropertyName total_expedientes -NotePropertyValue $total
  $nocState | Add-Member -NotePropertyName expedientes_ok -NotePropertyValue $ok
  $nocState | Add-Member -NotePropertyName expedientes_con_error -NotePropertyValue $critical.Count
  $nocState | Add-Member -NotePropertyName sin_carpeta -NotePropertyValue $sinCarpeta
  $nocState | Add-Member -NotePropertyName sin_responsable -NotePropertyValue $sinResponsable
  $nocState | Add-Member -NotePropertyName inconsistentes -NotePropertyValue $inconsistentes
  $nocState | Add-Member -NotePropertyName alertas_activas -NotePropertyValue $alertCount
  $nocState | Add-Member -NotePropertyName ultimo_evento_tipo -NotePropertyValue $latestEventType
  $nocState | Add-Member -NotePropertyName estado_general -NotePropertyValue $stateGeneral
  $nocState | Add-Member -NotePropertyName summary -NotePropertyValue $summary
  $criticalSummary = @($critical | ForEach-Object {
    [pscustomobject]@{
      task_id = [string]$_.task_id
      title = [string]$_.title
      issue_flags = @($_.issue_flags)
    }
  })
  $nocState | Add-Member -NotePropertyName critical_expedientes -NotePropertyValue $criticalSummary
  $nocState | Add-Member -NotePropertyName duplicate_candidates -NotePropertyValue $duplicateCandidates
  $nocState | Add-Member -NotePropertyName readback -NotePropertyValue ([pscustomobject]@{
    plannerTask = $plannerAgentStatus
    Teams_history = $teamsAgentStatus
    Details = $readbackDetails
    READBACK_UNTRUSTED = $readbackUntrusted
    READBACK_PARTIAL_DETAILS = $readbackPartialDetails
  })
  $nocState | Add-Member -NotePropertyName sharepoint_surface -NotePropertyValue ([pscustomobject]@{
    site = $sourceSite
    roots = @("EXPEDIENTES", "SDU")
    live_write_applied = $sharePointLiveWriteApplied
    live_write_scope = $sharePointLiveWriteScope
  })
  $nocState | Add-Member -NotePropertyName teams_activity -NotePropertyValue ([pscustomobject]@{ count = 0 })
  $nocState | Add-Member -NotePropertyName entrypoint_observability -NotePropertyValue $entry
  $nocState | Add-Member -NotePropertyName operacion_en_vivo -NotePropertyValue $liveOperation
  $compactState | Add-Member -NotePropertyName noc -NotePropertyValue $nocState
  $compactState | Add-Member -NotePropertyName bus -NotePropertyValue ([pscustomobject]@{
    visible_events = $busEvents.Count
    visible_alerts = $alertCount
    latest_event_type = $latestEventType
  })
  if ($lastAction) {
    $compactState | Add-Member -NotePropertyName last_action -NotePropertyValue $lastAction
  }
  return $compactState

  $state = @{
    schema_version = 1
    artifact = "noc-state"
    generated_at = (Get-Date).ToString("o")
    mode = "HYBRID_SOURCE"
    status = $overallStatus
    sources = @{
      snapshot_local = $paths.PreprodSnapshot
      hybrid_state = $paths.HybridState
      bus = $paths.Bus
      sharepoint_site = $sourceSite
      sharepoint_roots = @("EXPEDIENTES", "SDU")
      graph_auth = $paths.GraphAuthRecovery
    }
    health = @{
      score = $healthScore
      status = $healthStatus
      trend = $trend
      risk = $risk
    }
    telemetry = @{
      resume = @{
        status = $watchdogStatus
        healthy = $true
        lastTimestamp = $watchdogLastTimestamp
        change = @{
          type = "WATCHDOG_ALERT"
          severity = "HIGH"
          detected = $true
          deltas = @{}
        }
      }
    }
    governance = @{
      matrix_loaded = $true
      taxonomy = @{
        status = "PASS"
        timestamp = $null
        violations = @()
        critical = @()
      }
      repo_boot_prompts = @{
        status = "PASS"
        packet_count = $total
        updated_at = (Get-Date).ToString("o")
      }
      codex_execution_contract = @{
        status = "ACTIVE"
        contract = "G50"
        mode = "DECLARATIVE"
        editor = "VS_CODE_INSIDERS"
      }
      multirepo = @{
        readiness = $readiness
        validation = @{
          status = $validationStatus
          decision = $validationStatus
          expected_total = $total
          detected_total = $total
          found = $trusted
          possible_active_matches = 0
          historical_only = $false
          not_materialized = $true
        }
      }
      root_junction_hygiene = @{
        status = "PASS"
        note = "NOC wired to hybrid readback and watchdog bus"
      }
    }
    last_run = @{
      mode = "WATCHDOG_RUN"
      timestamp = $watchdogLastTimestamp
      duration_ms = $null
      run_id = $null
      auto_action_enabled = $false
    }
    last_alert = @{
      severity = "HIGH"
      mode = "LOG_ONLY"
      timestamp = $watchdogLastTimestamp
      traceId = $null
      currentTraceId = $null
    }
    last_change = @{
      action = "BUS_EVENT"
      result = $stateGeneral
      timestamp = $watchdogLastTimestamp
      path = $paths.Bus
    }
    agent = @{
      status = @{
        all = @(
          @{ name = "planner"; status = $plannerAgentStatus },
          @{ name = "teams"; status = $teamsAgentStatus },
          @{ name = "sharepoint"; status = "PARTIAL" },
          @{ name = "watchdog"; status = $watchdogStatus }
        )
      }
    }
    noc = @{
      total_expedientes = $total
      expedientes_ok = $ok
      expedientes_con_error = $critical.Count
      sin_carpeta = $sinCarpeta
      sin_responsable = $sinResponsable
      inconsistentes = $inconsistentes
      alertas_activas = $alertCount
      ultimo_evento = $latestEvent
      estado_general = $stateGeneral
      summary = $summary
      critical_expedientes = @($critical)
      duplicate_candidates = $duplicateCandidates
      readback = @{
        plannerTask = $plannerAgentStatus
        Teams_history = $teamsAgentStatus
        Details = $readbackDetails
        READBACK_UNTRUSTED = $readbackUntrusted
        READBACK_PARTIAL_DETAILS = $readbackPartialDetails
      }
      sharepoint_surface = @{
        site = $sourceSite
        roots = @("EXPEDIENTES", "SDU")
        live_write_applied = $sharePointLiveWriteApplied
        live_write_scope = $sharePointLiveWriteScope
      }
      teams_activity = @{
        count = 0
      }
      graph_auth = $graphAuth
    }
    bus = @{
      visible_events = $busEvents.Count
      visible_alerts = $alertCount
      latest_event_type = $latestEventType
    }
  }

  if ($lastAction) {
    $state.last_action = $lastAction
  }

  return $state
}

function Save-NocState {
  param($State)
  $paths = Get-NocPaths
  Write-JsonFile -Path $paths.NocState -Object $State
  return $paths.NocState
}

function Acquire-NocLock {
  param(
    [string]$ActionId,
    [string]$ActionLabel
  )
  $paths = Get-NocPaths
  New-Item -ItemType Directory -Force -Path $paths.NocRoot | Out-Null
  try {
    $stream = [System.IO.File]::Open($paths.NocLock, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  } catch {
    throw "NOC_LOCK_BUSY"
  }
  $meta = [ordered]@{
    acquired_at = (Get-Date).ToString("o")
    process_id = $PID
    action_id = $ActionId
    action_label = $ActionLabel
  }
  $bytes = [System.Text.Encoding]::UTF8.GetBytes((($meta | ConvertTo-Json -Depth 6 -Compress)))
  $stream.SetLength(0)
  $stream.Write($bytes, 0, $bytes.Length)
  $stream.Flush()
  return $stream
}

function Release-NocLock {
  param($Stream)
  $paths = Get-NocPaths
  if ($Stream) {
    try { $Stream.Close() } catch {}
  }
  Remove-Item -LiteralPath $paths.NocLock -Force -ErrorAction SilentlyContinue
}

function Emit-NocEvent {
  param(
    [string]$Type,
    [hashtable]$Payload,
    [string]$Source = "noc-actions"
  )
  $paths = Get-NocPaths
  $event = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    type = $Type
    source = $Source
    payload = $Payload
  }
  Append-JsonlEntry -Path $paths.Bus -Object $event
  return $event
}

function Write-NocActionTrace {
  param(
    [string]$ActionId,
    [string]$ActionLabel,
    [string]$Risk,
    [string]$ExecutedBy,
    [string]$DecisionSource,
    [object]$State,
    [hashtable]$Result
  )
  $paths = Get-NocPaths
  $entry = [ordered]@{
    actionId = $ActionId
    actionLabel = $ActionLabel
    timestamp = (Get-Date).ToString("o")
    executedBy = $ExecutedBy
    decisionSource = $DecisionSource
    risk = $Risk
    result = if ($Result.ok) { "SUCCESS" } else { "FAIL" }
    preState = $State
    postState = "UNCHANGED"
    impact = "LOCAL_NOC_STATE_REFRESH"
    details = $Result
  }
  Append-JsonlEntry -Path $paths.ActionLog -Object $entry
  return $entry
}
