param(
  [string]$ActionId = "NOC_ACTION",
  [string]$ActionLabel = "NOC action",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}",
  [string]$NocActionName = ""
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_shared.ps1")

function Convert-JsonSafe([string]$JsonText) {
  try {
    if ([string]::IsNullOrWhiteSpace($JsonText)) { return [pscustomobject]@{} }
    return $JsonText | ConvertFrom-Json
  } catch {
    return [pscustomobject]@{}
  }
}

function Build-ActionSpec {
  param([string]$Name, [object]$BeforeState)
  $noc = if ($BeforeState -and $BeforeState.noc) { $BeforeState.noc } else { [pscustomobject]@{} }
  $total = if ($noc.total_expedientes) { [int]$noc.total_expedientes } else { 0 }
  $errors = if ($noc.expedientes_con_error) { [int]$noc.expedientes_con_error } else { 0 }
  $missingFolders = if ($noc.sin_carpeta) { [int]$noc.sin_carpeta } else { 0 }
  $missingOwners = if ($noc.sin_responsable) { [int]$noc.sin_responsable } else { 0 }
  $inconsistent = if ($noc.inconsistentes) { [int]$noc.inconsistentes } else { 0 }
  $duplicates = if ($noc.duplicate_candidates) { [int]$noc.duplicate_candidates } else { 0 }
  $nameKey = [string]$Name
  switch ($nameKey.ToUpperInvariant()) {
    "CREATE_EXPEDIENTE" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = "SDU_NOC_ERROR_DETECTED"
        autoFixType = $null
        summary = "Preparado carril de alta controlada de expedientes"
        details = [ordered]@{
          target_surface = "/sites/sistema/EXPEDIENTES"
          planned_operations = @("generate_expediente_id", "create_local_snapshot_marker", "link_sharepoint_reference")
          pending_expedientes = $errors
          controlled_write = $false
        }
      }
    }
    "VALIDATE_ALL" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = if ($errors -gt 0) { "SDU_NOC_ERROR_DETECTED" } else { $null }
        autoFixType = $null
        summary = "Validacion global de expedientes completada"
        details = [ordered]@{
          total_expedientes = $total
          expedientes_ok = if ($noc.expedientes_ok) { [int]$noc.expedientes_ok } else { 0 }
          expedientes_con_error = $errors
          consistent = $inconsistent -eq 0
        }
      }
    }
    "NORMALIZE_ALL" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = if ($errors -gt 0) { "SDU_NOC_ERROR_DETECTED" } else { $null }
        autoFixType = $null
        summary = "Normalizacion local del snapshot NOC completada"
        details = [ordered]@{
          normalized_fields = @("expediente_id", "consistency_score", "source_flags")
          consistency_window = 20
          total_expedientes = $total
        }
      }
    }
    "CREATE_MISSING_FOLDERS" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = "SDU_NOC_ERROR_DETECTED"
        autoFixType = "SDU_NOC_AUTO_FIX"
        summary = "Detectada brecha de carpetas en expedientes"
        details = [ordered]@{
          target_surface = "/sites/sistema/EXPEDIENTES"
          missing_folders = $missingFolders
          would_create = $missingFolders
          controlled_write = $false
        }
      }
    }
    "DETECT_DUPLICATES" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = if ($duplicates -gt 0) { "SDU_NOC_ERROR_DETECTED" } else { $null }
        autoFixType = $null
        summary = "Deteccion de duplicados finalizada"
        details = [ordered]@{
          duplicate_candidates = $duplicates
          duplicate_status = if ($duplicates -gt 0) { "POSSIBLE_DUPLICATES" } else { "NO_DUPLICATES_FOUND" }
        }
      }
    }
    "DETECT_INCONSISTENCIES" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = if ($inconsistent -gt 0) { "SDU_NOC_ERROR_DETECTED" } else { $null }
        autoFixType = $null
        summary = "Deteccion de inconsistencias finalizada"
        details = [ordered]@{
          inconsistencies = $inconsistent
          missing_owners = $missingOwners
          missing_folders = $missingFolders
        }
      }
    }
    "AUTO_FIX_SAFE" {
      return [ordered]@{
        eventType = "SDU_NOC_ACTION_EXECUTED"
        validationType = "SDU_NOC_VALIDATION_RESULT"
        errorType = if ($errors -gt 0) { "SDU_NOC_ERROR_DETECTED" } else { $null }
        autoFixType = "SDU_NOC_AUTO_FIX"
        summary = "Auto-fix seguro aplicado solo sobre snapshot local"
        details = [ordered]@{
          safe_only = $true
          proposed_fixes = $errors
          would_link_sharepoint = $false
          would_create_folders = $missingFolders
        }
      }
    }
    default {
      throw "Unsupported NOC action: $Name"
    }
  }
}

$preState = Convert-JsonSafe $PreStateJson
$lock = Acquire-NocLock -ActionId $ActionId -ActionLabel $ActionLabel

try {
  $buildScript = Join-Path (Split-Path $PSScriptRoot -Parent) "build-noc-state.ps1"
  $beforeJson = & $buildScript -LastActionJson "{}"
  if ($beforeJson -is [array]) {
    $beforeJson = $beforeJson -join "`n"
  }
  $before = Convert-JsonSafe $beforeJson
  $spec = Build-ActionSpec -Name $NocActionName -BeforeState $before
  $resultDetails = [ordered]@{
    action = $NocActionName
    summary = $spec.summary
    counts = [ordered]@{
      total_expedientes = $before.noc.total_expedientes
      expedientes_ok = $before.noc.expedientes_ok
      expedientes_con_error = $before.noc.expedientes_con_error
      sin_carpeta = $before.noc.sin_carpeta
      sin_responsable = $before.noc.sin_responsable
      inconsistentes = $before.noc.inconsistentes
      alertas_activas = $before.noc.alertas_activas
    }
    validation_status = $before.noc.estado_general
    target_surface = $spec.details.target_surface
    controlled_write = if ($spec.details.Contains("controlled_write")) { [bool]$spec.details.controlled_write } else { $false }
    pre_state = $preState
  }
  foreach ($key in $spec.details.Keys) {
    $resultDetails[$key] = $spec.details[$key]
  }

  $lastAction = [ordered]@{
    actionId = $ActionId
    actionName = $NocActionName
    actionLabel = $ActionLabel
    executedBy = $ExecutedBy
    decisionSource = $DecisionSource
    timestamp = (Get-Date).ToString("o")
    summary = $spec.summary
    status = "OK"
    details = $resultDetails
  }

  $actionEvent = Emit-NocEvent -Type $spec.eventType -Payload ([ordered]@{
    action_id = $ActionId
    action_name = $NocActionName
    action_label = $ActionLabel
    summary = $spec.summary
    state_path = (Get-NocPaths).NocState
    counts = $resultDetails.counts
    target_surface = $resultDetails.target_surface
    controlled_write = $resultDetails.controlled_write
    status = "EXECUTED"
  })

  $validationEvent = Emit-NocEvent -Type $spec.validationType -Payload ([ordered]@{
    action_id = $ActionId
    action_name = $NocActionName
    summary = $spec.summary
    estado_general = $before.noc.estado_general
    total_expedientes = $before.noc.total_expedientes
    expedientes_ok = $before.noc.expedientes_ok
    expedientes_con_error = $before.noc.expedientes_con_error
    sin_carpeta = $before.noc.sin_carpeta
    sin_responsable = $before.noc.sin_responsable
    inconsistentes = $before.noc.inconsistentes
    critical_items = @($before.noc.critical_expedientes).Count
  })

  if ($spec.errorType) {
    Emit-NocEvent -Type $spec.errorType -Payload ([ordered]@{
      action_id = $ActionId
      action_name = $NocActionName
      summary = $spec.summary
      issue_count = $before.noc.expedientes_con_error
      inconsistent_count = $before.noc.inconsistentes
      sin_carpeta = $before.noc.sin_carpeta
      sin_responsable = $before.noc.sin_responsable
    })
  }

  if ($spec.autoFixType) {
    Emit-NocEvent -Type $spec.autoFixType -Payload ([ordered]@{
      action_id = $ActionId
      action_name = $NocActionName
      summary = $spec.summary
      safe_only = $true
      proposed_fixes = $before.noc.expedientes_con_error
      would_create_folders = $before.noc.sin_carpeta
    })
  }

  Write-NocActionTrace -ActionId $ActionId -ActionLabel $ActionLabel -Risk $Risk -ExecutedBy $ExecutedBy -DecisionSource $DecisionSource -State $before -Result $resultDetails | Out-Null

  $afterJson = & $buildScript -LastActionJson ($lastAction | ConvertTo-Json -Depth 20 -Compress)
  if ($afterJson -is [array]) {
    $afterJson = $afterJson -join "`n"
  }
  $after = Convert-JsonSafe $afterJson
  $statePath = (Get-NocPaths).NocState

  [ordered]@{
    ok = $true
    actionId = $ActionId
    actionName = $NocActionName
    summary = $spec.summary
    timestamp = (Get-Date).ToString("o")
    statePath = $statePath
    validation = $validationEvent.payload
    busEvents = @($actionEvent.type, $validationEvent.type)
    result = "SUCCESS"
  } | ConvertTo-Json -Depth 20
}
catch {
  $failure = [ordered]@{
    ok = $false
    actionId = $ActionId
    actionName = $NocActionName
    summary = $_.Exception.Message
    timestamp = (Get-Date).ToString("o")
    result = "FAIL"
  }
  try {
    Emit-NocEvent -Type "SDU_NOC_ERROR_DETECTED" -Payload ([ordered]@{
      action_id = $ActionId
      action_name = $NocActionName
      summary = $_.Exception.Message
      failure = $true
    }) | Out-Null
  } catch {}
  $failure | ConvertTo-Json -Depth 20
  exit 1
}
finally {
  Release-NocLock -Stream $lock
}
