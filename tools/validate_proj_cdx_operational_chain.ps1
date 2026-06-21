param(
  [string]$Root = "C:/Users/enzo1/PROJEC CDX",
  [string]$ChainCsv = "C:/Users/enzo1/Documents/Codex/2026-06-14/projec-cdx-handoff-20260614/outputs/PROJEC_CDX_CARRIL4_OPERATIONAL_CHAIN_INDEX.csv",
  [string]$SchemaCsv = "C:/Users/enzo1/Documents/Codex/2026-06-14/projec-cdx-handoff-20260614/outputs/PROJEC_CDX_OPERATIONAL_CHAIN_SCHEMA_20260615.csv",
  [string]$DataverseSourceMapCsv = "C:/Users/enzo1/PROJEC CDX/dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv",
  [string]$AtomicMatrixCsv = "C:/Users/enzo1/PROJEC CDX/atomic/CODEX_ATOMIC_ACTION_MATRIX.csv",
  [string]$ResolverPy = "C:/Users/enzo1/PROJEC CDX/tools/sdu_chain_resolver.py",
  [switch]$LegacyCsvValidation,
  [switch]$Json
)

$ErrorActionPreference = "Stop"

$result = [ordered]@{
  root = $Root
  chain_csv = $ChainCsv
  schema_csv = $SchemaCsv
  dataverse_source_map_csv = $DataverseSourceMapCsv
  atomic_matrix_csv = $AtomicMatrixCsv
  status = "PASS"
  checked_at = (Get-Date).ToString("s")
  checks = @()
}

function Add-Check {
  param(
    [string]$Name,
    [string]$Status,
    [string]$Detail
  )
  $script:result.checks += [ordered]@{
    name = $Name
    status = $Status
    detail = $Detail
  }
  if ($Status -eq "FAIL") {
    $script:result.status = "FAIL"
  } elseif ($Status -eq "OBSERVED" -and $script:result.status -ne "FAIL") {
    $script:result.status = "OBSERVED"
  }
}

if (-not $LegacyCsvValidation) {
  $result["resolver_py"] = $ResolverPy

  if (-not (Test-Path -LiteralPath $ResolverPy -PathType Leaf)) {
    Add-Check "resolver_exists" "FAIL" "No existe el resolvedor local SDU."
  } else {
    Add-Check "resolver_exists" "PASS" "OK"
    $VenvPython = Join-Path $Root ".venv/Scripts/python.exe"
    if (Test-Path -LiteralPath $VenvPython -PathType Leaf) {
      $Python = $VenvPython
    } else {
      $Python = "python"
    }

    $resolverOutput = & $Python $ResolverPy --root $Root --mode all --agent All --no-external --dry-run --json 2>&1
    $resolverText = ($resolverOutput | Out-String).Trim()
    $resolverPayload = $null

    try {
      $resolverPayload = $resolverText | ConvertFrom-Json
    } catch {
      Add-Check "resolver_json_parse" "FAIL" "El resolvedor no emitio JSON valido: $resolverText"
    }

    if ($null -ne $resolverPayload) {
      $result["resolver"] = $resolverPayload
      Add-Check "resolver_status" $resolverPayload.status "Cadena local: $($resolverPayload.chain)"
      foreach ($check in @($resolverPayload.checks)) {
        Add-Check "resolver:$($check.name)" $check.status $check.detail
      }
    }
  }

  if ($Json) {
    $result | ConvertTo-Json -Depth 12
  } else {
    "STATUS: $($result.status)"
    foreach ($check in $result.checks) {
      "$($check.status) | $($check.name) | $($check.detail)"
    }
  }

  if ($result.status -eq "FAIL") {
    exit 1
  }
  exit 0
}

if (-not (Test-Path -LiteralPath $ChainCsv -PathType Leaf)) {
  Add-Check "chain_csv_exists" "FAIL" "No existe el indice puente."
} else {
  Add-Check "chain_csv_exists" "PASS" "OK"
}

if (-not (Test-Path -LiteralPath $SchemaCsv -PathType Leaf)) {
  Add-Check "schema_csv_exists" "FAIL" "No existe el schema."
} else {
  Add-Check "schema_csv_exists" "PASS" "OK"
}

if (-not (Test-Path -LiteralPath $DataverseSourceMapCsv -PathType Leaf)) {
  Add-Check "dataverse_source_map_exists" "FAIL" "No existe el mapa fuente Dataverse."
} else {
  Add-Check "dataverse_source_map_exists" "PASS" "OK"
}

if (-not (Test-Path -LiteralPath $AtomicMatrixCsv -PathType Leaf)) {
  Add-Check "atomic_matrix_exists" "FAIL" "No existe la matriz atomica."
} else {
  Add-Check "atomic_matrix_exists" "PASS" "OK"
}

if ($result.status -ne "FAIL") {
  $rows = @(Import-Csv -LiteralPath $ChainCsv)
  $schema = @(Import-Csv -LiteralPath $SchemaCsv)
  $sourceMap = @(Import-Csv -LiteralPath $DataverseSourceMapCsv)
  $atomicMatrix = @(Import-Csv -LiteralPath $AtomicMatrixCsv)
  $required = @($schema | Where-Object { $_.required -eq "yes" } | Select-Object -ExpandProperty field)

  if ($rows.Count -gt 0) {
    Add-Check "chain_rows" "PASS" "Filas: $($rows.Count)"
  } else {
    Add-Check "chain_rows" "FAIL" "No hay filas."
  }

  $columns = @()
  if ($rows.Count -gt 0) {
    $columns = @($rows[0].PSObject.Properties.Name)
  }
  foreach ($field in $required) {
    if ($columns -contains $field) {
      Add-Check "schema_field:$field" "PASS" "Campo presente."
    } else {
      Add-Check "schema_field:$field" "FAIL" "Falta campo requerido."
    }
  }

  $missing = @()
  foreach ($row in $rows) {
    foreach ($field in $required) {
      if ([string]::IsNullOrWhiteSpace($row.$field)) {
        $missing += "$($row.repo)/$($row.execution_agent):$field"
      }
    }
  }
  if ($missing.Count -eq 0) {
    Add-Check "required_values" "PASS" "Sin campos requeridos vacios."
  } else {
    Add-Check "required_values" "FAIL" ($missing -join ";")
  }

  $allowedGap = @(
    "OK_GOVERNED",
    "OK_REPO_OWNER",
    "OK_CHAIN_VISIBLE",
    "OK_GATE_VISIBLE",
    "INDEX_ONLY",
    "INDEX_ONLY_NEEDS_MATRIX_JOIN",
    "PENDING_SKILL",
    "PENDING_RECIPE",
    "PENDING_TOOL",
    "PENDING_VALIDATOR",
    "PENDING_EVIDENCE",
    "PENDING_STOP_CONDITION"
  )
  $badGap = @($rows | Where-Object { $_.gap_status -notin $allowedGap })
  if ($badGap.Count -eq 0) {
    Add-Check "gap_status_enum" "PASS" "Estados permitidos."
  } else {
    Add-Check "gap_status_enum" "FAIL" (($badGap | Select-Object -ExpandProperty gap_status -Unique) -join ";")
  }

  $allowedBoundary = @(
    "NO_LIVE",
    "NO_LIVE_WITHOUT_ORDER",
    "REPO_ONLY_LOCAL_DOCUMENTAL_ACTIVE",
    "MICROSOFT_LIVE_GOVERNED_REQUIRES_ORDER_EVIDENCE_POSTCHECK",
    "OPENAI_LIVE_GOVERNED_REQUIRES_ORDER_EVIDENCE_POSTCHECK",
    "DATAVERSE_LIVE_GOVERNED_REQUIRES_GATE68"
  )
  $badBoundary = @($rows | Where-Object { $_.live_boundary -notin $allowedBoundary })
  if ($badBoundary.Count -eq 0) {
    Add-Check "live_boundary_enum" "PASS" "Fronteras permitidas."
  } else {
    Add-Check "live_boundary_enum" "FAIL" (($badBoundary | Select-Object -ExpandProperty live_boundary -Unique) -join ";")
  }

  $allowedDataverseStatus = @(
    "DATAVERSE_CANON_EXPECTED_LOCAL_PROJECTION",
    "LIVE_ROWS_CONFIRMED",
    "METADATA_ONLY",
    "TARGET_AMBIGUOUS"
  )
  $badDataverseStatus = @($rows | Where-Object { $_.dataverse_source_status -notin $allowedDataverseStatus })
  if ($badDataverseStatus.Count -eq 0) {
    Add-Check "dataverse_source_status_enum" "PASS" "Estados Dataverse permitidos."
  } else {
    Add-Check "dataverse_source_status_enum" "FAIL" (($badDataverseStatus | Select-Object -ExpandProperty dataverse_source_status -Unique) -join ";")
  }

  $mappedDataverseSources = @($sourceMap | Select-Object -ExpandProperty functional_source_table -Unique)
  $badDataverseSource = @($rows | Where-Object { $_.dataverse_source_table -notin $mappedDataverseSources })
  if ($badDataverseSource.Count -eq 0) {
    Add-Check "dataverse_source_table_mapped" "PASS" "Fuentes Dataverse declaradas en source map."
  } else {
    Add-Check "dataverse_source_table_mapped" "FAIL" (($badDataverseSource | Select-Object -ExpandProperty dataverse_source_table -Unique) -join ";")
  }

  $ungovernedDataverseSurface = @($sourceMap | Where-Object { $_.governance_state -notmatch "^GOVERNED_" })
  if ($ungovernedDataverseSurface.Count -eq 0) {
    Add-Check "dataverse_source_map_governed" "PASS" "Source map apunta a superficies gobernadas."
  } else {
    Add-Check "dataverse_source_map_governed" "FAIL" (($ungovernedDataverseSurface | Select-Object -ExpandProperty logical_surface -Unique) -join ";")
  }

  $badRowKeyPattern = @($rows | Where-Object { $_.dataverse_row_key -notmatch "^opchain_[0-9a-f]{16}$" })
  if ($badRowKeyPattern.Count -eq 0) {
    Add-Check "dataverse_row_key_pattern" "PASS" "Formato estable."
  } else {
    Add-Check "dataverse_row_key_pattern" "FAIL" "Claves Dataverse invalidas: $($badRowKeyPattern.Count)"
  }

  $duplicateRowKeys = @($rows | Group-Object dataverse_row_key | Where-Object { $_.Count -gt 1 })
  if ($duplicateRowKeys.Count -eq 0) {
    Add-Check "dataverse_row_key_unique" "PASS" "Sin duplicados."
  } else {
    Add-Check "dataverse_row_key_unique" "FAIL" (($duplicateRowKeys | Select-Object -ExpandProperty Name) -join ";")
  }

  $allowedAtomicPhase = @("CONCENTRATE", "DISPERSE", "MULTIPLY", "IMPULSE")
  $badAtomicPhase = @($rows | Where-Object { $_.atomic_energy_phase -notin $allowedAtomicPhase })
  if ($badAtomicPhase.Count -eq 0) {
    Add-Check "atomic_energy_phase_enum" "PASS" "Fases atomicas permitidas."
  } else {
    Add-Check "atomic_energy_phase_enum" "FAIL" (($badAtomicPhase | Select-Object -ExpandProperty atomic_energy_phase -Unique) -join ";")
  }

  $allowedAtomicTerminal = @("DONE", "NOOP", "BLOCKED", "REVERTED", "ESCALATED", "FAILED_SAFE")
  $badAtomicTerminal = @($rows | Where-Object { $_.atomic_terminal_state -notin $allowedAtomicTerminal })
  if ($badAtomicTerminal.Count -eq 0) {
    Add-Check "atomic_terminal_state_enum" "PASS" "Estados terminales atomicos permitidos."
  } else {
    Add-Check "atomic_terminal_state_enum" "FAIL" (($badAtomicTerminal | Select-Object -ExpandProperty atomic_terminal_state -Unique) -join ";")
  }

  $allowedAtomicActions = @()
  if ($atomicMatrix.Count -gt 0 -and ($atomicMatrix[0].PSObject.Properties.Name -contains "action_type")) {
    $allowedAtomicActions = @($atomicMatrix | Select-Object -ExpandProperty action_type -Unique)
  } elseif ($atomicMatrix.Count -gt 0 -and ($atomicMatrix[0].PSObject.Properties.Name -contains "atomic_action_type")) {
    $allowedAtomicActions = @($atomicMatrix | Select-Object -ExpandProperty atomic_action_type -Unique)
  }
  if ($allowedAtomicActions.Count -eq 0) {
    Add-Check "atomic_action_type_source" "FAIL" "La matriz atomica no expone action_type."
  } else {
    $badAtomicAction = @($rows | Where-Object { $_.atomic_action_type -notin $allowedAtomicActions })
    if ($badAtomicAction.Count -eq 0) {
      Add-Check "atomic_action_type_matrix" "PASS" "Tipos atomicos presentes en matriz canonica."
    } else {
      Add-Check "atomic_action_type_matrix" "FAIL" (($badAtomicAction | Select-Object -ExpandProperty atomic_action_type -Unique) -join ";")
    }
  }

  $badIdempotencyPattern = @($rows | Where-Object { $_.atomic_idempotency_key -notmatch "^atom_[0-9a-f]{24}$" })
  if ($badIdempotencyPattern.Count -eq 0) {
    Add-Check "atomic_idempotency_key_pattern" "PASS" "Formato estable."
  } else {
    Add-Check "atomic_idempotency_key_pattern" "FAIL" "Claves atomicas invalidas: $($badIdempotencyPattern.Count)"
  }

  $duplicateIdempotency = @($rows | Group-Object atomic_idempotency_key | Where-Object { $_.Count -gt 1 })
  if ($duplicateIdempotency.Count -eq 0) {
    Add-Check "atomic_idempotency_key_unique" "PASS" "Sin duplicados."
  } else {
    Add-Check "atomic_idempotency_key_unique" "FAIL" (($duplicateIdempotency | Select-Object -ExpandProperty Name) -join ";")
  }

  $badIdempotencyLink = @($rows | Where-Object {
    $rowKey = $_.dataverse_row_key -replace "^opchain_", ""
    $idemKey = $_.atomic_idempotency_key -replace "^atom_", ""
    $idemKey.Length -lt 16 -or $rowKey -ne $idemKey.Substring(0, 16)
  })
  if ($badIdempotencyLink.Count -eq 0) {
    Add-Check "atomic_idempotency_matches_dataverse_row_key" "PASS" "La idempotencia deriva de la identidad Dataverse."
  } else {
    Add-Check "atomic_idempotency_matches_dataverse_row_key" "FAIL" "Filas no correlacionadas: $($badIdempotencyLink.Count)"
  }

  $indexOnly = @($rows | Where-Object { $_.gap_status -like "INDEX_ONLY*" })
  if ($indexOnly.Count -gt 0) {
    Add-Check "index_only_rows" "OBSERVED" "Filas index-only: $($indexOnly.Count)"
    $badIndexOnly = @($indexOnly | Where-Object {
      $_.atomic_action_type -ne "ATOMIC_DISCOVER" -or
      $_.atomic_energy_phase -ne "DISPERSE" -or
      $_.atomic_next_impulse -ne "join_dataverse_source_matrix"
    })
    if ($badIndexOnly.Count -eq 0) {
      Add-Check "index_only_contract" "PASS" "INDEX_ONLY limitado a discovery y join de matriz fuente."
    } else {
      Add-Check "index_only_contract" "FAIL" "Filas INDEX_ONLY fuera de contrato: $($badIndexOnly.Count)"
    }
  } else {
    Add-Check "index_only_rows" "PASS" "Sin filas index-only."
  }
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  "STATUS: $($result.status)"
  foreach ($check in $result.checks) {
    "$($check.status) | $($check.name) | $($check.detail)"
  }
}

if ($result.status -eq "FAIL") {
  exit 1
}
