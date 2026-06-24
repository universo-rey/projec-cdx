param(
    [switch] $Json,
    [switch] $Full
)

$Root = 'C:\CEO\project-cdx'
$Python = Join-Path $Root '.venv\Scripts\python.exe'

function Invoke-LocalCheck {
    param(
        [string] $Name,
        [string] $File,
        [string[]] $Args,
        [switch] $Optional
    )

    if (-not (Test-Path -LiteralPath $File)) {
        return [PSCustomObject]@{
            name = $Name
            status = if ($Optional) { 'CANDIDATE_MISSING' } else { 'MISSING' }
            exit_code = $null
            command = $File
            tail = 'not_found'
        }
    }

    $output = @()
    $exitCode = $null
    try {
        $output = & $File @Args 2>&1
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) {
            $exitCode = 0
        }
    }
    catch {
        $output = @($_.Exception.Message)
        $exitCode = 1
    }

    [PSCustomObject]@{
        name = $Name
        status = if ($exitCode -eq 0) { 'PASS' } else { 'FAIL' }
        exit_code = $exitCode
        command = $File.Replace($Root + '\', '').Replace('\', '/')
        args = $Args
        tail = (($output | Select-Object -Last 4) -join ' | ')
    }
}

function Invoke-PythonCheck {
    param(
        [string] $Name,
        [string[]] $Args
    )

    if (-not (Test-Path -LiteralPath $Python)) {
        return [PSCustomObject]@{
            name = $Name
            status = 'MISSING'
            exit_code = $null
            command = $Python
            tail = 'python_not_found'
        }
    }

    $output = & $Python @Args 2>&1
    $exitCode = $LASTEXITCODE
    [PSCustomObject]@{
        name = $Name
        status = if ($exitCode -eq 0) { 'PASS' } else { 'FAIL' }
        exit_code = $exitCode
        command = $Python.Replace($Root + '\', '').Replace('\', '/')
        args = $Args
        tail = (($output | Select-Object -Last 4) -join ' | ')
    }
}

$checks = @(
    @{ name = 'status'; file = 'tools\ceo-vscode-insiders-status.ps1'; args = @('-Json') },
    @{ name = 'workspace'; file = 'tools\ceo-ide-workspace-status.ps1'; args = @('-Json') },
    @{ name = 'workspace-reconcile'; file = 'tools\ceo-ide-workspace-reconcile.ps1'; args = @('-Json') },
    @{ name = 'local-reconcile'; file = 'tools\ceo-local-reconcile.ps1'; args = @('-Mode', 'all', '-Json') },
    @{ name = 'local-inventory'; file = 'tools\ceo-local-inventory.ps1'; args = @('-Json') },
    @{ name = 'local-classify'; file = 'tools\ceo-local-classify.ps1'; args = @('-Json') },
    @{ name = 'repo-boundary-map'; file = 'tools\ceo-repo-boundary-map.ps1'; args = @('-Json') },
    @{ name = 'agent-assets-map'; file = 'tools\ceo-agent-assets-map.ps1'; args = @('-Json') },
    @{ name = 'sdk-assets-map'; file = 'tools\ceo-sdk-assets-map.ps1'; args = @('-Json') },
    @{ name = 'noise-plan'; file = 'tools\ceo-noise-plan.ps1'; args = @('-Json') },
    @{ name = 'cleanup-dryrun'; file = 'tools\ceo-cleanup-dryrun.ps1'; args = @('-Json') },
    @{ name = 'cleanup-gate-status'; file = 'tools\ceo-cleanup-gate-status.ps1'; args = @('-Json') },
    @{ name = 'terminal'; file = 'tools\ceo-ide-terminal-status.ps1'; args = @('-Json') },
    @{ name = 'doctor'; file = 'tools\ceo-cabina-doctor.ps1'; args = @('-Json') },
    @{ name = 'command-index'; file = 'tools\ceo-ide-command-index.ps1'; args = @('-Json') },
    @{ name = 'ide-agent-map'; file = 'tools\ceo-ide-agent-map.ps1'; args = @('-Json') },
    @{ name = 'ide-mcp-status'; file = 'tools\ceo-ide-mcp-status.ps1'; args = @('-Json') },
    @{ name = 'ide-extension-list'; file = 'tools\ceo-ide-extension-list.ps1'; args = @('-Json') },
    @{ name = 'ide-extension-policy'; file = 'tools\ceo-ide-extension-policy.ps1'; args = @('-Json') },
    @{ name = 'ide-evidence-status'; file = 'tools\ceo-ide-evidence-status.ps1'; args = @('-Json') },
    @{ name = 'ide-telemetry-status'; file = 'tools\ceo-ide-telemetry-status.ps1'; args = @('-Json') },
    @{ name = 'agent-map'; file = 'tools\ceo-agent-map.ps1'; args = @('-Json') },
    @{ name = 'mcp-status'; file = 'tools\ceo-mcp-status.ps1'; args = @('-Json') },
    @{ name = 'integration-map'; file = 'tools\ceo-integration-map.ps1'; args = @('-Json') },
    @{ name = 'integration-status'; file = 'tools\ceo-integration-status.ps1'; args = @('-Json') },
    @{ name = 'ide-to-codex-pack'; file = 'tools\ceo-ide-to-codex-pack.ps1'; args = @('-Json') },
    @{ name = 'github-pr-pack'; file = 'tools\ceo-github-pr-pack.ps1'; args = @('-Json') },
    @{ name = 'dataverse-memory-delta'; file = 'tools\ceo-dataverse-memory-delta.ps1'; args = @('-Json') },
    @{ name = 'dataverse-status'; file = 'tools\ceo-dataverse-status.ps1'; args = @('-Json') },
    @{ name = 'dataverse-solutions'; file = 'tools\ceo-dataverse-solutions.ps1'; args = @('-Json') },
    @{ name = 'dataverse-tables'; file = 'tools\ceo-dataverse-tables.ps1'; args = @('-Json') },
    @{ name = 'dataverse-memory'; file = 'tools\ceo-dataverse-memory.ps1'; args = @('-Json') },
    @{ name = 'dataverse-canon-delta'; file = 'tools\ceo-dataverse-canon-delta.ps1'; args = @('-Json') },
    @{ name = 'cabina-exec-status'; file = 'tools\ceo-cabina-exec-status.ps1'; args = @('-Json') },
    @{ name = 'repo-fleet-scan'; file = 'tools\ceo-repo-fleet-scan.ps1'; args = @('-Json') },
    @{ name = 'agent-reconcile'; file = 'tools\ceo-agent-reconcile.ps1'; args = @('-Json') },
    @{ name = 'sdk-status'; file = 'tools\ceo-sdk-status.ps1'; args = @('-Json') },
    @{ name = 'dataverse-active-memory'; file = 'tools\ceo-dataverse-active-memory.ps1'; args = @('-Json') },
    @{ name = 'cabina-next-action'; file = 'tools\ceo-cabina-next-action.ps1'; args = @('-Json') },
    @{ name = 'sharepoint-evidence-pack'; file = 'tools\ceo-sharepoint-evidence-pack.ps1'; args = @('-Json') },
    @{ name = 'integration-gates-status'; file = 'tools\ceo-integration-gates-status.ps1'; args = @('-Json') },
    @{ name = 'watchdog'; file = 'tools\ceo-runtime-sentinel.ps1'; args = @('--json') },
    @{ name = 'telemetry'; file = 'tools\ceo-runtime-state.ps1'; args = @('--json') }
)

$results = foreach ($check in $checks) {
    Invoke-LocalCheck -Name $check.name -File (Join-Path $Root $check.file) -Args $check.args
}

$results += Invoke-PythonCheck -Name 'validate' -Args @('-m', 'tools.validate')
$results += Invoke-LocalCheck -Name 'remote-ready' -File (Join-Path $Root 'tools\ceo-remote-ready.ps1') -Args @('-Json') -Optional

$failures = @($results | Where-Object { $_.status -eq 'FAIL' -or $_.status -eq 'MISSING' })
$candidateMissing = @($results | Where-Object { $_.status -eq 'CANDIDATE_MISSING' })

$payload = [PSCustomObject]@{
    command = 'ceo-ide-command-test'
    status = if ($failures.Count -eq 0) { 'IDE_COMMAND_SURFACE_READY' } else { 'IDE_COMMAND_SURFACE_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    full = [bool]$Full
    results = $results
    failures = $failures
    candidates = $candidateMissing
    frontera = @{
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
