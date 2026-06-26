param(
    [switch] $Json,
    [string] $Base = 'main',
    [string] $Version = 'v0.6.0-rc1'
)

$Root = 'C:\CEO\project-cdx'

function Invoke-GitRead {
    param([string[]] $GitArgs)

    try {
        $output = @(& git -C $Root @GitArgs 2>$null | ForEach-Object { [string]$_ })
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) {
            $exitCode = 0
        }
        return [PSCustomObject]@{
            ok = ($exitCode -eq 0)
            output = $output
            exit_code = $exitCode
        }
    }
    catch {
        return [PSCustomObject]@{
            ok = $false
            output = @($_.Exception.Message)
            exit_code = 1
        }
    }
}

$branchResult = Invoke-GitRead -GitArgs @('branch', '--show-current')
$headResult = Invoke-GitRead -GitArgs @('rev-parse', 'HEAD')
$shortHeadResult = Invoke-GitRead -GitArgs @('rev-parse', '--short', 'HEAD')
$statusResult = Invoke-GitRead -GitArgs @('status', '--short')
$diffResult = Invoke-GitRead -GitArgs @('diff', '--name-status')
$gitResults = @($branchResult, $headResult, $shortHeadResult, $statusResult, $diffResult)
$gitErrors = @($gitResults | Where-Object { -not $_.ok } | ForEach-Object {
    [PSCustomObject]@{
        exit_code = $_.exit_code
        output = @($_.output | Select-Object -First 4)
    }
})

$statusLines = @($statusResult.output)
$diffLines = @($diffResult.output)

$counts = [ordered]@{
    total_status_lines = $statusLines.Count
    staged = 0
    modified = 0
    deleted = 0
    untracked = 0
}

foreach ($line in $statusLines) {
    if ($line.StartsWith('??')) {
        $counts.untracked++
        continue
    }

    if ($line.Length -ge 2) {
        $indexState = $line.Substring(0, 1)
        $worktreeState = $line.Substring(1, 1)

        if ($indexState -ne ' ') { $counts.staged++ }
        if ($indexState -eq 'M' -or $worktreeState -eq 'M') { $counts.modified++ }
        if ($indexState -eq 'D' -or $worktreeState -eq 'D') { $counts.deleted++ }
    }
}

$payload = [PSCustomObject]@{
    command = 'ceo-github-pr-pack'
    status = if ($branchResult.ok -and $headResult.ok) { 'GITHUB_PR_PACK_READY_LOCAL_ONLY' } else { 'GITHUB_PR_PACK_WARN' }
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    root = $Root
    repository = 'universo-rey/projec-cdx'
    base = $Base
    branch = ($branchResult.output | Select-Object -First 1)
    head = ($headResult.output | Select-Object -First 1)
    short_head = ($shortHeadResult.output | Select-Object -First 1)
    version = $Version
    local_status = [PSCustomObject]$counts
    status_preview = @($statusLines | Select-Object -First 50)
    status_preview_truncated = $statusLines.Count -gt 50
    diff_name_status = if ($diffResult.ok) { @($diffLines | Select-Object -First 120) } else { @() }
    diff_name_status_truncated = $diffLines.Count -gt 120
    git_errors = $gitErrors
    pr_pack = [PSCustomObject]@{
        title = "[SDU] Publicacion gobernada $Version"
        body_sections = @(
            'Resumen',
            'Evidencia local',
            'Validaciones',
            'Frontera',
            'Rollback',
            'Postcheck'
        )
        decision = 'READY_FOR_OWNER_REMOTE_GATE'
        remote_write_allowed = $false
        pr_create_allowed = $false
    }
    gates = @('REMOTE_GATE', 'OWNER_GATE', 'ANUBIS_GATE')
    frontier = [PSCustomObject]@{
        no_push = $true
        no_pr = $true
        no_merge = $true
        no_tag_push = $true
        no_workflow_dispatch = $true
        no_secret_read = $true
        no_live = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 10
}
else {
    $payload
}
