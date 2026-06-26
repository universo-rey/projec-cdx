param(
  [string]$Root = ".agents\codex",
  [string]$RepoRoot = "C:\Users\enzo1\Documents\GitHub\cabina-universal-d"
)

$ErrorActionPreference = "Stop"
$script:CsvCache = @{}

function Read-CsvRequired {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing required CSV: $Path"
  }
  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  if (-not $script:CsvCache.ContainsKey($resolvedPath)) {
    $script:CsvCache[$resolvedPath] = @(Import-Csv -LiteralPath $resolvedPath)
  }
  return $script:CsvCache[$resolvedPath]
}

function Resolve-CabinaPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
  $normalized = $Path -replace "/", "\"
  if ($normalized.StartsWith(".agents\codex", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $Root ($normalized.Substring(".agents\codex".Length).TrimStart("\"))
  }
  if ($normalized.StartsWith("C:\Users\enzo1\Documents\GitHub\cabina-universal-d", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $RepoRoot ($normalized.Substring("C:\Users\enzo1\Documents\GitHub\cabina-universal-d".Length).TrimStart("\"))
  }
  return Join-Path $RepoRoot $normalized
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

function Require-Columns {
  param(
    [string]$Path,
    [string[]]$Columns,
    [System.Collections.Generic.List[string]]$Errors
  )
  $rows = Read-CsvRequired -Path $Path
  $actual = @()
  if ($rows.Count -gt 0) {
    $actual = @($rows[0].PSObject.Properties.Name)
  } else {
    $header = Get-Content -LiteralPath $Path -TotalCount 1
    if ($header) { $actual = @($header -split ",") }
  }
  $actualSet = New-StringSet -Values $actual
  foreach ($column in $Columns) {
    if (-not $actualSet.Contains($column)) {
      $Errors.Add("Missing column '$column' in $Path")
    }
  }
}

function Check-PathList {
  param(
    [string]$Value,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  foreach ($item in @($Value -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($item -match '^[A-Za-z]:[\\/]') {
      $resolved = Resolve-CabinaPath -Path $item
      if (-not (Test-Path -LiteralPath $resolved)) {
        $Errors.Add("$Context references missing path: $item")
      }
    }
  }
}

function Check-StopCondition {
  param(
    [string]$Value,
    [System.Collections.Generic.HashSet[string]]$KnownStops,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  foreach ($token in @($Value -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $KnownStops.Contains($token)) {
      $Errors.Add("$Context references unknown stop_condition: $token")
    }
  }
}

$matrixPath = Join-Path $Root "matrices\OPERATIONAL_CHAIN_GOVERNANCE_MATRIX.csv"
$agentsPath = Join-Path $Root "agents.json"
$routingPath = Join-Path $Root "routing.json"
$skillUsagePath = Join-Path $Root "skills\SKILL_USAGE_MATRIX.csv"
$recipeIndexPath = Join-Path $Root "recipes\RECIPE_INDEX.csv"
$toolIndexPath = Join-Path $Root "tools\TOOL_INDEX.csv"
$defaultSkillPath = Join-Path $Root "matrices\AGENT_DEFAULT_SKILL_ASSIGNMENT_MATRIX.csv"
$agentContractPath = Join-Path $Root "matrices\AGENT_TOOL_RECIPE_SKILL_MATRIX.csv"
$stopPath = Join-Path $Root "matrices\STOP_CONDITION_GLOSSARY.csv"
$orderClassPath = Join-Path $Root "matrices\ORDER_CLASS_CAPABILITY_MATRIX.csv"
$orderPrepPath = Join-Path $Root "matrices\ORDER_PREPARATION_ASSIGNMENT_MATRIX.csv"
$parallelPath = Join-Path $Root "matrices\PARALLEL_OPERATION_CRITERIA_MATRIX.csv"

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

Require-Columns -Path $matrixPath -Columns @("chain_id","applies_to","owner_agent","reviewer_agent","required_agent_source","required_skill_source","required_recipe_source","required_tool_source","required_validator_source","required_evidence_source","required_stop_condition_source","blocked_without_chain","status","validator","stop_condition") -Errors $errors

$agents = @((Get-Content -Raw -LiteralPath $agentsPath | ConvertFrom-Json).agents)
$agentIds = @($agents | ForEach-Object { $_.id })
$routingAgents = @((Get-Content -Raw -LiteralPath $routingPath | ConvertFrom-Json).routes.agents | ForEach-Object { $_ } | Select-Object -Unique)
$skillIds = @((Read-CsvRequired -Path $skillUsagePath) | ForEach-Object { $_.skill_id })
$recipeIds = @((Read-CsvRequired -Path $recipeIndexPath) | ForEach-Object { $_.recipe_id })
$toolIds = @((Read-CsvRequired -Path $toolIndexPath) | ForEach-Object { $_.tool_id })
$rows = Read-CsvRequired -Path $matrixPath
$agentIdSet = New-StringSet -Values $agentIds
$skillIdSet = New-StringSet -Values $skillIds
$recipeIdSet = New-StringSet -Values $recipeIds
$toolIdSet = New-StringSet -Values $toolIds
$knownStopSet = New-StringSet -Values @((Read-CsvRequired -Path $stopPath) | ForEach-Object { $_.stop_condition })
$chainIdSet = New-StringSet -Values @($rows | ForEach-Object { $_.chain_id })

foreach ($expected in @(
  "chain.chat_closeout_global",
  "chain.repo_change_global",
  "chain.github_automation_global",
  "chain.live_runtime_order_global",
  "chain.parallel_subagent_global"
)) {
  if (-not $chainIdSet.Contains($expected)) {
    $errors.Add("Missing operational chain row: $expected")
  }
}

foreach ($row in $rows) {
  foreach ($field in @("chain_id","applies_to","owner_agent","reviewer_agent","required_agent_source","required_skill_source","required_recipe_source","required_tool_source","required_validator_source","required_evidence_source","required_stop_condition_source","blocked_without_chain","status","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Operational chain '$($row.chain_id)' missing $field")
    }
  }
  if (-not $agentIdSet.Contains($row.owner_agent)) {
    $errors.Add("Operational chain '$($row.chain_id)' references unknown owner_agent: $($row.owner_agent)")
  }
  if (-not $agentIdSet.Contains($row.reviewer_agent)) {
    $errors.Add("Operational chain '$($row.chain_id)' references unknown reviewer_agent: $($row.reviewer_agent)")
  }
  if ($row.owner_agent -eq $row.reviewer_agent) {
    $errors.Add("Operational chain '$($row.chain_id)' owner_agent and reviewer_agent must differ")
  }
  if ($row.status -ne "ACTIVE_GLOBAL") {
    $errors.Add("Operational chain '$($row.chain_id)' must be ACTIVE_GLOBAL")
  }
  foreach ($sourceField in @("required_agent_source","required_skill_source","required_recipe_source","required_tool_source","required_validator_source","required_stop_condition_source","validator")) {
    Check-PathList -Value $row.$sourceField -Errors $errors -Context "Operational chain '$($row.chain_id)' $sourceField"
  }
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStopSet -Errors $errors -Context "Operational chain '$($row.chain_id)'"
}

foreach ($routeAgent in $routingAgents) {
  if (-not $agentIdSet.Contains($routeAgent)) {
    $errors.Add("routing.json references unknown agent: $routeAgent")
  }
}

foreach ($agent in $agents) {
  foreach ($skill in @($agent.default_skills | Where-Object { $_ })) {
    if (-not $skillIdSet.Contains($skill)) {
      $errors.Add("agents.json $($agent.id) default skill not indexed: $skill")
    }
  }
  foreach ($recipe in @($agent.default_recipes | Where-Object { $_ })) {
    if (-not $recipeIdSet.Contains($recipe)) {
      $errors.Add("agents.json $($agent.id) default recipe not indexed: $recipe")
    }
  }
  foreach ($tool in @($agent.default_tools | Where-Object { $_ })) {
    if (-not $toolIdSet.Contains($tool)) {
      $errors.Add("agents.json $($agent.id) default tool not indexed: $tool")
    }
  }
}

foreach ($row in Read-CsvRequired -Path $defaultSkillPath) {
  foreach ($field in @("agent_id","default_skill_refs","default_recipe_refs","default_tool_refs","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Default skill assignment row '$($row.agent_id)' missing $field")
    }
  }
  foreach ($skill in @($row.default_skill_refs -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $skillIdSet.Contains($skill)) {
      $errors.Add("Default skill assignment '$($row.agent_id)' references unknown skill: $skill")
    }
  }
  foreach ($recipe in @($row.default_recipe_refs -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $recipeIdSet.Contains($recipe)) {
      $errors.Add("Default skill assignment '$($row.agent_id)' references unknown recipe: $recipe")
    }
  }
  foreach ($tool in @($row.default_tool_refs -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if (-not $toolIdSet.Contains($tool)) {
      $errors.Add("Default skill assignment '$($row.agent_id)' references unknown tool: $tool")
    }
  }
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStopSet -Errors $errors -Context "Default skill assignment '$($row.agent_id)'"
}

foreach ($row in Read-CsvRequired -Path $agentContractPath) {
  foreach ($field in @("agent_id","skill_refs","recipe_refs","tool_refs","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Agent execution contract '$($row.agent_id)' missing $field")
    }
  }
}

foreach ($row in Read-CsvRequired -Path $orderClassPath) {
  foreach ($field in @("required_agents","required_skills","required_recipes","required_tools","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Order class '$($row.order_class)' missing $field")
    }
  }
}

foreach ($row in Read-CsvRequired -Path $orderPrepPath) {
  foreach ($field in @("preparer_agent","reviewer_agent","recipe","tool","evidence","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Order preparation '$($row.order_class)' missing $field")
    }
  }
}

foreach ($row in Read-CsvRequired -Path $parallelPath) {
  foreach ($field in @("lead_agent","owner_agent","reviewer_agent","required_recipe","required_tool","evidence","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Parallel lane '$($row.lane_id)' missing $field")
    }
  }
}

foreach ($template in @(
  (Join-Path $RepoRoot ".github\PULL_REQUEST_TEMPLATE.md"),
  (Join-Path $RepoRoot ".github\ISSUE_TEMPLATE\agent-task.yml"),
  (Join-Path $RepoRoot ".github\ISSUE_TEMPLATE\runtime-approval.yml")
)) {
  $text = Get-Content -Raw -LiteralPath $template
  foreach ($requiredText in @("skill", "recipe", "tool", "validator", "evidence", "stop_condition")) {
    if ($text -notmatch [regex]::Escape($requiredText)) {
      $errors.Add("Template missing operational chain field '$requiredText': $template")
    }
  }
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
[pscustomobject]@{
  status = $status
  root = $Root
  repo_root = $RepoRoot
  operational_chain_rows = $rows.Count
  agents = $agentIds.Count
  skills = $skillIds.Count
  recipes = $recipeIds.Count
  tools = $toolIds.Count
  warning_count = $warnings.Count
  warnings = $warnings
  error_count = $errors.Count
  errors = $errors
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
