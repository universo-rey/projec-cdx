param(
  [string]$Root = "",
  [string]$RepoRoot = "",
  [string]$ExpectedRepo = "universo-rey/projec-cdx",
  [string]$ExpectedBranch = "codex/w1-reconcile-20260826",
  [int]$IssueNumber = 44
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = Split-Path -Parent $PSScriptRoot
}
$Root = (Resolve-Path -LiteralPath $Root).Path

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $RepoRoot = Split-Path -Parent (Split-Path -Parent $Root)
}
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$errors = [System.Collections.Generic.List[string]]::new()
$secretHits = 0
$issueState = "UNKNOWN"
$duplicateW1EComment = -1
$remoteBranchState = "UNKNOWN"
$workflowsCovered = "0/6"
$codeqlException = "FAIL"
$promoteOwnerGate = "FAIL"

function Add-PreflightError {
  param([string]$Message)
  $errors.Add($Message)
}

function Get-RepoPath {
  param([string]$RelativePath)
  $normalized = $RelativePath.Replace("/", [IO.Path]::DirectorySeparatorChar)
  Join-Path $RepoRoot $normalized.TrimStart("\", "/")
}

function Normalize-GitPath {
  param([string]$Path)
  $Path.Replace("\", "/").Trim()
}

function Read-CsvChecked {
  param(
    [string]$RelativePath,
    [string[]]$RequiredColumns
  )

  $path = Get-RepoPath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-PreflightError "missing_csv:$RelativePath"
    return @()
  }

  try {
    $rows = @(Import-Csv -LiteralPath $path)
    $headerColumns = @()
    if ($rows.Count -gt 0) {
      $headerColumns = @($rows[0].PSObject.Properties.Name)
    } else {
      $header = Get-Content -LiteralPath $path -TotalCount 1
      if ($header) { $headerColumns = @($header -split "," | ForEach-Object { $_.Trim('"') }) }
    }
    foreach ($column in $RequiredColumns) {
      if ($column -notin $headerColumns) {
        Add-PreflightError "missing_column:${RelativePath}:$column"
      }
    }
    return $rows
  } catch {
    Add-PreflightError "invalid_csv:$RelativePath"
    return @()
  }
}

function Get-NativeOutput {
  param(
    [scriptblock]$Command,
    [string]$FailureCode
  )
  $output = & $Command 2>$null
  if ($LASTEXITCODE -ne 0) {
    Add-PreflightError $FailureCode
    return $null
  }
  return $output
}

function Test-TemplateFields {
  param(
    [string]$RelativePath,
    [string[]]$Fields
  )
  $path = Get-RepoPath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-PreflightError "missing_template:$RelativePath"
    return
  }
  $text = Get-Content -Raw -LiteralPath $path
  foreach ($field in $Fields) {
    $escapedField = [regex]::Escape($field)
    if ($text -notmatch ("(?im)^\s*(?:-\s*)?(?:id\s*:\s*)?" + $escapedField + "\s*:?(?:\s|$)")) {
      Add-PreflightError "template_field_missing:${RelativePath}:$field"
    }
  }
}

$allowedPaths = @(
  ".github/workflows/promote.yml",
  ".agents/codex/tools/local_validate_github_automation_preflight.ps1",
  ".agents/codex/tools/TOOL_INDEX.csv",
  ".agents/codex/matrices/TOOL_GOVERNANCE_MATRIX.csv",
  ".agents/codex/matrices/VALIDATION_COVERAGE_MATRIX.csv",
  ".agents/codex/matrices/GITHUB_AUTOMATION_PREFLIGHT_MATRIX.csv",
  ".agents/codex/matrices/GITHUB_ACTIONS_WORKFLOW_MATRIX.csv",
  ".agents/codex/matrices/W1_ISSUE_44_VALIDATOR_COVERAGE_20260826.csv",
  ".agents/codex/readbacks/READBACK_W1F3_PROJECT_CDX_GITHUB_PREFLIGHT_20260826.md",
  ".agents/codex/readbacks/READBACK_W1E_ISSUE_44_FANIN_20260826.md"
)

$expectedRepoRoot = Get-NativeOutput -FailureCode "git_repo_root_unavailable" -Command {
  git -C $RepoRoot rev-parse --show-toplevel
}
if ($null -ne $expectedRepoRoot) {
  try {
    $resolvedGitRoot = (Resolve-Path -LiteralPath ([string]$expectedRepoRoot).Trim()).Path
    if ($resolvedGitRoot -ne $RepoRoot) { Add-PreflightError "repo_root_mismatch" }
  } catch {
    Add-PreflightError "repo_root_invalid"
  }
}

$remoteUrl = Get-NativeOutput -FailureCode "origin_remote_unavailable" -Command {
  git -C $RepoRoot remote get-url origin
}
if ($null -ne $remoteUrl) {
  $remoteNormalized = ([string]$remoteUrl).Trim().ToLowerInvariant()
  $validRemoteUrls = @(
    "https://github.com/$($ExpectedRepo.ToLowerInvariant()).git",
    "https://github.com/$($ExpectedRepo.ToLowerInvariant())",
    "git@github.com:$($ExpectedRepo.ToLowerInvariant()).git"
  )
  if ($remoteNormalized -notin $validRemoteUrls) { Add-PreflightError "origin_remote_mismatch" }
}

$branch = Get-NativeOutput -FailureCode "branch_unavailable" -Command {
  git -C $RepoRoot branch --show-current
}
if ($null -ne $branch) {
  $branch = ([string]$branch).Trim()
  if ($branch -ne $ExpectedBranch -or $branch -notlike "codex/*") {
    Add-PreflightError "branch_mismatch"
  }
}

$statusRaw = Get-NativeOutput -FailureCode "git_status_unavailable" -Command {
  git -C $RepoRoot status --porcelain=v1 -z --untracked-files=all
}
if ($null -ne $statusRaw) {
  $statusRecords = (([string]$statusRaw) -split "`0") | Where-Object { $_ }
  foreach ($record in $statusRecords) {
    if ($record.Length -lt 4) {
      Add-PreflightError "unparseable_dirty_record"
      continue
    }
    $dirtyPath = Normalize-GitPath $record.Substring(3)
    if ($dirtyPath -notin $allowedPaths) {
      Add-PreflightError "dirty_path_outside_allowlist:$dirtyPath"
    }
  }
}

$stagedRaw = Get-NativeOutput -FailureCode "staging_inspection_failed" -Command {
  git -C $RepoRoot diff --cached --name-only -z
}
if ($null -ne $stagedRaw) {
  $stagedPaths = (([string]$stagedRaw) -split "`0") | Where-Object { $_ }
  foreach ($path in $stagedPaths) {
    $normalizedPath = Normalize-GitPath $path
    if ($normalizedPath -notin $allowedPaths) {
      Add-PreflightError "staged_path_outside_allowlist:$normalizedPath"
    }
  }
}

$automationColumns = @(
  "preflight_id","phase","required_before","owner_agent","reviewer_agent","surface",
  "required_artifacts","allowed_actions","blocked_actions","github_mode","agents_sdk_mode",
  "evidence","validator","status","stop_condition"
)
$automationRows = @(Read-CsvChecked -RelativePath ".agents/codex/matrices/GITHUB_AUTOMATION_PREFLIGHT_MATRIX.csv" -RequiredColumns $automationColumns)
if ($automationRows.Count -ne 5) { Add-PreflightError "github_preflight_row_count_not_5" }
if (@($automationRows | Group-Object preflight_id | Where-Object { $_.Count -ne 1 }).Count -gt 0) {
  Add-PreflightError "github_preflight_id_not_unique"
}
foreach ($row in $automationRows) {
  foreach ($field in @("preflight_id","owner_agent","reviewer_agent","required_artifacts","allowed_actions","blocked_actions","evidence","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace([string]$row.$field)) {
      Add-PreflightError "github_preflight_field_empty:$($row.preflight_id):$field"
    }
  }
  if ($row.owner_agent -eq $row.reviewer_agent) {
    Add-PreflightError "github_preflight_owner_reviewer_same:$($row.preflight_id)"
  }
  if ($row.github_mode -ne "GITHUB_REMOTE_READONLY") {
    Add-PreflightError "github_preflight_mode_not_readonly:$($row.preflight_id)"
  }
  foreach ($artifact in @([string]$row.required_artifacts -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($artifact -match '^[A-Za-z]:[\\/]') {
      Add-PreflightError "absolute_required_artifact_forbidden:$($row.preflight_id)"
      continue
    }
    if (-not (Test-Path -LiteralPath (Get-RepoPath $artifact))) {
      Add-PreflightError "required_artifact_missing:$($row.preflight_id):$artifact"
    }
  }
}

$workflowColumns = @(
  "workflow_id","path","triggers","runner","permissions","allowed_actions","blocked_actions",
  "status","owner_agent","validator","stop_condition"
)
$workflowRows = @(Read-CsvChecked -RelativePath ".agents/codex/matrices/GITHUB_ACTIONS_WORKFLOW_MATRIX.csv" -RequiredColumns $workflowColumns)
$workflowFiles = @(Get-ChildItem -LiteralPath (Get-RepoPath ".github/workflows") -File -Filter "*.yml" | ForEach-Object {
  ".github/workflows/$($_.Name)"
} | Sort-Object)
$matrixWorkflowPaths = @($workflowRows | ForEach-Object { Normalize-GitPath $_.path } | Sort-Object)

if ($workflowRows.Count -ne 6) { Add-PreflightError "workflow_matrix_row_count_not_6" }
if (@($workflowRows | Group-Object workflow_id | Where-Object { $_.Count -ne 1 }).Count -gt 0) {
  Add-PreflightError "workflow_matrix_id_not_unique"
}
if (@($workflowRows | Group-Object path | Where-Object { $_.Count -ne 1 }).Count -gt 0) {
  Add-PreflightError "workflow_matrix_path_not_unique"
}
$missingCoverage = @($workflowFiles | Where-Object { $_ -notin $matrixWorkflowPaths })
$staleCoverage = @($matrixWorkflowPaths | Where-Object { $_ -notin $workflowFiles })
if ($missingCoverage.Count -eq 0 -and $staleCoverage.Count -eq 0 -and $workflowFiles.Count -eq 6) {
  $workflowsCovered = "6/6"
} else {
  Add-PreflightError "workflow_coverage_not_1_to_1"
}

foreach ($row in $workflowRows) {
  foreach ($field in @("workflow_id","path","triggers","runner","permissions","allowed_actions","blocked_actions","status","owner_agent","validator","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace([string]$row.$field)) {
      Add-PreflightError "workflow_matrix_field_empty:$($row.workflow_id):$field"
    }
  }
  $workflowPath = Get-RepoPath $row.path
  if (-not (Test-Path -LiteralPath $workflowPath -PathType Leaf)) {
    Add-PreflightError "workflow_missing:$($row.path)"
    continue
  }
  $workflowText = Get-Content -Raw -LiteralPath $workflowPath
  if ($workflowText -match '(?im)^\s*pull_request_target\s*:|^\s*workflow_run\s*:|git\s+push\s+[^\r\n]*--force|git\s+merge\s+|gh\s+pr\s+merge|delete-branch\s*:\s*true') {
    Add-PreflightError "workflow_forbidden_operation:$($row.workflow_id)"
  }

  if ($row.workflow_id -notin @("codeql","promote")) {
    if ($row.status -ne "APPROVED_READONLY_VALIDATION" -or $row.permissions -ne "contents:read") {
      Add-PreflightError "ordinary_workflow_matrix_not_readonly:$($row.workflow_id)"
    }
    if ($workflowText -notmatch '(?im)^\s*contents\s*:\s*read\s*$') {
      Add-PreflightError "ordinary_workflow_contents_read_missing:$($row.workflow_id)"
    }
    if ($workflowText -match '(?im)^\s*[a-z-]+\s*:\s*write\s*$') {
      Add-PreflightError "ordinary_workflow_write_permission:$($row.workflow_id)"
    }
  }
}

$codeqlRow = @($workflowRows | Where-Object { $_.workflow_id -eq "codeql" })
$codeqlPath = Get-RepoPath ".github/workflows/codeql.yml"
if ($codeqlRow.Count -eq 1 -and (Test-Path -LiteralPath $codeqlPath)) {
  $codeqlText = Get-Content -Raw -LiteralPath $codeqlPath
  $expectedCodeqlPermissions = @("contents:read","packages:read","actions:read","security-events:write")
  $actualCodeqlPermissions = @($codeqlRow[0].permissions -split "\|" | Sort-Object)
  $codeqlMatrixExact = (@(Compare-Object ($expectedCodeqlPermissions | Sort-Object) $actualCodeqlPermissions).Count -eq 0)
  $codeqlActualExact =
    $codeqlText -match '(?im)^\s*contents\s*:\s*read\s*$' -and
    $codeqlText -match '(?im)^\s*packages\s*:\s*read\s*$' -and
    $codeqlText -match '(?im)^\s*actions\s*:\s*read\s*$' -and
    $codeqlText -match '(?im)^\s*security-events\s*:\s*write\s*$' -and
    @([regex]::Matches($codeqlText, '(?im)^\s*[a-z-]+\s*:\s*write\s*$')).Count -eq 1
  if ($codeqlMatrixExact -and $codeqlActualExact -and $codeqlRow[0].status -eq "GITHUB_SECURITY_EVENTS_WRITE_BOUNDED") {
    $codeqlException = "PASS_BOUNDED"
  } else {
    Add-PreflightError "codeql_exception_not_bounded"
  }
} else {
  Add-PreflightError "codeql_row_missing_or_duplicate"
}

$promoteRow = @($workflowRows | Where-Object { $_.workflow_id -eq "promote" })
$promotePath = Get-RepoPath ".github/workflows/promote.yml"
if ($promoteRow.Count -eq 1 -and (Test-Path -LiteralPath $promotePath)) {
  $promoteText = Get-Content -Raw -LiteralPath $promotePath
  $secretRefs = @([regex]::Matches($promoteText, '\$\{\{\s*secrets\.([A-Za-z0-9_]+)\s*\}\}') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
  $promoteChecks = @(
    ($promoteRow[0].status -eq "MANUAL_OWNER_GATED_WRITE"),
    ($promoteRow[0].permissions -eq "contents:write|pull-requests:write"),
    ($promoteText -match '(?im)^\s*workflow_dispatch\s*:'),
    ($promoteText -match '(?im)^\s*owner_gate_id\s*:'),
    ($promoteText -match '(?im)^\s*confirm_owner_gate\s*:'),
    ($promoteText -match '(?im)^\s*contents\s*:\s*write\s*$'),
    ($promoteText -match '(?im)^\s*pull-requests\s*:\s*write\s*$'),
    ($promoteText -match '(?im)^\s*delete-branch\s*:\s*false\s*$'),
    ($secretRefs.Count -eq 1 -and $secretRefs[0] -eq "GITHUB_TOKEN"),
    ($promoteText -notmatch '(?im)git\s+push\s+[^\r\n]*--force|git\s+merge\s+|gh\s+pr\s+merge|delete-branch\s*:\s*true')
  )
  if ($promoteChecks -notcontains $false) {
    $promoteOwnerGate = "PASS"
  } else {
    Add-PreflightError "promote_owner_gate_invalid"
  }
} else {
  Add-PreflightError "promote_row_missing_or_duplicate"
}

$requiredGovernanceFields = @("agent","skill","recipe","tool","validator","evidence","stop_condition")
Test-TemplateFields -RelativePath ".github/ISSUE_TEMPLATE/agent-task.yml" -Fields $requiredGovernanceFields
Test-TemplateFields -RelativePath ".github/ISSUE_TEMPLATE/runtime-approval.yml" -Fields $requiredGovernanceFields
Test-TemplateFields -RelativePath ".github/PULL_REQUEST_TEMPLATE.md" -Fields $requiredGovernanceFields

$ghCommand = Get-Command gh -ErrorAction SilentlyContinue
if ($null -eq $ghCommand) {
  Add-PreflightError "gh_cli_unavailable"
} else {
  $issueJson = Get-NativeOutput -FailureCode "github_issue_read_failed" -Command {
    gh issue view $IssueNumber --repo $ExpectedRepo --json state,comments
  }
  if ($null -ne $issueJson) {
    try {
      $issue = ([string]$issueJson) | ConvertFrom-Json
      $issueState = ([string]$issue.state).ToUpperInvariant()
      if ($issueState -ne "OPEN") { Add-PreflightError "issue_44_not_open" }
      $duplicateW1EComment = @($issue.comments | Where-Object {
        ([string]$_.body) -match 'READBACK_W1E_ISSUE_44_FANIN_20260826|W1E_ISSUE_44_FANIN_20260826'
      }).Count
      if ($duplicateW1EComment -ne 0) { Add-PreflightError "duplicate_w1e_comment_present" }
    } catch {
      Add-PreflightError "github_issue_json_invalid"
    }
  }
}

$remoteBranch = & git -C $RepoRoot ls-remote --heads origin "refs/heads/$ExpectedBranch" 2>$null
if ($LASTEXITCODE -ne 0) {
  Add-PreflightError "remote_branch_read_failed"
} elseif ([string]::IsNullOrWhiteSpace(([string]$remoteBranch))) {
  $remoteBranchState = "ABSENT_EXPECTED_PRE_PUSH"
} else {
  $remoteBranchState = "PRESENT"
}

$changedText = ""
$diffText = Get-NativeOutput -FailureCode "changed_content_read_failed" -Command {
  git -C $RepoRoot diff --no-ext-diff -- .
}
if ($null -ne $diffText) { $changedText += ([string]$diffText) }

$untrackedRaw = Get-NativeOutput -FailureCode "untracked_content_inventory_failed" -Command {
  git -C $RepoRoot ls-files --others --exclude-standard -z
}
if ($null -ne $untrackedRaw) {
  foreach ($untrackedPath in (([string]$untrackedRaw) -split "`0" | Where-Object { $_ })) {
    $normalizedUntracked = Normalize-GitPath $untrackedPath
    if ($normalizedUntracked -in $allowedPaths) {
      $fullPath = Get-RepoPath $normalizedUntracked
      if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        $changedText += (Get-Content -Raw -LiteralPath $fullPath)
      }
    }
  }
}

$secretPatterns = @(
  'github_pat_[A-Za-z0-9_]{20,}',
  'gh[pousr]_[A-Za-z0-9]{36,}',
  'AKIA[0-9A-Z]{16}',
  '-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'
)
foreach ($pattern in $secretPatterns) {
  $secretHits += @([regex]::Matches($changedText, $pattern)).Count
}
if ($secretHits -gt 0) { Add-PreflightError "secret_pattern_detected" }

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
$decision = if ($status -eq "PASS") { "ALLOW_GITHUB_FANIN_PREFLIGHT" } else { "BLOCK" }

"STATUS=$status"
"REPO=$ExpectedRepo"
"BRANCH=$ExpectedBranch"
"ISSUE_44=$issueState"
"DUPLICATE_W1E_COMMENT=$duplicateW1EComment"
"REMOTE_BRANCH_STATE=$remoteBranchState"
"ERROR_COUNT=$($errors.Count)"
"SECRET_HITS=$secretHits"
"REMOTE_WRITE=false"
"WORKFLOWS_COVERED=$workflowsCovered"
"CODEQL_EXCEPTION=$codeqlException"
"PROMOTE_OWNER_GATE=$promoteOwnerGate"
"DECISION=$decision"

for ($index = 0; $index -lt $errors.Count; $index++) {
  "ERROR_$($index + 1)=$($errors[$index])"
}

if ($status -ne "PASS") { exit 1 }
