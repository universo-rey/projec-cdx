param(
  [ValidateSet("all", "check", "agents")]
  [string]$Mode = "all",
  [string]$Agent = "All",
  [switch]$NoExternal,
  [switch]$DryRun,
  [switch]$Json
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$Resolver = Join-Path $Root "tools\sdu_chain_resolver.py"
$VenvPython = Join-Path $Root ".venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $Resolver -PathType Leaf)) {
  throw "No existe el resolvedor SDU: $Resolver"
}

if (Test-Path -LiteralPath $VenvPython -PathType Leaf) {
  $Python = $VenvPython
} else {
  $Python = "python"
}

$ArgsList = @(
  $Resolver,
  "--root", $Root,
  "--mode", $Mode,
  "--agent", $Agent
)

if ($NoExternal) {
  $ArgsList += "--no-external"
}

if ($DryRun) {
  $ArgsList += "--dry-run"
}

if ($Json) {
  $ArgsList += "--json"
}

& $Python @ArgsList
exit $LASTEXITCODE
