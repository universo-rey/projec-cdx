param(
    [string] $Path,
    [string] $JsonFile,
    [string] $SchemaFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

if (-not [string]::IsNullOrWhiteSpace($Path)) {
    $target = Resolve-CeoSuitePath -Path $Path
    $files = @(Get-ChildItem -LiteralPath $target -Recurse -File -Filter "*.json" -ErrorAction SilentlyContinue)
    $errors = @()
    foreach ($file in $files) {
        try {
            Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json | Out-Null
        }
        catch {
            $errors += "$($file.FullName):$($_.Exception.Message)"
        }
    }

    [ordered]@{
        valid = ($errors.Count -eq 0)
        path = $Path
        checked = $files.Count
        errors = @($errors)
    } | ConvertTo-Json -Depth 6

    if ($errors.Count -eq 0) { exit 0 }
    exit 10
}

if ([string]::IsNullOrWhiteSpace($JsonFile) -or [string]::IsNullOrWhiteSpace($SchemaFile)) {
    throw "JsonFile and SchemaFile are required unless -Path is provided."
}

$result = Test-CeoJsonFileAgainstSchema -JsonFile $JsonFile -SchemaFile $SchemaFile
Write-Output $result.Status
exit $result.ExitCode
