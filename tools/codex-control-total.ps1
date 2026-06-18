[CmdletBinding()]
param(
    [ValidateSet('Text', 'Json')]
    [string]$Format = 'Text',

    [string[]]$RepoPath,

    [switch]$Full,

    [switch]$ScanCodexRoot,

    [switch]$ScanGitHubRoot,

    [string]$GitHubRoot = 'C:\Users\enzo1\Documents\GitHub',

    [string]$CodexRoot = 'C:\Users\enzo1\.codex',

    [switch]$SkipProfileTest
)

$ErrorActionPreference = 'Stop'

$DefaultRepoPaths = @(
    'C:\Users\enzo1\Documents\GitHub\cabina-universal-d',
    'C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania',
    'C:\Users\enzo1\Documents\GitHub\seshat-bootstrap-sdu-cn',
    'C:\Users\enzo1\Documents\GitHub\tcu-agentic-runtime-control',
    'C:\Users\enzo1\Documents\GitHub\tge-agentic-runtime-control-escribania'
)

$FullRepoPaths = $DefaultRepoPaths + @(
    'C:\Users\enzo1\Documents\GitHub\microsoft-agents-governed-lab',
    'C:\Users\enzo1\Documents\GitHub\modo-on-foundation',
    'C:\Users\enzo1\Documents\GitHub\organizacion',
    'C:\Users\enzo1\Documents\GitHub\sgin-cumplimiento'
)

if ($ScanGitHubRoot) {
    if (Test-Path -LiteralPath $GitHubRoot) {
        $RepoPath = @(Get-ChildItem -LiteralPath $GitHubRoot -Directory | Sort-Object Name | ForEach-Object { $_.FullName })
    }
    else {
        $RepoPath = @()
    }
}
elseif (-not $RepoPath -or $RepoPath.Count -eq 0) {
    $RepoPath = if ($Full) { $FullRepoPaths } else { $DefaultRepoPaths }
}

$Checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [Parameter(Mandatory)][string]$Area,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('green', 'yellow', 'red')][string]$Status,
        [Parameter(Mandatory)][string]$Detail,
        [string]$Evidence = '',
        [string]$Recommendation = ''
    )

    $Checks.Add([pscustomobject]@{
        area = $Area
        name = $Name
        status = $Status
        detail = $Detail
        evidence = $Evidence
        recommendation = $Recommendation
    })
}

function Get-OverallStatus {
    param([object[]]$Items)

    if ($Items.status -contains 'red') { return 'red' }
    if ($Items.status -contains 'yellow') { return 'yellow' }
    return 'green'
}

function Invoke-ReadOnlyCommand {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$Arguments,
        [int]$TimeoutSeconds = 8
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $FilePath
    foreach ($arg in $Arguments) {
        [void]$psi.ArgumentList.Add($arg)
    }
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $psi
    [void]$process.Start()

    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        try { $process.Kill() } catch {}
        return [pscustomobject]@{
            exitCode = 124
            stdout = ''
            stderr = "Timeout after $TimeoutSeconds seconds"
        }
    }

    return [pscustomobject]@{
        exitCode = $process.ExitCode
        stdout = $process.StandardOutput.ReadToEnd()
        stderr = $process.StandardError.ReadToEnd()
    }
}

function Test-Tool {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Area
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) {
        Add-Check -Area $Area -Name $Name -Status green -Detail 'Disponible.' -Evidence $cmd.Source
    }
    else {
        Add-Check -Area $Area -Name $Name -Status yellow -Detail 'No disponible en PATH.' -Recommendation "Instalar o ajustar PATH solo si se necesita $Name."
    }
}

function Get-GitValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string[]]$Args
    )

    $result = Invoke-ReadOnlyCommand -FilePath 'git' -Arguments (@('-C', $Path) + $Args) -TimeoutSeconds 8
    if ($result.exitCode -ne 0) {
        return $null
    }
    return ($result.stdout.Trim())
}

function Get-CodexRootSummary {
    param(
        [Parameter(Mandatory)][string]$Root,
        [switch]$IncludeRecursive
    )

    $items = @(Get-ChildItem -LiteralPath $Root -Force)
    $summary = [ordered]@{
        directFolders = @($items | Where-Object { $_.PSIsContainer }).Count
        directFiles = @($items | Where-Object { -not $_.PSIsContainer }).Count
        directEntries = $items.Count
        versionedDirs = 0
        versionedBySurface = ''
        recursiveFolders = $null
        recursiveFiles = $null
        recursiveEntries = $null
    }

    $versionedParts = foreach ($surface in @('catalogo-local', 'hitos')) {
        $surfacePath = Join-Path $Root $surface
        if (-not (Test-Path -LiteralPath $surfacePath -PathType Container)) { continue }

        $count = @(Get-ChildItem -LiteralPath $surfacePath -Directory -Force | Where-Object { $_.Name -match '^\d{8}-v\d+$|^\d{8}-.*-v\d+$' }).Count
        if ($count -gt 0) {
            $summary.versionedDirs += $count
            "{0}={1}" -f $surface, $count
        }
    }

    $summary.versionedBySurface = ($versionedParts -join '; ')

    if ($IncludeRecursive) {
        $summary.recursiveFolders = @(Get-ChildItem -LiteralPath $Root -Directory -Recurse -Force).Count
        $summary.recursiveFiles = @(Get-ChildItem -LiteralPath $Root -File -Recurse -Force).Count
        $summary.recursiveEntries = [int]$summary.recursiveFolders + [int]$summary.recursiveFiles
    }

    return [pscustomobject]$summary
}

function Test-Repo {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Check -Area 'repos' -Name $Path -Status red -Detail 'Ruta no existe.' -Recommendation 'Verificar si el repo fue movido o archivado.'
        return
    }

    $inside = Get-GitValue -Path $Path -Args @('rev-parse', '--is-inside-work-tree')
    if ($inside -ne 'true') {
        Add-Check -Area 'repos' -Name $Path -Status yellow -Detail 'No es repo Git.' -Recommendation 'Clasificar como workspace/documentacion o excluir del control repo.'
        return
    }

    $root = Get-GitValue -Path $Path -Args @('rev-parse', '--show-toplevel')
    $branch = Get-GitValue -Path $Path -Args @('branch', '--show-current')
    if (-not $branch) { $branch = '(detached)' }

    $status = Get-GitValue -Path $Path -Args @('status', '--porcelain')
    $dirtyCount = 0
    if ($status) {
        $dirtyCount = (($status -split "`n") | Where-Object { $_.Trim().Length -gt 0 }).Count
    }

    $upstream = Get-GitValue -Path $Path -Args @('rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}')
    $ahead = 0
    $behind = 0
    if ($upstream) {
        $ab = Get-GitValue -Path $Path -Args @('rev-list', '--left-right', '--count', "$upstream...HEAD")
        if ($ab -match '^\s*(\d+)\s+(\d+)\s*$') {
            $behind = [int]$Matches[1]
            $ahead = [int]$Matches[2]
        }
    }

    $protected = $branch -in @('main', 'master')
    $statusColor = 'green'
    $detailParts = @("branch=$branch", "dirty=$dirtyCount", "ahead=$ahead", "behind=$behind")
    $recommendation = ''

    if ($dirtyCount -gt 0 -and $protected) {
        $statusColor = 'red'
        $recommendation = 'No tocar main/master con cambios locales; abrir rama o clasificar pendientes.'
    }
    elseif ($dirtyCount -gt 0) {
        $statusColor = 'yellow'
        $recommendation = 'Revisar diff antes de continuar.'
    }
    elseif ($protected) {
        $statusColor = 'yellow'
        $recommendation = 'Repo limpio en rama protegida; crear rama antes de cambios.'
    }
    elseif (-not $upstream) {
        $statusColor = 'yellow'
        $recommendation = 'Rama sin upstream; definir push target antes de publicar.'
    }

    Add-Check -Area 'repos' -Name (Split-Path -Leaf $root) -Status $statusColor -Detail ($detailParts -join '; ') -Evidence $root -Recommendation $recommendation
}

function Test-CodexRoot {
    $codexRoot = $CodexRoot
    if (-not (Test-Path -LiteralPath $codexRoot)) {
        Add-Check -Area 'codex-root' -Name '.codex root' -Status red -Detail 'No existe.' -Recommendation 'Restaurar o ubicar raiz real de Codex.'
        return
    }

    Add-Check -Area 'codex-root' -Name '.codex root' -Status green -Detail 'Existe.' -Evidence $codexRoot

    $inventory = Get-CodexRootSummary -Root $codexRoot -IncludeRecursive:$ScanCodexRoot
    Add-Check -Area 'codex-root' -Name 'inventory counts' -Status green -Detail ("direct_folders={0}; direct_files={1}; direct_entries={2}; versioned_dirs={3}" -f $inventory.directFolders, $inventory.directFiles, $inventory.directEntries, $inventory.versionedDirs) -Evidence ("versioned_by_surface={0}" -f $inventory.versionedBySurface)
    if ($ScanCodexRoot) {
        Add-Check -Area 'codex-root' -Name 'inventory recursive' -Status green -Detail ("recursive_folders={0}; recursive_files={1}; recursive_entries={2}" -f $inventory.recursiveFolders, $inventory.recursiveFiles, $inventory.recursiveEntries) -Evidence 'scan=root recursive'
    }

    $configPath = Join-Path $codexRoot 'config.toml'
    if (Test-Path -LiteralPath $configPath) {
        $shellLine = Select-String -Path $configPath -Pattern '^\s*integratedTerminalShell\s*=\s*"([^"]+)"' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($shellLine -and $shellLine.Line -match '"([^"]+)"') {
            $shell = $Matches[1]
            if ($shell -eq 'pwsh') {
                Add-Check -Area 'codex-root' -Name 'integrated terminal shell' -Status green -Detail 'Terminal integrada apunta a pwsh.' -Evidence $shellLine.Line.Trim()
            }
            else {
                Add-Check -Area 'codex-root' -Name 'integrated terminal shell' -Status red -Detail "Terminal integrada apunta a $shell." -Evidence $shellLine.Line.Trim() -Recommendation 'Preferir pwsh para evitar fallback a Windows PowerShell 5.1.'
            }
        }
        else {
            Add-Check -Area 'codex-root' -Name 'integrated terminal shell' -Status yellow -Detail 'No se encontro integratedTerminalShell.' -Recommendation 'Definir explicitamente pwsh si Codex vuelve a degradar terminal.'
        }
    }
    else {
        Add-Check -Area 'codex-root' -Name 'config.toml' -Status red -Detail 'No existe config.toml.' -Recommendation 'Revisar instalacion/configuracion de Codex.'
    }

    foreach ($item in @(
        @{ name = 'global-state'; path = Join-Path $codexRoot '.codex-global-state.json'; role = 'runtime state' },
        @{ name = 'global-state backup root'; path = Join-Path $codexRoot '.codex-global-state.json.bak'; role = 'root backup' },
        @{ name = 'sqlite state'; path = Join-Path $codexRoot 'sqlite\state_5.sqlite'; role = 'active sqlite state' },
        @{ name = 'sqlite logs'; path = Join-Path $codexRoot 'sqlite\logs_2.sqlite'; role = 'active sqlite logs' },
        @{ name = 'auth.json'; path = Join-Path $codexRoot 'auth.json'; role = 'sensitive marker only' },
        @{ name = 'cap_sid'; path = Join-Path $codexRoot 'cap_sid'; role = 'sensitive marker only' }
    )) {
        if (Test-Path -LiteralPath $item.path) {
            $file = Get-Item -LiteralPath $item.path -Force
            $color = if ($item.name -eq 'global-state backup root') { 'yellow' } else { 'green' }
            $rec = if ($item.name -eq 'global-state backup root') { 'Comparar generaciones antes de mover; no limpiar a ciegas.' } else { '' }
            Add-Check -Area 'codex-root' -Name $item.name -Status $color -Detail $item.role -Evidence ("{0}; bytes={1}; modified={2:s}" -f $file.FullName, $file.Length, $file.LastWriteTime) -Recommendation $rec
        }
        else {
            $color = if ($item.name -in @('auth.json', 'cap_sid')) { 'yellow' } else { 'red' }
            Add-Check -Area 'codex-root' -Name $item.name -Status $color -Detail 'No encontrado.' -Recommendation 'Confirmar si fue rotado, movido o si pertenece a otra instalacion.'
        }
    }
}

function Test-PowerShellLayer {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        $version = (& pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()').Trim()
        if ([version]$version -ge [version]'7.0.0') {
            Add-Check -Area 'powershell' -Name 'pwsh' -Status green -Detail "PowerShell moderno disponible: $version." -Evidence $pwsh.Source
        }
        else {
            Add-Check -Area 'powershell' -Name 'pwsh' -Status yellow -Detail "pwsh disponible pero antiguo: $version." -Evidence $pwsh.Source
        }
    }
    else {
        Add-Check -Area 'powershell' -Name 'pwsh' -Status red -Detail 'pwsh no disponible.' -Recommendation 'Instalar PowerShell 7.'
    }

    $profilePath = 'C:/Users/enzo1/Documents/PowerShell/Microsoft.PowerShell_profile.ps1'
    if (Test-Path -LiteralPath $profilePath) {
        $profile = Get-Item -LiteralPath $profilePath -Force
        $color = if ($profile.Length -eq 0) { 'green' } else { 'yellow' }
        $rec = if ($profile.Length -eq 0) { '' } else { 'Revisar que el perfil siga liviano y sin conexiones automaticas.' }
        Add-Check -Area 'powershell' -Name 'pwsh user profile' -Status $color -Detail 'Perfil de usuario detectado.' -Evidence ("{0}; bytes={1}" -f $profile.FullName, $profile.Length) -Recommendation $rec
    }
    else {
        Add-Check -Area 'powershell' -Name 'pwsh user profile' -Status green -Detail 'No hay perfil de usuario cargado.' -Evidence $profilePath
    }

    if (-not $SkipProfileTest) {
        $testScript = 'C:/Users/enzo1/PROJEC CDX/tools/test_codex_powershell_layout.ps1'
        if (Test-Path -LiteralPath $testScript) {
            $result = Invoke-ReadOnlyCommand -FilePath 'pwsh' -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $testScript) -TimeoutSeconds 15
            if ($result.exitCode -eq 0 -and $result.stdout -match 'LAYOUT_OK') {
                Add-Check -Area 'powershell' -Name 'codex profile layout' -Status green -Detail 'Layout de perfil Codex OK.' -Evidence 'LAYOUT_OK'
            }
            else {
                Add-Check -Area 'powershell' -Name 'codex profile layout' -Status red -Detail 'Fallo test de layout PowerShell.' -Evidence (($result.stdout + $result.stderr).Trim()) -Recommendation 'Revisar profiles/powershell antes de usar comandos on-demand.'
            }
        }
        else {
            Add-Check -Area 'powershell' -Name 'codex profile layout' -Status yellow -Detail 'No existe test local.' -Evidence $testScript
        }
    }
}

function Test-GuardianLayer {
    $guardian = "$env:USERPROFILE\.codex\plugins\operativa-guardian\scripts\estado-operativo.ps1"
    if (Test-Path -LiteralPath $guardian) {
        Add-Check -Area 'guardian' -Name 'operativa guardian' -Status green -Detail 'Script disponible.' -Evidence $guardian
    }
    else {
        Add-Check -Area 'guardian' -Name 'operativa guardian' -Status yellow -Detail 'Script no encontrado.' -Recommendation 'Revisar plugin operativa-guardian.'
    }
}

$startedAt = Get-Date

Test-Tool -Name 'git' -Area 'tools'
Test-Tool -Name 'gh' -Area 'tools'
Test-Tool -Name 'rg' -Area 'tools'
Test-Tool -Name 'python' -Area 'tools'

Test-PowerShellLayer
Test-CodexRoot
Test-GuardianLayer

foreach ($path in $RepoPath) {
    Test-Repo -Path $path
}

$finishedAt = Get-Date
$overall = Get-OverallStatus -Items $Checks
$report = [pscustomobject]@{
    generatedAt = $finishedAt.ToString('s')
    elapsedSeconds = [math]::Round(($finishedAt - $startedAt).TotalSeconds, 2)
    status = $overall
    checkCount = $Checks.Count
    counts = [pscustomobject]@{
        green = @($Checks | Where-Object status -eq 'green').Count
        yellow = @($Checks | Where-Object status -eq 'yellow').Count
        red = @($Checks | Where-Object status -eq 'red').Count
    }
    checks = $Checks
}

if ($Format -eq 'Json') {
    $report | ConvertTo-Json -Depth 8
    exit $(if ($overall -eq 'red') { 2 } elseif ($overall -eq 'yellow') { 1 } else { 0 })
}

Write-Host ("CODEX CONTROL TOTAL :: {0}" -f $overall.ToUpperInvariant())
Write-Host ("checks={0} green={1} yellow={2} red={3} elapsed={4}s" -f $report.checkCount, $report.counts.green, $report.counts.yellow, $report.counts.red, $report.elapsedSeconds)
Write-Host ''

foreach ($status in @('red', 'yellow', 'green')) {
    $items = @($Checks | Where-Object status -eq $status)
    if ($items.Count -eq 0) { continue }

    Write-Host ("[{0}]" -f $status.ToUpperInvariant())
    foreach ($item in $items) {
        Write-Host ("- {0} / {1}: {2}" -f $item.area, $item.name, $item.detail)
        if ($item.recommendation) {
            Write-Host ("  accion: {0}" -f $item.recommendation)
        }
    }
    Write-Host ''
}

exit $(if ($overall -eq 'red') { 2 } elseif ($overall -eq 'yellow') { 1 } else { 0 })
