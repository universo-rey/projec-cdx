param(
  [string]$Root = ".agents\codex",
  [switch]$SkipWorkflowNestedValidators
)

$ErrorActionPreference = "Stop"
$script:CsvCache = @{}

function Read-CsvSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing CSV: $Path"
  }
  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  if (-not $script:CsvCache.ContainsKey($resolvedPath)) {
    $script:CsvCache[$resolvedPath] = @(Import-Csv -LiteralPath $resolvedPath)
  }
  return $script:CsvCache[$resolvedPath]
}

function New-StringSet {
  param([object[]]$Values)
  $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  foreach ($value in @($Values)) {
    if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
      [void]$set.Add([string]$value)
    }
  }
  return $set
}

function Test-RequiredColumns {
  param(
    [string]$Path,
    [string[]]$Columns
  )
  $rows = Read-CsvSafe -Path $Path
  $actual = @()
  if ($rows.Count -gt 0) {
    $actual = @($rows[0].PSObject.Properties.Name)
  } else {
    $header = (Get-Content -LiteralPath $Path -TotalCount 1)
    if ($header) { $actual = @($header -split ",") }
  }
  $actualSet = New-StringSet -Values $actual
  foreach ($column in $Columns) {
    if (-not $actualSet.Contains($column)) {
      return "Missing column '$column' in $Path"
    }
  }
  return $null
}

function Is-LocalPathLike {
  param([string]$Value)
  return ($Value -match '^[A-Za-z]:\\')
}

function Resolve-CabinaPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $Path
  }
  $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
  $repoRoot = Split-Path -Parent (Split-Path -Parent $resolvedRoot)
  $normalized = $Path -replace "/", "\"
  if ($normalized.StartsWith(".agents\codex", [System.StringComparison]::OrdinalIgnoreCase)) {
    $suffix = $normalized.Substring(".agents\codex".Length).TrimStart("\")
    return Join-Path $Root $suffix
  }
  if ($normalized.StartsWith("C:\Users\enzo1\Documents\GitHub\cabina-universal-d", [System.StringComparison]::OrdinalIgnoreCase)) {
    $suffix = $normalized.Substring("C:\Users\enzo1\Documents\GitHub\cabina-universal-d".Length).TrimStart("\")
    return Join-Path $repoRoot $suffix
  }
  return $Path
}

$levelValidator = Join-Path $Root "tools\local_validate_agent_levels.ps1"
$matrixIndex = Join-Path $Root "matrices\MATRIX_INDEX.csv"
$recipeIndex = Join-Path $Root "recipes\RECIPE_INDEX.csv"
$skillUsage = Join-Path $Root "skills\SKILL_USAGE_MATRIX.csv"
$skillMetadataQuality = Join-Path $Root "skills\SKILL_METADATA_QUALITY_MATRIX.csv"
$toolIndex = Join-Path $Root "tools\TOOL_INDEX.csv"
$localSkillCatalog = Join-Path $Root "matrices\LOCAL_SKILL_CATALOG.csv"
$ratGovernance = Join-Path $Root "matrices\REPO_AGENT_TOOL_GOVERNANCE_MATRIX.csv"
$repoGovernance = Join-Path $Root "matrices\REPO_GOVERNANCE_ASSIGNMENT_MATRIX.csv"
$agentGovernance = Join-Path $Root "matrices\AGENT_GOVERNANCE_MATRIX.csv"
$toolGovernance = Join-Path $Root "matrices\TOOL_GOVERNANCE_MATRIX.csv"
$validationCoverage = Join-Path $Root "matrices\VALIDATION_COVERAGE_MATRIX.csv"
$canonicalInventory = Join-Path $Root "matrices\GOVERNED_ASSET_CANONICAL_INVENTORY.csv"
$stopGlossary = Join-Path $Root "matrices\STOP_CONDITION_GLOSSARY.csv"
$coverageExceptions = Join-Path $Root "matrices\COVERAGE_EXCEPTION_REGISTRY.csv"
$lineageAudit = Join-Path $Root "matrices\CANONICAL_INDEX_LINEAGE_AUDIT.csv"
$documentSkillLane = Join-Path $Root "matrices\DOCUMENT_SKILL_LANE_MATRIX.csv"
$agentWorkpapers = Join-Path $Root "matrices\AGENT_WORKPAPERS_MATRIX.csv"
$pluginUsage = Join-Path $Root "matrices\PLUGIN_USAGE_MATRIX.csv"
$purposeSurfaceCapability = Join-Path $Root "matrices\PURPOSE_SURFACE_CAPABILITY_MATRIX.csv"
$parallelOperationCriteria = Join-Path $Root "matrices\PARALLEL_OPERATION_CRITERIA_MATRIX.csv"
$parallelIssueQueue = Join-Path $Root "matrices\PARALLEL_ISSUE_LANE_QUEUE.csv"
$orderPreparationAssignment = Join-Path $Root "matrices\ORDER_PREPARATION_ASSIGNMENT_MATRIX.csv"
$orderClassCapability = Join-Path $Root "matrices\ORDER_CLASS_CAPABILITY_MATRIX.csv"
$operationalChainGovernance = Join-Path $Root "matrices\OPERATIONAL_CHAIN_GOVERNANCE_MATRIX.csv"
$pluginSkillBoundary = Join-Path $Root "matrices\PLUGIN_SKILL_BOUNDARY_MATRIX.csv"
$sourceCapabilityGap = Join-Path $Root "matrices\SOURCE_CAPABILITY_ADOPTION_GAP_MATRIX.csv"
$subagentAliasMap = Join-Path $Root "agents\SUBAGENT_ALIAS_MAP.csv"
$subagentCapabilityAssignment = Join-Path $Root "matrices\SUBAGENT_CAPABILITY_ASSIGNMENT_MATRIX.csv"
$subskillUsage = Join-Path $Root "skills\SUBSKILL_USAGE_MATRIX.csv"
$subrecipeIndex = Join-Path $Root "recipes\SUBRECIPE_INDEX.csv"
$workpaperIndex = Join-Path $Root "workpapers\WORKPAPER_INDEX.csv"
$workpaperValidator = Join-Path $Root "tools\local_validate_agent_workpapers.ps1"
$parallelOrderValidator = Join-Path $Root "tools\local_validate_parallel_order_governance.ps1"
$orderPacketValidator = Join-Path $Root "tools\local_validate_order_packets.ps1"
$operationalChainValidator = Join-Path $Root "tools\local_validate_operational_chain.ps1"

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $levelValidator)) {
  $errors.Add("Missing level validator: $levelValidator")
} else {
  & $levelValidator -Root $Root | Out-Null
}

$requiredColumnChecks = @(
  @{ Path = $matrixIndex; Columns = @("matrix_id","path","scope","primary_reader","update_rule") },
  @{ Path = $recipeIndex; Columns = @("recipe_id","level_id","primary_agent","path","output") },
  @{ Path = $skillUsage; Columns = @("skill_id","source","assigned_level","assigned_agents","use_when","live_boundary") },
  @{ Path = $skillMetadataQuality; Columns = @("skill_id","path","category","source","owner_agent","reviewer_agent","description_status","trigger_keywords","trigger_boundary","allowed_actions","blocked_actions","validator","evidence","stop_condition","quality_status","next_action") },
  @{ Path = $toolIndex; Columns = @("tool_id","level_id","tool_type","path_or_command","allowed_surface","blocked_surface") },
  @{ Path = $localSkillCatalog; Columns = @("skill_id","path","source","owner_agent","primary_recipe","validator","use_when","live_boundary") },
  @{ Path = $ratGovernance; Columns = @("asset_class","governing_matrix","primary_owner_agent","authority_level","required_recipe","required_tool","evidence","validator","stop_condition") },
  @{ Path = $repoGovernance; Columns = @("repo_id","path","remote","universe","tower","owner_agent","authority_level","allowed_actions","blocked_without_order","evidence","validator","stop_condition") },
  @{ Path = $agentGovernance; Columns = @("agent_id","level_id","governs_asset_classes","authority_scope","allowed_actions","blocked_without_order","escalates_to","evidence","validator") },
  @{ Path = $toolGovernance; Columns = @("tool_id","owner_agent","tool_type","governed_asset_classes","allowed_surface","allowed_actions","blocked_surface","required_evidence","validator") },
  @{ Path = $validationCoverage; Columns = @("artifact_class","required_index","required_validator","owner_agent","coverage_status","stop_condition") },
  @{ Path = $canonicalInventory; Columns = @("asset_class","asset_id","owner_agent","authority_level","governing_matrix","required_recipe","required_tool","evidence","validator","coverage_status","stop_condition") },
  @{ Path = $stopGlossary; Columns = @("stop_condition","normalized_family","meaning","required_action","applies_to") },
  @{ Path = $coverageExceptions; Columns = @("exception_id","asset_class","asset_id","reason","coverage_status","owner_agent","validator","next_review") },
  @{ Path = $lineageAudit; Columns = @("lineage_id","source","derived","derivation","owner_agent","validator") },
  @{ Path = $documentSkillLane; Columns = @("lane_id","document_type","extensions","skill_id","skill_source","intake_agent","owner_agent","reviewer_agent","allowed_scope","requires_order_for","blocked_scope","template_storage","evidence_storage","redline_storage","sanitized_output_storage","required_recipe","required_tool","validator","evidence","stop_condition","status") },
  @{ Path = $agentWorkpapers; Columns = @("agent_id","level_id","workpapers_path","repo_snapshot_path","status","primary_surface","purpose","required_matrices","required_recipes","required_tools","required_validators","evidence_policy","validator","stop_condition") },
  @{ Path = $pluginUsage; Columns = @("plugin_id","availability","assigned_agents","purpose","surface","live_boundary","tool_refs","validator","stop_condition") },
  @{ Path = $purposeSurfaceCapability; Columns = @("artifact_id","artifact_type","agent_id","level_id","purpose","surface","universe","tower","owner_agent","authority_level","lifecycle","status","local_allowed","governed_order_required","allowed_actions","blocked_actions","skill_refs","recipe_refs","tool_refs","plugin_refs","validator_refs","evidence_required","workpaper_path","source_policy","source_refs","last_validated","stop_condition","next_review") },
  @{ Path = $parallelOperationCriteria; Columns = @("lane_id","lead_agent","owner_agent","reviewer_agent","delegate_agents","read_scope","write_scope","lock_key","dependency","max_parallel","allowed_parallelism","required_precheck","required_recipe","required_tool","evidence","validator","serialization_rule","stop_condition") },
  @{ Path = $parallelIssueQueue; Columns = @("work_unit_id","issue_id","issue_url","title","base_sha","branch","lane_id","lead_agent","owner_agent","reviewer_agent","read_scope","write_scope","lock_key","dependency","max_parallel","allowed_actions","blocked_actions","rollback","postcheck","evidence","validator","status","stop_condition") },
  @{ Path = $orderPreparationAssignment; Columns = @("order_class","preparer_agent","reviewer_agent","approver_role","canon_as_of","source_authority","required_fields","allowed_actions","blocked_actions","recipe","tool","evidence","validator","expiration_rule","stop_condition") },
  @{ Path = $orderClassCapability; Columns = @("order_class","required_agents","required_skills","required_recipes","required_tools","required_fields","validator","stop_condition") },
  @{ Path = $operationalChainGovernance; Columns = @("chain_id","applies_to","owner_agent","reviewer_agent","required_agent_source","required_skill_source","required_recipe_source","required_tool_source","required_validator_source","required_evidence_source","required_stop_condition_source","blocked_without_chain","status","validator","stop_condition") },
  @{ Path = $pluginSkillBoundary; Columns = @("plugin_id","skill_refs","assigned_agents","allowed_surface","requires_order_for","blocked_surface","validator","stop_condition") },
  @{ Path = $sourceCapabilityGap; Columns = @("source_id","source_path","capability_class","current_state","gap","decision","owner_agent","next_action","validator","stop_condition") },
  @{ Path = $subagentAliasMap; Columns = @("subagent_id","alias","role","assigned_lane","lead_agent","status","read_scope","write_scope","validator","stop_condition") },
  @{ Path = $subagentCapabilityAssignment; Columns = @("subagent_class","agent_template","default_skills","default_recipes","default_tools","allowed_surface","blocked_surface","parallel_policy","validator","stop_condition") },
  @{ Path = $subskillUsage; Columns = @("subskill_id","parent_skill","assigned_agents","use_when","required_recipe","required_tool","validator","stop_condition") },
  @{ Path = $subrecipeIndex; Columns = @("subrecipe_id","parent_recipe","primary_agent","input","output","validator","stop_condition") },
  @{ Path = $workpaperIndex; Columns = @("agent_id","level_id","workpaper_path","status","last_updated","primary_surface","purpose","owner_agent","required_matrices","required_recipes","required_tools","required_validators","evidence_policy","stop_condition") }
)

foreach ($check in $requiredColumnChecks) {
  $err = Test-RequiredColumns -Path $check.Path -Columns $check.Columns
  if ($err) { $errors.Add($err) }
}

$matrixRows = Read-CsvSafe -Path $matrixIndex
foreach ($row in $matrixRows) {
  if ([string]::IsNullOrWhiteSpace($row.matrix_id) -or [string]::IsNullOrWhiteSpace($row.path)) {
    $errors.Add("Matrix index row with blank matrix_id or path")
  } elseif ((Is-LocalPathLike $row.path) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.path))) {
    $errors.Add("Matrix index path missing: $($row.path)")
  }
}

$recipeRows = Read-CsvSafe -Path $recipeIndex
foreach ($row in $recipeRows) {
  if ([string]::IsNullOrWhiteSpace($row.recipe_id) -or [string]::IsNullOrWhiteSpace($row.primary_agent)) {
    $errors.Add("Recipe row with blank recipe_id or primary_agent")
  }
  if ((Is-LocalPathLike $row.path) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.path))) {
    $errors.Add("Recipe path missing: $($row.path)")
  }
}

$toolRows = Read-CsvSafe -Path $toolIndex
foreach ($row in $toolRows) {
  if ([string]::IsNullOrWhiteSpace($row.tool_id) -or [string]::IsNullOrWhiteSpace($row.allowed_surface) -or [string]::IsNullOrWhiteSpace($row.blocked_surface)) {
    $errors.Add("Tool row missing id, allowed_surface or blocked_surface")
  }
  if ((Is-LocalPathLike $row.path_or_command) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.path_or_command))) {
    $errors.Add("Tool path missing: $($row.path_or_command)")
  }
}
$toolGovernanceIds = @((Read-CsvSafe -Path $toolGovernance) | ForEach-Object { $_.tool_id })
$toolGovernanceIdSet = New-StringSet -Values $toolGovernanceIds
foreach ($row in $toolRows) {
  if (-not $toolGovernanceIdSet.Contains($row.tool_id)) {
    $errors.Add("Tool missing governance row: $($row.tool_id)")
  }
}

$skillRows = Read-CsvSafe -Path $localSkillCatalog
foreach ($row in $skillRows) {
  if ([string]::IsNullOrWhiteSpace($row.skill_id) -or [string]::IsNullOrWhiteSpace($row.owner_agent)) {
    $errors.Add("Skill catalog row missing skill_id or owner_agent")
  }
  if ((Is-LocalPathLike $row.path) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.path))) {
    $warnings.Add("Skill catalog path not present in this cabina: $($row.path)")
  }
}

$repoRows = Read-CsvSafe -Path $repoGovernance
foreach ($row in $repoRows) {
  if ([string]::IsNullOrWhiteSpace($row.repo_id) -or [string]::IsNullOrWhiteSpace($row.universe) -or [string]::IsNullOrWhiteSpace($row.owner_agent)) {
    $errors.Add("Repo governance row missing repo_id, universe or owner_agent")
  }
  if ((Is-LocalPathLike $row.path) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.path))) {
    $warnings.Add("Repo path not present in this cabina: $($row.path)")
  }
}

$agentRows = Read-CsvSafe -Path $agentGovernance
foreach ($row in $agentRows) {
  if ([string]::IsNullOrWhiteSpace($row.agent_id) -or [string]::IsNullOrWhiteSpace($row.level_id) -or [string]::IsNullOrWhiteSpace($row.escalates_to)) {
    $errors.Add("Agent governance row missing agent_id, level_id or escalates_to")
  }
}

$governanceRows = Read-CsvSafe -Path $ratGovernance
foreach ($row in $governanceRows) {
  if ([string]::IsNullOrWhiteSpace($row.asset_class) -or [string]::IsNullOrWhiteSpace($row.primary_owner_agent) -or [string]::IsNullOrWhiteSpace($row.required_recipe) -or [string]::IsNullOrWhiteSpace($row.required_tool)) {
    $errors.Add("Repo-agent-tool governance row missing asset_class, owner, recipe or tool")
  }
  if ((Is-LocalPathLike $row.governing_matrix) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.governing_matrix))) {
    $errors.Add("Governance matrix path missing: $($row.governing_matrix)")
  }
}

$inventoryRows = Read-CsvSafe -Path $canonicalInventory
foreach ($row in $inventoryRows) {
  if ([string]::IsNullOrWhiteSpace($row.asset_class) -or [string]::IsNullOrWhiteSpace($row.asset_id) -or [string]::IsNullOrWhiteSpace($row.owner_agent) -or [string]::IsNullOrWhiteSpace($row.validator)) {
    $errors.Add("Canonical inventory row missing asset_class, asset_id, owner_agent or validator")
  }
}

$glossaryRows = Read-CsvSafe -Path $stopGlossary
foreach ($row in $glossaryRows) {
  if ([string]::IsNullOrWhiteSpace($row.stop_condition) -or [string]::IsNullOrWhiteSpace($row.normalized_family)) {
    $errors.Add("Stop condition glossary row missing stop_condition or normalized_family")
  }
}
$knownStopConditions = @($glossaryRows | ForEach-Object { $_.stop_condition })
$knownStopConditionSet = New-StringSet -Values $knownStopConditions
foreach ($path in @(
  $parallelOperationCriteria,
  $parallelIssueQueue,
  $orderPreparationAssignment,
  $orderClassCapability,
  $operationalChainGovernance,
  $pluginSkillBoundary,
  $sourceCapabilityGap,
  $documentSkillLane,
  $subagentAliasMap,
  $subagentCapabilityAssignment,
  $skillMetadataQuality,
  $subskillUsage,
  $subrecipeIndex
)) {
  foreach ($row in Read-CsvSafe -Path $path) {
    $propertyNameSet = New-StringSet -Values @($row.PSObject.Properties.Name)
    if ($propertyNameSet.Contains("stop_condition")) {
      foreach ($token in @($row.stop_condition -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
        if (-not $knownStopConditionSet.Contains($token)) {
          $errors.Add("Unknown stop_condition '$token' in $path")
        }
      }
    }
  }
}

$exceptionRows = Read-CsvSafe -Path $coverageExceptions
foreach ($row in $exceptionRows) {
  if ([string]::IsNullOrWhiteSpace($row.exception_id) -or [string]::IsNullOrWhiteSpace($row.owner_agent) -or [string]::IsNullOrWhiteSpace($row.validator)) {
    $errors.Add("Coverage exception row missing exception_id, owner_agent or validator")
  }
}

$lineageRows = Read-CsvSafe -Path $lineageAudit
foreach ($row in $lineageRows) {
  if ([string]::IsNullOrWhiteSpace($row.lineage_id) -or [string]::IsNullOrWhiteSpace($row.source) -or [string]::IsNullOrWhiteSpace($row.derived)) {
    $errors.Add("Lineage audit row missing lineage_id, source or derived")
  }
}

if (-not (Test-Path -LiteralPath $workpaperValidator)) {
  $errors.Add("Missing workpaper validator: $workpaperValidator")
} else {
  & $workpaperValidator -Root $Root | Out-Null
}

foreach ($validatorSpec in @(
  @{ Path = $parallelOrderValidator; Name = "parallel order governance" },
  @{ Path = $orderPacketValidator; Name = "order packet" },
  @{ Path = $operationalChainValidator; Name = "operational chain" }
)) {
  if ($SkipWorkflowNestedValidators) {
    $warnings.Add("Skipped workflow-level nested validator: $($validatorSpec.Name)")
    continue
  }
  if (-not (Test-Path -LiteralPath $validatorSpec.Path)) {
    $errors.Add("Missing $($validatorSpec.Name) validator: $($validatorSpec.Path)")
  } else {
    if ($validatorSpec.Name -eq "operational chain") {
      $resolvedRootForValidator = (Resolve-Path -LiteralPath $Root).Path
      $repoRootForValidator = Split-Path -Parent (Split-Path -Parent $resolvedRootForValidator)
      $validatorOutput = & $validatorSpec.Path -Root $Root -RepoRoot $repoRootForValidator
    } else {
      $validatorOutput = & $validatorSpec.Path -Root $Root
    }
    $validatorPayload = ($validatorOutput -join "`n") | ConvertFrom-Json
    if ($validatorPayload.status -ne "PASS") {
      $errors.Add("$($validatorSpec.Name) validator failed: $($validatorOutput -join ' ')")
    }
  }
}

$agentData = Get-Content -LiteralPath (Join-Path $Root "agents.json") -Raw | ConvertFrom-Json
$agentIds = @($agentData.agents | ForEach-Object { $_.id })
$defaultSkillAssignment = Read-CsvSafe -Path (Join-Path $Root "matrices\AGENT_DEFAULT_SKILL_ASSIGNMENT_MATRIX.csv")
$defaultSkillAssignmentByAgent = @{}
foreach ($row in $defaultSkillAssignment) {
  if (-not [string]::IsNullOrWhiteSpace($row.agent_id)) {
    $defaultSkillAssignmentByAgent[$row.agent_id] = $row
  }
}
foreach ($agent in $agentData.agents) {
  if (-not $defaultSkillAssignmentByAgent.ContainsKey($agent.id)) {
    $errors.Add("Agent missing from default skill assignment matrix: $($agent.id)")
    continue
  }
  $defaultRow = $defaultSkillAssignmentByAgent[$agent.id]
  $agentDefaultSkillSet = New-StringSet -Values @($agent.default_skills)
  $agentDefaultRecipeSet = New-StringSet -Values @($agent.default_recipes)
  $agentDefaultToolSet = New-StringSet -Values @($agent.default_tools)
  foreach ($skill in @($defaultRow.default_skill_refs -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $agentDefaultSkillSet.Contains($skill)) {
      $errors.Add("agents.json drift for $($agent.id): missing default_skill $skill")
    }
  }
  foreach ($recipe in @($defaultRow.default_recipe_refs -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $agentDefaultRecipeSet.Contains($recipe)) {
      $errors.Add("agents.json drift for $($agent.id): missing default_recipe $recipe")
    }
  }
  foreach ($tool in @($defaultRow.default_tool_refs -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $agentDefaultToolSet.Contains($tool)) {
      $errors.Add("agents.json drift for $($agent.id): missing default_tool $tool")
    }
  }
}
$agentWorkpaperRows = Read-CsvSafe -Path $agentWorkpapers
$workpaperIndexRows = Read-CsvSafe -Path $workpaperIndex
$workpaperMatrixIds = @($agentWorkpaperRows | ForEach-Object { $_.agent_id })
$workpaperIndexIds = @($workpaperIndexRows | ForEach-Object { $_.agent_id })
$workpaperMatrixIdSet = New-StringSet -Values $workpaperMatrixIds
$workpaperIndexIdSet = New-StringSet -Values $workpaperIndexIds
foreach ($agentId in $agentIds) {
  if (-not $workpaperMatrixIdSet.Contains($agentId)) {
    $errors.Add("Agent missing from workpaper matrix: $agentId")
  }
  if (-not $workpaperIndexIdSet.Contains($agentId)) {
    $errors.Add("Agent missing from workpaper index: $agentId")
  }
}
foreach ($row in $agentWorkpaperRows) {
  if ((Is-LocalPathLike $row.workpapers_path) -and -not (Test-Path -LiteralPath (Resolve-CabinaPath $row.workpapers_path) -PathType Container)) {
    $errors.Add("Workpaper folder missing: $($row.workpapers_path)")
  }
  if ([string]::IsNullOrWhiteSpace($row.repo_snapshot_path) -or [string]::IsNullOrWhiteSpace($row.required_validators)) {
    $errors.Add("Workpaper matrix row missing repo_snapshot_path or required_validators: $($row.agent_id)")
  }
}
foreach ($row in Read-CsvSafe -Path $pluginUsage) {
  if ([string]::IsNullOrWhiteSpace($row.plugin_id) -or [string]::IsNullOrWhiteSpace($row.availability) -or [string]::IsNullOrWhiteSpace($row.live_boundary)) {
    $errors.Add("Plugin usage row missing plugin_id, availability or live_boundary")
  }
}
foreach ($row in Read-CsvSafe -Path $purposeSurfaceCapability) {
  if ([string]::IsNullOrWhiteSpace($row.artifact_id) -or [string]::IsNullOrWhiteSpace($row.agent_id) -or [string]::IsNullOrWhiteSpace($row.surface) -or [string]::IsNullOrWhiteSpace($row.workpaper_path)) {
    $errors.Add("Purpose surface capability row missing artifact_id, agent_id, surface or workpaper_path")
  }
}
foreach ($row in Read-CsvSafe -Path $parallelOperationCriteria) {
  if ([string]::IsNullOrWhiteSpace($row.lane_id) -or [string]::IsNullOrWhiteSpace($row.lead_agent) -or [string]::IsNullOrWhiteSpace($row.owner_agent) -or [string]::IsNullOrWhiteSpace($row.reviewer_agent) -or [string]::IsNullOrWhiteSpace($row.read_scope) -or [string]::IsNullOrWhiteSpace($row.write_scope) -or [string]::IsNullOrWhiteSpace($row.lock_key) -or [string]::IsNullOrWhiteSpace($row.validator) -or [string]::IsNullOrWhiteSpace($row.stop_condition)) {
    $errors.Add("Parallel operation row missing lane_id, lead_agent, owner_agent, reviewer_agent, scope, lock_key, validator or stop_condition")
  }
}
foreach ($row in Read-CsvSafe -Path $orderPreparationAssignment) {
  if ([string]::IsNullOrWhiteSpace($row.order_class) -or [string]::IsNullOrWhiteSpace($row.preparer_agent) -or [string]::IsNullOrWhiteSpace($row.reviewer_agent) -or [string]::IsNullOrWhiteSpace($row.canon_as_of) -or [string]::IsNullOrWhiteSpace($row.source_authority) -or [string]::IsNullOrWhiteSpace($row.required_fields) -or [string]::IsNullOrWhiteSpace($row.validator) -or [string]::IsNullOrWhiteSpace($row.stop_condition)) {
    $errors.Add("Order preparation row missing order_class, preparer_agent, reviewer_agent, canon_as_of, source_authority, required_fields, validator or stop_condition")
  }
}

$secretPatterns = @(
  "sk-[A-Za-z0-9_-]{20,}",
  "OPENAI_API_KEY\s*=",
  "BEGIN [A-Z ]*PRIVATE KEY",
  "password\s*=",
  "secret\s*=",
  "token\s*="
)
$scanFiles = @(
  Get-ChildItem -LiteralPath $Root -Recurse -File -Include "*.md","*.csv","*.json","*.yaml","*.yml","*.ps1" |
    Where-Object { $_.FullName -notmatch "\\readbacks\\.*RAW" -and $_.FullName -notmatch "\\SOURCE_" }
)
$secretHits = New-Object System.Collections.Generic.List[object]
foreach ($file in $scanFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
  if ([string]::IsNullOrEmpty($content)) {
    continue
  }
  $lines = @($content -split '\r?\n')
  for ($index = 0; $index -lt $lines.Count; $index++) {
    foreach ($pattern in $secretPatterns) {
      if ($lines[$index] -cmatch $pattern) {
        $secretHits.Add([pscustomobject]@{ path = $file.FullName; line = ($index + 1); pattern = $pattern })
      }
    }
  }
}
if ($secretHits.Count -gt 0) {
  $errors.Add("Secret-like hits detected: $($secretHits.Count)")
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }

[pscustomobject]@{
  status = $status
  root = $Root
  skip_workflow_nested_validators = [bool]$SkipWorkflowNestedValidators
  matrix_count = $matrixRows.Count
  recipe_count = $recipeRows.Count
  tool_count = $toolRows.Count
  local_skill_count = $skillRows.Count
  governed_repo_count = $repoRows.Count
  governed_agent_count = $agentRows.Count
  governed_asset_class_count = $governanceRows.Count
  canonical_inventory_count = $inventoryRows.Count
  stop_condition_count = $glossaryRows.Count
  coverage_exception_count = $exceptionRows.Count
  lineage_count = $lineageRows.Count
  document_skill_lane_count = (Read-CsvSafe -Path $documentSkillLane).Count
  workpaper_count = $agentWorkpaperRows.Count
  plugin_usage_count = (Read-CsvSafe -Path $pluginUsage).Count
  purpose_surface_capability_count = (Read-CsvSafe -Path $purposeSurfaceCapability).Count
  parallel_operation_count = (Read-CsvSafe -Path $parallelOperationCriteria).Count
  parallel_issue_queue_count = (Read-CsvSafe -Path $parallelIssueQueue).Count
  order_preparation_count = (Read-CsvSafe -Path $orderPreparationAssignment).Count
  order_class_capability_count = (Read-CsvSafe -Path $orderClassCapability).Count
  operational_chain_count = (Read-CsvSafe -Path $operationalChainGovernance).Count
  skill_metadata_quality_count = (Read-CsvSafe -Path $skillMetadataQuality).Count
  plugin_skill_boundary_count = (Read-CsvSafe -Path $pluginSkillBoundary).Count
  source_capability_gap_count = (Read-CsvSafe -Path $sourceCapabilityGap).Count
  subagent_alias_count = (Read-CsvSafe -Path $subagentAliasMap).Count
  subagent_capability_count = (Read-CsvSafe -Path $subagentCapabilityAssignment).Count
  subskill_count = (Read-CsvSafe -Path $subskillUsage).Count
  subrecipe_count = (Read-CsvSafe -Path $subrecipeIndex).Count
  warning_count = $warnings.Count
  warnings = $warnings
  error_count = $errors.Count
  errors = $errors
  secret_hit_count = $secretHits.Count
  secret_hits = $secretHits
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
