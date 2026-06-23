param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Python = Join-Path $Root ".venv\Scripts\python.exe"
if (-not (Test-Path -LiteralPath $Python)) {
    $Python = "python"
}

$oldPythonPath = $env:PYTHONPATH
$env:PYTHONPATH = "$Root\src;$Root"
try {
    & $Python -m runtime_versioning.cli --root $Root restore @Args
    exit $LASTEXITCODE
}
finally {
    $env:PYTHONPATH = $oldPythonPath
}
