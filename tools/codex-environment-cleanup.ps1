[CmdletBinding()]
param(
  [string]$WorktreePath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$worktreeRoot = (Resolve-Path -LiteralPath $WorktreePath).Path
Set-Location $worktreeRoot

if (Get-Command docker -ErrorAction SilentlyContinue) {
  docker compose down --remove-orphans
}

$cacheTmp = [System.IO.Path]::GetFullPath((Join-Path $worktreeRoot '.cache/tmp'))
$worktreeFull = [System.IO.Path]::GetFullPath($worktreeRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
if ($cacheTmp.StartsWith($worktreeFull, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $cacheTmp)) {
  Remove-Item -LiteralPath $cacheTmp -Recurse -Force -ErrorAction SilentlyContinue
}
