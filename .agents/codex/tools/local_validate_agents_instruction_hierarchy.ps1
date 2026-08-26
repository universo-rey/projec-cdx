param(
  [string]$Root = (Join-Path (Split-Path -Parent $PSScriptRoot) ""),
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
)

$ErrorActionPreference = "Stop"

function Read-CsvRequired {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Missing required CSV: $Path"
  }
  @(Import-Csv -LiteralPath $Path)
}

function Resolve-RepoPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
  $normalized = $Path -replace "/", "\"
  if ($normalized.StartsWith(".agents\codex", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $Root ($normalized.Substring(".agents\codex".Length).TrimStart("\"))
  }
  if ($normalized -match '^[A-Za-z]:\\' -or $normalized.StartsWith("\\", [System.StringComparison]::Ordinal)) {
    return $normalized
  }
  Join-Path $RepoRoot $normalized
}

function Require-Columns {
  param(
    [string]$Path,
    [string[]]$Columns,
    [System.Collections.Generic.List[string]]$Errors
  )
  $rows = Read-CsvRequired -Path $Path
  $actual = if ($rows.Count -gt 0) { @($rows[0].PSObject.Properties.Name) } else { @() }
  foreach ($column in $Columns) {
    if ($column -notin $actual) { $Errors.Add("Missing column '$column' in $Path") }
  }
}

function Test-PathToken {
  param(
    [string]$PathToken,
    [string]$PathCheck,
    [System.Collections.Generic.List[string]]$Errors,
    [System.Collections.Generic.List[string]]$Warnings,
    [string]$Context
  )
  $resolved = Resolve-RepoPath -Path $PathToken
  switch ($PathCheck) {
    "literal" {
      if (-not (Test-Path -LiteralPath $resolved)) { $Errors.Add("$Context missing literal path: $PathToken") }
    }
    "wildcard" {
      if (@(Get-ChildItem -Path $resolved -ErrorAction SilentlyContinue).Count -lt 1) {
        $Errors.Add("$Context wildcard matched no files: $PathToken")
      }
    }
    "boundary_pattern" {
      if ($PathToken -notmatch "\\\*\\\.git$" -and $PathToken -notmatch "\*\*\\\.git$") {
        $Errors.Add("$Context boundary pattern must point to nested .git folders: $PathToken")
      }
    }
    default { $Errors.Add("$Context unsupported path_check: $PathCheck") }
  }
}

function Test-Markers {
  param([object]$Row, [System.Collections.Generic.List[string]]$Errors)
  if ($Row.path_check -ne "literal") { return }
  $resolved = Resolve-RepoPath -Path $Row.path
  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) { return }
  $text = Get-Content -LiteralPath $resolved -Raw
  foreach ($marker in @($Row.required_markers -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($text -notmatch [regex]::Escape($marker)) {
      $Errors.Add("$($Row.surface_id) missing required marker '$marker' in $($Row.path)")
    }
  }
}

$matrixPath = Join-Path $Root "matrices\AGENTS_INSTRUCTION_SURFACE_MATRIX.csv"
$docPath = Join-Path $Root "maps\AGENTS_INSTRUCTION_HIERARCHY.md"
$agentsPath = Join-Path $Root "agents.json"
$toolIndexPath = Join-Path $Root "tools\TOOL_INDEX.csv"
$toolGovernancePath = Join-Path $Root "matrices\TOOL_GOVERNANCE_MATRIX.csv"
$stopGlossaryPath = Join-Path $Root "matrices\STOP_CONDITION_GLOSSARY.csv"
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

Require-Columns -Path $matrixPath -Columns @(
  "surface_id", "path", "path_check", "scope", "precedence_rank", "instruction_role",
  "owner_agent", "reviewer_agent", "required_markers", "allowed_actions", "blocked_actions",
  "nested_repo_policy", "validator", "evidence", "stop_condition"
) -Errors $errors

$rows = Read-CsvRequired -Path $matrixPath
$agentIds = @((Get-Content -LiteralPath $agentsPath -Raw | ConvertFrom-Json).agents | ForEach-Object { $_.id })
$toolIds = @((Read-CsvRequired -Path $toolIndexPath) | ForEach-Object { $_.tool_id })
$toolGovernanceIds = @((Read-CsvRequired -Path $toolGovernancePath) | ForEach-Object { $_.tool_id })
$knownStops = @((Read-CsvRequired -Path $stopGlossaryPath) | ForEach-Object { $_.stop_condition })

foreach ($expected in @(
  "root_agents_md", "codex_agent_layer", "agent_registry", "routing_registry",
  "repo_local_skills", "recipe_registry", "tool_registry", "nested_repositories"
)) {
  if ($expected -notin @($rows | ForEach-Object { $_.surface_id })) {
    $errors.Add("Missing instruction surface row: $expected")
  }
}

$rootRow = @($rows | Where-Object { $_.surface_id -eq "root_agents_md" }) | Select-Object -First 1
if (-not $rootRow) {
  $errors.Add("Root AGENTS.md row missing")
} else {
  if ((Split-Path -Leaf $rootRow.path) -ne "AGENTS.md") { $errors.Add("root_agents_md must point to AGENTS.md") }
  if ([int]$rootRow.precedence_rank -ne 10) { $errors.Add("root_agents_md precedence_rank must be 10") }
  if ($rootRow.instruction_role -ne "local_rector_source") { $errors.Add("root_agents_md must be local_rector_source") }
}

$ranks = @{}
foreach ($row in $rows) {
  foreach ($field in @("surface_id","path","path_check","scope","precedence_rank","instruction_role","owner_agent","reviewer_agent","allowed_actions","blocked_actions","nested_repo_policy","validator","evidence","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) { $errors.Add("Instruction surface '$($row.surface_id)' missing $field") }
  }
  if ($row.owner_agent -notin $agentIds) { $errors.Add("Instruction surface '$($row.surface_id)' references unknown owner_agent: $($row.owner_agent)") }
  if ($row.reviewer_agent -notin $agentIds) { $errors.Add("Instruction surface '$($row.surface_id)' references unknown reviewer_agent: $($row.reviewer_agent)") }
  if ($row.validator -notin $toolIds) { $errors.Add("Instruction surface '$($row.surface_id)' references unknown validator: $($row.validator)") }
  if ($row.validator -notin $toolGovernanceIds) { $errors.Add("Instruction validator lacks tool governance row: $($row.validator)") }
  foreach ($stop in @($row.stop_condition -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($stop -notin $knownStops) { $errors.Add("Instruction surface '$($row.surface_id)' references unknown stop_condition: $stop") }
  }
  $rank = 0
  if (-not [int]::TryParse([string]$row.precedence_rank, [ref]$rank)) {
    $errors.Add("Instruction surface '$($row.surface_id)' has non-numeric precedence_rank")
  } elseif ($ranks.ContainsKey($rank)) {
    $errors.Add("Duplicate precedence_rank $rank on $($row.surface_id) and $($ranks[$rank])")
  } else { $ranks[$rank] = $row.surface_id }
  Test-PathToken -PathToken $row.path -PathCheck $row.path_check -Errors $errors -Warnings $warnings -Context $row.surface_id
  Test-Markers -Row $row -Errors $errors
}

if (-not (Test-Path -LiteralPath $docPath -PathType Leaf)) {
  $errors.Add("Missing instruction hierarchy document: $docPath")
} else {
  $docText = Get-Content -LiteralPath $docPath -Raw
  foreach ($required in @("Effective Canonical Root", "Precedence", "Contradiction Rule", "Nested Surface Policy", "Validation")) {
    if ($docText -notmatch [regex]::Escape($required)) { $errors.Add("Instruction hierarchy document missing marker: $required") }
  }
}

$nestedRow = @($rows | Where-Object { $_.surface_id -eq "nested_repositories" }) | Select-Object -First 1
if ($nestedRow) {
  foreach ($blocked in @("absorb_nested_repo", "move_clone", "delete_branch_remote")) {
    if ($nestedRow.blocked_actions -notmatch [regex]::Escape($blocked)) { $errors.Add("nested_repositories row missing blocked action: $blocked") }
  }
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
[pscustomobject]@{
  status = $status
  root = $Root
  repo_root = $RepoRoot
  instruction_surface_rows = $rows.Count
  root_surface = Resolve-RepoPath -Path $rootRow.path
  validator = "tool.local_validate_agents_instruction_hierarchy"
  warning_count = $warnings.Count
  warnings = @($warnings)
  error_count = $errors.Count
  errors = @($errors)
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") { exit 1 }
