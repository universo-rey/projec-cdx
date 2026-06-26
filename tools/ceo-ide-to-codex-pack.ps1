param(
    [switch] $Json,
    [string] $Lane = 'senior-integration-fabric',
    [string] $OrderId = 'IDE_TO_CODEX_PACKET_20260623'
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

function Get-ArtifactStatus {
    param([string] $RelativePath)

    $fullPath = Join-Path $Root $RelativePath
    [PSCustomObject]@{
        path = $RelativePath.Replace('\', '/')
        exists = Test-Path -LiteralPath $fullPath
    }
}

$sources = @(
    'operativa\tasks\20260623\IDE_CONTROL_INDEX_G1_STEP1_20260623.json',
    'operativa\tasks\20260623\IDE_SKILL_RECIPE_PROMOTION_PACK_G1_INDEX_20260623.json',
    'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_INDEX_20260623.json',
    'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv'
)

$sourceStatus = @($sources | ForEach-Object { Get-ArtifactStatus -RelativePath $_ })
$missing = @($sourceStatus | Where-Object { -not $_.exists })

$payload = [PSCustomObject]@{
    command = 'ceo-ide-to-codex-pack'
    status = if ($missing.Count -eq 0) { 'IDE_TO_CODEX_PACKET_READY' } else { 'IDE_TO_CODEX_PACKET_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    packet = [PSCustomObject]@{
        order_id = $OrderId
        lane = $Lane
        contract = 'IDE_TO_CODEX'
        mode = 'PACKET_ONLY_NO_EXECUTION'
        gate = 'AGENT_GATE'
        owner_agent = 'CODEX_CLOUD_OPERATOR'
        input = 'orden normalizada + carril + limites + evidencia esperada'
        output = 'propuesta tecnica + diff/readback + riesgos + siguiente accion'
        evidence_expected = @(
            'readback tecnico local',
            'matriz de decisiones',
            'diff propuesto o paquete manual',
            'postcheck local'
        )
        limits = [PSCustomObject]@{
            no_external_execution = $true
            no_openai_api_call = $true
            no_codex_cloud_execution = $true
            no_secret_read = $true
            no_push = $true
            no_pr = $true
            no_live = $true
        }
    }
    agents = @(
        'THOT_INTEGRATION_ARCHITECT',
        'ANUBIS_GATE',
        'MAAT_COMPLIANCE_TRACE',
        'SESHAT_GOVERNANCE_EVIDENCE',
        'HORUS_RISK_SIGNAL'
    )
    source_artifacts = $sourceStatus
    missing_artifacts = $missing
    suggested_task = 'CEO: IDE to Codex Pack'
    next_action = 'usar este packet como entrada local antes de cualquier ejecucion Codex Cloud'
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
