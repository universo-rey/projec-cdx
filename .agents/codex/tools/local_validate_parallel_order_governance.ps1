param(
  [string]$Root = ".agents\codex"
)

$ErrorActionPreference = "Stop"

function Read-CsvSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing CSV: $Path"
  }
  @(Import-Csv -LiteralPath $Path)
}

function Require-Columns {
  param(
    [string]$Path,
    [string[]]$Columns,
    [System.Collections.Generic.List[string]]$Errors
  )
  $rows = Read-CsvSafe -Path $Path
  $actual = @()
  if ($rows.Count -gt 0) {
    $actual = @($rows[0].PSObject.Properties.Name)
  } else {
    $header = Get-Content -LiteralPath $Path -TotalCount 1
    if ($header) { $actual = @($header -split ",") }
  }
  foreach ($column in $Columns) {
    if ($column -notin $actual) {
      $Errors.Add("Missing column '$column' in $Path")
    }
  }
}

function Resolve-CabinaPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
  $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
  $repoRoot = Split-Path -Parent (Split-Path -Parent $resolvedRoot)
  $normalized = $Path -replace "/", "\"
  if ($normalized.StartsWith(".agents\codex", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $Root ($normalized.Substring(".agents\codex".Length).TrimStart("\"))
  }
  if ($normalized.StartsWith("C:\Users\enzo1\Documents\GitHub\cabina-universal-d", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $repoRoot ($normalized.Substring("C:\Users\enzo1\Documents\GitHub\cabina-universal-d".Length).TrimStart("\"))
  }
  return $Path
}

function Check-ValidatorRef {
  param(
    [string]$Value,
    [string[]]$ToolIds,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  if ([string]::IsNullOrWhiteSpace($Value)) {
    $Errors.Add("$Context missing validator")
    return
  }
  if ($Value -like "tool.*") {
    if ($Value -notin $ToolIds) {
      $Errors.Add("$Context references unknown validator tool: $Value")
    }
    return
  }
  if ($Value -match '^[A-Za-z]:[\\/]') {
    $resolved = Resolve-CabinaPath -Path $Value
    if (-not (Test-Path -LiteralPath $resolved)) {
      $Errors.Add("$Context validator path missing: $Value")
    }
  }
}

function Check-StopCondition {
  param(
    [string]$Value,
    [string[]]$KnownStops,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  foreach ($token in @($Value -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($token -notin $KnownStops) {
      $Errors.Add("$Context references unknown stop_condition: $token")
    }
  }
}

$parallelPath = Join-Path $Root "matrices\PARALLEL_OPERATION_CRITERIA_MATRIX.csv"
$orderPath = Join-Path $Root "matrices\ORDER_PREPARATION_ASSIGNMENT_MATRIX.csv"
$subagentAliasPath = Join-Path $Root "agents\SUBAGENT_ALIAS_MAP.csv"
$subagentCapabilityPath = Join-Path $Root "matrices\SUBAGENT_CAPABILITY_ASSIGNMENT_MATRIX.csv"
$subskillPath = Join-Path $Root "skills\SUBSKILL_USAGE_MATRIX.csv"
$subrecipePath = Join-Path $Root "recipes\SUBRECIPE_INDEX.csv"
$toolIndexPath = Join-Path $Root "tools\TOOL_INDEX.csv"
$stopPath = Join-Path $Root "matrices\STOP_CONDITION_GLOSSARY.csv"
$agentsPath = Join-Path $Root "agents.json"

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

Require-Columns -Path $parallelPath -Columns @("lane_id","lead_agent","owner_agent","reviewer_agent","delegate_agents","read_scope","write_scope","lock_key","dependency","max_parallel","allowed_parallelism","required_precheck","required_recipe","required_tool","evidence","validator","serialization_rule","stop_condition") -Errors $errors
Require-Columns -Path $subagentAliasPath -Columns @("subagent_id","alias","role","assigned_lane","lead_agent","status","read_scope","write_scope","validator","stop_condition") -Errors $errors
Require-Columns -Path $subagentCapabilityPath -Columns @("subagent_class","agent_template","default_skills","default_recipes","default_tools","allowed_surface","blocked_surface","parallel_policy","validator","stop_condition") -Errors $errors
Require-Columns -Path $subskillPath -Columns @("subskill_id","parent_skill","assigned_agents","use_when","required_recipe","required_tool","validator","stop_condition") -Errors $errors
Require-Columns -Path $subrecipePath -Columns @("subrecipe_id","parent_recipe","primary_agent","input","output","validator","stop_condition") -Errors $errors

$toolIds = @((Read-CsvSafe -Path $toolIndexPath) | ForEach-Object { $_.tool_id })
$knownStops = @((Read-CsvSafe -Path $stopPath) | ForEach-Object { $_.stop_condition })
$agentIds = @((Get-Content -Raw -LiteralPath $agentsPath | ConvertFrom-Json).agents | ForEach-Object { $_.id })
$lanes = Read-CsvSafe -Path $parallelPath
$laneIds = @($lanes | ForEach-Object { $_.lane_id })

foreach ($lane in $lanes) {
  foreach ($field in @("lane_id","lead_agent","owner_agent","reviewer_agent","read_scope","write_scope","lock_key","max_parallel","validator","evidence","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($lane.$field)) {
      $errors.Add("Parallel lane '$($lane.lane_id)' missing $field")
    }
  }
  foreach ($field in @("lead_agent","owner_agent","reviewer_agent")) {
    if ($lane.$field -notin $agentIds) {
      $errors.Add("Parallel lane '$($lane.lane_id)' references unknown ${field}: $($lane.$field)")
    }
  }
  if ($lane.owner_agent -eq $lane.reviewer_agent) {
    $errors.Add("Parallel lane '$($lane.lane_id)' owner_agent and reviewer_agent must differ")
  }
  $max = 0
  if (-not [int]::TryParse([string]$lane.max_parallel, [ref]$max) -or $max -lt 1 -or $max -gt 5) {
    $errors.Add("Parallel lane '$($lane.lane_id)' max_parallel must be an integer between 1 and 5")
  }
  Check-ValidatorRef -Value $lane.validator -ToolIds $toolIds -Errors $errors -Context "Parallel lane '$($lane.lane_id)'"
  Check-StopCondition -Value $lane.stop_condition -KnownStops $knownStops -Errors $errors -Context "Parallel lane '$($lane.lane_id)'"
}

$duplicateLocks = @($lanes | Group-Object lock_key | Where-Object { $_.Name -and $_.Count -gt 1 })
foreach ($group in $duplicateLocks) {
  $errors.Add("Duplicate parallel lock_key requires serialization row split: $($group.Name)")
}

foreach ($alias in Read-CsvSafe -Path $subagentAliasPath) {
  if ($alias.assigned_lane -notin $laneIds) {
    $errors.Add("Subagent alias '$($alias.alias)' references unknown lane: $($alias.assigned_lane)")
  }
  if ($alias.lead_agent -notin $agentIds) {
    $errors.Add("Subagent alias '$($alias.alias)' references unknown lead_agent: $($alias.lead_agent)")
  }
  Check-ValidatorRef -Value $alias.validator -ToolIds $toolIds -Errors $errors -Context "Subagent alias '$($alias.alias)'"
  Check-StopCondition -Value $alias.stop_condition -KnownStops $knownStops -Errors $errors -Context "Subagent alias '$($alias.alias)'"
}

foreach ($row in Read-CsvSafe -Path $subagentCapabilityPath) {
  if ($row.agent_template -notin $agentIds) {
    $errors.Add("Subagent class '$($row.subagent_class)' references unknown agent_template: $($row.agent_template)")
  }
  foreach ($tool in @($row.default_tools -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($tool -notin $toolIds) {
      $errors.Add("Subagent class '$($row.subagent_class)' references unknown tool: $tool")
    }
  }
  Check-ValidatorRef -Value $row.validator -ToolIds $toolIds -Errors $errors -Context "Subagent class '$($row.subagent_class)'"
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStops -Errors $errors -Context "Subagent class '$($row.subagent_class)'"
}

foreach ($row in Read-CsvSafe -Path $subskillPath) {
  Check-ValidatorRef -Value $row.validator -ToolIds $toolIds -Errors $errors -Context "Subskill '$($row.subskill_id)'"
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStops -Errors $errors -Context "Subskill '$($row.subskill_id)'"
}

foreach ($row in Read-CsvSafe -Path $subrecipePath) {
  if ($row.primary_agent -notin $agentIds) {
    $errors.Add("Subrecipe '$($row.subrecipe_id)' references unknown primary_agent: $($row.primary_agent)")
  }
  Check-ValidatorRef -Value $row.validator -ToolIds $toolIds -Errors $errors -Context "Subrecipe '$($row.subrecipe_id)'"
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStops -Errors $errors -Context "Subrecipe '$($row.subrecipe_id)'"
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
[pscustomobject]@{
  status = $status
  root = $Root
  parallel_lane_count = $lanes.Count
  subagent_alias_count = (Read-CsvSafe -Path $subagentAliasPath).Count
  subagent_capability_count = (Read-CsvSafe -Path $subagentCapabilityPath).Count
  subskill_count = (Read-CsvSafe -Path $subskillPath).Count
  subrecipe_count = (Read-CsvSafe -Path $subrecipePath).Count
  warning_count = $warnings.Count
  warnings = $warnings
  error_count = $errors.Count
  errors = $errors
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
