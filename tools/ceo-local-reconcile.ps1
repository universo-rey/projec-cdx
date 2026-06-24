param(
    [ValidateSet(
        'inventory',
        'classify',
        'repo-boundary',
        'agent-assets',
        'sdk-assets',
        'noise-plan',
        'cleanup-dryrun',
        'cleanup-gate-status',
        'all'
    )]
    [string] $Mode = 'all',
    [switch] $Json,
    [int] $MaxDepth = 4
)

$Root = 'C:\CEO\project-cdx'
$Alias = 'C:\Users\enzo1\PROJEC CDX'
$OutDir = Join-Path $Root '.cabina\local-reconcile\out'
$TaskDir = Join-Path $Root 'operativa\tasks\20260623'
$SkipDirectoryNames = @(
    '.git',
    '.venv',
    'node_modules',
    '.cache',
    '.pytest_cache',
    '.ruff_cache',
    '.mypy_cache',
    '__pycache__',
    'dist',
    'build',
    'coverage'
)

function New-Directory {
    param([string] $Path)
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
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

function Save-CsvFile {
    param(
        [string] $Path,
        [object[]] $Rows
    )

    New-Directory -Path (Split-Path -Parent $Path)
    $Rows | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
}

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    if ($Path.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($Root.Length).TrimStart('\').Replace('\', '/')
    }

    return $Path.Replace('\', '/')
}

function Invoke-Git {
    param(
        [string] $Repo,
        [string[]] $GitArgs
    )

    try {
        $output = & git -C $Repo @GitArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            return @($output)
        }
        return @($output)
    }
    catch {
        return @($_.Exception.Message)
    }
}

function Get-GitInfo {
    param([string] $Repo)

    $inside = @(Invoke-Git -Repo $Repo -GitArgs @('rev-parse', '--is-inside-work-tree') | Select-Object -First 1)
    if ($inside.Count -eq 0 -or $inside[0] -ne 'true') {
        $txt = ($inside -join ' ')
        $reason = if ($txt -match 'dubious ownership') { 'dubious_ownership' } else { 'unavailable' }
        return [PSCustomObject]@{
            git_read = $reason
            git_error = $txt
            branch = $null
            head = $null
            remote = $null
            clean = $null
            status_count = $null
        }
    }

    $status = @(Invoke-Git -Repo $Repo -GitArgs @('status', '--short', '--untracked-files=all'))
    $branch = (Invoke-Git -Repo $Repo -GitArgs @('branch', '--show-current') | Select-Object -First 1)
    $head = (Invoke-Git -Repo $Repo -GitArgs @('rev-parse', '--short', 'HEAD') | Select-Object -First 1)
    $remote = (Invoke-Git -Repo $Repo -GitArgs @('config', '--get', 'remote.origin.url') | Select-Object -First 1)

    [PSCustomObject]@{
        git_read = 'ok'
        git_error = $null
        branch = if ($branch) { $branch } else { $null }
        head = if ($head) { $head } else { $null }
        remote = if ($remote) { $remote } else { $null }
        clean = ($status.Count -eq 0)
        status_count = $status.Count
    }
}

function Get-StatusEntries {
    $lines = @(Invoke-Git -Repo $Root -GitArgs @('status', '--short', '--untracked-files=all'))
    $entries = foreach ($line in $lines) {
        if ($line -match '^(?<status>.{2})\s+(?<path>.+)$') {
            $status = $Matches.status
            $path = $Matches.path
            $target = $null
            if ($path -match '^(?<old>.+)\s+->\s+(?<new>.+)$') {
                $path = $Matches.old
                $target = $Matches.new
            }

            $fullPath = Join-Path $Root $path
            $exists = Test-Path -LiteralPath $fullPath
            $item = if ($exists) { Get-Item -LiteralPath $fullPath -Force } else { $null }
            $size = if ($item -and -not $item.PSIsContainer) { [int64] $item.Length } else { $null }
            $class = Get-LocalClass -Path $path -Status $status
            $decision = Get-LocalDecision -Path $path -Status $status -Class $class

            [PSCustomObject]@{
                status = $status
                path = $path
                path_target = $target
                exists = $exists
                size_bytes = $size
                extension = if ($item -and -not $item.PSIsContainer) { $item.Extension } else { [System.IO.Path]::GetExtension($path) }
                root_bucket = (($path -split '[\\/]' | Select-Object -First 1))
                class = $class
                decision = $decision
                tracked_kind = if ($status -match '^\?\?') { 'untracked' } elseif ($status -match '^ D|^D') { 'deleted' } elseif ($status -match '^ M|^M |^A|^AM|^MM|^R') { 'tracked' } else { 'other' }
                owner_gate = if ($decision -in @('BLOCKED_NEEDS_OWNER', 'DEFERRED_WITH_REASON')) { $true } else { $false }
                safe_to_ignore = if ($decision -in @('GENERATED_CACHE', 'SCRATCH')) { $true } else { $false }
                safe_to_version = if ($decision -in @('VERSIONABLE_CANON', 'VERSIONABLE_READBACK', 'LOCAL_CONFIG')) { $true } else { $false }
                safe_to_delete = $false
            }
        }
    }

    return @($entries)
}

function Get-LocalClass {
    param(
        [string] $Path,
        [string] $Status
    )

    $normalized = $Path.Replace('\', '/')

    if ($normalized -match '(^|/)\.env\.local$|(^|/)(secret|token|password|credential)(/|\.|$)') {
        return 'SENSITIVE_DOCUMENT'
    }
    if ($normalized -match '(^|/)(\.git|\.venv|node_modules|\.cache|\.pytest_cache|\.ruff_cache|\.mypy_cache)(/|$)') {
        return 'CACHE'
    }
    if ($normalized -match '(^|/)(logs?)(/|$)|\.(log|trace)$') {
        return 'LOG'
    }
    if ($normalized -match '(^|/)(out)(/|$)|(^|/)outputs?(/|$)') {
        return 'OUT'
    }
    if ($normalized -match '(^|/)(tmp|temp|scratch)(/|$)|\.tmp$|\.temp$|\.bak$|\.old$|\.previous-') {
        return 'TEMP'
    }
    if ($normalized -match '(^|/)snapshots?(/|$)|VERSION_STATE\.json$|SNAPSHOT_INDEX\.json$|CEORUNTIME_') {
        return 'SNAPSHOT'
    }
    if ($normalized -match '(^|/)(\.vscode|\.cursor|\.codex|\.agents|\.github)(/|$)|(^|/)(AGENTS\.md|AGENTS\.reference\.md|CODEOWNERS|CONTRIBUTING\.md|SECURITY\.md|README\.md|README_CORTO\.md|MAPA_.*\.md|VERSION_.*|index\.json|live-manifest\.json|schema\.json|pyproject\.toml)$') {
        return 'CONFIG'
    }
    if ($normalized -match '(^|/)(skills|\.codex/skills)(/|$)|SKILL\.md$') {
        return 'SKILL'
    }
    if ($normalized -match '(^|/)(recipes|playbooks)(/|$)') {
        return 'RECIPE'
    }
    if ($normalized -match '(^|/)(tools|scripts)(/|$)|\.(ps1|py|mjs|js|ts)$') {
        return 'TOOL'
    }
    if ($normalized -match '(^|/)(AGENTS\.md|agents)(/|$)|cabina-contract|agent-map|agent-reconcile|agent-duplicates') {
        return 'AGENT_ASSET'
    }
    if ($normalized -match '(^|/)(docs|hitos|inventarios|workbooks|patrones|procesos)(/|$)|READBACK_|MANIFEST|INDICE|EVIDENCIA|READBACK|MATRIX|SENTINEL|RUNTIME_STATE') {
        return 'EVIDENCE'
    }
    if ($normalized -match '(^|/)(dataverse)(/|$)|(^|/)main\.py$|(^|/)src(/|$)|(^|/)tests(/|$)|(^|/)\.github/workflows(/|$)') {
        return 'CORE_REPO'
    }
    if ($normalized -match '(^|/)(README|MAPA|VERSION|CHANGELOG)(\.md)?$') {
        return 'BUSINESS_DOCUMENT'
    }
    if ($Status -match '^ D|^D ') {
        return 'LEGACY_READONLY'
    }

    return 'UNKNOWN_REVIEW'
}

function Get-LocalDecision {
    param(
        [string] $Path,
        [string] $Status,
        [string] $Class
    )

    switch ($Class) {
        'SENSITIVE_DOCUMENT' { return 'BLOCKED_NEEDS_OWNER' }
        'CACHE' { return 'GENERATED_CACHE' }
        'LOG' { return 'GENERATED_CACHE' }
        'OUT' { return 'GENERATED_CACHE' }
        'TEMP' { return 'SCRATCH' }
        'SNAPSHOT' { return 'VERSIONABLE_READBACK' }
        'SKILL' { return 'VERSIONABLE_CANON' }
        'RECIPE' { return 'VERSIONABLE_CANON' }
        'TOOL' { return 'VERSIONABLE_CANON' }
        'AGENT_ASSET' { return 'VERSIONABLE_CANON' }
        'CORE_REPO' { return 'VERSIONABLE_CANON' }
        'BUSINESS_DOCUMENT' { return 'VERSIONABLE_CANON' }
        'CONFIG' {
            if ($Path -match '^\.vscode[\\/]|^\.cursor[\\/]|^\.codex[\\/]|^\.agents[\\/]|^\.github[\\/]' ) {
                return 'LOCAL_CONFIG'
            }
            return 'VERSIONABLE_CANON'
        }
        'EVIDENCE' {
            if ($Path -match 'READBACK|MANIFEST|MATRIX|INDICE|EVIDENCIA|SUMMARY|REPORT|READ_ONLY') {
                return 'VERSIONABLE_READBACK'
            }
            return 'VERSIONABLE_CANON'
        }
        'LEGACY_READONLY' { return 'DEFERRED_WITH_REASON' }
        default { return 'BLOCKED_NEEDS_OWNER' }
    }
}

function Get-RepoBoundaries {
    $repos = @()
    $gitDirs = @(Get-ChildItem -LiteralPath $Root -Recurse -Directory -Force -Depth $MaxDepth -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq '.git' -and $_.FullName -notmatch '\\(\.git|node_modules|\.venv|\.cache|\.pytest_cache|\.ruff_cache|\.mypy_cache)\\' })

    foreach ($gitDir in $gitDirs) {
        $repo = Split-Path -Parent $gitDir.FullName
        $git = Get-GitInfo -Repo $repo
        $repos += [PSCustomObject]@{
            repo = Get-RepoPath -Path $repo
            name = Split-Path -Leaf $repo
            class = if ($repo -ieq $Root) { 'ROOT_CABINA' } elseif ($repo -match '\\\.cabina($|\\)') { 'SUPPORT_REPO' } elseif ($repo -match '\\(work|worktrees|archive)(\\|$)') { 'LEGACY_READONLY' } else { 'CHILD_REPO' }
            git_read = $git.git_read
            git_error = $git.git_error
            branch = $git.branch
            head = $git.head
            remote = $git.remote
            status_count = $git.status_count
            clean = $git.clean
        }
    }

    return @($repos | Sort-Object class, repo)
}

function Get-AgentAssets {
    $roots = @(
        '.agents',
        '.codex',
        'AGENTS.md',
        'AGENTS.reference.md',
        'skills',
        'recipes',
        'playbooks',
        'tools',
        '.github\workflows'
    )

    $items = @()
    foreach ($rel in $roots) {
        $path = Join-Path $Root $rel
        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }

        if ((Get-Item -LiteralPath $path).PSIsContainer) {
            $entries = @(Get-ChildItem -LiteralPath $path -Recurse -File -Depth $MaxDepth -ErrorAction SilentlyContinue)
            $items += [PSCustomObject]@{
                surface = $rel.Replace('\', '/')
                kind = 'directory'
                count = $entries.Count
                sample = @($entries | Select-Object -First 10 | ForEach-Object { Get-RepoPath -Path $_.FullName })
            }
        }
        else {
            $items += [PSCustomObject]@{
                surface = $rel.Replace('\', '/')
                kind = 'file'
                count = 1
                sample = @(Get-RepoPath -Path $path)
            }
        }
    }

    $agentFiles = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Depth $MaxDepth -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\(\.agents|\.codex|skills|recipes|playbooks|tools|\.github\\workflows)\\|\\AGENTS\.md$|\\AGENTS\.reference\.md$' } |
        Select-Object -First 250)

    $duplicates = @($agentFiles | Group-Object Name | Where-Object Count -gt 1 | ForEach-Object {
            [PSCustomObject]@{
                name = $_.Name
                count = $_.Count
                decision = 'REVIEW_DUPLICATE_SURFACE'
            }
        })

    [PSCustomObject]@{
        agent_assets = $items
        duplicates = $duplicates
        status = if ($items.Count -gt 0) { 'AGENT_ASSETS_READY' } else { 'AGENT_ASSETS_MISSING' }
    }
}

function Get-SdkAssets {
    $markers = @(
        'openai-agents',
        'from agents',
        'import agents',
        'Runner.run',
        'Agent('
    )

    $candidateFiles = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Depth $MaxDepth -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\(\.git|\.venv|node_modules|\.cache|\.pytest_cache|\.ruff_cache|\.mypy_cache)\\' -and
            $_.Extension -in @('.ps1', '.py', '.json', '.toml', '.md', '.yml', '.yaml', '.js', '.ts')
        } |
        Select-Object -First 500)

    $hits = @()
    foreach ($file in $candidateFiles) {
        try {
            $hit = Select-String -LiteralPath $file.FullName -Pattern $markers -SimpleMatch -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hit) {
                $hits += [PSCustomObject]@{
                    file = Get-RepoPath -Path $file.FullName
                    pattern = $hit.Pattern
                    line = $hit.LineNumber
                }
            }
        }
        catch {
        }
    }

    [PSCustomObject]@{
        sdk_matches = $hits
        sdk_match_count = $hits.Count
        status = if ($hits.Count -gt 0) { 'SDK_ASSETS_READY' } else { 'SDK_ASSETS_NOT_OBSERVED' }
    }
}

function Get-NoisePlan {
    param([object[]] $Entries)

    $safeIgnorePatterns = @(
        '.pytest_cache/',
        '.ruff_cache/',
        '.mypy_cache/',
        '.cache/',
        'node_modules/',
        'out/',
        'logs/',
        'work/backups/',
        '*.log',
        '*.trace',
        '*.tmp',
        '*.temp',
        '*.bak'
    )

    $safeCandidates = @($Entries | Where-Object { $_.decision -in @('GENERATED_CACHE', 'SCRATCH') } | Select-Object -First 200)
    $gateCandidates = @($Entries | Where-Object { $_.decision -in @('BLOCKED_NEEDS_OWNER', 'DEFERRED_WITH_REASON') } | Select-Object -First 200)
    $versionable = @($Entries | Where-Object { $_.decision -in @('VERSIONABLE_CANON', 'VERSIONABLE_READBACK', 'LOCAL_CONFIG') } | Select-Object -First 200)
    $neverDelete = @(
        'Evidence readbacks',
        'Versioned canonical docs',
        'Workspace config that governs current runtime',
        '.env.local',
        '.git',
        '.vscode/settings.json',
        '.vscode/tasks.json',
        '.cursor/mcp.json'
    )

    [PSCustomObject]@{
        safe_ignore_patterns = $safeIgnorePatterns
        safe_candidates = $safeCandidates
        gate_candidates = $gateCandidates
        versionable = $versionable
        never_delete = $neverDelete
    }
}

function Get-CleanupDryRun {
    param([object] $Inventory, [object] $NoisePlan)

    $safe = @($NoisePlan.safe_candidates | ForEach-Object {
        [PSCustomObject]@{
            path = $_.path
            decision = $_.decision
            reason = 'Generated cache or scratch; ignore candidate only, do not delete'
        }
    })

    $gate = @($NoisePlan.gate_candidates | ForEach-Object {
        [PSCustomObject]@{
            path = $_.path
            decision = $_.decision
            reason = 'Owner decision required before archive/move/version'
        }
    })

    $versionable = @($NoisePlan.versionable | ForEach-Object {
        [PSCustomObject]@{
            path = $_.path
            decision = $_.decision
            reason = 'Keep as canonical, readback, or local config'
        }
    })

    [PSCustomObject]@{
        dryrun_status = 'DRYRUN_ONLY_NO_ACTION'
        safe = $safe
        requires_gate = $gate
        versionable = $versionable
        reversal = [PSCustomObject]@{
            method = 'No destructive actions executed; revert by removing generated outputs only if owner asks.'
            scope = 'current repo and .cabina/local-reconcile/out outputs'
        }
        frontier = [PSCustomObject]@{
            no_delete = $true
            no_move = $true
            no_overwrite = $true
            no_push = $true
            no_pr = $true
            no_live = $true
            no_secret_read = $true
        }
    }
}

function New-InventoryText {
    param([object[]] $Entries)

    $summary = $Entries | Group-Object root_bucket | Sort-Object Count -Descending
    $lines = @(
        '# CABINA LOCAL FILE INVENTORY',
        '',
        '## Git status summary',
        '',
        "- total entries: $($Entries.Count)",
        "- modified: $(@($Entries | Where-Object { $_.status -match '^ M|^M ' }).Count)",
        "- deleted: $(@($Entries | Where-Object { $_.status -match '^ D|^D ' }).Count)",
        "- untracked: $(@($Entries | Where-Object { $_.status -match '^\?\?' }).Count)",
        '',
        '## Top level counts',
        ''
    )

    foreach ($item in $summary) {
        $lines += "- $($item.Name): $($item.Count)"
    }

    $lines += @(
        '',
        '## Category counts',
        ''
    )

    $classCounts = $Entries | Group-Object class | Sort-Object Count -Descending
    foreach ($item in $classCounts) {
        $lines += "- $($item.Name): $($item.Count)"
    }

    return ($lines -join "`n")
}

function New-FolderMapText {
    param([object[]] $Repos)

    $lines = @(
        '# CABINA LOCAL FOLDER MAP',
        '',
        '## Repo boundaries',
        ''
    )

    foreach ($repo in $Repos) {
        $lines += "- $($repo.repo) [$($repo.class)] git_read=$($repo.git_read) clean=$($repo.clean)"
    }

    return ($lines -join "`n")
}

function New-ReadbackText {
    param(
        [object[]] $Entries,
        [object[]] $Repos,
        [object] $AgentAssets,
        [object] $SdkAssets,
        [object] $NoisePlan,
        [object] $Cleanup
    )

    $counts = $Entries | Group-Object decision | Sort-Object Count -Descending
    $classCounts = $Entries | Group-Object class | Sort-Object Count -Descending
    $rootCounts = $Entries | Group-Object root_bucket | Sort-Object Count -Descending
    $topGate = @($Cleanup.requires_gate | Select-Object -First 5)
    $topSafe = @($Cleanup.safe | Select-Object -First 5)

    $lines = @(
        '---',
        "artifact_id: operativa/tasks/20260623/READBACK_CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623.md",
        'categoria: operativa',
        'tipo: readback',
        'estado: en_revision',
        'version: v0.6.0-rc1',
        "fecha_evento: '2026-06-23'",
        'autoridad:',
        '  tipo: sistema',
        '  referencia: CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1',
        'origen: GitHub',
        'ubicacion_repo: operativa/tasks/20260623/READBACK_CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623.md',
        'etiquetas:',
        '  - cabina',
        '  - local-files',
        '  - reconciliation',
        '  - noise-reduction',
        'relacionados:',
        '  - .cabina/local-reconcile/out/local-file-inventory.json',
        '  - .cabina/local-reconcile/out/local-file-classification.json',
        '  - .cabina/local-reconcile/out/repo-boundary-map.json',
        '  - .cabina/local-reconcile/out/agent-assets-map.json',
        '  - .cabina/local-reconcile/out/sdk-assets-map.json',
        '  - .cabina/local-reconcile/out/noise-reduction-plan.md',
        '  - .cabina/local-reconcile/out/cleanup-dryrun.json',
        'descripcion: Readback del carril de reconciliacion local y reduccion de ruido de la cabina.',
        '---',
        '# CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1',
        '',
        '## 1. Dictamen ejecutivo',
        '',
        'CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_READY',
        '',
        '## 2. Resumen del inventario',
        '',
        "- git status entries: $($Entries.Count)",
        "- repos boundaries observed: $($Repos.Count)",
        "- agent asset groups: $(@($AgentAssets.agent_assets).Count)",
        "- sdk matches: $($SdkAssets.sdk_match_count)",
        "- safe ignore candidates: $(@($Cleanup.safe).Count)",
        "- gate candidates: $(@($Cleanup.requires_gate).Count)",
        '',
        '## 3. Categorias principales',
        ''
    )

    foreach ($item in $classCounts) {
        $lines += "- $($item.Name): $($item.Count)"
    }

    $lines += @(
        '',
        '## 4. Raices y superficies',
        ''
    )

    foreach ($item in $rootCounts) {
        $lines += "- $($item.Name): $($item.Count)"
    }

    $lines += @(
        '',
        '## 5. Ruido operativo detectado',
        '',
        '- cache, out, logs, temp, backups, and generated residual surfaces remain present as governed candidates',
        '- tracked whitespace-only owner decision remains on tools/promote_sdu_manifesto_dataverse.ps1',
        '',
        '## 6. Activos protegidos',
        '',
        '- evidence readbacks',
        '- canonical docs',
        '- config surfaces',
        '- agent and SDK surfaces',
        '',
        '## 7. Candidatos a .gitignore / exclude',
        ''
    )

    foreach ($pattern in @($NoisePlan.safe_ignore_patterns)) {
        $lines += "- $pattern"
    }

    $lines += @(
        '',
        '## 8. Candidatos a quarantine / hold',
        ''
    )
    foreach ($item in $topGate) {
        $lines += "- $($item.path) => $($item.decision)"
    }

    $lines += @(
        '',
        '## 9. Acciones seguras propuestas',
        ''
    )
    foreach ($item in $topSafe) {
        $lines += "- $($item.path) => $($item.decision)"
    }

    $lines += @(
        '',
        '## 10. Acciones que requieren gate',
        '',
        '- normalize or revert tools/promote_sdu_manifesto_dataverse.ps1 after owner review',
        '- archive or move generated legacy surfaces only under explicit owner gate',
        '',
        '## 11. Cambios realizados',
        '',
        '- inventory and classification outputs generated under .cabina/local-reconcile/out',
        '- readback generated under operativa/tasks/20260623',
        '',
        '## 12. Cambios no realizados',
        '',
        '- no delete',
        '- no overwrite',
        '- no move',
        '- no push',
        '- no PR',
        '- no live',
        '- no secrets',
        '',
        '## 13. Evidencia generada',
        '',
        '- local-file-inventory.json',
        '- local-file-classification.json',
        '- repo-boundary-map.json',
        '- agent-assets-map.json',
        '- sdk-assets-map.json',
        '- noise-reduction-plan.md',
        '- cleanup-dryrun.json',
        '',
        '## 14. Comandos/tasks candidatos',
        '',
        '- ceo-local-inventory',
        '- ceo-local-classify',
        '- ceo-repo-boundary-map',
        '- ceo-agent-assets-map',
        '- ceo-sdk-assets-map',
        '- ceo-noise-plan',
        '- ceo-cleanup-dryrun',
        '- ceo-cleanup-gate-status',
        '',
        '## 15. Proxima accion ejecutable',
        '',
        '- owner decision on tools/promote_sdu_manifesto_dataverse.ps1',
        '- promote or archive governed readbacks only after gate',
        '- keep noisy generated surfaces isolated, not deleted'
    )

    return ($lines -join "`n")
}

function Write-Outputs {
    $entries = @(Get-StatusEntries)
    $repos = @(Get-RepoBoundaries)
    $agentAssets = Get-AgentAssets
    $sdkAssets = Get-SdkAssets
    $noisePlan = Get-NoisePlan -Entries $entries
    $cleanup = Get-CleanupDryRun -Inventory $entries -NoisePlan $noisePlan

    $inventory = [PSCustomObject]@{
        command = 'ceo-local-inventory'
        status = 'CABINA_LOCAL_FILES_INVENTORY_READY'
        generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        workspace_root = $Root
        physical_alias = $Alias
        git = [PSCustomObject]@{
            branch = (Invoke-Git -Repo $Root -GitArgs @('branch', '--show-current') | Select-Object -First 1)
            head = (Invoke-Git -Repo $Root -GitArgs @('rev-parse', '--short', 'HEAD') | Select-Object -First 1)
            status_count = $entries.Count
            modified = @($entries | Where-Object { $_.status -match '^ M|^M |^MM|^AM|^RM' }).Count
            deleted = @($entries | Where-Object { $_.status -match '^ D|^D ' }).Count
            untracked = @($entries | Where-Object { $_.status -match '^\?\?' }).Count
        }
        root_counts = @($entries | Group-Object root_bucket | Sort-Object Count -Descending | ForEach-Object {
            [PSCustomObject]@{ root = $_.Name; count = $_.Count }
        })
        class_counts = @($entries | Group-Object class | Sort-Object Count -Descending | ForEach-Object {
            [PSCustomObject]@{ class = $_.Name; count = $_.Count }
        })
        decision_counts = @($entries | Group-Object decision | Sort-Object Count -Descending | ForEach-Object {
            [PSCustomObject]@{ decision = $_.Name; count = $_.Count }
        })
        large_files = @($entries | Where-Object { $_.size_bytes -ge 1048576 } | Sort-Object size_bytes -Descending | Select-Object -First 50)
        frontier = [PSCustomObject]@{
            no_delete = $true
            no_move = $true
            no_push = $true
            no_pr = $true
            no_live = $true
            no_secret_read = $true
        }
    }

    $classify = [PSCustomObject]@{
        command = 'ceo-local-classify'
        status = 'CABINA_LOCAL_FILES_CLASSIFICATION_READY'
        generated_at = $inventory.generated_at
        entries = $entries
        summary = [PSCustomObject]@{
            total = $entries.Count
            versionable_canon = @($entries | Where-Object { $_.decision -eq 'VERSIONABLE_CANON' }).Count
            versionable_readback = @($entries | Where-Object { $_.decision -eq 'VERSIONABLE_READBACK' }).Count
            local_config = @($entries | Where-Object { $_.decision -eq 'LOCAL_CONFIG' }).Count
            generated_cache = @($entries | Where-Object { $_.decision -eq 'GENERATED_CACHE' }).Count
            scratch = @($entries | Where-Object { $_.decision -eq 'SCRATCH' }).Count
            deferred = @($entries | Where-Object { $_.decision -eq 'DEFERRED_WITH_REASON' }).Count
            blocked = @($entries | Where-Object { $_.decision -eq 'BLOCKED_NEEDS_OWNER' }).Count
        }
    }

    $repoBoundary = [PSCustomObject]@{
        command = 'ceo-repo-boundary-map'
        status = 'CABINA_REPO_BOUNDARY_MAP_READY'
        generated_at = $inventory.generated_at
        repo_boundaries = $repos
        nested_repo_count = $repos.Count
        frontier = [PSCustomObject]@{
            no_absorb_nested_repos = $true
            no_modify_worktree = $true
            no_push = $true
            no_pr = $true
        }
    }

    $agentMap = [PSCustomObject]@{
        command = 'ceo-agent-assets-map'
        status = $agentAssets.status
        generated_at = $inventory.generated_at
        agent_assets = $agentAssets.agent_assets
        duplicates = $agentAssets.duplicates
        duplicate_count = $agentAssets.duplicates.Count
        frontier = [PSCustomObject]@{
            no_new_agents_by_default = $true
            no_duplicate_skills = $true
            no_secret_read = $true
        }
    }

    $sdkMap = [PSCustomObject]@{
        command = 'ceo-sdk-assets-map'
        status = $sdkAssets.status
        generated_at = $inventory.generated_at
        sdk_match_count = $sdkAssets.sdk_match_count
        sdk_matches = $sdkAssets.sdk_matches
        command_candidates = @(
            'ceo-sdk-status',
            'ceo-sdk-agent-routes'
        )
        frontier = [PSCustomObject]@{
            no_install = $true
            no_openai_api_call = $true
            no_secret_read = $true
        }
    }

    $noise = [PSCustomObject]@{
        command = 'ceo-noise-plan'
        status = 'CABINA_NOISE_PLAN_READY'
        generated_at = $inventory.generated_at
        safe_ignore_patterns = $noisePlan.safe_ignore_patterns
        safe_candidates = $noisePlan.safe_candidates
        gate_candidates = $noisePlan.gate_candidates
        versionable = $noisePlan.versionable
        never_delete = $noisePlan.never_delete
        frontier = [PSCustomObject]@{
            no_delete = $true
            no_move = $true
            no_push = $true
            no_pr = $true
        }
    }

    $dryrun = [PSCustomObject]@{
        command = 'ceo-cleanup-dryrun'
        status = $cleanup.dryrun_status
        generated_at = $inventory.generated_at
        safe = $cleanup.safe
        requires_gate = $cleanup.requires_gate
        versionable = $cleanup.versionable
        reversal = $cleanup.reversal
        frontier = $cleanup.frontier
    }

    $gateStatus = [PSCustomObject]@{
        command = 'ceo-cleanup-gate-status'
        status = if ($cleanup.requires_gate.Count -gt 0) { 'CABINA_CLEANUP_GATE_PENDING' } else { 'CABINA_CLEANUP_GATE_CLEAR' }
        generated_at = $inventory.generated_at
        owner_decisions_required = @($cleanup.requires_gate | Select-Object -First 25)
        safe_candidates = @($cleanup.safe | Select-Object -First 25)
        next_action = if ($cleanup.requires_gate.Count -gt 0) { 'hold_until_owner_decision' } else { 'safe_to_prepare_archive_candidates_only' }
        frontier = [PSCustomObject]@{
            no_delete = $true
            no_move = $true
            no_push = $true
            no_pr = $true
            no_live = $true
        }
    }

    Save-JsonFile -Path (Join-Path $OutDir 'local-file-inventory.json') -Value $inventory
    Save-TextFile -Path (Join-Path $OutDir 'local-folder-map.md') -Value (New-FolderMapText -Repos $repos)
    Save-TextFile -Path (Join-Path $OutDir 'local-file-summary.md') -Value (New-InventoryText -Entries $entries)
    Save-JsonFile -Path (Join-Path $OutDir 'local-file-classification.json') -Value $classify
    Save-TextFile -Path (Join-Path $OutDir 'unknown-review-list.md') -Value (($entries | Where-Object { $_.class -eq 'UNKNOWN_REVIEW' } | Select-Object -First 100 | ForEach-Object { "- $($_.path) [$($_.status)]" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'sensitive-or-evidence-protected.md') -Value (($entries | Where-Object { $_.class -eq 'SENSITIVE_DOCUMENT' -or $_.decision -in @('VERSIONABLE_READBACK', 'VERSIONABLE_CANON') } | Select-Object -First 100 | ForEach-Object { "- $($_.path) => $($_.decision)" }) -join "`n")
    Save-JsonFile -Path (Join-Path $OutDir 'repo-boundary-map.json') -Value $repoBoundary
    Save-TextFile -Path (Join-Path $OutDir 'repo-noise-candidates.md') -Value (($noisePlan.gate_candidates | Select-Object -First 100 | ForEach-Object { "- $($_.path) => $($_.decision)" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'gitignore-exclude-candidates.md') -Value (($noisePlan.safe_ignore_patterns | ForEach-Object { "- $_" }) -join "`n")
    Save-JsonFile -Path (Join-Path $OutDir 'agent-assets-map.json') -Value $agentMap
    Save-TextFile -Path (Join-Path $OutDir 'skills-recipes-map.md') -Value (@(
            '# SKILLS AND RECIPES MAP',
            '',
            "Agent asset groups: $($agentAssets.agent_assets.Count)",
            "Duplicate candidate groups: $($agentAssets.duplicates.Count)",
            '',
            '## Groups',
            ''
        ) + @($agentAssets.agent_assets | ForEach-Object { "- $($_.surface) [$($_.kind)] count=$($_.count)" }) -join "`n")
    Save-JsonFile -Path (Join-Path $OutDir 'sdk-assets-map.json') -Value $sdkMap
    Save-TextFile -Path (Join-Path $OutDir 'agent-duplicates-orphans.md') -Value (@(
            '# AGENT DUPLICATES AND ORPHANS',
            '',
            "Duplicate candidate groups: $($agentAssets.duplicates.Count)",
            "Unknown review count: $(@($entries | Where-Object { $_.class -eq 'UNKNOWN_REVIEW' }).Count)",
            '',
            '## Duplicates',
            ''
        ) + @($agentAssets.duplicates | Select-Object -First 50 | ForEach-Object { "- $($_.name): $($_.count) => $($_.decision)" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'noise-reduction-plan.md') -Value (@(
            '# NOISE REDUCTION PLAN',
            '',
            '## Safe ignore patterns',
            ''
        ) + @($noisePlan.safe_ignore_patterns | ForEach-Object { "- $_" }) + @(
            '',
            '## Gate candidates',
            ''
        ) + @($noisePlan.gate_candidates | Select-Object -First 100 | ForEach-Object { "- $($_.path) => $($_.decision)" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'ignore-rules-candidates.md') -Value (($noisePlan.safe_ignore_patterns | ForEach-Object { "- $_" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'quarantine-candidates.md') -Value (($cleanup.requires_gate | Select-Object -First 100 | ForEach-Object { "- $($_.path) => $($_.decision)" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'delete-never-list.md') -Value (($noisePlan.never_delete | ForEach-Object { "- $_" }) -join "`n")
    Save-JsonFile -Path (Join-Path $OutDir 'cleanup-dryrun.json') -Value $dryrun
    Save-TextFile -Path (Join-Path $OutDir 'cleanup-actions-safe.md') -Value (($cleanup.safe | Select-Object -First 100 | ForEach-Object { "- $($_.path) => $($_.reason)" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'cleanup-actions-require-gate.md') -Value (($cleanup.requires_gate | Select-Object -First 100 | ForEach-Object { "- $($_.path) => $($_.reason)" }) -join "`n")
    Save-TextFile -Path (Join-Path $OutDir 'reversal-plan.md') -Value @"
# REVERSAL PLAN

No destructive actions were executed in this carril.

If the owner later authorizes an apply pass, reversal is:
- remove generated outputs under `.cabina/local-reconcile/out`
- restore any staged canonical files only if the owner explicitly asks for a revert
- do not delete evidence or snapshots
"@

    $readback = New-ReadbackText -Entries $entries -Repos $repos -AgentAssets $agentAssets -SdkAssets $sdkAssets -NoisePlan $noisePlan -Cleanup $cleanup
    Save-TextFile -Path (Join-Path $TaskDir 'READBACK_CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623.md') -Value $readback

    $csvRows = @($entries | ForEach-Object {
        [PSCustomObject]@{
            path = $_.path
            git_status = $_.status
            tracked_kind = $_.tracked_kind
            class = $_.class
            decision = $_.decision
            root_bucket = $_.root_bucket
            size_bytes = $_.size_bytes
            exists = $_.exists
            safe_to_ignore = $_.safe_to_ignore
            safe_to_version = $_.safe_to_version
            owner_gate = $_.owner_gate
        }
    })

    Save-CsvFile -Path (Join-Path $TaskDir 'CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623.csv') -Rows $csvRows
    Save-JsonFile -Path (Join-Path $TaskDir 'CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623.csv.meta.json') -Value ([PSCustomObject]@{
            artifact_id = 'operativa/tasks/20260623/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623'
            categoria = 'operativa'
            tipo = 'matriz'
            estado = 'en_revision'
            version = 'v0.6.0-rc1'
            fecha_evento = '2026-06-23'
            autoridad = [PSCustomObject]@{ tipo = 'sistema'; referencia = 'CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1' }
            origen = 'GitHub'
            ubicacion_repo = 'operativa/tasks/20260623/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_20260623.csv'
            etiquetas = @('cabina', 'local-files', 'reconciliation', 'noise-reduction', 'filesystem')
            relacionados = @(
                '.cabina/local-reconcile/out/local-file-inventory.json',
                '.cabina/local-reconcile/out/local-file-classification.json',
                '.cabina/local-reconcile/out/repo-boundary-map.json',
                '.cabina/local-reconcile/out/agent-assets-map.json',
                '.cabina/local-reconcile/out/sdk-assets-map.json',
                '.cabina/local-reconcile/out/noise-reduction-plan.md',
                '.cabina/local-reconcile/out/cleanup-dryrun.json'
            )
            descripcion = 'Matriz de reconciliacion local y reduccion de ruido para la cabina, sin borrar ni sobrescribir.'
        })

    return [PSCustomObject]@{
        command = 'ceo-local-reconcile'
        status = 'CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1_READY'
        generated_at = $inventory.generated_at
        inventory = $inventory
        classification = $classify
        repo_boundaries = $repoBoundary
        agent_assets = $agentMap
        sdk_assets = $sdkMap
        noise_plan = $noise
        cleanup_dryrun = $dryrun
        frontier = [PSCustomObject]@{
            no_delete = $true
            no_move = $true
            no_push = $true
            no_pr = $true
            no_live = $true
            no_secret_read = $true
        }
    }
}

$payload = switch ($Mode) {
    'inventory' { (Write-Outputs).inventory }
    'classify' { (Write-Outputs).classification }
    'repo-boundary' { (Write-Outputs).repo_boundaries }
    'agent-assets' { (Write-Outputs).agent_assets }
    'sdk-assets' { (Write-Outputs).sdk_assets }
    'noise-plan' { (Write-Outputs).noise_plan }
    'cleanup-dryrun' { (Write-Outputs).cleanup_dryrun }
    'cleanup-gate-status' { [PSCustomObject]@{ command = 'ceo-cleanup-gate-status'; status = 'CABINA_CLEANUP_GATE_PENDING'; details = (Write-Outputs).cleanup_dryrun } }
    'all' { Write-Outputs }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 20
}
else {
    $payload
}

$global:LASTEXITCODE = 0
