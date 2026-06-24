param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$MapPath = Join-Path $Root 'operativa\tasks\20260623\SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv'

$map = @()
if (Test-Path -LiteralPath $MapPath) {
    $map = @(Import-Csv -LiteralPath $MapPath)
}

$gateRows = @($map | Group-Object gate | Sort-Object Name | ForEach-Object {
    $rows = @($_.Group)
    [PSCustomObject]@{
        gate = $_.Name
        nodes = @($rows | ForEach-Object { $_.node })
        count = $_.Count
        statuses = @($rows | Select-Object -ExpandProperty status -Unique)
        external_write_allowed = $false
        owner_required = $true
    }
})

$commands = @(
    'tools\ceo-ide-to-codex-pack.ps1',
    'tools\ceo-github-pr-pack.ps1',
    'tools\ceo-dataverse-memory-delta.ps1',
    'tools\ceo-sharepoint-evidence-pack.ps1',
    'tools\ceo-integration-gates-status.ps1'
)

$commandStatus = @($commands | ForEach-Object {
    $fullPath = Join-Path $Root $_
    [PSCustomObject]@{
        command = $_.Replace('\', '/')
        exists = Test-Path -LiteralPath $fullPath
    }
})

$missingCommands = @($commandStatus | Where-Object { -not $_.exists })

$payload = [PSCustomObject]@{
    command = 'ceo-integration-gates-status'
    status = if ($map.Count -gt 0 -and $missingCommands.Count -eq 0) { 'INTEGRATION_GATES_STATUS_READY' } else { 'INTEGRATION_GATES_STATUS_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    gates = $gateRows
    packet_commands = $commandStatus
    missing_packet_commands = $missingCommands
    decision = 'ALL_EXTERNAL_ACTIONS_BLOCKED_WITHOUT_GATE'
    frontier = [PSCustomObject]@{
        no_push = $true
        no_pr = $true
        no_live = $true
        no_openai_api_call = $true
        no_dataverse_write = $true
        no_sharepoint_publish = $true
        no_power_platform_mutation = $true
        no_teams_post = $true
        no_secret_read = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 10
}
else {
    $payload
}

$global:LASTEXITCODE = 0
