param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$WaveId = '20260616-sdu-dataverse-metadata-wave-v1'
)

$ErrorActionPreference = 'Stop'

$hito = Join-Path $Root "hitos\$WaveId"
$required = @(
    'README.md',
    'MANIFEST.yaml',
    'READBACK.md',
    'EVIDENCIA.md',
    'INDICE.csv',
    'METADATA_HYDRATION_MATRIX.csv',
    'METADATA_HYDRATION_MATRIX.json',
    'ROLLBACK.md',
    'POSTCHECK.md',
    'STOP_CONDITIONS.md'
)

$status = 'PASS'

if (-not (Test-Path $hito)) {
    Write-Output "FAIL | hito_exists | $hito"
    exit 1
}

foreach ($file in $required) {
    $path = Join-Path $hito $file
    if (Test-Path $path) {
        Write-Output "PASS | required:$file | OK"
    } else {
        $status = 'FAIL'
        Write-Output "FAIL | required:$file | missing"
    }
}

$matrix = Join-Path $hito 'METADATA_HYDRATION_MATRIX.csv'
if (Test-Path $matrix) {
    $rows = @(Import-Csv $matrix)
    if ($rows.Count -gt 0) {
        Write-Output "PASS | matrix_rows | $($rows.Count)"
    } else {
        $status = 'FAIL'
        Write-Output "FAIL | matrix_rows | empty"
    }

    $badStatus = @($rows | Where-Object { $_.status -ne 'METADATA_ONLY_PREPARED' })
    if ($badStatus.Count -eq 0) {
        Write-Output "PASS | matrix_status | METADATA_ONLY_PREPARED"
    } else {
        $status = 'FAIL'
        Write-Output "FAIL | matrix_status | unexpected=$($badStatus.Count)"
    }
}

$planner = Join-Path $Root 'inventarios\PLANNER_TASKS_SANITIZED_COUNTS_20260616.csv'
if (Test-Path $planner) {
    $headers = ((Get-Content -LiteralPath $planner -First 1) -split ',') -replace '"',''
    if ($headers -contains 'plan_title') {
        $status = 'FAIL'
        Write-Output "FAIL | planner_sanitized | plan_title_present"
    } else {
        Write-Output "PASS | planner_sanitized | no_plan_title"
    }
}

if ($status -eq 'PASS') {
    Write-Output 'STATUS: PASS'
    exit 0
}

Write-Output 'STATUS: FAIL'
exit 1
