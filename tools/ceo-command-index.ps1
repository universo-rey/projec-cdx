param(
    [switch] $Json
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Get-ProjectScripts {
    $pyproject = Join-Path $Root 'pyproject.toml'
    $items = @()
    if (-not (Test-Path -LiteralPath $pyproject)) {
        return $items
    }

    $inSection = $false
    foreach ($line in Get-Content -LiteralPath $pyproject) {
        if ($line -match '^\[project\.scripts\]') {
            $inSection = $true
            continue
        }
        if ($inSection -and $line -match '^\[') {
            break
        }
        if ($inSection -and $line -match '^\s*([A-Za-z0-9_.-]+)\s*=\s*"([^"]+)"') {
            $items += [PSCustomObject]@{
                name = $Matches[1]
                target = $Matches[2]
                source = 'pyproject.toml'
                status = 'configured'
            }
        }
    }
    return $items
}

$toolScripts = Get-ChildItem -LiteralPath (Join-Path $Root 'tools') -File |
    Where-Object { $_.Extension -in @('.ps1', '.py', '.mjs', '.sh') } |
    Sort-Object Name |
    ForEach-Object {
        [PSCustomObject]@{
            name = $_.Name
            path = $_.FullName.Replace($Root + '\', '').Replace('\', '/')
            extension = $_.Extension
            status = 'observed'
        }
    }

$payload = [PSCustomObject]@{
    command = 'ceo-command-index'
    root = '<REPO_ROOT>'
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    tools_count = @($toolScripts).Count
    project_scripts_count = @(Get-ProjectScripts).Count
    project_scripts = @(Get-ProjectScripts)
    tool_scripts = @($toolScripts)
    g3_trace_intelligence_commands = @(
        'ceo-trace-indexer.ps1',
        'ceo-trace-query.ps1',
        'ceo-trace-dashboard.ps1',
        'ceo-anomaly-detector.ps1',
        'ceo-alert-engine.ps1',
        'ceo-replay-control.ps1',
        'ceo-policy-feedback.ps1'
    )
    frontera = @{
        no_external = $true
        no_secret_read = $true
        no_write = $true
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 8
}
