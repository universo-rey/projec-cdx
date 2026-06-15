param(
    [string]$WorkspaceRoot = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

$codexSkillsRoot = 'C:\Users\enzo1\.codex\skills'
$agentsSkillsRoot = 'C:\Users\enzo1\.agents\skills'
$agentsPluginManifest = 'C:\Users\enzo1\.agents\plugins\marketplace.json'
$codexStackPath = Join-Path $codexSkillsRoot 'STACK.md'
$codexIndexPath = Join-Path $codexSkillsRoot 'SKILLS_INDEX.csv'
$agentsRegistryPath = Join-Path $agentsSkillsRoot 'REY_MODO_SKILLS_REGISTRY_V1.md'

$outputCsv = Join-Path $WorkspaceRoot 'SKILLS_UNIFIED_TABLE.csv'
$outputMd = Join-Path $WorkspaceRoot 'SKILLS_UNIFIED_TABLE.md'

function Normalize-Text {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    return (($Text -replace '\s+', ' ').Trim()).Trim('"')
}

function Escape-MdCell {
    param([string]$Text)
    if ($null -eq $Text) { return '' }
    return ($Text -replace '\|', '\|')
}

function Get-SkillRecords {
    param(
        [string]$RootPath,
        [string]$RootLabel
    )

    Get-ChildItem -LiteralPath $RootPath -Recurse -Filter SKILL.md -File | ForEach-Object {
        $lines = Get-Content -LiteralPath $_.FullName -TotalCount 24
        $name = ''
        $description = ''

        foreach ($line in $lines) {
            if ($line -match '^name:\s*(.+)$') {
                $name = Normalize-Text $Matches[1]
                continue
            }
            if ($line -match '^description:\s*(.+)$') {
                $description = Normalize-Text $Matches[1]
                continue
            }
            if ($name -and $description) { break }
        }

        $folderName = Split-Path -Path (Split-Path -Path $_.FullName -Parent) -Leaf
        [pscustomobject]@{
            RootLabel    = $RootLabel
            Canonical    = $name
            FolderName   = $folderName
            SourcePath   = $_.FullName
            Purpose      = $description
        }
    }
}

function Get-CodexStackMap {
    param([string]$Path)

    $map = @{}
    $section = ''

    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        switch -Regex ($trimmed) {
            '^## Carril 1' { $section = 'Continuidad'; continue }
            '^## Carril 2' { $section = 'Arranque y Delegacion'; continue }
            '^## Carril 3' { $section = 'Vivo'; continue }
            '^### SharePoint Vivo' { $section = 'Vivo / SharePoint'; continue }
            '^### Dataverse Vivo' { $section = 'Vivo / Dataverse'; continue }
            '^- `([^`]+)`$' {
                if ($section) {
                    $map[$Matches[1]] = $section
                }
                continue
            }
        }
    }

    return $map
}

function Get-CodexFamily {
    param(
        [string]$Canonical,
        [hashtable]$StackMap
    )

    if ($StackMap.ContainsKey($Canonical)) {
        return $StackMap[$Canonical]
    }

    switch -Regex ($Canonical) {
        '^sdu-' { return 'Vivo / soporte' }
        '^dataverse-' { return 'Vivo / soporte' }
        '^rey-modo-' { return 'Continuidad / Rey Modo' }
        '^cabina-' { return 'Arranque y Delegacion / soporte' }
        '^parallel-' { return 'Arranque y Delegacion / soporte' }
        '^matrix-' { return 'Soporte / matrices' }
        '^skill-' { return 'Soporte / sistema' }
        '^mcp-' { return 'Soporte / tooling' }
        '^doc$' { return 'Soporte / documentos' }
        '^pdf$' { return 'Soporte / documentos' }
        '^playwright$' { return 'Soporte / navegacion' }
        '^cli-creator$' { return 'Soporte / tooling' }
        '^chatgpt-apps$' { return 'Soporte / apps' }
        '^agentation$' { return 'Soporte / frontend' }
        '^security-ownership-map$' { return 'Soporte / seguridad' }
        '^tcu-' { return 'Soporte / TCU' }
        default { return 'Soporte / tooling' }
    }
}

function Get-AgentsFamily {
    param([string]$Canonical)

    switch -Regex ($Canonical) {
        '^(tcu-descubridor-capacidades|tcu-despacho-agentes-paralelos|tcu-planificador-con-archivos|tcu-desarrollo-con-subagentes|tcu-redactor-planes-operativos)$' {
            return 'Descubrimiento / planificacion / subagentes'
        }
        '^rey-modo-' { return 'REY-MODO / gobierno' }
        '^tcu-' { return 'TCU / normalizacion / sistemas' }
        default { return 'Plugins / soporte' }
    }
}

function Get-ShortNote {
    param(
        [string]$Canonical,
        [string]$FolderName,
        [string]$RootLabel
    )

    $notes = New-Object System.Collections.Generic.List[string]

    if ($FolderName -and $FolderName -ne $Canonical) {
        $notes.Add("alias de archivo: $FolderName")
    }

    if ($Canonical -eq 'sdu-ejecutor-gates') {
        $notes.Add('alias de index: sdu-gate-executor')
    }

    if ($Canonical -eq 'rey-modo-gobernador-capacidades') {
        $notes.Add('alias de registry: rey-modo-gobierno-skills')
    }

    if ($RootLabel -eq '.agents/plugins' -and $Canonical -eq 'operativa-guardian') {
        $notes.Add('marketplace.json -> ./.codex/plugins/operativa-guardian')
    }

    return ($notes -join '; ')
}

function Get-PluginRecords {
    param([string]$ManifestPath)

    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    foreach ($plugin in $manifest.plugins) {
        [pscustomobject]@{
            RootLabel  = '.agents/plugins'
            Canonical  = $plugin.name
            FolderName = ''
            SourcePath = $plugin.source.path
            Purpose    = "Productivity plugin disponible via marketplace.json; instalación $($plugin.policy.installation), auth $($plugin.policy.authentication)."
            Family     = 'Plugins'
        }
    }
}

$stackMap = Get-CodexStackMap -Path $codexStackPath
$codexIndex = if (Test-Path -LiteralPath $codexIndexPath) { Import-Csv -LiteralPath $codexIndexPath } else { @() }

$records = New-Object System.Collections.Generic.List[object]

foreach ($skill in (Get-SkillRecords -RootPath $codexSkillsRoot -RootLabel '.codex/skills')) {
    $family = Get-CodexFamily -Canonical $skill.Canonical -StackMap $stackMap
    $record = [pscustomobject]@{
        RootLabel  = '.codex/skills'
        Kind       = 'skill'
        Family     = $family
        Canonical  = $skill.Canonical
        Alias      = $skill.FolderName
        Purpose    = $skill.Purpose
        SourcePath = $skill.SourcePath
        Notes      = Get-ShortNote -Canonical $skill.Canonical -FolderName $skill.FolderName -RootLabel '.codex/skills'
    }
    $records.Add($record)
}

foreach ($skill in (Get-SkillRecords -RootPath $agentsSkillsRoot -RootLabel '.agents/skills')) {
    $family = Get-AgentsFamily -Canonical $skill.Canonical
    $record = [pscustomobject]@{
        RootLabel  = '.agents/skills'
        Kind       = 'skill'
        Family     = $family
        Canonical  = $skill.Canonical
        Alias      = $skill.FolderName
        Purpose    = $skill.Purpose
        SourcePath = $skill.SourcePath
        Notes      = Get-ShortNote -Canonical $skill.Canonical -FolderName $skill.FolderName -RootLabel '.agents/skills'
    }
    $records.Add($record)
}

foreach ($plugin in (Get-PluginRecords -ManifestPath $agentsPluginManifest)) {
    $records.Add([pscustomobject]@{
        RootLabel  = '.agents/plugins'
        Kind       = 'plugin'
        Family     = $plugin.Family
        Canonical  = $plugin.Canonical
        Alias      = ''
        Purpose    = $plugin.Purpose
        SourcePath = $plugin.SourcePath
        Notes      = Get-ShortNote -Canonical $plugin.Canonical -FolderName '' -RootLabel '.agents/plugins'
    })
}

$ordered = $records | Sort-Object RootLabel, Family, Canonical

$ordered |
    Select-Object RootLabel, Kind, Family, Canonical, Alias, Purpose, SourcePath, Notes |
    Export-Csv -LiteralPath $outputCsv -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Tabla unica de skills')
$lines.Add('')
$lines.Add('Mapa unico de skills activas de `.codex` y `.agents` con raiz real, carril/familia y notas de drift.')
$lines.Add('')
$lines.Add('## Criterio')
$lines.Add('- `Canonical` = nombre visible en el `SKILL.md` o manifesto de plugin.')
$lines.Add('- `Alias` = carpeta o nombre alternativo cuando hay drift.')
$lines.Add('- `RootLabel` = raiz efectiva donde vive la capacidad.')
$lines.Add('- `Kind` = `skill` o `plugin`.')
$lines.Add('')

$summary = $ordered | Group-Object RootLabel | Sort-Object Name
$lines.Add('## Resumen')
$lines.Add('| Root | Count |')
$lines.Add('| --- | ---: |')
foreach ($group in $summary) {
    $lines.Add("| $($group.Name) | $($group.Count) |")
}
$lines.Add('')

foreach ($rootGroup in ($ordered | Group-Object RootLabel | Sort-Object Name)) {
    $lines.Add("## $($rootGroup.Name)")
    foreach ($familyGroup in ($rootGroup.Group | Group-Object Family | Sort-Object Name)) {
        $lines.Add('')
        $lines.Add("### $($familyGroup.Name)")
        $lines.Add('| Canonical | Alias / drift | Purpose | Notes |')
        $lines.Add('| --- | --- | --- | --- |')
        foreach ($item in ($familyGroup.Group | Sort-Object Canonical)) {
            $alias = if ([string]::IsNullOrWhiteSpace($item.Alias)) { '' } else { $item.Alias }
            $notes = if ([string]::IsNullOrWhiteSpace($item.Notes)) { '' } else { $item.Notes }
            $purpose = Normalize-Text $item.Purpose
            $lines.Add("| $(Escape-MdCell $item.Canonical) | $(Escape-MdCell $alias) | $(Escape-MdCell $purpose) | $(Escape-MdCell $notes) |")
        }
    }
    $lines.Add('')
}

Set-Content -LiteralPath $outputMd -Value ($lines -join [Environment]::NewLine) -Encoding UTF8

Write-Host "Wrote: $outputMd"
Write-Host "Wrote: $outputCsv"

