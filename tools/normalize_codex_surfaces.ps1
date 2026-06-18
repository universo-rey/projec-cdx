param(
    [string]$WorkspaceRoot = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

$stackPath = 'C:\Users\enzo1\.codex\skills\STACK.md'
$skillsIndexPath = 'C:\Users\enzo1\.codex\skills\SKILLS_INDEX.csv'

function Write-TextFileUtf8 {
    param(
        [string]$Path,
        [string]$Content
    )
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
}

$stackLines = Get-Content -LiteralPath $stackPath

$stack = ($stackLines -join [Environment]::NewLine)
$stack = $stack.Replace('`rey-modo-continuidad-sesion`', '`rey-modo-handoff-continuidad` *(alias: `rey-modo-continuidad-sesion`)*')
$stack = $stack.Replace('`rey-modo-salida-breve`', '`rey-modo-respuesta-breve` *(alias: `rey-modo-salida-breve`)*')
$stack = $stack.Replace('`rey-modo-sharepoint-safety-auditor`', '`rey-modo-auditor-sharepoint-seguro` *(alias: `rey-modo-sharepoint-safety-auditor`)*')
$stack = $stack.Replace('`sdu-live-sharepoint-audit`', '`sdu-auditor-sharepoint-vivo` *(alias: `sdu-live-sharepoint-audit`)*')
$stack = $stack.Replace('`sdu-snapshot-publisher`', '`sdu-publicador-snapshots` *(alias: `sdu-snapshot-publisher`)*')
$stack = $stack.Replace('`tcu-powerautomate-flow-auth-fix`', '`tcu-fix-auth-flows-power-automate` *(alias: `tcu-powerautomate-flow-auth-fix`)*')

if ($stack -notmatch 'SKILLS_UNIFIED_TABLE\.xlsx') {
    $stack = $stack -replace '(## Referencias\s*)', "$1`n- [SKILLS_UNIFIED_TABLE.xlsx](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.xlsx)`n"
}

$referenceStart = [Array]::IndexOf($stackLines, '## Referencias')
if ($referenceStart -ge 0) {
    $prefix = @()
    if ($referenceStart -gt 0) {
        $prefix = $stackLines[0..($referenceStart - 1)]
    }
    $newLines = New-Object System.Collections.Generic.List[string]
    foreach ($line in $prefix) {
        [void]$newLines.Add($line)
    }
    [void]$newLines.Add('## Referencias')
    [void]$newLines.Add('')
    [void]$newLines.Add('- [SKILLS_UNIFIED_TABLE.xlsx](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.xlsx)')
    [void]$newLines.Add('- [README.md](C:/Users/enzo1/.codex/skills/README.md)')
    [void]$newLines.Add('- [MATRIZ_OPERATIVA.md](C:/Users/enzo1/.codex/skills/MATRIZ_OPERATIVA.md)')
    [void]$newLines.Add('- [PROMPT_ARRANQUE.md](C:/Users/enzo1/.codex/skills/PROMPT_ARRANQUE.md)')
    [void]$newLines.Add('- [SKILLS_INDEX.csv](C:/Users/enzo1/.codex/skills/SKILLS_INDEX.csv)')
    $stack = ($newLines -join [Environment]::NewLine)
}

Write-TextFileUtf8 -Path $stackPath -Content $stack

$csv = Import-Csv -LiteralPath $skillsIndexPath
foreach ($row in $csv) {
    if ($row.skill_name -eq 'sdu-gate-executor') {
        $row.skill_name = 'sdu-ejecutor-gates'
        $row.note = 'skill file present; alias: sdu-gate-executor'
    }
}

$csv | Export-Csv -LiteralPath $skillsIndexPath -NoTypeInformation -Encoding utf8

Write-Host "Updated: $stackPath"
Write-Host "Updated: $skillsIndexPath"
