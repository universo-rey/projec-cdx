param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$ContractPath = Join-Path $Root '.cabina\SDU_RUNTIME_ROOT\05_CONFIG\cabina-contract.v1.json'
$TasksPath = Join-Path $Root '.vscode\tasks.json'

function Test-JsonFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return 'missing'
    }

    try {
        Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json > $null
        return 'ok'
    }
    catch {
        return 'parse_error'
    }
}

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $Path.Replace($Root + '\', '').Replace('\', '/')
}

function Get-ToolMapping {
    param([string] $ToolName)

    switch -Regex ($ToolName) {
        'cabina-doctor' { return @('THOT_IDE_CONTROL', 'RUN_SUPPORT_IDE', 'CABINA_DOCTOR', 'runtime_diagnosis') }
        'command' { return @('THOT_IDE_CONTROL', 'MAAT_IDE_COMPLIANCE', 'COMMAND_FACTORY', 'command_surface') }
        'agent-map' { return @('SESHAT_IDE_EVIDENCE', 'THOT_IDE_CONTROL', 'AGENT_CHAIN_FACTORY', 'agent_map') }
        'mcp' { return @('ANUBIS_IDE_GATE', 'THOT_IDE_CONTROL', 'MCP_HUB', 'mcp_status_no_execution') }
        'terminal' { return @('THOT_IDE_CONTROL', 'ANUBIS_IDE_GATE', 'IDE_TERMINAL_CONTROL', 'governed_terminal') }
        'workspace' { return @('THOT_IDE_CONTROL', 'HORUS_IDE_SIGNAL', 'IDE_WORKSPACE_CONTROL', 'workspace_governance') }
        'runtime|sentinel' { return @('SENTINEL_RUNTIME', 'HORUS_IDE_SIGNAL', 'RUNTIME_WATCHDOG', 'drift_watchdog') }
        'intelligence' { return @('HORUS_IDE_SIGNAL', 'NARRADOR_IDE', 'INTELLIGENCE_LOOP', 'pattern_promotion') }
        default { return @('THOT_IDE_CONTROL', 'MAAT_IDE_COMPLIANCE', 'IDE_COMMAND_CONTROL', 'tool_observed') }
    }
}

$contractState = Test-JsonFile -Path $ContractPath
$contractAgents = @()
$requiredCarriles = @()
if ($contractState -eq 'ok') {
    $contract = Get-Content -LiteralPath $ContractPath -Raw | ConvertFrom-Json
    $contractAgents = @($contract.agents | ForEach-Object {
            [PSCustomObject]@{
                agent_id = $_.agent_id
                role = $_.role
                responsibilities = @($_.responsibilities)
                source = Get-RepoPath -Path $ContractPath
                status = 'CONFIGURED'
            }
        })
    $requiredCarriles = @($contract.required_carriles)
}

$taskLabels = @()
if ((Test-JsonFile -Path $TasksPath) -eq 'ok') {
    $taskLabels = @((Get-Content -LiteralPath $TasksPath -Raw | ConvertFrom-Json).tasks | ForEach-Object { $_.label })
}

$tools = @(Get-ChildItem -LiteralPath (Join-Path $Root 'tools') -File -Filter 'ceo-*' -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object {
        $mapping = Get-ToolMapping -ToolName $_.BaseName
        [PSCustomObject]@{
            tool = $_.BaseName
            path = Get-RepoPath -Path $_.FullName
            owner_agent = $mapping[0]
            reviewer_agent = $mapping[1]
            carril = $mapping[2]
            use = $mapping[3]
            state = 'AVAILABLE'
        }
    })

$runnerTasks = @(
    @{ runner = 'agent-map'; task = 'CEO IDE: Agent Map'; mode = 'MAP_ONLY_NO_LIVE_DISPATCH' },
    @{ runner = 'mcp-status'; task = 'CEO IDE: MCP Status'; mode = 'STATUS_ONLY_NO_MCP_EXECUTION' },
    @{ runner = 'agent-chain-factory'; task = 'CEO G1: Agent Chain Factory'; mode = 'LOCAL_FACTORY' },
    @{ runner = 'command-test'; task = 'CEO Command: Test'; mode = 'LOCAL_VALIDATION' }
) | ForEach-Object {
    [PSCustomObject]@{
        runner = $_.runner
        task = $_.task
        mode = $_.mode
        state = if ($taskLabels -contains $_.task) { 'INVOCABLE_FROM_IDE' } else { 'TASK_MISSING' }
    }
}

$connections = @(
    [PSCustomObject]@{ tool = 'ceo-ide-agent-map'; agent = 'SESHAT_IDE_EVIDENCE'; carril = 'IDE_AGENT_MCP_CONTROL'; use = 'indice_conexiones_agentes'; gate = 'none_local_read' },
    [PSCustomObject]@{ tool = 'ceo-ide-mcp-status'; agent = 'ANUBIS_IDE_GATE'; carril = 'IDE_AGENT_MCP_CONTROL'; use = 'mcp_status_sanitizado'; gate = 'none_status_only' },
    [PSCustomObject]@{ tool = 'ceo-agent-map'; agent = 'THOT_IDE_CONTROL'; carril = 'AGENT_CHAIN_FACTORY'; use = 'contrato_agentes'; gate = 'none_local_read' },
    [PSCustomObject]@{ tool = 'ceo-mcp-status'; agent = 'ANUBIS_IDE_GATE'; carril = 'MCP_HUB'; use = 'mcp_status_base'; gate = 'none_status_only' },
    [PSCustomObject]@{ tool = 'ceo-command-index'; agent = 'THOT_IDE_CONTROL'; carril = 'COMMAND_FACTORY'; use = 'scripts_comandos'; gate = 'none_local_read' },
    [PSCustomObject]@{ tool = 'ceo-ide-command-test'; agent = 'MAAT_IDE_COMPLIANCE'; carril = 'IDE_COMMAND_CONTROL'; use = 'validacion_surface'; gate = 'none_local_validation' }
)

$missingGovernanceMatrices = @(
    '.agents/codex/matrices/REPO_AGENT_TOOL_GOVERNANCE_MATRIX.csv',
    '.agents/codex/matrices/REPO_GOVERNANCE_ASSIGNMENT_MATRIX.csv',
    '.agents/codex/matrices/AGENT_GOVERNANCE_MATRIX.csv',
    '.agents/codex/matrices/TOOL_GOVERNANCE_MATRIX.csv',
    '.agents/codex/maps/SURFACE_BOUNDARY_MAP.csv'
) | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Root $_.Replace('/', '\'))) }

$status = if ($contractAgents.Count -gt 0 -and @($runnerTasks | Where-Object { $_.state -eq 'TASK_MISSING' }).Count -eq 0) {
    'IDE_AGENT_MAP_READY'
}
else {
    'IDE_AGENT_MAP_WARN'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-agent-map'
    status = $status
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    contract = @{
        path = Get-RepoPath -Path $ContractPath
        state = $contractState
        agent_count = $contractAgents.Count
        carril_count = $requiredCarriles.Count
    }
    agents = $contractAgents
    carriles = $requiredCarriles
    tools = $tools
    runners = $runnerTasks
    connections = $connections
    governance_matrices = @{
        missing = $missingGovernanceMatrices
        state = if ($missingGovernanceMatrices.Count -eq 0) { 'AVAILABLE' } else { 'NO_DISPONIBLE_LOCAL' }
    }
    frontera = @{
        map_only = $true
        no_agent_live_dispatch = $true
        no_mcp_execution = $true
        no_secret_read = $true
        no_live = $true
        no_push = $true
        no_pr = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
