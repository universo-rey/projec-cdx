param(
  [string]$Root = ".agents\codex",
  [string]$RepoRoot = "C:\Users\enzo1\Documents\GitHub\cabina-universal-d"
)

$ErrorActionPreference = "Stop"

function Read-CsvRequired {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing required CSV: $Path"
  }
  @(Import-Csv -LiteralPath $Path)
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
  foreach ($column in $Columns) {
    if ($column -notin $actual) {
      $Errors.Add("Missing column '$column' in $Path")
    }
  }
}

function Get-SkillFrontmatter {
  param([string]$Path)
  $text = Get-Content -Raw -LiteralPath $Path
  $match = [regex]::Match($text, "(?s)^---\s*(.*?)\s*---")
  $frontmatter = @{}
  if (-not $match.Success) {
    return [pscustomobject]@{ Data = $frontmatter; Text = $text; HasFrontmatter = $false }
  }
  foreach ($line in @($match.Groups[1].Value -split "`r?`n")) {
    if ($line -match "^\s*([A-Za-z0-9_-]+):\s*(.+?)\s*$") {
      $frontmatter[$matches[1]] = ($matches[2].Trim() -replace '^"|"$', "")
    }
  }
  [pscustomobject]@{ Data = $frontmatter; Text = $text; HasFrontmatter = $true }
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

function Check-PathTokens {
  param(
    [string]$Value,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  foreach ($token in @($Value -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($token -match '^[A-Za-z]:[\\/]') {
      $resolved = Resolve-CabinaPath -Path $token
      if (-not (Test-Path -LiteralPath $resolved)) {
        $Errors.Add("$Context references missing path: $token")
      }
    }
  }
}

function Get-RepoLocalSkillRecords {
  param(
    [string]$SkillRoot,
    [string]$RepoRoot
  )

  $records = @()
  $gitOutput = @(& git -C $RepoRoot ls-files -- ".agents/skills/*/SKILL.md" 2>$null)
  if ($LASTEXITCODE -eq 0 -and $gitOutput.Count -gt 0) {
    foreach ($path in $gitOutput) {
      $parts = @($path -split "/")
      if ($parts.Count -eq 4 -and $parts[0] -eq ".agents" -and $parts[1] -eq "skills" -and $parts[3] -eq "SKILL.md") {
        $records += [pscustomobject]@{
          SkillId = $parts[2]
          SkillPath = Join-Path $RepoRoot ($path -replace "/", "\")
        }
      }
    }
    return @($records)
  }

  if (Test-Path -LiteralPath $SkillRoot) {
    foreach ($dir in @(Get-ChildItem -LiteralPath $SkillRoot -Directory)) {
      $records += [pscustomobject]@{
        SkillId = $dir.Name
        SkillPath = Join-Path $dir.FullName "SKILL.md"
      }
    }
  }
  @($records)
}

$skillRoot = Join-Path $RepoRoot ".agents\skills"
$qualityPath = Join-Path $Root "skills\SKILL_METADATA_QUALITY_MATRIX.csv"
$catalogPath = Join-Path $Root "matrices\LOCAL_SKILL_CATALOG.csv"
$usagePath = Join-Path $Root "skills\SKILL_USAGE_MATRIX.csv"
$stopPath = Join-Path $Root "matrices\STOP_CONDITION_GLOSSARY.csv"

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $skillRoot)) {
  $errors.Add("Missing repo-local skill root: $skillRoot")
}

Require-Columns -Path $qualityPath -Columns @(
  "skill_id",
  "path",
  "category",
  "source",
  "owner_agent",
  "reviewer_agent",
  "description_status",
  "trigger_keywords",
  "trigger_boundary",
  "allowed_actions",
  "blocked_actions",
  "validator",
  "evidence",
  "stop_condition",
  "quality_status",
  "next_action"
) -Errors $errors

$qualityRows = Read-CsvRequired -Path $qualityPath
$catalogRows = Read-CsvRequired -Path $catalogPath
$usageRows = Read-CsvRequired -Path $usagePath
$knownStops = @((Read-CsvRequired -Path $stopPath) | ForEach-Object { $_.stop_condition })

$qualityBySkill = @{}
foreach ($row in $qualityRows) {
  if ([string]::IsNullOrWhiteSpace($row.skill_id)) {
    $errors.Add("Skill metadata quality row missing skill_id")
    continue
  }
  if ($qualityBySkill.ContainsKey($row.skill_id)) {
    $errors.Add("Duplicate skill metadata quality row: $($row.skill_id)")
  } else {
    $qualityBySkill[$row.skill_id] = $row
  }
  foreach ($field in @("path","category","source","owner_agent","reviewer_agent","description_status","trigger_keywords","trigger_boundary","allowed_actions","blocked_actions","validator","evidence","stop_condition","quality_status","next_action")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Skill metadata quality '$($row.skill_id)' missing $field")
    }
  }
  if ($row.quality_status -ne "PASS") {
    $errors.Add("Skill metadata quality '$($row.skill_id)' must be PASS for repo-local skills")
  }
  Check-PathTokens -Value $row.path -Errors $errors -Context "Skill metadata quality '$($row.skill_id)' path"
  Check-PathTokens -Value $row.validator -Errors $errors -Context "Skill metadata quality '$($row.skill_id)' validator"
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStops -Errors $errors -Context "Skill metadata quality '$($row.skill_id)'"
}

$catalogIds = @($catalogRows | Where-Object { $_.source -eq "d_drive_repo_local" } | ForEach-Object { $_.skill_id })
$usageIds = @($usageRows | Where-Object { $_.source -eq "d_drive_repo_local" } | ForEach-Object { $_.skill_id })
$repoLocalSkills = @(Get-RepoLocalSkillRecords -SkillRoot $skillRoot -RepoRoot $RepoRoot)

foreach ($skillRecord in $repoLocalSkills) {
    $skillId = $skillRecord.SkillId
    $skillPath = $skillRecord.SkillPath
    if (-not (Test-Path -LiteralPath $skillPath)) {
      $errors.Add("Repo-local skill missing SKILL.md: $skillId")
      continue
    }
    if ($skillId -notin $catalogIds) {
      $errors.Add("Repo-local skill missing LOCAL_SKILL_CATALOG row: $skillId")
    }
    if ($skillId -notin $usageIds) {
      $errors.Add("Repo-local skill missing SKILL_USAGE_MATRIX row: $skillId")
    }
    if (-not $qualityBySkill.ContainsKey($skillId)) {
      $errors.Add("Repo-local skill missing SKILL_METADATA_QUALITY_MATRIX row: $skillId")
      continue
    }

    $row = $qualityBySkill[$skillId]
    $skill = Get-SkillFrontmatter -Path $skillPath
    if (-not $skill.HasFrontmatter) {
      $errors.Add("Skill missing YAML frontmatter: $skillId")
      continue
    }
    if (-not $skill.Data.ContainsKey("name") -or $skill.Data["name"] -ne $skillId) {
      $errors.Add("Skill frontmatter name must match folder '$skillId'")
    }
    if (-not $skill.Data.ContainsKey("description") -or [string]::IsNullOrWhiteSpace($skill.Data["description"])) {
      $errors.Add("Skill missing frontmatter description: $skillId")
    } else {
      $description = $skill.Data["description"]
      if ($description -notmatch "^Use when\b") {
        $errors.Add("Skill description must start with 'Use when': $skillId")
      }
      if ($description.Length -lt 100) {
        $errors.Add("Skill description is too short for reliable activation: $skillId")
      }
      $keywordHits = 0
      foreach ($keyword in @($row.trigger_keywords -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
        if ($description -match [regex]::Escape($keyword)) {
          $keywordHits += 1
        }
      }
      if ($keywordHits -lt 2) {
        $errors.Add("Skill description lacks at least two declared trigger keywords: $skillId")
      }
    }

    foreach ($heading in @("Trigger Boundary","Allowed Actions","Blocked Actions","Validator")) {
      if ($skill.Text -notmatch "(?m)^## $([regex]::Escape($heading))\s*$") {
        $errors.Add("Skill '$skillId' missing section: $heading")
      }
    }
    foreach ($blocked in @("microsoft_live","openai_api_live","production","secrets")) {
      if ($row.blocked_actions -notmatch [regex]::Escape($blocked)) {
        $errors.Add("Skill metadata '$skillId' blocked_actions missing $blocked")
      }
    }
  }

foreach ($skillId in $catalogIds) {
  if ($skillId -notin $usageIds) {
    $errors.Add("d_drive_repo_local catalog skill missing usage row: $skillId")
  }
}
foreach ($skillId in $usageIds) {
  if ($skillId -notin $catalogIds) {
    $errors.Add("d_drive_repo_local usage skill missing catalog row: $skillId")
  }
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
[pscustomobject]@{
  status = $status
  root = $Root
  repo_root = $RepoRoot
  repo_local_skill_count = $repoLocalSkills.Count
  metadata_quality_rows = $qualityRows.Count
  warning_count = $warnings.Count
  warnings = $warnings
  error_count = $errors.Count
  errors = $errors
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
