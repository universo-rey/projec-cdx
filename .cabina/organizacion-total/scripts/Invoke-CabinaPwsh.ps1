param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs = @()
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Script not found: $ScriptPath"
}

$resolvedScript = (Resolve-Path -LiteralPath $ScriptPath).Path

& pwsh -NoProfile -ExecutionPolicy Bypass -File $resolvedScript @ScriptArgs
exit $LASTEXITCODE
