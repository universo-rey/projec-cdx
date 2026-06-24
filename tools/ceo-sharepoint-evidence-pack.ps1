param(
    [switch] $Json,
    [string] $PackId = 'SHAREPOINT_EVIDENCE_PACK_20260623'
)

$Root = 'C:\CEO\project-cdx'
$TaskRoot = Join-Path $Root 'operativa\tasks\20260623'

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    return $Path.Replace($Root + '\', '').Replace('\', '/')
}

$evidence = @()
if (Test-Path -LiteralPath $TaskRoot) {
    $evidence = @(Get-ChildItem -LiteralPath $TaskRoot -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -like 'READBACK_SENIOR_INTEGRATION_FABRIC_G1*' -or
            $_.Name -like 'SENIOR_INTEGRATION_FABRIC_G1*' -or
            $_.Name -like 'IDE_CONTROL_INDEX_G1_STEP1*' -or
            $_.Name -like 'IDE_SKILL_RECIPE_PROMOTION_PACK_G1*'
        } |
        Sort-Object Name |
        ForEach-Object {
            [PSCustomObject]@{
                path = Get-RepoPath -Path $_.FullName
                kind = if ($_.Extension -eq '.md') { 'readback' } elseif ($_.Extension -eq '.csv') { 'matrix' } elseif ($_.Extension -eq '.json') { 'index_or_metadata' } else { 'artifact' }
                bytes = $_.Length
            }
        })
}

$payload = [PSCustomObject]@{
    command = 'ceo-sharepoint-evidence-pack'
    status = if ($evidence.Count -gt 0) { 'SHAREPOINT_EVIDENCE_PACK_READY_NO_PUBLISH' } else { 'SHAREPOINT_EVIDENCE_PACK_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    pack_id = $PackId
    mode = 'PACK_ONLY_NO_SHAREPOINT_PUBLISH'
    gate = 'GOVERNANCE_GATE'
    page_candidates = @(
        'Pagina Madre: Cabina Senior Integration Fabric',
        'Bitacora: Integracion G1',
        'Lista: Integration Gates',
        'Lista: Integration Evidence',
        'Biblioteca: Runbooks Cabina',
        'Biblioteca: Evidence Packs'
    )
    evidence_files = $evidence
    publish_decision = 'BLOCKED_WITHOUT_OWNER_GATE'
    frontier = [PSCustomObject]@{
        no_sharepoint_publish = $true
        no_list_mutation = $true
        no_file_upload = $true
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

$global:LASTEXITCODE = 0
