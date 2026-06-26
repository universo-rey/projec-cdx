param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
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

function Expand-TaskPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $expanded = $Path.Replace('${workspaceFolder}', $Root).Replace('/', '\')
    if ([System.IO.Path]::IsPathRooted($expanded)) {
        return [System.IO.Path]::GetFullPath($expanded)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $Root $expanded))
}

function Resolve-TaskCommandTarget {
    param($Task)

    $args = @($Task.args)
    $fileIndex = [array]::IndexOf($args, '-File')
    if ($fileIndex -ge 0 -and ($fileIndex + 1) -lt $args.Count) {
        return Expand-TaskPath -Path $args[$fileIndex + 1]
    }

    if ($Task.command -and $Task.command.ToString().Contains('${workspaceFolder}')) {
        return Expand-TaskPath -Path $Task.command.ToString()
    }

    return $null
}

function Get-TaskOutputKind {
    param($Task)

    $args = @($Task.args)
    if ($args -contains '-Json' -or $args -contains '--json') {
        return 'json'
    }

    if ($Task.dependsOn) {
        return 'composite'
    }

    return 'terminal'
}

function Get-TaskDependencies {
    param($Task)

    if ($null -eq $Task.dependsOn) {
        return @()
    }

    @($Task.dependsOn | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

$jsonState = Test-JsonFile -Path $TasksPath
$tasks = @()
if ($jsonState -eq 'ok') {
    $tasks = @((Get-Content -LiteralPath $TasksPath -Raw | ConvertFrom-Json).tasks)
}

$labels = @($tasks | ForEach-Object { $_.label })
$duplicateLabels = @($labels | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })

$taskAnalysis = foreach ($task in $tasks) {
    $target = Resolve-TaskCommandTarget -Task $task
    $depends = @(Get-TaskDependencies -Task $task)
    $missingDepends = @($depends | Where-Object { $_ -notin $labels })
    $targetExists = if ($target) { Test-Path -LiteralPath $target } else { $null }
    $isComposite = $depends.Count -gt 0
    $hasCommand = -not [string]::IsNullOrWhiteSpace($task.command)
    $isDecorative = (-not $hasCommand) -and (-not $isComposite)
    $status = if ($isDecorative) {
        'DECORATIVE'
    }
    elseif ($missingDepends.Count -gt 0) {
        'BROKEN_DEPENDENCY'
    }
    elseif ($target -and -not $targetExists) {
        'BROKEN_COMMAND_TARGET'
    }
    else {
        'PRODUCTIVE'
    }

    [PSCustomObject]@{
        label = $task.label
        type = $task.type
        command = $task.command
        target = $target
        target_exists = $targetExists
        depends_on = $depends
        missing_depends = $missingDepends
        output = Get-TaskOutputKind -Task $task
        status = $status
    }
}

$expectedSlots = @(
    @{ slot = 'status'; label = 'CEO Command: Status'; mode = 'required'; evidence = 'CEO IDE: Status + Workspace Control + Terminal Status' },
    @{ slot = 'workspace-reconcile'; label = 'CEO IDE: Workspace Reconcile'; mode = 'required'; evidence = 'tools/ceo-ide-workspace-reconcile.ps1 -Json' },
    @{ slot = 'validate'; label = 'CEO Command: Validate Metadata'; mode = 'required'; evidence = '.venv/Scripts/python.exe -m tools.validate' },
    @{ slot = 'watchdog'; label = 'CEO Command: Watchdog'; mode = 'required'; evidence = 'tools/ceo-runtime-sentinel.ps1 --json' },
    @{ slot = 'telemetry'; label = 'CEO Command: Telemetry'; mode = 'required'; evidence = 'tools/ceo-runtime-state.ps1 --json' },
    @{ slot = 'command-index'; label = 'CEO Command: Index'; mode = 'required'; evidence = 'tools/ceo-ide-command-index.ps1 -Json' },
    @{ slot = 'path-doctor'; label = 'CEO Command: Doctor'; mode = 'covered'; evidence = 'tools/ceo-cabina-doctor.ps1 -Json' },
    @{ slot = 'agent-dispatch'; label = 'CEO Command: Agent Map'; mode = 'covered'; evidence = 'agent dispatch not executed; map available' },
    @{ slot = 'mcp-status'; label = 'CEO Command: MCP Status'; mode = 'required'; evidence = 'tools/ceo-mcp-status.ps1 -Json' },
    @{ slot = 'ide-agent-map'; label = 'CEO IDE: Agent Map'; mode = 'required'; evidence = 'tools/ceo-ide-agent-map.ps1 -Json' },
    @{ slot = 'ide-mcp-status'; label = 'CEO IDE: MCP Status'; mode = 'required'; evidence = 'tools/ceo-ide-mcp-status.ps1 -Json' },
    @{ slot = 'agent-mcp-hub'; label = 'CEO IDE: Agent MCP Hub'; mode = 'required'; evidence = 'composite IDE agent and MCP hub status' },
    @{ slot = 'ide-extension-list'; label = 'CEO IDE: Extension List'; mode = 'required'; evidence = 'tools/ceo-ide-extension-list.ps1 -Json' },
    @{ slot = 'ide-extension-policy'; label = 'CEO IDE: Extension Policy'; mode = 'required'; evidence = 'tools/ceo-ide-extension-policy.ps1 -Json' },
    @{ slot = 'ide-extension-control'; label = 'CEO IDE: Extension Control'; mode = 'required'; evidence = 'composite extension inventory and policy' },
    @{ slot = 'ide-evidence-status'; label = 'CEO IDE: Evidence Status'; mode = 'required'; evidence = 'tools/ceo-ide-evidence-status.ps1 -Json' },
    @{ slot = 'ide-telemetry-status'; label = 'CEO IDE: Telemetry Status'; mode = 'required'; evidence = 'tools/ceo-ide-telemetry-status.ps1 -Json' },
    @{ slot = 'ide-evidence-telemetry-control'; label = 'CEO IDE: Evidence Telemetry Control'; mode = 'required'; evidence = 'composite evidence, telemetry, watchdog and runtime state' },
    @{ slot = 'remote-ready'; label = 'CEO Command: Remote Ready'; mode = 'candidate'; evidence = 'requires remote publication delta' }
)

$slotCoverage = foreach ($slot in $expectedSlots) {
    $task = $taskAnalysis | Where-Object { $_.label -eq $slot.label } | Select-Object -First 1
    $status = if ($task -and $task.status -eq 'PRODUCTIVE') {
        if ($slot.mode -eq 'candidate') { 'READY_BUT_GATE_REQUIRED' } else { 'READY' }
    }
    elseif ($slot.mode -eq 'candidate') {
        'CANDIDATE_MISSING'
    }
    elseif ($task) {
        $task.status
    }
    else {
        'MISSING'
    }

    [PSCustomObject]@{
        slot = $slot.slot
        expected_task = $slot.label
        mode = $slot.mode
        status = $status
        evidence = $slot.evidence
    }
}

$brokenTasks = @($taskAnalysis | Where-Object { $_.status -ne 'PRODUCTIVE' })
$missingRequired = @($slotCoverage | Where-Object { $_.mode -ne 'candidate' -and $_.status -notin @('READY') })
$candidateSlots = @($slotCoverage | Where-Object { $_.mode -eq 'candidate' -and $_.status -like 'CANDIDATE*' })

$status = if ($jsonState -eq 'ok' -and $duplicateLabels.Count -eq 0 -and $brokenTasks.Count -eq 0 -and $missingRequired.Count -eq 0) {
    'IDE_TASKS_PRODUCTIVE_READY'
}
else {
    'IDE_TASKS_PRODUCTIVE_WARN'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-tasks-status'
    status = $status
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    tasks_file = '.vscode/tasks.json'
    tasks_json = $jsonState
    task_count = $tasks.Count
    duplicate_labels = $duplicateLabels
    slot_coverage = $slotCoverage
    productive_tasks = @($taskAnalysis | Where-Object { $_.status -eq 'PRODUCTIVE' }).Count
    broken_tasks = $brokenTasks
    candidate_slots = $candidateSlots
    task_analysis = $taskAnalysis
    frontera = @{
        no_live = $true
        no_secret_read = $true
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
