param(
    [string]$PolicyPath = ".\config\sdu-org-policy.json",
    [string]$OutPath = ".\out\preflight-readback.md",
    [string]$LogPath = ".\logs\preflight.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
$policy = Read-SduJson $PolicyPath

Write-SduLog "Preflight iniciado" "INFO" $LogPath

$cwd = (Get-Location).Path
$gitStatus = $null
try { $gitStatus = git status --short 2>$null } catch { $gitStatus = "GIT_STATUS_ERROR" }
$gitBranch = $null
try { $gitBranch = git branch --show-current 2>$null } catch { $gitBranch = "GIT_BRANCH_ERROR" }

$commands = @("pwsh", "powershell", "git", "code-insiders", "ceo-runtime-status") | ForEach-Object { Get-SduCommandResolution $_ }
$codeInsidersVersion = $null
try { $codeInsidersVersion = (& code-insiders --version 2>$null) -join " | " } catch { $codeInsidersVersion = "NOT_AVAILABLE" }

$registries = @(
    "01_GOVERNANCE_REGISTRY\AGENT_REGISTRY.yaml",
    "01_GOVERNANCE_REGISTRY\RUNTIME_REGISTRY.yaml",
    "01_GOVERNANCE_REGISTRY\CONFIGURATION_REGISTRY.yaml",
    "01_GOVERNANCE_REGISTRY\UNIVERSE_REGISTRY.yaml",
    "01_GOVERNANCE_REGISTRY\ENVIRONMENT_REGISTRY.yaml",
    "01_GOVERNANCE_REGISTRY\BASELINE_REGISTRY.yaml",
    "C:\CEO\policy.json"
) | ForEach-Object {
    [pscustomobject]@{ Path=$_; Exists=(Test-Path $_) }
}

$readback = @()
$readback += "# Preflight Readback — SDU Organización Total"
$readback += ""
$readback += "Fecha UTC: $(Get-SduTimestamp)"
$readback += "CWD: `$cwd`"
$readback += "Runner: `$($policy.runner_id)`"
$readback += "Modo: `$($policy.mode)`"
$readback += ""
$readback += "## Git"
$readback += "- Branch: `$gitBranch`"
$readback += "- Status short:"
$readback += '```text'
$readback += ($gitStatus | Out-String).Trim()
$readback += '```'
$readback += ""
$readback += "## Comandos"
foreach ($c in $commands) { $readback += "- $($c.Name): Found=$($c.Found); Source=$($c.Source)" }
$readback += ""
$readback += "## VS Code Insiders"
$readback += "- Version: `$codeInsidersVersion`"
$readback += ""
$readback += "## Registros"
foreach ($r in $registries) { $readback += "- [$($r.Exists)] $($r.Path)" }
$readback += ""
$readback += "## Política"
$readback += "- dry_run_default: $($policy.dry_run_default)"
$readback += "- no_delete: $($policy.no_delete)"
$readback += "- no_overwrite: $($policy.no_overwrite)"
$readback += "- cross_universe_policy: $($policy.cross_universe_policy)"

$readback | Set-Content -LiteralPath $OutPath -Encoding UTF8
Write-SduLog "Preflight completado: $OutPath" "INFO" $LogPath
