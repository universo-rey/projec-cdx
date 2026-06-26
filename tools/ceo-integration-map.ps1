param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$IndexPath = Join-Path $Root 'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_INDEX_20260623.json'
$MapPath = Join-Path $Root 'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv'

function Read-JsonFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

$index = Read-JsonFile -Path $IndexPath
$map = @()
if (Test-Path -LiteralPath $MapPath) {
    $map = @(Import-Csv -LiteralPath $MapPath)
}

$payload = [PSCustomObject]@{
    command = 'ceo-integration-map'
    status = if ($index -and $map.Count -gt 0) { 'INTEGRATION_MAP_READY' } else { 'INTEGRATION_MAP_MISSING' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    fabric_id = if ($index) { $index.fabric_id } else { $null }
    fabric_status = if ($index) { $index.status } else { $null }
    node_count = $map.Count
    nodes = $map
    contracts = if ($index) { $index.contracts } else { @() }
    commands = if ($index) { $index.commands } else { @() }
    tasks = if ($index) { $index.tasks } else { @() }
    frontier = if ($index) { $index.frontier } else {
        @{
            no_push = $true
            no_pr = $true
            no_live = $true
            no_secret_read = $true
        }
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
