param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$Venv = Join-Path $Root '.venv'
$VenvScripts = Join-Path $Venv 'Scripts'
$SettingsPath = Join-Path $Root '.vscode\settings.json'
$TasksPath = Join-Path $Root '.vscode\tasks.json'
$EnterScriptPath = Join-Path $Root 'tools\ceo-ide-terminal-enter.ps1'

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

function Get-CommandSources {
    param([string] $Name)

    @(Get-Command $Name -All -ErrorAction SilentlyContinue | Select-Object -First 8 | ForEach-Object {
        [PSCustomObject]@{
            name = $_.Name
            source = $_.Source
            command_type = $_.CommandType.ToString()
        }
    })
}

function Get-PathIndex {
    param(
        [string[]] $Paths,
        [string] $Needle
    )

    for ($i = 0; $i -lt $Paths.Count; $i++) {
        if ($Paths[$i].TrimEnd('\') -ieq $Needle.TrimEnd('\')) {
            return $i
        }
    }

    return -1
}

function Add-PathHead {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return
    }

    $current = @($env:PATH -split ';' | Where-Object { $_ })
    $alreadyPresent = @($current | Where-Object { $_.TrimEnd('\') -ieq $Path.TrimEnd('\') }).Count -gt 0
    if (-not $alreadyPresent) {
        $env:PATH = @($Path) + $current -join ';'
    }
}

function Get-ToolRole {
    param(
        [string] $Name,
        [string] $Source
    )

    if ([string]::IsNullOrWhiteSpace($Source)) {
        return 'NOT_FOUND'
    }

    if ($Name -eq 'python' -and $Source.StartsWith($VenvScripts, [System.StringComparison]::OrdinalIgnoreCase)) {
        return 'CEO_VENV_CANONICAL'
    }

    if ($Source -like '*\Microsoft\WindowsApps\*') {
        return 'WINDOWSAPPS_OBSERVED'
    }

    if ($Name -eq 'codex' -and $Source -like '*\AppData\Local\OpenAI\Codex\bin\*') {
        return 'CODEX_CLI_CANONICAL'
    }

    if ($Name -eq 'codex' -and $Source -like '*\.vscode-insiders\extensions\openai.chatgpt-*') {
        return 'VSCODE_EXTENSION_RUNTIME_OBSERVED'
    }

    if ($Name -eq 'node' -and ($Source -like '*\WinGet\Packages\OpenJS.NodeJS*' -or $Source -like '*\nodejs\*')) {
        return 'NODE_CANONICAL_AVAILABLE'
    }

    if ($Name -eq 'codeburn' -and ($Source -like '*\WinGet\Packages\OpenJS.NodeJS*\codeburn*' -or $Source -like '*\nodejs\codeburn*')) {
        return 'CODEBURN_CANONICAL_AVAILABLE'
    }

    if ($Name -eq 'pwsh' -and $Source -like 'C:\Program Files\PowerShell\7\pwsh.exe') {
        return 'POWERSHELL_7_CANONICAL'
    }

    return 'OBSERVED'
}

$settingsState = Test-JsonFile -Path $SettingsPath
$tasksState = Test-JsonFile -Path $TasksPath
$settings = if ($settingsState -eq 'ok') { Get-Content -LiteralPath $SettingsPath -Raw | ConvertFrom-Json } else { $null }
$profileName = if ($settings) { $settings.'terminal.integrated.defaultProfile.windows' } else { $null }
$profile = if ($settings -and $profileName) { $settings.'terminal.integrated.profiles.windows'.$profileName } else { $null }
$codeburnPath = if ($settings) { [string] $settings.'agileagentcanvas.codeburn.path' } else { $null }
$codeburnDir = if (-not [string]::IsNullOrWhiteSpace($codeburnPath)) { Split-Path -Parent $codeburnPath } else { $null }

$oldPath = $env:PATH
try {
    Add-PathHead -Path $codeburnDir
    Add-PathHead -Path $VenvScripts

    $toolNames = @('python', 'node', 'codeburn', 'codex', 'pwsh')
    $toolResolution = foreach ($toolName in $toolNames) {
        $sources = @(Get-CommandSources -Name $toolName)
        $first = if ($sources.Count -gt 0) { $sources[0].source } else { $null }
        [PSCustomObject]@{
            name = $toolName
            first = $first
            role = Get-ToolRole -Name $toolName -Source $first
            count = $sources.Count
            sources = $sources
        }
    }
}
finally {
    $env:PATH = $oldPath
}

$effectivePath = @()
if (Test-Path -LiteralPath $VenvScripts) {
    $effectivePath += $VenvScripts
}
if (-not [string]::IsNullOrWhiteSpace($codeburnDir) -and (Test-Path -LiteralPath $codeburnDir)) {
    $effectivePath += $codeburnDir
}
$effectivePath += @($oldPath -split ';' | Where-Object { $_ })
$windowsApps = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
$pathIndices = @{
    venvScripts = Get-PathIndex -Paths $effectivePath -Needle $VenvScripts
    codeburnDir = if (-not [string]::IsNullOrWhiteSpace($codeburnDir)) { Get-PathIndex -Paths $effectivePath -Needle $codeburnDir } else { -1 }
    windowsApps = Get-PathIndex -Paths $effectivePath -Needle $windowsApps
}

$profileArgs = @()
if ($profile -and $profile.args) {
    $profileArgs = @($profile.args)
}
$usesNoProfile = $profileArgs -contains '-NoProfile'
$usesEnterScript = @($profileArgs | Where-Object { $_ -ieq $EnterScriptPath }).Count -gt 0
$cwdReady = ($settings -and $settings.'terminal.integrated.cwd' -eq $Root)
$defaultReady = ($profileName -eq 'CEO PowerShell')
$pythonReady = @($toolResolution | Where-Object { $_.name -eq 'python' -and $_.role -eq 'CEO_VENV_CANONICAL' }).Count -gt 0
$nodeReady = @($toolResolution | Where-Object { $_.name -eq 'node' -and $_.role -eq 'NODE_CANONICAL_AVAILABLE' }).Count -gt 0
$codeburnReady = @($toolResolution | Where-Object { $_.name -eq 'codeburn' -and $_.role -eq 'CODEBURN_CANONICAL_AVAILABLE' }).Count -gt 0
$windowsAppsBehindRuntime = ($pathIndices.windowsApps -eq -1) -or (($pathIndices.venvScripts -ge 0) -and ($pathIndices.venvScripts -lt $pathIndices.windowsApps))

$processes = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -match '^(Code - Insiders|Code|Codex|codex|node|python|pwsh)$'
    } | Select-Object -First 80 | ForEach-Object {
        [PSCustomObject]@{
            name = $_.ProcessName
            id = $_.Id
            path = $_.Path
            role = if ($_.Path -like '*\WindowsApps\OpenAI.Codex_*') {
                'CODEX_DESKTOP_APP_OBSERVED'
            }
            elseif ($_.Path -like '*\.vscode-insiders\extensions\openai.chatgpt-*') {
                'VSCODE_EXTENSION_RUNTIME_OBSERVED'
            }
            elseif ($_.Path -like "$VenvScripts*") {
                'CEO_VENV_PROCESS'
            }
            elseif ($_.Path -like '*\WinGet\Packages\OpenJS.NodeJS*') {
                'NODE_CANONICAL_AVAILABLE'
            }
            elseif ($_.Path -like 'C:\Program Files\PowerShell\7\pwsh.exe') {
                'POWERSHELL_7_CANONICAL'
            }
            else {
                'OBSERVED'
            }
        }
    })

$status = if ($settingsState -eq 'ok' -and $tasksState -eq 'ok' -and $defaultReady -and $cwdReady -and $usesNoProfile -and $usesEnterScript -and $pythonReady -and $nodeReady -and $codeburnReady -and $windowsAppsBehindRuntime) {
    'IDE_TERMINAL_GOVERNED_READY'
}
else {
    'IDE_TERMINAL_GOVERNED_WARN'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-terminal-status'
    status = $status
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    workspace = @{
        root = $Root
        cwd = (Get-Location).Path
        venv_scripts = $VenvScripts
    }
    vscode_terminal = @{
        default_profile = $profileName
        profile_path = if ($profile) { $profile.path } else { $null }
        profile_args = $profileArgs
        cwd = if ($settings) { $settings.'terminal.integrated.cwd' } else { $null }
        uses_no_profile = $usesNoProfile
        uses_enter_script = $usesEnterScript
        enter_script = $EnterScriptPath
        user_profile_loaded_by_vscode_terminal = $false
    }
    local_config = @{
        settings = $settingsState
        tasks = $tasksState
    }
    path_control = @{
        windows_apps = $windowsApps
        codeburn_path = $codeburnPath
        codeburn_dir = $codeburnDir
        indices = $pathIndices
        windows_apps_behind_runtime = $windowsAppsBehindRuntime
    }
    tool_resolution = $toolResolution
    processes = @{
        count = $processes.Count
        observed = $processes
    }
    frontera = @{
        no_global_profile_edit = $true
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
