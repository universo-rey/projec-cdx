param(
    [switch] $Json
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$backlogPath = Join-Path $Root 'operativa\tasks\20260623\CEO_PRODUCTIVE_CELL_G1_BACKLOG_20260623.csv'
$capabilityPath = Join-Path $Root 'operativa\tasks\20260623\CEO_PRODUCTIVE_CELL_G1_CAPABILITY_MATRIX_20260623.csv'

$backlog = @()
if (Test-Path -LiteralPath $backlogPath) {
    $backlog = @(Import-Csv -LiteralPath $backlogPath)
}

$capabilities = @()
if (Test-Path -LiteralPath $capabilityPath) {
    $capabilities = @(Import-Csv -LiteralPath $capabilityPath)
}

$automationCandidates = @($backlog | Where-Object { $_.type -match 'automation|capability|skill_recipe_promotion|gate_ready_for_decision' } | ForEach-Object {
    [PSCustomObject]@{
        priority = $_.priority
        item = $_.item
        produces = $_.produces
        owner_agent = $_.owner_agent
        gate = $_.gate
        status = $_.status
        next_order = $_.next_order
    }
})

$promotableCapabilities = @($capabilities | Where-Object { $_.command_status -match 'implemented|candidate' } | ForEach-Object {
    [PSCustomObject]@{
        lane = $_.lane
        capability = $_.capability_produced
        command = $_.command_candidate
        skill = $_.skill_candidate
        recipe = $_.recipe_candidate
        owner_agent = $_.owner_agent
        gate = $_.gate_required
    }
})

$payload = [PSCustomObject]@{
    command = 'ceo-intelligence-loop'
    root = $Root
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    backlog_count = $backlog.Count
    capability_count = $capabilities.Count
    automation_candidates = @($automationCandidates)
    promotable_capabilities = @($promotableCapabilities)
    recommended_next = @(
        'RUN_CEO_G1_PRODUCTIVE_CELL',
        'CABINA_ARCHIVE_RECONCILIATION_PASS',
        'ADD_VSCODE_TASKS_PRODUCTIVE_G1_TO_CANON_IF_OWNER_APPROVES'
    )
    frontera = @{
        no_external = $true
        no_secret_read = $true
        no_live = $true
        no_write = $true
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 8
}

