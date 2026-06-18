[CmdletBinding()]
param(
  [string]$SourceTreePath = 'C:/Users/enzo1/PROJEC CDX',
  [string]$WorktreePath = (Get-Location).Path,
  [string]$ReposRoot = 'C:/Users/enzo1/Documents/GitHub',
  [string]$CanonicalRepoRoot = 'C:/Users/enzo1/Documents/GitHub/cabina-universal-d',
  [string]$GitCommand = 'C:/Program Files/Git/cmd/git.exe',
  [string]$PythonCommand = 'C:/Users/enzo1/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe',
  [string]$PwshCommand = 'C:/Users/enzo1/AppData/Local/Microsoft/WindowsApps/pwsh.exe'
)

$ErrorActionPreference = 'Stop'

function ConvertTo-PortableWindowsPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return $Path.Replace('\', '/')
}

$sourceRoot = (Resolve-Path -LiteralPath $SourceTreePath).Path
$worktreeRoot = (Resolve-Path -LiteralPath $WorktreePath).Path
$reposRoot = (Resolve-Path -LiteralPath $ReposRoot).Path
$canonicalRepoRoot = (Resolve-Path -LiteralPath $CanonicalRepoRoot).Path
$sourceRootEnv = ConvertTo-PortableWindowsPath -Path $sourceRoot
$worktreeRootEnv = ConvertTo-PortableWindowsPath -Path $worktreeRoot
$reposRootEnv = ConvertTo-PortableWindowsPath -Path $reposRoot
$canonicalRepoRootEnv = ConvertTo-PortableWindowsPath -Path $canonicalRepoRoot

Set-Location $worktreeRoot

foreach ($requiredPath in @($GitCommand, $PythonCommand, $PwshCommand)) {
  if (-not (Test-Path -LiteralPath $requiredPath)) {
    throw "No se encontro el ejecutable requerido: $requiredPath"
  }
}

$env:CODEX_SOURCE_TREE_PATH = $sourceRootEnv
$env:CODEX_WORKTREE_PATH = $worktreeRootEnv
$env:CODEX_REPOS_ROOT = $reposRootEnv
$env:CODEX_CABINA_REPO_ROOT = $canonicalRepoRootEnv
$env:CODEX_WORKBENCH_ROOT = $sourceRootEnv
$env:CODEX_METADATA_ROOT = $sourceRootEnv
$env:CODEX_CLOUD_REPO_ROOT = $canonicalRepoRootEnv
$env:CODEX_CLOUD_METADATA_ROOT = $sourceRootEnv
$env:CODEX_CLOUD_WORKTREE = $worktreeRootEnv

$branch = (& $GitCommand -C $worktreeRoot branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) { $branch = 'main' }
$env:CODEX_CLOUD_BRANCH = $branch

& $PythonCommand -m pip install -e ".[dev,agents-sdk,openai-orchestration]"
$bootstrapScript = Join-Path $sourceRoot 'tools/codex-cloud-bootstrap.ps1'
& $PwshCommand -NoProfile -File $bootstrapScript -RepoRoot $canonicalRepoRootEnv -MetadataRoot $sourceRootEnv -WorkspaceRoot $worktreeRootEnv -GitCommand $GitCommand
