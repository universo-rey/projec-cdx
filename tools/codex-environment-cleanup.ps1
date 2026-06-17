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
Remove-Item -Recurse -Force '.cache\tmp' -ErrorAction SilentlyContinue
