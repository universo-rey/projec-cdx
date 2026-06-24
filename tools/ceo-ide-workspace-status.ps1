param(
    [switch] $Json
)

$CanonicalRoot = 'C:\CEO\project-cdx'
$PhysicalAlias = 'C:\Users\enzo1\PROJEC CDX'
$ScriptRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$WorkspaceRoot = if (Test-Path -LiteralPath $CanonicalRoot) { $CanonicalRoot } else { $ScriptRoot }

function Convert-ToComparablePath {
    param([string] $Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    try {
        return ([System.IO.Path]::GetFullPath($Path)).TrimEnd('\', '/').ToLowerInvariant()
    }
    catch {
        return $Path.TrimEnd('\', '/').ToLowerInvariant()
    }
}

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

function Resolve-WorkspaceFolderPath {
    param(
        [string] $WorkspaceFile,
        [string] $FolderPath,
        [string] $FolderUri
    )

    if (-not [string]::IsNullOrWhiteSpace($FolderUri)) {
        try {
            $uri = [System.Uri]::new($FolderUri)
            if ($uri.IsFile) {
                return [System.Uri]::UnescapeDataString($uri.LocalPath)
            }
        }
        catch {
            return $FolderUri
        }
    }

    if ([string]::IsNullOrWhiteSpace($FolderPath)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($FolderPath)) {
        return [System.IO.Path]::GetFullPath($FolderPath)
    }

    $workspaceDir = Split-Path -Parent $WorkspaceFile
    return [System.IO.Path]::GetFullPath((Join-Path $workspaceDir $FolderPath))
}

function Get-FolderRole {
    param([string] $ResolvedPath)

    $resolved = Convert-ToComparablePath -Path $ResolvedPath
    $canonical = Convert-ToComparablePath -Path $CanonicalRoot
    $physical = Convert-ToComparablePath -Path $PhysicalAlias
    $ceoRoot = Convert-ToComparablePath -Path 'C:\CEO'
    $cabinaPrefix = Convert-ToComparablePath -Path (Join-Path $CanonicalRoot '.cabina')

    if ($resolved -eq $canonical) {
        return 'CORE_CANONICAL_ROOT'
    }

    if ($resolved -eq $physical) {
        return 'PHYSICAL_ALIAS_NOT_SECOND_WORKSPACE'
    }

    if ($resolved -eq $ceoRoot) {
        return 'CEO_ROOT_OBSERVED_NO_CORE'
    }

    if ($resolved -and $cabinaPrefix -and $resolved.StartsWith($cabinaPrefix)) {
        return 'CABINA_LOCAL_RUNTIME_OBSERVED_NO_ABSORB'
    }

    if ($resolved -and $canonical -and $resolved.StartsWith($canonical)) {
        return 'REPO_SUBPATH_OBSERVED'
    }

    return 'EXTERNAL_OR_LEGACY_OBSERVED_NO_CORE'
}

function Get-GitValue {
    param([string[]] $GitArgs)

    try {
        $value = & git -C $WorkspaceRoot @GitArgs 2>$null
        if ($LASTEXITCODE -eq 0) {
            return ($value | Select-Object -First 1)
        }
    }
    catch {
        return $null
    }

    return $null
}

$codeCommands = @(Get-Command code-insiders -All -ErrorAction SilentlyContinue)
$settingsPath = Join-Path $WorkspaceRoot '.vscode\settings.json'
$tasksPath = Join-Path $WorkspaceRoot '.vscode\tasks.json'
$mcpPath = Join-Path $WorkspaceRoot '.cursor\mcp.json'

$rootItem = Get-Item -LiteralPath $CanonicalRoot -Force -ErrorAction SilentlyContinue
$workspaceCandidates = @()
$workspaceCandidates += @(Get-ChildItem -LiteralPath $WorkspaceRoot -Filter '*.code-workspace' -File -ErrorAction SilentlyContinue)

$vscodeDir = Join-Path $WorkspaceRoot '.vscode'
if (Test-Path -LiteralPath $vscodeDir) {
    $workspaceCandidates += @(Get-ChildItem -LiteralPath $vscodeDir -Filter '*.code-workspace' -File -ErrorAction SilentlyContinue)
}

$cabinaDir = Join-Path $WorkspaceRoot '.cabina'
if (Test-Path -LiteralPath $cabinaDir) {
    $workspaceCandidates += @(Get-ChildItem -LiteralPath $cabinaDir -Filter '*.code-workspace' -File -Recurse -ErrorAction SilentlyContinue)
}

$workspaceFiles = @()
foreach ($file in ($workspaceCandidates | Sort-Object FullName -Unique)) {
    $jsonState = Test-JsonFile -Path $file.FullName
    $folders = @()
    $classification = 'UNREADABLE'

    if ($jsonState -eq 'ok') {
        $content = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        foreach ($folder in @($content.folders)) {
            $resolved = Resolve-WorkspaceFolderPath -WorkspaceFile $file.FullName -FolderPath $folder.path -FolderUri $folder.uri
            $folders += [PSCustomObject]@{
                name = $folder.name
                raw_path = $folder.path
                raw_uri = $folder.uri
                resolved_path = $resolved
                role = Get-FolderRole -ResolvedPath $resolved
            }
        }

        $roles = @($folders | ForEach-Object { $_.role })
        if ($roles -contains 'CEO_ROOT_OBSERVED_NO_CORE' -or $roles -contains 'CABINA_LOCAL_RUNTIME_OBSERVED_NO_ABSORB' -or $roles -contains 'EXTERNAL_OR_LEGACY_OBSERVED_NO_CORE') {
            $classification = 'OBSERVED_NO_CORE'
        }
        elseif ($roles -contains 'PHYSICAL_ALIAS_NOT_SECOND_WORKSPACE') {
            $classification = 'ALIAS_ONLY_DO_NOT_OPEN_AS_SECOND_PROJECT'
        }
        elseif ($roles -contains 'CORE_CANONICAL_ROOT') {
            $classification = 'CANONICAL_READY'
        }
        else {
            $classification = 'NO_CORE_REFERENCE'
        }
    }

    $workspaceFiles += [PSCustomObject]@{
        path = $file.FullName
        repo_path = $file.FullName.Replace($WorkspaceRoot, '').TrimStart('\')
        json = $jsonState
        classification = $classification
        folder_count = $folders.Count
        folders = $folders
    }
}

$nestedRepoCandidates = @()
$topLevelDirs = @(Get-ChildItem -LiteralPath $WorkspaceRoot -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -notin @('.git', '.venv', 'node_modules', '.pytest_cache', '.ruff_cache')
    })
$nestedRepoCandidates += $topLevelDirs
foreach ($dir in $topLevelDirs) {
    if ($dir.Name -in @('.cabina', 'repos', 'work', 'worktrees', 'packages', 'src')) {
        $nestedRepoCandidates += @(Get-ChildItem -LiteralPath $dir.FullName -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -notin @('.git', '.venv', 'node_modules')
            })
    }
}

$nestedRepos = @()
foreach ($dir in ($nestedRepoCandidates | Sort-Object FullName -Unique)) {
    $marker = Join-Path $dir.FullName '.git'
    if (Test-Path -LiteralPath $marker) {
        $nestedRepos += [PSCustomObject]@{
            path = $dir.FullName
            repo_path = $dir.FullName.Replace($WorkspaceRoot, '').TrimStart('\')
            classification = 'OBSERVED_NO_ABSORB'
        }
    }
}

$workspaceCoreReady = ($workspaceFiles.Count -eq 0) -or (@($workspaceFiles | Where-Object { $_.classification -in @('CANONICAL_READY', 'OBSERVED_NO_CORE') }).Count -eq $workspaceFiles.Count)
$status = if ((Test-Path -LiteralPath $CanonicalRoot) -and ($codeCommands.Count -gt 0) -and ((Test-JsonFile -Path $settingsPath) -eq 'ok') -and ((Test-JsonFile -Path $tasksPath) -eq 'ok') -and $workspaceCoreReady) {
    'IDE_WORKSPACE_CONTROL_READY'
}
else {
    'IDE_WORKSPACE_CONTROL_WARN'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-workspace-status'
    status = $status
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    workspace = @{
        canonical_root = $CanonicalRoot
        physical_alias = $PhysicalAlias
        script_root = $ScriptRoot
        effective_root = $WorkspaceRoot
        cwd = (Get-Location).Path
        canonical_exists = (Test-Path -LiteralPath $CanonicalRoot)
        canonical_link_type = if ($rootItem) { $rootItem.LinkType } else { $null }
        canonical_target = if ($rootItem) { @($rootItem.Target) } else { @() }
    }
    git = @{
        root = Get-GitValue -GitArgs @('rev-parse', '--show-toplevel')
        branch = Get-GitValue -GitArgs @('branch', '--show-current')
        head = Get-GitValue -GitArgs @('rev-parse', '--short', 'HEAD')
    }
    code_insiders = @{
        resolves = ($codeCommands.Count -gt 0)
        count = $codeCommands.Count
        first_path = if ($codeCommands.Count -gt 0) { $codeCommands[0].Source } else { $null }
    }
    local_config = @{
        settings = Test-JsonFile -Path $settingsPath
        tasks = Test-JsonFile -Path $tasksPath
        mcp = Test-JsonFile -Path $mcpPath
    }
    code_workspaces = @{
        count = $workspaceFiles.Count
        files = $workspaceFiles
    }
    nested_repos = @{
        count = $nestedRepos.Count
        policy = 'OBSERVE_ONLY_NO_ABSORB'
        repos = $nestedRepos
    }
    non_core_folders_policy = @{
        ceo_root = 'OBSERVED_NO_CORE'
        physical_alias = 'ALIAS_NOT_SECOND_WORKSPACE'
        cabina_runtime = 'LOCAL_RUNTIME_OBSERVED_NO_ABSORB'
        legacy = 'READ_ONLY'
    }
    frontera = @{
        no_delete = $true
        no_live = $true
        no_secret_read = $true
        no_mcp_execution = $true
        no_push = $true
        no_pr = $true
        no_absorb_nested_repos = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
