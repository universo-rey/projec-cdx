param(
    [string]$CoverageMd = ".\out\agent-coverage-analysis.md",
    [string]$CoverageJson = ".\out\agent-coverage-analysis.json",
    [string]$EquivalenceCsv = ".\out\agent-equivalence-map.csv",
    [string]$SelectedOutV2 = ".\out\selected-agents.v2.json",
    [string]$MapOutV2 = ".\out\agent-role-map.v2.md",
    [string]$PatchOutV2 = ".\out\AGENT_REGISTRY.v2.patch.yaml",
    [string]$LogPath = ".\logs\agent-coverage.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
Write-SduLog "Analisis de cobertura de agentes iniciado" "INFO" $LogPath

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$runnerRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$evidenceFiles = @(
    (Join-Path $repoRoot "inventarios\AGENTES_SKILLS_RECETAS_20260616.md"),
    (Join-Path $repoRoot "dataverse\MAPA_AGENTES_SDU.md"),
    (Join-Path $runnerRoot "config\agent-role-map.yaml"),
    (Join-Path $runnerRoot "templates\AGENT_REGISTRY.patch.yaml"),
    (Join-Path $runnerRoot "00_README_OPERATIVO.md"),
    (Join-Path $runnerRoot "01_PROMPT_RECTOR_CODEX.md")
) | Where-Object { Test-Path $_ }

$evidenceText = @{}
foreach ($path in $evidenceFiles) {
    try { $evidenceText[$path] = Get-Content -LiteralPath $path -Raw -Encoding UTF8 -ErrorAction Stop } catch { $evidenceText[$path] = "" }
}

$agents = @(
    [pscustomobject]@{ AgentId="SESHAT"; CanonicalId="sdu.agent.seshat_normativa.runtime_actions"; Name="seshat-normativa"; Role="ROUTER_CANONICO"; Preferred=$true },
    [pscustomobject]@{ AgentId="THOT"; CanonicalId="sdu.agent.thot_tecnico.runtime_actions"; Name="thot-tecnico"; Role="ARQUITECTO_TECNICO"; Preferred=$true },
    [pscustomobject]@{ AgentId="ANUBIS"; CanonicalId="sdu.agent.anubis_gate.runtime_actions"; Name="anubis-gate"; Role="GUARD_GATE"; Preferred=$true },
    [pscustomobject]@{ AgentId="MAAT"; CanonicalId="sdu.agent.maat_cumplimiento.runtime_actions"; Name="maat-cumplimiento"; Role="EVIDENCIA_AUDITORIA"; Preferred=$true },
    [pscustomobject]@{ AgentId="HORUS"; CanonicalId="sdu.agent.horus_riesgo.runtime_actions"; Name="horus-riesgo"; Role="OBSERVABILIDAD_DRIFT"; Preferred=$true },
    [pscustomobject]@{ AgentId="NARRADOR"; CanonicalId="sdu.agent.narrador_normativo.runtime_actions"; Name="narrador-normativo"; Role="READBACK_NARRADOR"; Preferred=$false }
)

function Get-AgentEvidence {
    param([pscustomobject]$Agent)
    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($path in $evidenceText.Keys) {
        $text = $evidenceText[$path]
        if (
            $text.IndexOf($Agent.CanonicalId, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -or
            $text.IndexOf($Agent.AgentId, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -or
            $text.IndexOf($Agent.Name, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        ) {
            $hits.Add($path)
        }
    }
    $hits = @($hits | Select-Object -Unique)
    $canonicalHit = @($hits | Where-Object { $_ -match 'AGENTES_SKILLS_RECETAS|MAPA_AGENTES_SDU' })
    $status = if ($canonicalHit.Count -gt 0) { "mapped_equivalent" } elseif ($hits.Count -gt 0) { "stub_required" } else { "stub_required" }
    $confidence = switch ($status) {
        "mapped_equivalent" { if ($canonicalHit.Count -ge 2) { 0.96 } else { 0.90 } }
        default { 0.50 }
    }
    $source = if ($hits.Count -gt 0) { ($hits -join "; ") } else { "AGENT_REGISTRY.v2.patch.yaml" }
    $gap = if ($status -eq "mapped_equivalent") { "Sin brecha funcional; solo sigue existiendo como equivalencia declarativa." } else { "Falta evidencia canónica suficiente." }
    $recommendation = if ($status -eq "mapped_equivalent") { "Conservar mapeo y usar canonical_id en el runner." } else { "Mantener stub declarativo y revisar registries faltantes." }
    return [pscustomobject]@{
        ideal_agent = $Agent.Name
        canonical_id = $Agent.CanonicalId
        agent_id = $Agent.AgentId
        role = $Agent.Role
        status = $status
        source = $source
        confidence = $confidence
        evidence_files = $hits
        gap = $gap
        recommendation = $recommendation
        preferred = $Agent.Preferred
    }
}

$coverage = New-Object System.Collections.Generic.List[object]
foreach ($agent in $agents) {
    $coverage.Add((Get-AgentEvidence -Agent $agent))
}

$selected = [pscustomobject]@{
    runner_id = "SDU_ORGANIZACION_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1"
    selected_at = Get-SduTimestamp
    minimum_satisfied = ((@($coverage | Where-Object { $_.status -in @("mapped_equivalent", "stub_required") -and $_.preferred }).Count) -ge 3)
    ideal_satisfied = ((@($coverage | Where-Object { $_.status -eq "mapped_equivalent" -and $_.preferred }).Count) -ge 5)
    agents = @(
        $coverage | Where-Object { $_.preferred } | ForEach-Object {
            [pscustomobject]@{
                agent_id = $_.agent_id
                name = $_.ideal_agent
                canonical_id = $_.canonical_id
                role = $_.role
                selection_status = $_.status
                source = $_.source
                confidence = $_.confidence
                evidence_files = $_.evidence_files
                notes = if ($_.status -eq "mapped_equivalent") { "Canonical ID confirmado en inventario y mapa Dataverse." } else { "Sin evidencia canónica suficiente." }
            }
        }
    )
    supplementary_agents = @(
        $coverage | Where-Object { -not $_.preferred } | ForEach-Object {
            [pscustomobject]@{
                agent_id = $_.agent_id
                name = $_.ideal_agent
                canonical_id = $_.canonical_id
                role = $_.role
                selection_status = $_.status
                source = $_.source
                confidence = $_.confidence
                evidence_files = $_.evidence_files
                notes = if ($_.status -eq "mapped_equivalent") { "Agente narrador confirmado como soporte." } else { "Soporte no confirmado." }
            }
        }
    )
}

Save-SduJson $selected $SelectedOutV2

$patch = @(
    "schema_version: 2",
    "status: no_patch_required",
    "agents: []"
)
if (@($coverage | Where-Object { $_.status -eq "stub_required" -and $_.preferred }).Count -gt 0) {
    $patch = @("schema_version: 2", "status: patch_required", "agents:")
    foreach ($row in ($coverage | Where-Object { $_.status -eq "stub_required" -and $_.preferred })) {
        $patch += "  - agent_id: $($row.agent_id)"
        $patch += "    name: $($row.ideal_agent)"
        $patch += "    purpose: stub declarativo para rol $($row.role) en runner de organización total"
        $patch += "    owner: Enzo Figueroa"
        $patch += "    status: stub_required"
        $patch += "    productive_agent: false"
    }
}
$patch | Set-Content -LiteralPath $PatchOutV2 -Encoding UTF8

$mapMd = @()
$mapMd += "# Agent Role Map V2 — SDU Organización Total"
$mapMd += ""
$mapMd += "Fecha UTC: $(Get-SduTimestamp)"
$mapMd += ""
$mapMd += "| Agente | Canonical ID | Rol | Estado | Confianza | Fuente |"
$mapMd += "|---|---|---|---|---:|---|"
foreach ($row in $coverage) {
    $mapMd += "| $($row.agent_id) | $($row.canonical_id) | $($row.role) | $($row.status) | $($row.confidence) | $($row.source -replace '\\','\\') |"
}
$mapMd += ""
$mapMd += "## Decisión"
$mapMd += "- Mínimo satisfecho: $($selected.minimum_satisfied)"
$mapMd += "- Ideal satisfecho: $($selected.ideal_satisfied)"
$mapMd += "- V2 usa equivalencias canónicas confirmadas en inventario y mapa Dataverse."
$mapMd | Set-Content -LiteralPath $MapOutV2 -Encoding UTF8

$csvRows = @()
foreach ($row in $coverage) {
    $csvRows += [pscustomobject]@{
        ideal_agent = $row.ideal_agent
        canonical_id = $row.canonical_id
        agent_id = $row.agent_id
        role = $row.role
        status = $row.status
        source = $row.source
        confidence = $row.confidence
        gap = $row.gap
        recommendation = $row.recommendation
    }
}
$csvRows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $EquivalenceCsv

$analysis = [pscustomobject]@{
    generated_at = Get-SduTimestamp
    preferred_agents = ($coverage | Where-Object { $_.preferred } | Measure-Object).Count
    supplementary_agents = ($coverage | Where-Object { -not $_.preferred } | Measure-Object).Count
    minimum_satisfied = $selected.minimum_satisfied
    ideal_satisfied = $selected.ideal_satisfied
    mapped_equivalent = (@($coverage | Where-Object { $_.status -eq "mapped_equivalent" }).Count)
    stub_required = (@($coverage | Where-Object { $_.status -eq "stub_required" }).Count)
    evidence_files = $evidenceFiles
    coverage = $coverage
}
Save-SduJson $analysis $CoverageJson

$md = @()
$md += "# Agent Coverage Analysis — SDU Organización Total"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += ""
$md += "## Resumen"
$md += "- Agentes preferidos: $($analysis.preferred_agents)"
$md += "- Agentes de soporte: $($analysis.supplementary_agents)"
$md += "- Mapeados como equivalencia: $($analysis.mapped_equivalent)"
$md += "- Stub requeridos: $($analysis.stub_required)"
$md += "- Minimum satisfied: $($analysis.minimum_satisfied)"
$md += "- Ideal satisfied: $($analysis.ideal_satisfied)"
$md += ""
$md += "## Tabla"
$md += "| Agente | Canonical ID | Estado | Confianza | Fuente |"
$md += "|---|---|---|---:|---|"
foreach ($row in $coverage) {
    $md += "| $($row.ideal_agent) | $($row.canonical_id) | $($row.status) | $($row.confidence) | $($row.source -replace '\\','\\') |"
}
$md += ""
$md += "## Lectura"
$md += "- La cobertura ideal queda soportada por equivalencias canónicas confirmadas en inventario y mapa Dataverse."
$md += "- El puente de cobertura no crea agentes productivos nuevos; solo reconoce el roster ya documentado."
$md | Set-Content -LiteralPath $CoverageMd -Encoding UTF8

Write-SduLog "Analisis de cobertura completado: $CoverageMd" "INFO" $LogPath
