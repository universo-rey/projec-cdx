param(
    [switch] $Json
)

$CanonicalRoot = 'C:\CEO\project-cdx'
$PhysicalAlias = 'C:\Users\enzo1\PROJEC CDX'
$WorkspaceStorage = Join-Path $env:APPDATA 'Code - Insiders\User\workspaceStorage'
$CanonicalUri = 'file:///c%3A/CEO/project-cdx'
$PhysicalUri = 'file:///c%3A/Users/enzo1/PROJEC%20CDX'

function Get-WorkspaceFolder {
    param([string] $Path)

    try {
        $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        if ($json.folder) {
            return [string]$json.folder
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-WorkspaceRole {
    param([string] $Folder)

    if ([string]::IsNullOrWhiteSpace($Folder)) {
        return 'UNREADABLE'
    }

    if ($Folder -ieq $CanonicalUri) {
        return 'CANONICAL_ACTIVE_CANDIDATE'
    }

    if ($Folder -ieq $PhysicalUri) {
        return 'PHYSICAL_ALIAS_RESIDUAL_HOLD'
    }

    if ($Folder -match 'project-cdx|PROJEC%20CDX|PROJEC CDX') {
        return 'PROJECT_CDX_VARIANT_REVIEW'
    }

    return 'OBSERVED'
}

$entries = @()
if (Test-Path -LiteralPath $WorkspaceStorage) {
    $entries = @(Get-ChildItem -LiteralPath $WorkspaceStorage -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
            $workspaceJson = Join-Path $_.FullName 'workspace.json'
            $folder = if (Test-Path -LiteralPath $workspaceJson) { Get-WorkspaceFolder -Path $workspaceJson } else { $null }
            [PSCustomObject]@{
                id = $_.Name
                workspace_json = $workspaceJson
                folder = $folder
                role = Get-WorkspaceRole -Folder $folder
                last_write_time = $_.LastWriteTime.ToString('yyyy-MM-ddTHH:mm:sszzz')
                sort_ticks = $_.LastWriteTimeUtc.Ticks
            }
        } | Sort-Object sort_ticks -Descending)
}

$projectEntries = @($entries | Where-Object { $_.role -ne 'UNREADABLE' })
$latest = $projectEntries | Select-Object -First 1
$unreadable = @($entries | Where-Object { $_.role -eq 'UNREADABLE' })
$canonical = @($entries | Where-Object { $_.role -eq 'CANONICAL_ACTIVE_CANDIDATE' })
$physical = @($entries | Where-Object { $_.role -eq 'PHYSICAL_ALIAS_RESIDUAL_HOLD' })
$projectVariants = @($entries | Where-Object { $_.role -eq 'PROJECT_CDX_VARIANT_REVIEW' })

$status = if ($latest -and $latest.role -eq 'CANONICAL_ACTIVE_CANDIDATE') {
    'IDE_WORKSPACE_IDENTITY_RECONCILED'
}
elseif ($latest -and $latest.role -eq 'PHYSICAL_ALIAS_RESIDUAL_HOLD') {
    'IDE_WORKSPACE_IDENTITY_WARN_PHYSICAL_ACTIVE'
}
elseif ($canonical.Count -gt 0) {
    'IDE_WORKSPACE_IDENTITY_CANONICAL_OBSERVED_NOT_LATEST'
}
else {
    'IDE_WORKSPACE_IDENTITY_CANONICAL_NOT_OBSERVED'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-workspace-reconcile'
    status = $status
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    identity = @{
        canonical_root = $CanonicalRoot
        physical_alias = $PhysicalAlias
        canonical_uri = $CanonicalUri
        physical_uri = $PhysicalUri
        policy = 'CANONICAL_ENTRY_ONLY_PHYSICAL_ALIAS_TARGET_ONLY'
    }
    workspace_storage = @{
        path = $WorkspaceStorage
        exists = (Test-Path -LiteralPath $WorkspaceStorage)
        total_entries = $entries.Count
        project_entries = $projectEntries.Count
        latest_project_entry = $latest
        ignored_unreadable_entries = $unreadable
        canonical_entries = $canonical
        physical_alias_residuals = $physical
        project_variants = $projectVariants
    }
    decision = @{
        delete_cache = $false
        delete_workspace_storage = $false
        open_command = 'tools/ceo-vscode-insiders-open.ps1 -DryRun -Json'
        next_if_warn = 'close physical workspace window and reopen with canonical open command'
    }
    frontera = @{
        no_cache_cleanup = $true
        no_workspaceStorage_delete = $true
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
