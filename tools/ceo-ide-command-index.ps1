param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$Tools = Join-Path $Root 'tools'
$TasksPath = Join-Path $Root '.vscode\tasks.json'
$Python = Join-Path $Root '.venv\Scripts\python.exe'

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

function Get-ToolPath {
    param([string] $Name)

    $path = Join-Path $Tools $Name
    if (Test-Path -LiteralPath $path) {
        return $path
    }

    return $null
}

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    return $Path.Replace($Root + '\', '').Replace('\', '/')
}

$taskLabels = @()
if ((Test-JsonFile -Path $TasksPath) -eq 'ok') {
    $taskLabels = @((Get-Content -LiteralPath $TasksPath -Raw | ConvertFrom-Json).tasks | ForEach-Object { $_.label })
}

$ceoTools = @(Get-ChildItem -LiteralPath $Tools -File -Filter 'ceo-*' -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object {
        [PSCustomObject]@{
            name = $_.BaseName
            file = Get-RepoPath -Path $_.FullName
            extension = $_.Extension
            command_kind = 'repo_tool'
            status = 'READY'
        }
    })

$paletteSpec = @(
    @{ slot = 'status'; task = 'CEO Command: Status'; file = 'ceo-vscode-insiders-status.ps1'; args = @('-Json'); capability = 'Estado rapido IDE' },
    @{ slot = 'workspace'; task = 'CEO IDE: Workspace Control'; file = 'ceo-ide-workspace-status.ps1'; args = @('-Json'); capability = 'Workspace Governance' },
    @{ slot = 'workspace-reconcile'; task = 'CEO IDE: Workspace Reconcile'; file = 'ceo-ide-workspace-reconcile.ps1'; args = @('-Json'); capability = 'Workspace Identity Reconciliation' },
    @{ slot = 'local-reconcile'; task = 'CEO Local: Reconcile All'; file = 'ceo-local-reconcile.ps1'; args = @('-Mode', 'all', '-Json'); capability = 'Local File Reconciliation' },
    @{ slot = 'local-inventory'; task = 'CEO Local: Inventory'; file = 'ceo-local-inventory.ps1'; args = @('-Json'); capability = 'Local File Inventory' },
    @{ slot = 'local-classify'; task = 'CEO Local: Classify'; file = 'ceo-local-classify.ps1'; args = @('-Json'); capability = 'Local File Classification' },
    @{ slot = 'repo-boundary-map'; task = 'CEO Local: Repo Boundary Map'; file = 'ceo-repo-boundary-map.ps1'; args = @('-Json'); capability = 'Repo Boundary Map' },
    @{ slot = 'agent-assets-map'; task = 'CEO Local: Agent Assets Map'; file = 'ceo-agent-assets-map.ps1'; args = @('-Json'); capability = 'Agent Assets Map' },
    @{ slot = 'sdk-assets-map'; task = 'CEO Local: SDK Assets Map'; file = 'ceo-sdk-assets-map.ps1'; args = @('-Json'); capability = 'SDK Assets Map' },
    @{ slot = 'noise-plan'; task = 'CEO Local: Noise Plan'; file = 'ceo-noise-plan.ps1'; args = @('-Json'); capability = 'Noise Reduction Plan' },
    @{ slot = 'cleanup-dryrun'; task = 'CEO Local: Cleanup DryRun'; file = 'ceo-cleanup-dryrun.ps1'; args = @('-Json'); capability = 'Cleanup DryRun' },
    @{ slot = 'cleanup-gate-status'; task = 'CEO Local: Cleanup Gate Status'; file = 'ceo-cleanup-gate-status.ps1'; args = @('-Json'); capability = 'Cleanup Gate Status' },
    @{ slot = 'terminal'; task = 'CEO IDE: Terminal Status'; file = 'ceo-ide-terminal-status.ps1'; args = @('-Json'); capability = 'Governed IDE Terminal' },
    @{ slot = 'doctor'; task = 'CEO Command: Doctor'; file = 'ceo-cabina-doctor.ps1'; args = @('-Json'); capability = 'Cabina Doctor' },
    @{ slot = 'watchdog'; task = 'CEO Command: Watchdog'; file = 'ceo-runtime-sentinel.ps1'; args = @('--json'); capability = 'Runtime Sentinel' },
    @{ slot = 'telemetry'; task = 'CEO Command: Telemetry'; file = 'ceo-runtime-state.ps1'; args = @('--json'); capability = 'Runtime State' },
    @{ slot = 'validate'; task = 'CEO Command: Validate Metadata'; file = $null; args = @('-m', 'tools.validate'); capability = 'Metadata Validate' },
    @{ slot = 'agent-map'; task = 'CEO Command: Agent Map'; file = 'ceo-agent-map.ps1'; args = @('-Json'); capability = 'Agent Chain Map' },
    @{ slot = 'mcp-status'; task = 'CEO Command: MCP Status'; file = 'ceo-mcp-status.ps1'; args = @('-Json'); capability = 'MCP Hub Status' },
    @{ slot = 'integration-map'; task = 'CEO: Integration Map'; file = 'ceo-integration-map.ps1'; args = @('-Json'); capability = 'Senior Integration Fabric Map' },
    @{ slot = 'integration-status'; task = 'CEO: Integration Status'; file = 'ceo-integration-status.ps1'; args = @('-Json'); capability = 'Senior Integration Fabric Status' },
    @{ slot = 'ide-to-codex-pack'; task = 'CEO: IDE to Codex Pack'; file = 'ceo-ide-to-codex-pack.ps1'; args = @('-Json'); capability = 'IDE to Codex Packet Generator' },
    @{ slot = 'github-pr-pack'; task = 'CEO: GitHub PR Pack'; file = 'ceo-github-pr-pack.ps1'; args = @('-Json'); capability = 'GitHub PR Packet Generator' },
    @{ slot = 'dataverse-memory-delta'; task = 'CEO: Dataverse Memory Delta'; file = 'ceo-dataverse-memory-delta.ps1'; args = @('-Json'); capability = 'Dataverse Metadata Delta' },
    @{ slot = 'dataverse-status'; task = 'CEO: Dataverse Status'; file = 'ceo-dataverse-status.ps1'; args = @('-Json'); capability = 'Dataverse Live Read Status' },
    @{ slot = 'dataverse-solutions'; task = 'CEO: Dataverse Solutions'; file = 'ceo-dataverse-solutions.ps1'; args = @('-Json'); capability = 'Dataverse Solution Inventory' },
    @{ slot = 'dataverse-tables'; task = 'CEO: Dataverse Tables'; file = 'ceo-dataverse-tables.ps1'; args = @('-Json'); capability = 'Dataverse Table Inventory' },
    @{ slot = 'dataverse-schema'; task = 'CEO: Dataverse Schema'; file = 'ceo-dataverse-schema.ps1'; args = @('-Json'); capability = 'Dataverse Schema Snapshot' },
    @{ slot = 'dataverse-records'; task = 'CEO: Dataverse Records'; file = 'ceo-dataverse-records.ps1'; args = @('-Json'); capability = 'Dataverse Sanitized Row Samples' },
    @{ slot = 'dataverse-memory'; task = 'CEO: Dataverse Memory'; file = 'ceo-dataverse-memory.ps1'; args = @('-Json'); capability = 'Dataverse Usable Memory Map' },
    @{ slot = 'dataverse-canon-delta'; task = 'CEO: Dataverse Canon Delta'; file = 'ceo-dataverse-canon-delta.ps1'; args = @('-Json'); capability = 'Dataverse Canon Drift Map' },
    @{ slot = 'cabina-exec-status'; task = 'CEO: Cabina Exec Status'; file = 'ceo-cabina-exec-status.ps1'; args = @('-Json'); capability = 'Cabina Execution Surface' },
    @{ slot = 'repo-fleet-scan'; task = 'CEO: Repo Fleet Scan'; file = 'ceo-repo-fleet-scan.ps1'; args = @('-Json'); capability = 'Repo Fleet Discovery' },
    @{ slot = 'repo-fleet-map'; task = 'CEO: Repo Fleet Map'; file = 'ceo-repo-fleet-map.ps1'; args = @('-Json'); capability = 'Repo Fleet Map' },
    @{ slot = 'agent-reconcile'; task = 'CEO: Agent Reconcile'; file = 'ceo-agent-reconcile.ps1'; args = @('-Json'); capability = 'Agent Reconciliation' },
    @{ slot = 'agent-duplicates'; task = 'CEO: Agent Duplicates'; file = 'ceo-agent-duplicates.ps1'; args = @('-Json'); capability = 'Agent Duplicate Review' },
    @{ slot = 'sdk-status'; task = 'CEO: SDK Status'; file = 'ceo-sdk-status.ps1'; args = @('-Json'); capability = 'SDK Active Use' },
    @{ slot = 'sdk-agent-routes'; task = 'CEO: SDK Agent Routes'; file = 'ceo-sdk-agent-routes.ps1'; args = @('-Json'); capability = 'SDK Agent Routes' },
    @{ slot = 'dataverse-active-memory'; task = 'CEO: Dataverse Active Memory'; file = 'ceo-dataverse-active-memory.ps1'; args = @('-Json'); capability = 'Dataverse Active Memory' },
    @{ slot = 'cabina-capability-map'; task = 'CEO: Cabina Capability Map'; file = 'ceo-cabina-capability-map.ps1'; args = @('-Json'); capability = 'Cabina Capability Map' },
    @{ slot = 'cabina-next-action'; task = 'CEO: Cabina Next Action'; file = 'ceo-cabina-next-action.ps1'; args = @('-Json'); capability = 'Cabina Next Action' },
    @{ slot = 'sharepoint-evidence-pack'; task = 'CEO: SharePoint Evidence Pack'; file = 'ceo-sharepoint-evidence-pack.ps1'; args = @('-Json'); capability = 'SharePoint Evidence Pack' },
    @{ slot = 'integration-gates-status'; task = 'CEO: Integration Gates Status'; file = 'ceo-integration-gates-status.ps1'; args = @('-Json'); capability = 'Integration Gates Status' },
    @{ slot = 'ide-agent-map'; task = 'CEO IDE: Agent Map'; file = 'ceo-ide-agent-map.ps1'; args = @('-Json'); capability = 'IDE Agent Tool Hub' },
    @{ slot = 'ide-mcp-status'; task = 'CEO IDE: MCP Status'; file = 'ceo-ide-mcp-status.ps1'; args = @('-Json'); capability = 'IDE MCP Hub Status' },
    @{ slot = 'ide-extension-list'; task = 'CEO IDE: Extension List'; file = 'ceo-ide-extension-list.ps1'; args = @('-Json'); capability = 'IDE Extension Inventory' },
    @{ slot = 'ide-extension-policy'; task = 'CEO IDE: Extension Policy'; file = 'ceo-ide-extension-policy.ps1'; args = @('-Json'); capability = 'Extension Policy' },
    @{ slot = 'ide-evidence-status'; task = 'CEO IDE: Evidence Status'; file = 'ceo-ide-evidence-status.ps1'; args = @('-Json'); capability = 'IDE Evidence Capture' },
    @{ slot = 'ide-telemetry-status'; task = 'CEO IDE: Telemetry Status'; file = 'ceo-ide-telemetry-status.ps1'; args = @('-Json'); capability = 'IDE Telemetry Status' },
    @{ slot = 'remote-ready'; task = 'CEO Command: Remote Ready'; file = $null; args = @(); capability = 'Remote Publication Readiness' }
)

$palette = foreach ($item in $paletteSpec) {
    $commandPath = if ($item.file) { Get-ToolPath -Name $item.file } elseif ($item.slot -eq 'validate') { $Python } else { $null }
    $status = if ($commandPath -and ($taskLabels -contains $item.task)) {
        'READY'
    }
    elseif ($commandPath) {
        'COMMAND_READY_TASK_MISSING'
    }
    elseif ($item.slot -eq 'remote-ready') {
        'CANDIDATE_MISSING'
    }
    else {
        'MISSING'
    }

    [PSCustomObject]@{
        slot = $item.slot
        task_label = $item.task
        capability = $item.capability
        status = $status
        command = if ($item.slot -eq 'validate') { Get-RepoPath -Path $Python } elseif ($commandPath) { Get-RepoPath -Path $commandPath } else { $null }
        args = $item.args
        risk = if ($item.slot -eq 'remote-ready') { 'needs_explicit_delta' } else { 'local_read_or_validation' }
    }
}

$toolNames = @($ceoTools | ForEach-Object { $_.name })
$usefulScriptsWithoutCeoCommand = @(Get-ChildItem -LiteralPath $Tools -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -notlike 'ceo-*' -and
        $_.Extension -in @('.ps1', '.py') -and
        $_.Name -match 'sentinel|remediation|validate|remote|runtime|sdu|chain'
    } |
    Sort-Object Name |
    ForEach-Object {
        $mapped = switch -Regex ($_.Name) {
            '^sdu_sentinel\.py$' { 'CEO Command: Watchdog'; break }
            '^sdu_auto_remediation\.py$' { 'candidate: remediation-status'; break }
            '^validate\.py$' { 'CEO Command: Validate Metadata'; break }
            '^sdu_chain_resolver\.py$' { 'candidate: chain-resolver-status'; break }
            default { 'unmapped' }
        }
        [PSCustomObject]@{
            script = Get-RepoPath -Path $_.FullName
            status = if ($mapped -eq 'unmapped') { 'USEFUL_WITHOUT_COMMAND' } else { 'MAPPED_OR_CANDIDATE' }
            mapped_to = $mapped
        }
    })

$missingCritical = @($palette | Where-Object { $_.status -in @('MISSING', 'CANDIDATE_MISSING', 'COMMAND_READY_TASK_MISSING') })

$payload = [PSCustomObject]@{
    command = 'ceo-ide-command-index'
    status = if ($missingCritical.Count -eq 0 -or (@($missingCritical | Where-Object { $_.slot -ne 'remote-ready' }).Count -eq 0)) { 'IDE_COMMAND_SURFACE_READY' } else { 'IDE_COMMAND_SURFACE_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    ceo_tools_count = $ceoTools.Count
    ceo_tools = $ceoTools
    tasks_count = $taskLabels.Count
    command_palette = $palette
    critical_not_accessible = $missingCritical
    useful_scripts_without_ceo_command = $usefulScriptsWithoutCeoCommand
    frontera = @{
        no_write = $true
        no_secret_read = $true
        no_live = $true
        no_push = $true
        no_pr = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 10
}
else {
    $payload
}
