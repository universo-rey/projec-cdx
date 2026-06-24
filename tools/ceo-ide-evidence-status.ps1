param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'

function Get-RepoPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $full = [System.IO.Path]::GetFullPath($Path)
    $prefix = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    if ($full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($prefix.Length).Replace('\', '/')
    }

    return $full
}

function Get-FileSummary {
    param(
        [string] $Path,
        [int] $RecentLimit = 5
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [PSCustomObject]@{
            path = Get-RepoPath -Path $Path
            exists = $false
            file_count = 0
            total_bytes = 0
            recent_files = @()
        }
    }

    $item = Get-Item -LiteralPath $Path
    $files = if ($item.PSIsContainer) {
        @(Get-ChildItem -LiteralPath $Path -File -Recurse -ErrorAction SilentlyContinue)
    }
    else {
        @($item)
    }

    [PSCustomObject]@{
        path = Get-RepoPath -Path $Path
        exists = $true
        file_count = $files.Count
        total_bytes = [int64](($files | Measure-Object -Property Length -Sum).Sum)
        recent_files = @($files |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First $RecentLimit |
            ForEach-Object {
                [PSCustomObject]@{
                    path = Get-RepoPath -Path $_.FullName
                    bytes = $_.Length
                    last_write_time = $_.LastWriteTime.ToString('yyyy-MM-ddTHH:mm:sszzz')
                }
            })
    }
}

function Test-TaskLabel {
    param([string] $Label)

    $tasksPath = Join-Path $Root '.vscode\tasks.json'
    if (-not (Test-Path -LiteralPath $tasksPath)) {
        return $false
    }

    try {
        $labels = @((Get-Content -LiteralPath $tasksPath -Raw | ConvertFrom-Json).tasks | ForEach-Object { $_.label })
        return $labels -contains $Label
    }
    catch {
        return $false
    }
}

$categories = @(
    [PSCustomObject]@{
        category = 'runtime'
        locations = @(
            'operativa/runtime-events',
            'operativa/snapshots',
            'VERSION_STATE.json',
            'VERSION_POLICY.md'
        )
    },
    [PSCustomObject]@{
        category = 'command'
        locations = @(
            '.vscode/tasks.json',
            'tools',
            'operativa/tasks/20260623'
        )
    },
    [PSCustomObject]@{
        category = 'agent'
        locations = @(
            'operativa/tasks/20260623/IDE_AGENT_MCP_CONTROL_MATRIX_20260623.csv',
            'operativa/tasks/20260623/READBACK_IDE_AGENT_MCP_CONTROL_20260623.md',
            'tools/ceo-agent-map.ps1',
            'tools/ceo-ide-agent-map.ps1'
        )
    },
    [PSCustomObject]@{
        category = 'mcp'
        locations = @(
            'operativa/tasks/20260623/IDE_AGENT_MCP_CONTROL_MATRIX_20260623.csv',
            'tools/ceo-mcp-status.ps1',
            'tools/ceo-ide-mcp-status.ps1'
        )
    },
    [PSCustomObject]@{
        category = 'git'
        locations = @(
            '.github/workflows',
            'operativa/tasks/20260623/READBACK_IDE_COMMAND_CONTROL_20260623.md'
        )
    },
    [PSCustomObject]@{
        category = 'watchdog'
        locations = @(
            'operativa/sentinel',
            'operativa/SENTINEL_EVENTS.jsonl',
            'operativa/SENTINEL_STATE.md',
            'tools/ceo-runtime-sentinel.ps1'
        )
    },
    [PSCustomObject]@{
        category = 'telemetry'
        locations = @(
            'tools/ceo-runtime-state.ps1',
            'operativa/runtime-events',
            'VERSION_STATE.json'
        )
    },
    [PSCustomObject]@{
        category = 'remote'
        locations = @(
            '.github/workflows',
            'operativa/tasks/20260623'
        )
    },
    [PSCustomObject]@{
        category = 'decision'
        locations = @(
            'operativa/tasks/20260623',
            'operativa/index.json'
        )
    }
)

$evidence = foreach ($category in $categories) {
    $locationSummaries = foreach ($location in $category.locations) {
        Get-FileSummary -Path (Join-Path $Root $location)
    }

    [PSCustomObject]@{
        category = $category.category
        status = if (@($locationSummaries | Where-Object { $_.exists }).Count -gt 0) { 'OBSERVED' } else { 'MISSING' }
        file_count = [int](@($locationSummaries | Measure-Object -Property file_count -Sum).Sum)
        total_bytes = [int64](@($locationSummaries | Measure-Object -Property total_bytes -Sum).Sum)
        locations = $locationSummaries
    }
}

$tasks = @(
    [PSCustomObject]@{ label = 'CEO Command: Watchdog'; status = if (Test-TaskLabel -Label 'CEO Command: Watchdog') { 'READY' } else { 'MISSING' }; category = 'watchdog' },
    [PSCustomObject]@{ label = 'CEO Command: Telemetry'; status = if (Test-TaskLabel -Label 'CEO Command: Telemetry') { 'READY' } else { 'MISSING' }; category = 'telemetry' },
    [PSCustomObject]@{ label = 'CEO IDE: Evidence Status'; status = if (Test-TaskLabel -Label 'CEO IDE: Evidence Status') { 'READY' } else { 'MISSING' }; category = 'command' },
    [PSCustomObject]@{ label = 'CEO IDE: Telemetry Status'; status = if (Test-TaskLabel -Label 'CEO IDE: Telemetry Status') { 'READY' } else { 'MISSING' }; category = 'telemetry' }
)

$missingCategories = @($evidence | Where-Object { $_.status -eq 'MISSING' })
$missingTasks = @($tasks | Where-Object { $_.status -eq 'MISSING' })

$payload = [PSCustomObject]@{
    command = 'ceo-ide-evidence-status'
    status = if ($missingCategories.Count -eq 0 -and $missingTasks.Count -eq 0) { 'IDE_EVIDENCE_CAPTURE_READY' } else { 'IDE_EVIDENCE_CAPTURE_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    evidence_categories = $evidence
    task_readbacks = $tasks
    missing_categories = $missingCategories
    missing_tasks = $missingTasks
    policy = @{
        avoid_noisy_logs = $true
        minimal_readback_by_task = $true
        json_output_required = $true
    }
    frontera = @{
        no_secret_read = $true
        no_live = $true
        no_mcp_execution = $true
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
