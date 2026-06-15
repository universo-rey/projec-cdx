[CmdletBinding()]
param(
  [string]$SourceTreePath = 'C:\Users\enzo1\PROJEC CDX',
  [string]$WorktreePath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$sourceRoot = (Resolve-Path -LiteralPath $SourceTreePath).Path
$worktreeRoot = (Resolve-Path -LiteralPath $WorktreePath).Path

Set-Location $worktreeRoot

$env:CODEX_SOURCE_TREE_PATH = $sourceRoot
$env:CODEX_WORKTREE_PATH = $worktreeRoot
$env:CODEX_CLOUD_REPO_ROOT = $sourceRoot
$env:CODEX_CLOUD_WORKTREE = $worktreeRoot

$branch = (git -C $worktreeRoot branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) { $branch = 'main' }
$env:CODEX_CLOUD_BRANCH = $branch

python -m pip install -e ".[dev,agents-sdk,openai-orchestration]"
pwsh -NoProfile -File ".\tools\codex-cloud-bootstrap.ps1" -RepoRoot $sourceRoot -WorkspaceRoot $worktreeRoot
