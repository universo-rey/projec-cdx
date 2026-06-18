[CmdletBinding()]
param(
  [string]$RepoRoot = '',
  [string]$Prompt = 'Resume el estado del carril Codex Cloud con energia atomica.',
  [string]$Model = $env:OPENAI_MODEL
)

# MANUAL-ONLY: local/cloud agent invocation. Do not run from CI or automation without explicit approval.

$ErrorActionPreference = 'Stop'

function Resolve-ProjectRoot {
  param([Parameter(Mandatory = $true)][string]$BaseRoot)

  $candidates = New-Object System.Collections.Generic.List[string]
  $candidates.Add($BaseRoot)

  $gitWorktrees = & git -C $BaseRoot worktree list --porcelain 2>$null
  if ($gitWorktrees) {
    foreach ($line in ($gitWorktrees -split [Environment]::NewLine)) {
      if ($line.StartsWith('worktree ')) {
        $candidate = $line.Substring(9).Trim()
        if ($candidate -and -not $candidates.Contains($candidate)) {
          $candidates.Add($candidate)
        }
      }
    }
  }

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath (Join-Path $candidate 'src/projec_cdx_cloud/__init__.py')) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  throw "No se encontro una raiz con src/projec_cdx_cloud en $BaseRoot ni en sus worktrees."
}

function Resolve-PythonExe {
  param([Parameter(Mandatory = $true)][string]$ProjectRoot)

  $candidate = Join-Path $ProjectRoot '.venv/Scripts/python.exe'
  if (Test-Path -LiteralPath $candidate) {
    return $candidate
  }

  $gitWorktrees = & git -C $ProjectRoot worktree list --porcelain 2>$null
  if ($gitWorktrees) {
    foreach ($line in ($gitWorktrees -split [Environment]::NewLine)) {
      if ($line.StartsWith('worktree ')) {
        $worktreeRoot = $line.Substring(9).Trim()
        $candidate = Join-Path $worktreeRoot '.venv/Scripts/python.exe'
        if (Test-Path -LiteralPath $candidate) {
          return $candidate
        }
      }
    }
  }

  throw "No se encontro un python ejecutable en una .venv asociada a $ProjectRoot."
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
} else {
  $repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
}

$projectRoot = Resolve-ProjectRoot -BaseRoot $repoRoot
$python = Resolve-PythonExe -ProjectRoot $projectRoot

if ([string]::IsNullOrWhiteSpace($Model)) {
  $Model = 'gpt-5.5'
}

Set-Location $projectRoot

$env:CODEX_CLOUD_ENABLED = '1'
$env:CODEX_CLOUD_MODE = 'cloud'
$env:CODEX_CLOUD_GATE = 'metadata-only'

& $python -m projec_cdx_cloud --prompt $Prompt --model $Model
exit $LASTEXITCODE
