param(
  [switch]$SelfTest,
  [string]$RepoRoot,
  [string]$EvidencePath,
  [string]$ExpectedRepository,
  [ValidatePattern('^$|^[0-9a-fA-F]{40}$')][string]$ExpectedBaseSha,
  [ValidatePattern('^$|^[0-9a-fA-F]{40}$')][string]$ExpectedHeadSha,
  [ValidateRange(0, 2147483647)][int]$ExpectedOriginalPr,
  [string[]]$AllowedDependencyPath
)

$ErrorActionPreference = 'Stop'
$errors = [System.Collections.Generic.List[string]]::new()
$secretHits = 0
$derivedDecision = 'INSUFFICIENT_EVIDENCE'

if ($SelfTest) {
  $selfErrors = [System.Collections.Generic.List[string]]::new()
  $toolPath = $MyInvocation.MyCommand.Path
  $codexRoot = Split-Path -Parent $PSScriptRoot
  $recipePath = Join-Path $codexRoot 'recipes\recipe.baseline_differential_dependency_validation.md'
  $recipeIndexPath = Join-Path $codexRoot 'recipes\RECIPE_INDEX.csv'
  $toolIndexPath = Join-Path $codexRoot 'tools\TOOL_INDEX.csv'
  $toolGovernancePath = Join-Path $codexRoot 'matrices\TOOL_GOVERNANCE_MATRIX.csv'
  $coveragePath = Join-Path $codexRoot 'matrices\VALIDATION_COVERAGE_MATRIX.csv'
  foreach ($path in @($recipePath, $recipeIndexPath, $toolIndexPath, $toolGovernancePath, $coveragePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $selfErrors.Add("Missing governed asset: $path") }
  }
  $tokens = $null
  $parseErrors = $null
  $ast = [System.Management.Automation.Language.Parser]::ParseFile($toolPath, [ref]$tokens, [ref]$parseErrors)
  foreach ($parseError in @($parseErrors)) { $selfErrors.Add("PowerShell parse error: $($parseError.Message)") }
  $source = Get-Content -LiteralPath $toolPath -Raw
  foreach ($label in @('REGRESSION_INTRODUCED','BASELINE_DEBT_REPRODUCED','HARNESS_DEFECT','COMPATIBLE','INSUFFICIENT_EVIDENCE','FILE_BYTES_SHA256_NOT_DOMAIN_GLOBAL_HASH')) {
    if ($source -notmatch [regex]::Escape($label)) { $selfErrors.Add("Missing canonical contract token: $label") }
  }
  $commandNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() } | Where-Object { $_ })
  foreach ($forbiddenInvocation in @('Invoke-WebRequest','Invoke-RestMethod','Start-Process','npm','npx','gh')) {
    if ($forbiddenInvocation -in $commandNames) { $selfErrors.Add("Forbidden command invocation in validator: $forbiddenInvocation") }
  }
  if (Test-Path -LiteralPath $recipeIndexPath) {
    $count = @((Import-Csv -LiteralPath $recipeIndexPath) | Where-Object recipe_id -eq 'recipe.baseline_differential_dependency_validation').Count
    if ($count -ne 1) { $selfErrors.Add("Recipe index count must be 1; found $count") }
  }
  if (Test-Path -LiteralPath $toolIndexPath) {
    $count = @((Import-Csv -LiteralPath $toolIndexPath) | Where-Object tool_id -eq 'tool.local_validate_baseline_differential_dependency').Count
    if ($count -ne 1) { $selfErrors.Add("Tool index count must be 1; found $count") }
  }
  if (Test-Path -LiteralPath $toolGovernancePath) {
    $count = @((Import-Csv -LiteralPath $toolGovernancePath) | Where-Object tool_id -eq 'tool.local_validate_baseline_differential_dependency').Count
    if ($count -ne 1) { $selfErrors.Add("Tool governance count must be 1; found $count") }
  }
  $selfStatus = if ($selfErrors.Count -eq 0) { 'PASS' } else { 'FAIL' }
  [pscustomobject]@{
    status = $selfStatus
    mode = 'SELF_TEST_READ_ONLY'
    error_count = $selfErrors.Count
    errors = $selfErrors
    local_file_writes = 0
    github_writes = 0
    network_install_attempts = 0
    secret_hits = 0
  } | ConvertTo-Json -Depth 6
  if ($selfStatus -ne 'PASS') { exit 1 }
  exit 0
}

foreach ($required in @(
  @{ Name = 'RepoRoot'; Value = $RepoRoot },
  @{ Name = 'EvidencePath'; Value = $EvidencePath },
  @{ Name = 'ExpectedRepository'; Value = $ExpectedRepository },
  @{ Name = 'ExpectedBaseSha'; Value = $ExpectedBaseSha },
  @{ Name = 'ExpectedHeadSha'; Value = $ExpectedHeadSha }
)) {
  if ([string]::IsNullOrWhiteSpace([string]$required.Value)) { $errors.Add("Missing required parameter: $($required.Name)") }
}
if ($ExpectedOriginalPr -lt 1) { $errors.Add('Missing or invalid ExpectedOriginalPr.') }
if (@($AllowedDependencyPath).Count -eq 0) { $errors.Add('AllowedDependencyPath must contain at least one path.') }

function Add-Error {
  param([string]$Message)
  $script:errors.Add($Message)
}

function Invoke-LocalGitRead {
  param([string[]]$Arguments)
  $output = & git -C $RepoRoot @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) {
    Add-Error "Local git read failed: git $($Arguments -join ' ')"
    return $null
  }
  return @($output | ForEach-Object { [string]$_ })
}

function Normalize-PathToken {
  param([string]$Value)
  return (($Value -replace '\\', '/').TrimStart('./'))
}

function New-OrdinalSet {
  param([string[]]$Values)
  $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
  foreach ($value in @($Values)) {
    if (-not [string]::IsNullOrWhiteSpace($value)) {
      [void]$set.Add((Normalize-PathToken $value))
    }
  }
  return $set
}

if (-not (Test-Path -LiteralPath $RepoRoot -PathType Container)) {
  Add-Error 'RepoRoot is missing.'
}
if (-not (Test-Path -LiteralPath $EvidencePath -PathType Leaf)) {
  Add-Error 'EvidencePath is missing.'
}

$evidence = $null
if ($errors.Count -eq 0) {
  try {
    $evidence = Get-Content -LiteralPath $EvidencePath -Raw | ConvertFrom-Json -Depth 20
  } catch {
    Add-Error 'Evidence packet is not valid JSON.'
  }
}

$allowedSet = New-OrdinalSet -Values $AllowedDependencyPath
if ($allowedSet.Count -ne @($AllowedDependencyPath).Count) {
  Add-Error 'Allowed dependency paths must be non-empty and unique after normalization.'
}

$changedPaths = @()
if ($errors.Count -eq 0) {
  $rootResult = Invoke-LocalGitRead -Arguments @('rev-parse', '--show-toplevel')
  $headResult = Invoke-LocalGitRead -Arguments @('rev-parse', 'HEAD')
  $remoteResult = Invoke-LocalGitRead -Arguments @('remote', 'get-url', 'origin')
  [void](Invoke-LocalGitRead -Arguments @('cat-file', '-e', "$ExpectedBaseSha`^{commit}"))
  [void](Invoke-LocalGitRead -Arguments @('cat-file', '-e', "$ExpectedHeadSha`^{commit}"))
  if ($rootResult -and ((Resolve-Path -LiteralPath $rootResult[0]).Path -ne (Resolve-Path -LiteralPath $RepoRoot).Path)) {
    Add-Error 'RepoRoot does not resolve to the Git top level.'
  }
  if (-not $headResult -or $headResult[0].Trim().ToLowerInvariant() -ne $ExpectedHeadSha.ToLowerInvariant()) {
    Add-Error 'Checked-out HEAD does not equal ExpectedHeadSha.'
  }
  $remoteText = if ($remoteResult) { $remoteResult[0].Trim() } else { '' }
  $remoteSlug = $remoteText -replace '^https://github\.com/', '' -replace '^git@github\.com:', '' -replace '\.git$', ''
  if ($remoteSlug -ne $ExpectedRepository) {
    Add-Error 'Origin remote does not equal ExpectedRepository.'
  }
  $changedResult = Invoke-LocalGitRead -Arguments @('diff', '--name-only', $ExpectedBaseSha, $ExpectedHeadSha, '--')
  $changedPaths = @($changedResult | Where-Object { $_ } | ForEach-Object { Normalize-PathToken $_ })
  foreach ($path in $changedPaths) {
    if (-not $allowedSet.Contains($path)) {
      Add-Error "Changed path is outside allowlist: $path"
    }
  }
}

if ($evidence) {
  if ($evidence.schema_version -ne '1.0') { Add-Error 'Unsupported schema_version.' }
  if ($evidence.repository -ne $ExpectedRepository) { Add-Error 'Evidence repository mismatch.' }
  if ([string]$evidence.base_sha -ne $ExpectedBaseSha) { Add-Error 'Evidence base SHA mismatch.' }
  if ([string]$evidence.head_sha -ne $ExpectedHeadSha) { Add-Error 'Evidence head SHA mismatch.' }

  $evidenceAllowed = New-OrdinalSet -Values @($evidence.allowed_dependency_paths)
  if ($evidenceAllowed.Count -ne $allowedSet.Count) {
    Add-Error 'Evidence allowlist count mismatch.'
  } else {
    foreach ($path in $allowedSet) {
      if (-not $evidenceAllowed.Contains($path)) { Add-Error "Evidence allowlist mismatch: $path" }
    }
  }

  if (-not $evidence.original_pr -or [int]$evidence.original_pr.number -ne $ExpectedOriginalPr) {
    Add-Error 'Original PR identity mismatch.'
  } else {
    if (-not [bool]$evidence.original_pr.preserved) { Add-Error 'Original PR was not preserved.' }
    if ([bool]$evidence.original_pr.rebase_performed) { Add-Error 'Original PR rebase is prohibited.' }
    if ([bool]$evidence.original_pr.close_performed) { Add-Error 'Original PR close is prohibited.' }
    if ([string]$evidence.original_pr.state_before -ne [string]$evidence.original_pr.state_after) {
      Add-Error 'Original PR state changed.'
    }
  }

  if ([int]$evidence.network_install_attempts -ne 0) { Add-Error 'Network installation attempt recorded.' }
  if ([int]$evidence.github_write_count -ne 0) { Add-Error 'GitHub write recorded.' }
  if ([int]$evidence.secret_hits -ne 0) {
    $secretHits = [int]$evidence.secret_hits
    Add-Error 'Secret hit recorded.'
  }

  $hashRows = @($evidence.file_hashes)
  $hashPaths = New-OrdinalSet -Values @($hashRows | ForEach-Object { [string]$_.path })
  foreach ($path in $changedPaths) {
    if (-not $hashPaths.Contains($path)) {
      Add-Error "Changed path lacks file hash evidence: $path"
    }
  }
  foreach ($row in $hashRows) {
    $path = Normalize-PathToken ([string]$row.path)
    if (-not $allowedSet.Contains($path)) { Add-Error "File hash path is outside allowlist: $path"; continue }
    if ([string]$row.hash_semantics -ne 'FILE_BYTES_SHA256_NOT_DOMAIN_GLOBAL_HASH') {
      Add-Error "Invalid hash semantics for $path"
    }
    $fileHash = ([string]$row.file_sha256).ToUpperInvariant()
    if ($fileHash -notmatch '^[0-9A-F]{64}$') { Add-Error "Invalid file SHA-256 for $path"; continue }
    $domainHash = [string]$row.domain_global_hash
    if (-not [string]::IsNullOrWhiteSpace($domainHash) -and $domainHash.ToUpperInvariant() -eq $fileHash) {
      Add-Error "Domain global_hash was conflated with file SHA-256 for $path"
    }
    $localPath = Join-Path $RepoRoot ($path -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $localPath -PathType Leaf)) {
      Add-Error "Hashed file is missing at checked-out head: $path"
    } elseif ((Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash -ne $fileHash) {
      Add-Error "File SHA-256 mismatch for $path"
    }
  }

  $commands = @($evidence.commands)
  if ($commands.Count -eq 0) {
    Add-Error 'No paired command results supplied.'
  } else {
    $regression = $false
    $harnessDefect = $false
    $baselineDebt = $false
    $allHeadPass = $true
    foreach ($command in $commands) {
      if ([string]::IsNullOrWhiteSpace([string]$command.id) -or [string]::IsNullOrWhiteSpace([string]$command.command)) {
        Add-Error 'Command evidence lacks id or command.'
        continue
      }
      $baseStatus = ([string]$command.baseline.status).ToUpperInvariant()
      $headStatus = ([string]$command.head.status).ToUpperInvariant()
      if ($baseStatus -notin @('PASS','FAIL') -or $headStatus -notin @('PASS','FAIL')) {
        Add-Error "Command '$($command.id)' has invalid status."
        continue
      }
      if ($headStatus -ne 'PASS') { $allHeadPass = $false }
      $baseFingerprint = [string]$command.baseline.normalized_fingerprint
      $headFingerprint = [string]$command.head.normalized_fingerprint
      if ($headStatus -eq 'FAIL' -and ([string]::IsNullOrWhiteSpace($headFingerprint) -or [string]::IsNullOrWhiteSpace($baseFingerprint))) {
        Add-Error "Command '$($command.id)' failure lacks paired normalized fingerprints."
        continue
      }
      if ($baseStatus -eq 'PASS' -and $headStatus -eq 'FAIL') {
        $regression = $true
      } elseif ($baseStatus -eq 'FAIL' -and $headStatus -eq 'FAIL') {
        if ($baseFingerprint -ne $headFingerprint) {
          $regression = $true
        } elseif ([bool]$command.harness_defect) {
          $harnessDefect = $true
        } else {
          $baselineDebt = $true
        }
      }
    }
    if ($errors.Count -eq 0) {
      if ($regression) { $derivedDecision = 'REGRESSION_INTRODUCED' }
      elseif ($harnessDefect) { $derivedDecision = 'HARNESS_DEFECT' }
      elseif ($baselineDebt) { $derivedDecision = 'BASELINE_DEBT_REPRODUCED' }
      elseif ($allHeadPass) { $derivedDecision = 'COMPATIBLE' }
    }
  }
  if ([string]$evidence.decision -notin @('REGRESSION_INTRODUCED','BASELINE_DEBT_REPRODUCED','HARNESS_DEFECT','COMPATIBLE','INSUFFICIENT_EVIDENCE')) {
    Add-Error 'Declared decision is outside the canonical classification set.'
  } elseif ($errors.Count -eq 0 -and [string]$evidence.decision -ne $derivedDecision) {
    Add-Error "Declared decision '$($evidence.decision)' does not equal derived decision '$derivedDecision'."
  }
}

$status = if ($errors.Count -eq 0) { 'PASS' } else { 'FAIL' }
[pscustomobject]@{
  status = $status
  decision = $derivedDecision
  repository = $ExpectedRepository
  base_sha = $ExpectedBaseSha
  head_sha = $ExpectedHeadSha
  original_pr = $ExpectedOriginalPr
  changed_paths = $changedPaths
  error_count = $errors.Count
  errors = $errors
  secret_hits = $secretHits
  local_file_writes = 0
  github_writes = 0
  network_install_attempts = 0
} | ConvertTo-Json -Depth 8

if ($status -ne 'PASS') { exit 1 }
