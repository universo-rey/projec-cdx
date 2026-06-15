[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$baseProfile = 'C:\Users\enzo1\.codex\profiles\powershell\base\Microsoft.PowerShell_profile.ps1'
$codexProfile = 'C:\Users\enzo1\.codex\profiles\powershell\CodexProfile.ps1'
$masterMap = 'C:\Users\enzo1\.codex\profiles\powershell\MAPA_MAESTRO.md'
$reference = 'C:\Users\enzo1\.codex\profiles\powershell\README.reference.md'
$bootstrapReadme = 'C:\Users\enzo1\.codex\profiles\powershell\base\README.md'
$onDemandReadme = 'C:\Users\enzo1\.codex\profiles\powershell\on-demand\README.md'
$scriptsReadme = 'C:\Users\enzo1\.codex\profiles\powershell\scripts\README.md'

if (-not (Test-Path -LiteralPath $baseProfile)) {
    throw "No existe el perfil base: $baseProfile"
}

if (-not (Test-Path -LiteralPath $codexProfile)) {
    throw "No existe el perfil Codex: $codexProfile"
}

foreach ($path in @($masterMap, $reference, $bootstrapReadme, $onDemandReadme, $scriptsReadme)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Falta documentación esperada: $path"
    }
}

. $baseProfile
. $codexProfile

if (Get-Command pretty -ErrorAction SilentlyContinue) {
    throw 'pretty no deberia existir antes de cargar codex-opt.'
}

if (Get-Command epp -ErrorAction SilentlyContinue) {
    throw 'epp no deberia existir antes de cargar codex-opt.'
}

codex-opt

$required = 'pretty', 'epp', 'copen', 'codex-help'
foreach ($name in $required) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Falta el comando requerido: $name"
    }
}

'LAYOUT_OK'
