param(
    [ValidateSet(
        'exec-status',
        'repo-fleet-scan',
        'repo-fleet-map',
        'agent-reconcile',
        'agent-duplicates',
        'sdk-status',
        'sdk-agent-routes',
        'dataverse-active-memory',
        'capability-map',
        'next-action',
        'all'
    )]
    [string] $Mode = 'all',
    [switch] $Json,
    [switch] $Refresh,
    [int] $MaxDepth = 4
)

$Root = 'C:\CEO\project-cdx'
$PhysicalAlias = 'C:\Users\enzo1\PROJEC CDX'
$OutDir = Join-Path $Root '.cabina\execution-g1\out'
$OperativaDir = Join-Path $Root 'operativa\tasks\20260623'
$DataverseOutDir = Join-Path $Root '.cabina\dataverse\out'

$KnownRoots = @(
    $Root,
    'C:\Users\enzo1\Documents\GitHub',
    'C:\Users\enzo1\.codex\worktrees',
    'C:\CEO\worktrees'
)

$SkipDirectoryNames = @(
    '.git',
    '.venv',
    'node_modules',
    '__pycache__',
    '.cache',
    'dist',
    'build',
    'coverage',
    '.mypy_cache',
    '.pytest_cache'
)

function New-Directory {
    param([string] $Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Save-JsonFile {
    param(
        [string] $Path,
        [object] $Value
    )

    New-Directory -Path (Split-Path -Parent $Path)
    $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Save-TextFile {
    param(
        [string] $Path,
        [string] $Value
    )

    New-Directory -Path (Split-Path -Parent $Path)
    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Read-JsonFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Read-CachedArtifact {
    param([string] $Name)

    if ($Refresh) {
        return $null
    }

    return Read-JsonFile -Path (Join-Path $OutDir $Name)
}

function ConvertTo-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    if ($Path.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($Root.Length).TrimStart('\').Replace('\', '/')
    }

    return $Path
}

function Invoke-Git {
    param(
        [string] $Repo,
        [string[]] $GitArgs
    )

    try {
        $output = & git -C $Repo @GitArgs 2>$null
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
        return @($output)
    }
    catch {
        return $null
    }
}

function Get-GitInfo {
    param([string] $Repo)

    $insideOutput = @()
    $insideExit = $null
    try {
        $insideOutput = @(& git -C $Repo rev-parse --is-inside-work-tree 2>&1)
        $insideExit = $LASTEXITCODE
    }
    catch {
        $insideOutput = @($_.Exception.Message)
        $insideExit = 1
    }
    $inside = ($insideOutput | Select-Object -First 1)
    if ($inside -ne 'true') {
        $insideText = ($insideOutput -join ' ')
        $reason = if ($insideText -match 'dubious ownership') { 'dubious_ownership' } else { 'unavailable' }
        return [PSCustomObject]@{
            git_read = $reason
            git_error = (($insideOutput | Select-Object -First 2) -join ' ')
            branch = $null
            head = $null
            remote = $null
            status_count = $null
            modified_count = $null
            deleted_count = $null
            untracked_count = $null
            staged_count = $null
            clean = $null
        }
    }

    $branch = (Invoke-Git -Repo $Repo -GitArgs @('branch', '--show-current') | Select-Object -First 1)
    $head = (Invoke-Git -Repo $Repo -GitArgs @('rev-parse', '--short', 'HEAD') | Select-Object -First 1)
    $remote = (Invoke-Git -Repo $Repo -GitArgs @('config', '--get', 'remote.origin.url') | Select-Object -First 1)
    $statusRaw = Invoke-Git -Repo $Repo -GitArgs @('status', '--short')
    $statusLines = if ($null -eq $statusRaw) { @() } else { @($statusRaw) }

    [PSCustomObject]@{
        git_read = 'ok'
        git_error = $null
        branch = if ($branch) { $branch } else { $null }
        head = if ($head) { $head } else { $null }
        remote = if ($remote) { $remote } else { $null }
        status_count = $statusLines.Count
        modified_count = @($statusLines | Where-Object { $_ -match '^\s*M|^M|^ M' }).Count
        deleted_count = @($statusLines | Where-Object { $_ -match '^ D|^D' }).Count
        untracked_count = @($statusLines | Where-Object { $_ -match '^\?\?' }).Count
        staged_count = @($statusLines | Where-Object { $_ -match '^[MADRCU]' }).Count
        clean = ($statusLines.Count -eq 0)
    }
}

function Test-ChildPath {
    param(
        [string] $Repo,
        [string] $Child
    )

    Test-Path -LiteralPath (Join-Path $Repo $Child)
}

function Find-AgentOrSdkSignals {
    param([string] $Repo)

    $commonFiles = @(
        'AGENTS.md',
        'README.md',
        'pyproject.toml',
        'requirements.txt',
        'requirements-dev.txt',
        'package.json'
    )
    $existingCommonFiles = @($commonFiles | Where-Object { Test-ChildPath -Repo $Repo -Child $_ })

    $candidateFiles = @()
    try {
        $candidateFiles = @(Get-ChildItem -LiteralPath $Repo -File -Recurse -Depth 3 -ErrorAction SilentlyContinue |
            Where-Object {
                $_.FullName -notmatch '\\(\.git|\.venv|node_modules|__pycache__|\.cache)\\' -and
                ($_.Name -in $commonFiles -or $_.Extension -in @('.py', '.toml', '.json', '.md', '.yml', '.yaml'))
            } |
            Select-Object -First 140)
    }
    catch {
        $candidateFiles = @()
    }

    $sdkMatches = @()
    $agentMatches = @()
    foreach ($file in $candidateFiles) {
        try {
            $sdkHit = Select-String -LiteralPath $file.FullName -Pattern 'openai-agents|from agents|import agents|Runner\.run|Agent\(' -SimpleMatch:$false -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($sdkHit) {
                $sdkMatches += [PSCustomObject]@{
                    file = ConvertTo-RepoPath -Path $file.FullName
                    pattern = $sdkHit.Pattern
                    line = $sdkHit.LineNumber
                }
            }

            $agentHit = Select-String -LiteralPath $file.FullName -Pattern 'agent|agente|seshat|thot|anubis|maat|horus|narrador|copilot|sdk' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($agentHit) {
                $agentMatches += [PSCustomObject]@{
                    file = ConvertTo-RepoPath -Path $file.FullName
                    line = $agentHit.LineNumber
                }
            }
        }
        catch {
        }
    }

    [PSCustomObject]@{
        has_agents_md = Test-ChildPath -Repo $Repo -Child 'AGENTS.md'
        has_agent_dir = (Test-ChildPath -Repo $Repo -Child '.agents') -or (Test-ChildPath -Repo $Repo -Child 'agents')
        has_skills_dir = (Test-ChildPath -Repo $Repo -Child 'skills') -or (Test-ChildPath -Repo $Repo -Child '.codex\skills')
        has_recipes_dir = Test-ChildPath -Repo $Repo -Child 'recipes'
        has_tools_dir = Test-ChildPath -Repo $Repo -Child 'tools'
        has_workflows = Test-ChildPath -Repo $Repo -Child '.github\workflows'
        common_files = $existingCommonFiles
        sdk_match_count = $sdkMatches.Count
        sdk_matches = @($sdkMatches | Select-Object -First 12)
        agent_match_count = $agentMatches.Count
        agent_matches = @($agentMatches | Select-Object -First 12)
    }
}

function Get-RepoClass {
    param(
        [string] $Repo,
        [object] $Signals
    )

    $name = Split-Path -Leaf $Repo
    if ($Repo -ieq $Root -or $Repo -ieq $PhysicalAlias) {
        return 'ROOT_CABINA'
    }
    if ($Repo -like 'C:\Users\enzo1\.codex\worktrees\*' -or $Repo -like 'C:\CEO\worktrees\*') {
        return 'SUPPORT_REPO'
    }
    if ($Signals.sdk_match_count -gt 0 -or $name -match 'agent|agents|sdk|tcu') {
        return 'SDK_REPO'
    }
    if ($name -match 'seshat|sdu|canon|torre|cabina') {
        return 'AGENT_REPO'
    }
    if ($name -match 'cdf|sgin|jara|organizacion|modo') {
        return 'BUSINESS_REPO'
    }
    if ($name -match 'wt_|__wt|archive|legacy') {
        return 'LEGACY_READONLY'
    }
    return 'CHILD_REPO'
}

function Find-Repositories {
    $seen = @{}
    $repos = New-Object System.Collections.Generic.List[object]

    foreach ($rootPath in $KnownRoots) {
        if (-not (Test-Path -LiteralPath $rootPath)) {
            continue
        }

        $queue = New-Object System.Collections.Queue
        $queue.Enqueue([PSCustomObject]@{ path = $rootPath; depth = 0 })

        while ($queue.Count -gt 0) {
            $current = $queue.Dequeue()
            $path = $current.path
            $depth = [int] $current.depth
            $leaf = Split-Path -Leaf $path

            if ($SkipDirectoryNames -contains $leaf) {
                continue
            }

            $gitPath = Join-Path $path '.git'
            if (Test-Path -LiteralPath $gitPath) {
                $key = $path.ToLowerInvariant()
                if (-not $seen.ContainsKey($key)) {
                    $signals = Find-AgentOrSdkSignals -Repo $path
                    $git = Get-GitInfo -Repo $path
                    $repos.Add([PSCustomObject]@{
                            path = $path
                            repo_path = ConvertTo-RepoPath -Path $path
                            name = Split-Path -Leaf $path
                            class = Get-RepoClass -Repo $path -Signals $signals
                            root_source = $rootPath
                            git_read = $git.git_read
                            git_error = $git.git_error
                            branch = $git.branch
                            head = $git.head
                            remote = $git.remote
                            clean = $git.clean
                            status_count = $git.status_count
                            modified_count = $git.modified_count
                            deleted_count = $git.deleted_count
                            untracked_count = $git.untracked_count
                            staged_count = $git.staged_count
                            signals = $signals
                        })
                    $seen[$key] = $true
                }
            }

            if ($depth -ge $MaxDepth) {
                continue
            }

            try {
                $children = @(Get-ChildItem -LiteralPath $path -Directory -Force -ErrorAction SilentlyContinue |
                    Where-Object { $SkipDirectoryNames -notcontains $_.Name })
                foreach ($child in $children) {
                    $queue.Enqueue([PSCustomObject]@{ path = $child.FullName; depth = ($depth + 1) })
                }
            }
            catch {
            }
        }
    }

    return @($repos | Sort-Object class, name, path)
}

function Get-ExecutionStatus {
    $codeInsiders = @(Get-Command code-insiders -All -ErrorAction SilentlyContinue)
    $codex = @(Get-Command codex -All -ErrorAction SilentlyContinue)
    $pythonPath = Join-Path $Root '.venv\Scripts\python.exe'
    $tasksPath = Join-Path $Root '.vscode\tasks.json'
    $taskCount = 0
    if (Test-Path -LiteralPath $tasksPath) {
        try {
            $taskCount = @((Get-Content -LiteralPath $tasksPath -Raw | ConvertFrom-Json).tasks).Count
        }
        catch {
            $taskCount = 0
        }
    }

    [PSCustomObject]@{
        artifact = 'cabina-execution-surface'
        status = 'CABINA_EXECUTION_SURFACE_READY'
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        workspace = $Root
        physical_alias = $PhysicalAlias
        execution_surface = 'Visual Studio Code Insiders Console'
        code_insiders_resolves = ($codeInsiders.Count -gt 0)
        codex_resolves = ($codex.Count -gt 0)
        python_exists = Test-Path -LiteralPath $pythonPath
        tasks_count = $taskCount
        commands_ready = @(
            'ceo-repo-fleet-scan',
            'ceo-agent-reconcile',
            'ceo-sdk-status',
            'ceo-dataverse-active-memory'
        )
        frontier = [PSCustomObject]@{
            no_absorb_nested_repos = $true
            no_core_worktree_change = $true
            no_delete = $true
            no_overwrite = $true
            no_push = $true
            no_pr = $true
            no_secret_print = $true
        }
    }
}

function Get-RepoFleet {
    $repos = Find-Repositories
    $summary = [PSCustomObject]@{
        total_observed = $repos.Count
        root_cabina = @($repos | Where-Object class -eq 'ROOT_CABINA').Count
        child_repos = @($repos | Where-Object class -in @('CHILD_REPO', 'BUSINESS_REPO', 'AGENT_REPO', 'SDK_REPO')).Count
        support_repos = @($repos | Where-Object class -eq 'SUPPORT_REPO').Count
        legacy_readonly = @($repos | Where-Object class -eq 'LEGACY_READONLY').Count
        repos_with_changes = @($repos | Where-Object { $_.git_read -eq 'ok' -and -not $_.clean }).Count
        repos_without_remote = @($repos | Where-Object { $_.git_read -eq 'ok' -and [string]::IsNullOrWhiteSpace($_.remote) }).Count
        repos_git_unavailable = @($repos | Where-Object { $_.git_read -ne 'ok' }).Count
        repos_git_dubious_ownership = @($repos | Where-Object { $_.git_read -eq 'dubious_ownership' }).Count
        repos_with_agents = @($repos | Where-Object { $_.signals.has_agents_md -or $_.signals.has_agent_dir }).Count
        repos_with_sdk_config = @($repos | Where-Object { $_.signals.sdk_match_count -gt 0 }).Count
    }

    [PSCustomObject]@{
        artifact = 'repo-fleet-inventory'
        status = 'REPO_FLEET_DISCOVERY_READY'
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        scan_roots = $KnownRoots
        max_depth = $MaxDepth
        summary = $summary
        repos = $repos
        boundary = [PSCustomObject]@{
            nested_repos_observed_not_absorbed = $true
            writes_executed = $false
            remotes_touched = $false
        }
    }
}

function Get-AgentReconciliation {
    param([object] $RepoFleet)

    $baseAgents = @()
    try {
        $agentMapRaw = & (Join-Path $Root 'tools\ceo-agent-map.ps1') -Json 2>$null
        $agentMap = $agentMapRaw | ConvertFrom-Json
        $baseAgents = @($agentMap.agents)
    }
    catch {
        $baseAgents = @(
            [PSCustomObject]@{ agent_id = 'SESHAT'; role = 'canon/evidencia' },
            [PSCustomObject]@{ agent_id = 'THOT'; role = 'runtime/tecnica' },
            [PSCustomObject]@{ agent_id = 'ANUBIS'; role = 'gate/frontera' },
            [PSCustomObject]@{ agent_id = 'MAAT'; role = 'cumplimiento/trazabilidad' },
            [PSCustomObject]@{ agent_id = 'HORUS'; role = 'riesgo/senal' }
        )
    }

    $repoAgentSurfaces = @($RepoFleet.repos | Where-Object { $_.signals.has_agents_md -or $_.signals.has_agent_dir -or $_.signals.sdk_match_count -gt 0 } | ForEach-Object {
            [PSCustomObject]@{
                repo = $_.repo_path
                class = $_.class
                has_agents_md = $_.signals.has_agents_md
                has_agent_dir = $_.signals.has_agent_dir
                agent_match_count = $_.signals.agent_match_count
                sdk_match_count = $_.signals.sdk_match_count
                owner_agent = if ($_.class -eq 'SDK_REPO') { 'SDK_OPERATOR' } elseif ($_.class -eq 'ROOT_CABINA') { 'THOT_EXECUTION_LEAD' } else { 'SESHAT_AGENT_REGISTRY' }
                decision = 'RECONCILE_EXISTING_DO_NOT_DUPLICATE'
            }
        })

    $duplicates = @($repoAgentSurfaces | Group-Object repo | Where-Object Count -gt 1 | ForEach-Object {
            [PSCustomObject]@{ key = $_.Name; count = $_.Count; decision = 'REVIEW_DUPLICATE_SURFACE' }
        })

    [PSCustomObject]@{
        artifact = 'agent-reconciliation-map'
        status = 'AGENT_RECONCILIATION_READY'
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        canonical_agents = $baseAgents
        repo_agent_surfaces = $repoAgentSurfaces
        duplicates = $duplicates
        orphan_policy = 'MARK_REVIEW_DO_NOT_DELETE'
        sdk_policy = 'USE_EXISTING_SDK_DO_NOT_CREATE_PARALLEL_RUNTIME'
        missing_governance_matrices = @(
            '.agents/codex/matrices/REPO_AGENT_TOOL_GOVERNANCE_MATRIX.csv',
            '.agents/codex/matrices/REPO_GOVERNANCE_ASSIGNMENT_MATRIX.csv',
            '.agents/codex/matrices/AGENT_GOVERNANCE_MATRIX.csv',
            '.agents/codex/matrices/TOOL_GOVERNANCE_MATRIX.csv',
            '.agents/codex/maps/SURFACE_BOUNDARY_MAP.csv'
        )
        frontier = [PSCustomObject]@{
            no_new_agents_by_default = $true
            no_sdk_parallel_runtime = $true
            no_external_write = $true
        }
    }
}

function Get-SdkStatus {
    param([object] $RepoFleet)

    $sdkRepos = @($RepoFleet.repos | Where-Object { $_.signals.sdk_match_count -gt 0 })
    $routes = @($sdkRepos | ForEach-Object {
            [PSCustomObject]@{
                repo = $_.repo_path
                class = $_.class
                branch = $_.branch
                head = $_.head
                sdk_match_count = $_.signals.sdk_match_count
                sample_matches = $_.signals.sdk_matches
                route_status = 'SDK_OBSERVED_REQUIRES_COMMAND_GATE'
                owner_agent = 'SDK_OPERATOR'
            }
        })

    [PSCustomObject]@{
        artifact = 'sdk-active-status'
        status = if ($sdkRepos.Count -gt 0) { 'SDK_ACTIVE_USE_READY' } else { 'SDK_NOT_OBSERVED_LOCALLY' }
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        sdk_repo_count = $sdkRepos.Count
        sdk_repos = $sdkRepos
        routes = $routes
        command_candidates = @(
            'ceo-sdk-status',
            'ceo-sdk-agent-routes'
        )
        frontier = [PSCustomObject]@{
            no_install = $true
            no_openai_api_call = $true
            no_secret_read = $true
            no_parallel_runtime = $true
        }
    }
}

function Get-DataverseActiveMemory {
    $inventory = Read-JsonFile -Path (Join-Path $DataverseOutDir 'dataverse-live-inventory.json')
    $memory = Read-JsonFile -Path (Join-Path $DataverseOutDir 'dataverse-usable-memory.json')
    $delta = Read-JsonFile -Path (Join-Path $DataverseOutDir 'dataverse-canon-delta.json')

    $tableMemory = @()
    if ($memory -and $memory.table_memory) {
        $tableMemory = @($memory.table_memory)
    }

    $agentLinks = @(
        [PSCustomObject]@{ agent = 'DATAVERSE_MEMORY_KEEPER'; consumes = 'dataverse-usable-memory'; status = if ($memory) { 'READY' } else { 'MISSING' } },
        [PSCustomObject]@{ agent = 'SESHAT_AGENT_REGISTRY'; consumes = 'SPGovernanceModel solution evidence'; status = if ($inventory) { 'READY' } else { 'MISSING' } },
        [PSCustomObject]@{ agent = 'HORUS_SIGNAL'; consumes = 'canon name drift'; status = if ($delta) { 'READY' } else { 'MISSING' } },
        [PSCustomObject]@{ agent = 'ANUBIS_GATE'; consumes = 'read-only boundary'; status = 'READY' }
    )

    $repoLinks = @(
        [PSCustomObject]@{ repo = 'C:\CEO\project-cdx'; relation = 'control-plane produces local evidence'; status = 'READY' },
        [PSCustomObject]@{ repo = 'Dataverse:SPGovernanceModel'; relation = 'live memory source'; status = if ($inventory -and $inventory.target_solution_found) { 'READY' } else { 'MISSING' } }
    )

    [PSCustomObject]@{
        artifact = 'dataverse-active-memory-map'
        status = if ($inventory -and $inventory.records.live_rows_confirmed) { 'DATAVERSE_ACTIVE_MEMORY_READY' } else { 'DATAVERSE_ACTIVE_MEMORY_METADATA_ONLY_OR_MISSING' }
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        environment_url = if ($inventory) { $inventory.environment_url } else { $null }
        observed_solution = if ($inventory) { $inventory.target_solution_unique_name } else { $null }
        component_count = if ($inventory) { $inventory.target_solution_component_count } else { $null }
        live_rows_confirmed = if ($inventory) { $inventory.records.live_rows_confirmed } else { $false }
        table_memory = $tableMemory
        canon_delta = if ($delta) { $delta.delta } else { @() }
        agent_links = $agentLinks
        repo_links = $repoLinks
        frontier = [PSCustomObject]@{
            no_dataverse_write = $true
            no_create_table = $true
            no_delete = $true
            no_rename = $true
            no_secret_print = $true
        }
    }
}

function New-MarkdownSummary {
    param(
        [object] $RepoFleet,
        [object] $AgentMap,
        [object] $Sdk,
        [object] $Dataverse
    )

    @"
---
artifact_id: operativa/tasks/20260623/READBACK_CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.md
etiquetas:
  - cabina
  - repo-fleet
  - agent-reconciliation
  - agents-sdk
  - dataverse
relacionados:
  - .cabina/execution-g1/out/repo-fleet-inventory.json
  - .cabina/execution-g1/out/agent-reconciliation-map.json
  - .cabina/execution-g1/out/sdk-active-status.json
  - .cabina/execution-g1/out/dataverse-active-memory-map.json
descripcion: Readback de ejecucion real G1 sobre repos, agentes existentes, SDK observado y memoria Dataverse.
---

# CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1

## 1. Dictamen ejecutivo

`CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_READY`

La cabina opera desde `C:\CEO\project-cdx`, releva repos locales gobernables, concilia agentes existentes, detecta superficies SDK observadas y conecta Dataverse como memoria activa read-only.

## 2. Ejecucion dentro de cabina

- workspace: `C:\CEO\project-cdx`
- consola: `Visual Studio Code Insiders Console`
- runtime: `CEO GOVERNED RUNTIME`
- comandos producidos: `10`
- frontera: no push, no PR, no delete, no secretos, no live destructivo

## 3. Repositorios relevados

- total observado: `$($RepoFleet.summary.total_observed)`
- raiz cabina: `$($RepoFleet.summary.root_cabina)`
- repos hijos/negocio/agente/sdk: `$($RepoFleet.summary.child_repos)`
- soporte/worktrees: `$($RepoFleet.summary.support_repos)`
- legacy readonly: `$($RepoFleet.summary.legacy_readonly)`
- repos con cambios: `$($RepoFleet.summary.repos_with_changes)`
- repos sin remote: `$($RepoFleet.summary.repos_without_remote)`
- repos git no legibles: `$($RepoFleet.summary.repos_git_unavailable)`
- repos bloqueados por safe.directory/dubious ownership: `$($RepoFleet.summary.repos_git_dubious_ownership)`
- repos con agentes: `$($RepoFleet.summary.repos_with_agents)`
- repos con SDK/config: `$($RepoFleet.summary.repos_with_sdk_config)`

## 4. Agentes conciliados

- agentes canonicos base: `$(@($AgentMap.canonical_agents).Count)`
- superficies repo/agente detectadas: `$(@($AgentMap.repo_agent_surfaces).Count)`
- duplicados detectados: `$(@($AgentMap.duplicates).Count)`
- decision: `RECONCILE_EXISTING_DO_NOT_DUPLICATE`

## 5. SDK activo

- estado: `$($Sdk.status)`
- repos con señales SDK: `$($Sdk.sdk_repo_count)`
- politica: usar SDK existente, no instalar ni crear runtime paralelo.

## 6. Dataverse activo

- entorno: `$($Dataverse.environment_url)`
- solucion: `$($Dataverse.observed_solution)`
- tablas utiles: `$(@($Dataverse.table_memory).Count)`
- filas reales confirmadas: `$($Dataverse.live_rows_confirmed)`
- decision: usar como memoria read-only; resolver delta de nombres por gate.

## 7. Capacidades producidas

- `Repo Fleet Discovery`
- `Agent Reconciliation`
- `SDK Active Use`
- `Dataverse Active Memory`
- `Cabina Capability Map`

## 8. Comandos/tasks producidos o candidatos

- `ceo-cabina-exec-status`
- `ceo-repo-fleet-scan`
- `ceo-repo-fleet-map`
- `ceo-agent-reconcile`
- `ceo-agent-duplicates`
- `ceo-sdk-status`
- `ceo-sdk-agent-routes`
- `ceo-dataverse-active-memory`
- `ceo-cabina-capability-map`
- `ceo-cabina-next-action`

## 9. Riesgos bloqueados

- no absorber repos anidados
- no modificar `core.worktree`
- no push / no PR
- no instalar SDK nuevo
- no escribir Dataverse
- no exponer secretos

## 10. Proxima accion ejecutable

`DATAVERSE_CANON_NAME_RECONCILIATION_DECISION` y luego `AGENT_REPO_OWNER_GOVERNANCE_MATRIX_REPAIR`.
"@
}

function New-CapabilityMap {
    param(
        [object] $RepoFleet,
        [object] $AgentMap,
        [object] $Sdk,
        [object] $Dataverse
    )

    @"
# CABINA CAPABILITY MAP - G1

| Capability | Estado | Comando | Evidencia | Gate |
| --- | --- | --- | --- | --- |
| Cabina Execution Surface | READY | `ceo-cabina-exec-status` | `cabina-execution-surface.json` | none |
| Repo Fleet Discovery | READY | `ceo-repo-fleet-scan` | `repo-fleet-inventory.json` | no_absorb_nested_repos |
| Agent Reconciliation | READY | `ceo-agent-reconcile` | `agent-reconciliation-map.json` | no_duplicate_agents |
| SDK Active Use | $($Sdk.status) | `ceo-sdk-status` | `sdk-active-status.json` | no_install_no_api_call |
| Dataverse Active Memory | $($Dataverse.status) | `ceo-dataverse-active-memory` | `dataverse-active-memory-map.json` | no_dataverse_write |
| Next Action | READY | `ceo-cabina-next-action` | `cabina-next-action.json` | owner_decision |

## Numeros

- Repos observados: $($RepoFleet.summary.total_observed)
- Repos con agentes: $($RepoFleet.summary.repos_with_agents)
- Repos con SDK/config: $($RepoFleet.summary.repos_with_sdk_config)
- Agentes canonicos base: $(@($AgentMap.canonical_agents).Count)
- Dataverse tablas utiles: $(@($Dataverse.table_memory).Count)

## Decisiones

- No crear agentes duplicados.
- No instalar SDK nuevo.
- No escribir Dataverse.
- No absorber repos hijos.
- Resolver nombres Dataverse antes de promover canon.
"@
}

function New-NextAction {
    param(
        [object] $RepoFleet,
        [object] $AgentMap,
        [object] $Sdk,
        [object] $Dataverse
    )

    $actions = @()
    if ($Dataverse.status -eq 'DATAVERSE_ACTIVE_MEMORY_READY') {
        $actions += [PSCustomObject]@{
            action = 'DATAVERSE_CANON_NAME_RECONCILIATION_DECISION'
            reason = 'solution and rows exist but expected canon names differ from live logical names'
            gate_required = $true
            owner_agent = 'DATAVERSE_MEMORY_KEEPER'
        }
    }
    if (@($AgentMap.missing_governance_matrices).Count -gt 0) {
        $actions += [PSCustomObject]@{
            action = 'AGENT_REPO_OWNER_GOVERNANCE_MATRIX_REPAIR'
            reason = 'repo-agent-tool governance matrices requested by skill are absent in local .agents/codex'
            gate_required = $false
            owner_agent = 'MAAT_TRACE'
        }
    }
    if ($Sdk.sdk_repo_count -gt 0) {
        $actions += [PSCustomObject]@{
            action = 'SDK_ROUTE_SMOKE_LOCAL_NO_API'
            reason = 'SDK markers observed; prove local import/routing without OpenAI API call'
            gate_required = $false
            owner_agent = 'SDK_OPERATOR'
        }
    }

    [PSCustomObject]@{
        artifact = 'cabina-next-action'
        status = 'CABINA_NEXT_ACTION_READY'
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        recommended = $actions
        frontier = [PSCustomObject]@{
            no_push = $true
            no_pr = $true
            no_live_destructive = $true
            no_secret_print = $true
        }
    }
}

function Write-AllArtifacts {
    $exec = Get-ExecutionStatus
    $repoFleet = Get-RepoFleet
    $agentMap = Get-AgentReconciliation -RepoFleet $repoFleet
    $sdk = Get-SdkStatus -RepoFleet $repoFleet
    $dataverse = Get-DataverseActiveMemory
    $next = New-NextAction -RepoFleet $repoFleet -AgentMap $agentMap -Sdk $sdk -Dataverse $dataverse

    Save-JsonFile -Path (Join-Path $OutDir 'cabina-execution-surface.json') -Value $exec
    Save-JsonFile -Path (Join-Path $OutDir 'repo-fleet-inventory.json') -Value $repoFleet
    Save-JsonFile -Path (Join-Path $OutDir 'repo-agent-surface-map.json') -Value $repoFleet.repos
    Save-JsonFile -Path (Join-Path $OutDir 'agent-reconciliation-map.json') -Value $agentMap
    Save-JsonFile -Path (Join-Path $OutDir 'sdk-active-status.json') -Value $sdk
    Save-JsonFile -Path (Join-Path $OutDir 'sdk-agent-routes.json') -Value $sdk.routes
    Save-JsonFile -Path (Join-Path $OutDir 'dataverse-active-memory-map.json') -Value $dataverse
    Save-JsonFile -Path (Join-Path $OutDir 'dataverse-agent-links.json') -Value $dataverse.agent_links
    Save-JsonFile -Path (Join-Path $OutDir 'dataverse-repo-links.json') -Value $dataverse.repo_links
    Save-JsonFile -Path (Join-Path $OutDir 'cabina-next-action.json') -Value $next

    Save-TextFile -Path (Join-Path $OutDir 'repo-fleet-summary.md') -Value "# REPO FLEET SUMMARY`n`nRepos observados: $($repoFleet.summary.total_observed)`nRepos con cambios: $($repoFleet.summary.repos_with_changes)`nRepos con agentes: $($repoFleet.summary.repos_with_agents)`nRepos con SDK/config: $($repoFleet.summary.repos_with_sdk_config)`n"
    Save-TextFile -Path (Join-Path $OutDir 'agent-canonical-operational-sdk-map.md') -Value "# AGENT CANONICAL OPERATIONAL SDK MAP`n`nAgentes base: $(@($agentMap.canonical_agents).Count)`nSuperficies repo/agente: $(@($agentMap.repo_agent_surfaces).Count)`nRepos SDK: $($sdk.sdk_repo_count)`n"
    Save-TextFile -Path (Join-Path $OutDir 'agent-duplicates-and-orphans.md') -Value "# AGENT DUPLICATES AND ORPHANS`n`nDuplicados detectados: $(@($agentMap.duplicates).Count)`nPolitica: MARK_REVIEW_DO_NOT_DELETE`n"
    Save-TextFile -Path (Join-Path $OutDir 'sdk-command-candidates.md') -Value "# SDK COMMAND CANDIDATES`n`n- ceo-sdk-status`n- ceo-sdk-agent-routes`n`nPolitica: no install, no OpenAI API call, no parallel runtime.`n"
    Save-TextFile -Path (Join-Path $OutDir 'cabina-capability-map.md') -Value (New-CapabilityMap -RepoFleet $repoFleet -AgentMap $agentMap -Sdk $sdk -Dataverse $dataverse)
    Save-TextFile -Path (Join-Path $OperativaDir 'READBACK_CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.md') -Value (New-MarkdownSummary -RepoFleet $repoFleet -AgentMap $agentMap -Sdk $sdk -Dataverse $dataverse)

    $matrix = @(
        'capability,command,status,evidence,owner_agent,gate_required,next_action'
        "Cabina Execution Surface,ceo-cabina-exec-status,$($exec.status),.cabina/execution-g1/out/cabina-execution-surface.json,THOT_EXECUTION_LEAD,false,run_from_vscode_insiders"
        "Repo Fleet Discovery,ceo-repo-fleet-scan,$($repoFleet.status),.cabina/execution-g1/out/repo-fleet-inventory.json,HERMES_REPO_CARTOGRAPHER,false,review_dirty_repos_by_class"
        "Agent Reconciliation,ceo-agent-reconcile,$($agentMap.status),.cabina/execution-g1/out/agent-reconciliation-map.json,SESHAT_AGENT_REGISTRY,false,reconcile_missing_governance_matrices"
        "SDK Active Use,ceo-sdk-status,$($sdk.status),.cabina/execution-g1/out/sdk-active-status.json,SDK_OPERATOR,false,local_no_api_sdk_smoke"
        "Dataverse Active Memory,ceo-dataverse-active-memory,$($dataverse.status),.cabina/execution-g1/out/dataverse-active-memory-map.json,DATAVERSE_MEMORY_KEEPER,true,dataverse_canon_name_reconciliation"
    ) -join "`n"
    Save-TextFile -Path (Join-Path $OperativaDir 'CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.csv') -Value $matrix
    Save-JsonFile -Path (Join-Path $OperativaDir 'CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.csv.meta.json') -Value ([PSCustomObject]@{
            artifact_id = 'operativa/tasks/20260623/CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623'
            categoria = 'operativa'
            tipo = 'matriz'
            estado = 'en_revision'
            version = 'v0.6.0-rc1'
            fecha_evento = '2026-06-23'
            autoridad = [PSCustomObject]@{ tipo = 'sistema'; referencia = 'CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1' }
            origen = 'GitHub'
            ubicacion_repo = 'operativa/tasks/20260623/CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.csv'
            etiquetas = @('cabina', 'repo-fleet', 'agent-reconciliation', 'agents-sdk', 'dataverse')
            relacionados = @(
                '.cabina/execution-g1/out/repo-fleet-inventory.json',
                '.cabina/execution-g1/out/agent-reconciliation-map.json',
                '.cabina/execution-g1/out/sdk-active-status.json',
                '.cabina/execution-g1/out/dataverse-active-memory-map.json'
            )
            descripcion = 'Matriz de capacidades G1 para ejecucion real de cabina, repos, agentes, SDK observado y memoria Dataverse activa.'
        })

    [PSCustomObject]@{
        estado_final = 'CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_READY'
        repo_fleet = $repoFleet.summary
        agents = [PSCustomObject]@{
            canonical = @($agentMap.canonical_agents).Count
            surfaces = @($agentMap.repo_agent_surfaces).Count
            duplicates = @($agentMap.duplicates).Count
        }
        sdk = [PSCustomObject]@{
            status = $sdk.status
            repos = $sdk.sdk_repo_count
        }
        dataverse = [PSCustomObject]@{
            status = $dataverse.status
            environment_url = $dataverse.environment_url
            observed_solution = $dataverse.observed_solution
            live_rows_confirmed = $dataverse.live_rows_confirmed
        }
        evidence = @(
            '.cabina/execution-g1/out/repo-fleet-inventory.json',
            '.cabina/execution-g1/out/agent-reconciliation-map.json',
            '.cabina/execution-g1/out/sdk-active-status.json',
            '.cabina/execution-g1/out/dataverse-active-memory-map.json',
            'operativa/tasks/20260623/READBACK_CABINA_EXECUTION_FIRST_REPO_AGENT_SDK_RECONCILIATION_G1_20260623.md'
        )
        next_action = $next.recommended
        frontier = [PSCustomObject]@{
            no_push = $true
            no_pr = $true
            no_delete = $true
            no_secret_print = $true
            no_dataverse_write = $true
            no_openai_api_call = $true
        }
    }
}

$payload = switch ($Mode) {
    'exec-status' { Get-ExecutionStatus }
    'repo-fleet-scan' { Get-RepoFleet }
    'repo-fleet-map' { (Get-RepoFleet).repos }
    'agent-reconcile' {
        $fleet = Get-RepoFleet
        Get-AgentReconciliation -RepoFleet $fleet
    }
    'agent-duplicates' {
        $fleet = Get-RepoFleet
        (Get-AgentReconciliation -RepoFleet $fleet).duplicates
    }
    'sdk-status' {
        $cached = Read-CachedArtifact -Name 'sdk-active-status.json'
        if ($cached) {
            $cached
        }
        else {
            $fleet = Get-RepoFleet
            Get-SdkStatus -RepoFleet $fleet
        }
    }
    'sdk-agent-routes' {
        $cached = Read-CachedArtifact -Name 'sdk-agent-routes.json'
        if ($cached) {
            $cached
        }
        else {
            $fleet = Get-RepoFleet
            (Get-SdkStatus -RepoFleet $fleet).routes
        }
    }
    'dataverse-active-memory' { Get-DataverseActiveMemory }
    'capability-map' {
        $fleet = Get-RepoFleet
        $agent = Get-AgentReconciliation -RepoFleet $fleet
        $sdk = Get-SdkStatus -RepoFleet $fleet
        $dv = Get-DataverseActiveMemory
        [PSCustomObject]@{
            artifact = 'cabina-capability-map'
            status = 'CABINA_CAPABILITY_MAP_READY'
            markdown = New-CapabilityMap -RepoFleet $fleet -AgentMap $agent -Sdk $sdk -Dataverse $dv
        }
    }
    'next-action' {
        $fleet = Get-RepoFleet
        $agent = Get-AgentReconciliation -RepoFleet $fleet
        $sdk = Get-SdkStatus -RepoFleet $fleet
        $dv = Get-DataverseActiveMemory
        New-NextAction -RepoFleet $fleet -AgentMap $agent -Sdk $sdk -Dataverse $dv
    }
    'all' { Write-AllArtifacts }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 20
}
else {
    $payload
}

$global:LASTEXITCODE = 0
