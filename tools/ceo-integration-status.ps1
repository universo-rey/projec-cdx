param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$IndexPath = Join-Path $Root 'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_INDEX_20260623.json'
$MapPath = Join-Path $Root 'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv'
$ReadbackPath = Join-Path $Root 'operativa\tasks\20260623\READBACK_SENIOR_INTEGRATION_FABRIC_G1_20260623.md'

function Read-JsonFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        return [PSCustomObject]@{ parse_error = $_.Exception.Message }
    }
}

$index = Read-JsonFile -Path $IndexPath
$map = @()
if (Test-Path -LiteralPath $MapPath) {
    $map = @(Import-Csv -LiteralPath $MapPath)
}

$implemented = @()
if ($index -and $index.implemented_commands) {
    foreach ($commandPath in $index.implemented_commands) {
        $fullPath = Join-Path $Root $commandPath
        $implemented += [PSCustomObject]@{
            command = $commandPath
            exists = Test-Path -LiteralPath $fullPath
        }
    }
}

$gates = @()
if ($map.Count -gt 0) {
    $gates = @($map | Group-Object gate | Sort-Object Name | ForEach-Object {
        [PSCustomObject]@{
            gate = $_.Name
            count = $_.Count
        }
    })
}

$blockingWrites = @($map | Where-Object {
    $_.status -notin @('READY_LOCAL', 'CANDIDATE_METADATA_ONLY', 'CANDIDATE_BLUEPRINT_ONLY', 'CANDIDATE_NO_PUBLISH', 'CANDIDATE_NO_POST', 'CANDIDATE_GATE_REQUIRED')
})

$payload = [PSCustomObject]@{
    command = 'ceo-integration-status'
    status = if ($index -and -not $index.parse_error -and $map.Count -eq 8 -and (Test-Path -LiteralPath $ReadbackPath)) { 'SENIOR_INTEGRATION_FABRIC_READY_LOCAL_ONLY' } else { 'SENIOR_INTEGRATION_FABRIC_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    fabric_id = if ($index) { $index.fabric_id } else { $null }
    index_exists = Test-Path -LiteralPath $IndexPath
    map_exists = Test-Path -LiteralPath $MapPath
    readback_exists = Test-Path -LiteralPath $ReadbackPath
    node_count = $map.Count
    implemented_commands = $implemented
    gates = $gates
    blocking_writes = $blockingWrites
    frontier = if ($index) { $index.frontier } else {
        @{
            no_push = $true
            no_pr = $true
            no_live = $true
            no_secret_read = $true
        }
    }
    next_step = if ($index) { $index.next_step } else { $null }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 10
}
else {
    $payload
}
