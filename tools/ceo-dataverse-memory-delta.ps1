param(
    [switch] $Json,
    [string] $DeltaId = 'DATAVERSE_MEMORY_DELTA_20260623'
)

$Root = 'C:\CEO\project-cdx'
$IndexPath = Join-Path $Root 'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_INDEX_20260623.json'

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
$entities = @()
if ($index -and $index.dataverse_entities_metadata_only) {
    $entities = @($index.dataverse_entities_metadata_only)
}
else {
    $entities = @(
        'sdu_system',
        'sdu_agent',
        'sdu_skill',
        'sdu_recipe',
        'sdu_command',
        'sdu_gate',
        'sdu_evidence',
        'sdu_decision',
        'sdu_capability'
    )
}

$candidateRecords = @(
    [PSCustomObject]@{ table = 'sdu_system'; key = 'project-cdx'; action = 'UPSERT_CANDIDATE'; evidence = 'SENIOR_INTEGRATION_FABRIC_G1_INDEX_20260623.json' },
    [PSCustomObject]@{ table = 'sdu_integration_endpoint'; key = 'vscode-insiders'; action = 'UPSERT_CANDIDATE'; evidence = 'IDE_CONTROL_INDEX_G1_STEP1_20260623.json' },
    [PSCustomObject]@{ table = 'sdu_integration_endpoint'; key = 'github'; action = 'UPSERT_CANDIDATE'; evidence = 'SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv' },
    [PSCustomObject]@{ table = 'sdu_integration_endpoint'; key = 'dataverse'; action = 'UPSERT_CANDIDATE'; evidence = 'SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv' },
    [PSCustomObject]@{ table = 'sdu_integration_endpoint'; key = 'sharepoint'; action = 'UPSERT_CANDIDATE'; evidence = 'SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv' },
    [PSCustomObject]@{ table = 'sdu_capability'; key = 'senior-integration-fabric'; action = 'UPSERT_CANDIDATE'; evidence = 'READBACK_SENIOR_INTEGRATION_FABRIC_G1_20260623.md' }
)

$payload = [PSCustomObject]@{
    command = 'ceo-dataverse-memory-delta'
    status = 'DATAVERSE_MEMORY_DELTA_READY_METADATA_ONLY'
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    delta_id = $DeltaId
    mode = 'METADATA_ONLY_NO_TABLE_WRITE'
    gate = 'MEMORY_GATE'
    source_index_exists = Test-Path -LiteralPath $IndexPath
    entities = $entities
    candidate_records = $candidateRecords
    validation_required = @(
        'owner approval',
        'target environment',
        'rollback',
        'postcheck',
        'dry-run evidence'
    )
    frontier = [PSCustomObject]@{
        no_pac_execution = $true
        no_dataverse_write = $true
        no_table_mutation = $true
        no_secret_read = $true
        no_live = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 10
}
else {
    $payload
}
