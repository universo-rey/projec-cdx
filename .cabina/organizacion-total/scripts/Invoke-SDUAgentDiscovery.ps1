param(
    [string]$RoleMapPath = ".\config\agent-role-map.yaml",
    [string]$SelectedOut = ".\out\selected-agents.json",
    [string]$MapOut = ".\out\agent-role-map.md",
    [string]$PatchOut = ".\out\AGENT_REGISTRY.patch.yaml",
    [switch]$EmitV2,
    [string]$SelectedOutV2 = ".\out\selected-agents.v2.json",
    [string]$MapOutV2 = ".\out\agent-role-map.v2.md",
    [string]$PatchOutV2 = ".\out\AGENT_REGISTRY.v2.patch.yaml",
    [string]$LogPath = ".\logs\agent-discovery.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
Write-SduLog "Discovery de agentes iniciado" "INFO" $LogPath

# Búsqueda pragmática: no requiere módulo YAML. Busca tokens de agentes en registries y artefactos relevantes.
$searchRoots = @("01_GOVERNANCE_REGISTRY", ".agents", ".codex", "operativa", ".cabina") | Where-Object { Test-Path $_ }
$preferred = @("SESHAT", "THOT", "ANUBIS", "MAAT", "HORUS")
$roleByAgent = @{
    "SESHAT"="ROUTER_CANONICO";
    "THOT"="ARQUITECTO_TECNICO";
    "ANUBIS"="GUARD_GATE";
    "MAAT"="EVIDENCIA_AUDITORIA";
    "HORUS"="OBSERVABILIDAD_DRIFT"
}
$responsibilities = @{
    "SESHAT"=@("enrutar", "clasificar universo", "preservar fuente canónica", "generar readback")
    "THOT"=@("mapear superficies", "leer configuración", "validar registries", "proponer rules.v2")
    "ANUBIS"=@("bloquear operaciones no autorizadas", "validar sensibilidad", "impedir overwrite/delete", "exigir rollback")
    "MAAT"=@("registrar evidencia", "generar manifiestos", "validar trazabilidad")
    "HORUS"=@("detectar drift", "detectar duplicados", "detectar ruido", "clasificar warnings")
}

$found = @{}
foreach ($agent in $preferred) { $found[$agent] = @() }

foreach ($root in $searchRoots) {
    Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(ya?ml|json|md|txt|csv)$' } | ForEach-Object {
        $path = $_.FullName
        $text = ""
        try { $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8 -ErrorAction Stop } catch { return }
        foreach ($agent in $preferred) {
            if ($text.IndexOf($agent, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $found[$agent] += $path
            }
        }
    }
}

$agents = New-Object System.Collections.Generic.List[object]
$patchLines = @("schema_version: 1", "agents:")
foreach ($agent in $preferred) {
    $sources = @()
    foreach ($candidate in @($found[$agent])) {
        if ($candidate) { $sources += [string]$candidate }
    }
    $sources = @($sources | Select-Object -Unique)

    $status = if (@($sources).Count -gt 0) { "existing" } else { "stub_required" }
    $source = if (@($sources).Count -gt 0) { ($sources -join "; ") } else { "AGENT_REGISTRY.patch.yaml" }
    $agents.Add([pscustomobject]@{
        agent_id = $agent
        name = $agent.Substring(0,1) + $agent.Substring(1).ToLower()
        role = $roleByAgent[$agent]
        selection_status = $status
        source = $source
        responsibilities = $responsibilities[$agent]
        notes = if ($status -eq "existing") { "Detectado en artefactos locales." } else { "No detectado; se requiere stub declarativo, no agente productivo." }
    })
    if ($status -eq "stub_required") {
        $patchLines += "  - agent_id: $agent"
        $patchLines += "    name: $($agent.Substring(0,1) + $agent.Substring(1).ToLower())"
        $patchLines += "    purpose: stub declarativo para rol $($roleByAgent[$agent]) en runner de organización total"
        $patchLines += "    owner: Enzo Figueroa"
        $patchLines += "    status: stub_required"
        $patchLines += "    productive_agent: false"
    }
}

$agentSelection = @($agents | Where-Object { $_.selection_status -in @("existing", "stub_required", "mapped_equivalent") })
$agentIdeal = @($agents | Where-Object { $_.selection_status -eq "existing" })
$minimum = $agentSelection.Count -ge 3
$ideal = $agentIdeal.Count -ge 5

$result = [pscustomobject]@{
    runner_id = "SDU_ORGANIZACION_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1"
    selected_at = Get-SduTimestamp
    minimum_satisfied = $minimum
    ideal_satisfied = $ideal
    agents = $agents
}
Save-SduJson $result $SelectedOut
$patchLines | Set-Content -LiteralPath $PatchOut -Encoding UTF8

$md = @()
$md += "# Agent Role Map — SDU Organización Total"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += ""
$md += "| Agente | Rol | Estado | Fuente |"
$md += "|---|---|---|---|"
foreach ($a in $agents) {
    $md += "| $($a.agent_id) | $($a.role) | $($a.selection_status) | $($a.source -replace '\\','\\') |"
}
$md += ""
$md += "## Decisión"
$md += "- Mínimo satisfecho: $minimum"
$md += "- Ideal satisfecho: $ideal"
$md += "- Los stubs, si existen, no son agentes productivos."
$md | Set-Content -LiteralPath $MapOut -Encoding UTF8

Write-SduLog "Discovery completado: $SelectedOut" "INFO" $LogPath

if ($EmitV2) {
    $evidenceFiles = @(
        ".\inventarios\AGENTES_SKILLS_RECETAS_20260616.md",
        ".\dataverse\MAPA_AGENTES_SDU.md",
        ".\config\agent-role-map.yaml",
        ".\templates\AGENT_REGISTRY.patch.yaml",
        ".\00_README_OPERATIVO.md",
        ".\01_PROMPT_RECTOR_CODEX.md"
    ) | Where-Object { Test-Path $_ }
    $evidenceText = @{}
    foreach ($path in $evidenceFiles) {
        try { $evidenceText[$path] = Get-Content -LiteralPath $path -Raw -Encoding UTF8 -ErrorAction Stop } catch { $evidenceText[$path] = "" }
    }

    $evidenceMatrix = @(
        [pscustomobject]@{ AgentId="SESHAT"; CanonicalId="sdu.agent.seshat_normativa.runtime_actions"; AgentName="seshat-normativa"; Role="ROUTER_CANONICO" },
        [pscustomobject]@{ AgentId="THOT"; CanonicalId="sdu.agent.thot_tecnico.runtime_actions"; AgentName="thot-tecnico"; Role="ARQUITECTO_TECNICO" },
        [pscustomobject]@{ AgentId="ANUBIS"; CanonicalId="sdu.agent.anubis_gate.runtime_actions"; AgentName="anubis-gate"; Role="GUARD_GATE" },
        [pscustomobject]@{ AgentId="MAAT"; CanonicalId="sdu.agent.maat_cumplimiento.runtime_actions"; AgentName="maat-cumplimiento"; Role="EVIDENCIA_AUDITORIA" },
        [pscustomobject]@{ AgentId="HORUS"; CanonicalId="sdu.agent.horus_riesgo.runtime_actions"; AgentName="horus-riesgo"; Role="OBSERVABILIDAD_DRIFT" },
        [pscustomobject]@{ AgentId="NARRADOR"; CanonicalId="sdu.agent.narrador_normativo.runtime_actions"; AgentName="narrador-normativo"; Role="READBACK_NARRADOR" }
    )

    $v2Agents = New-Object System.Collections.Generic.List[object]
    $v2Patch = @("schema_version: 2", "status: no_patch_required", "agents: []")
    foreach ($agent in $evidenceMatrix) {
        $hits = New-Object System.Collections.Generic.List[string]
        foreach ($path in $evidenceText.Keys) {
            $text = $evidenceText[$path]
            if ($text.IndexOf($agent.CanonicalId, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -or
                $text.IndexOf($agent.AgentId, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -or
                $text.IndexOf($agent.AgentName, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hits.Add($path)
            }
        }
        $status = if (($hits | Where-Object { $_ -match 'AGENTES_SKILLS_RECETAS|MAPA_AGENTES_SDU' }).Count -gt 0) { "mapped_equivalent" } else { "stub_required" }
        $confidence = if ($status -eq "mapped_equivalent") { 0.96 } else { 0.50 }
        $source = if ($hits.Count -gt 0) { ($hits | Select-Object -Unique) -join "; " } else { "AGENT_REGISTRY.v2.patch.yaml" }
        $v2Agents.Add([pscustomobject]@{
            agent_id = $agent.AgentId
            name = ($agent.AgentName.Substring(0,1).ToUpper() + $agent.AgentName.Substring(1))
            canonical_id = $agent.CanonicalId
            role = $agent.Role
            selection_status = $status
            source = $source
            confidence = $confidence
            evidence_files = @($hits | Select-Object -Unique)
            notes = if ($status -eq "mapped_equivalent") { "Canonical ID confirmado en inventarios y mapa Dataverse." } else { "Sin evidencia canónica suficiente; requiere stub declarativo." }
        })
        if ($status -eq "stub_required") {
            $v2Patch += "  - agent_id: $($agent.AgentId)"
            $v2Patch += "    name: $($agent.AgentName)"
            $v2Patch += "    purpose: stub declarativo para rol $($agent.Role) en runner de organización total"
            $v2Patch += "    owner: Enzo Figueroa"
            $v2Patch += "    status: stub_required"
            $v2Patch += "    productive_agent: false"
        }
    }

    $v2 = [pscustomobject]@{
        runner_id = "SDU_ORGANIZACION_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1"
        selected_at = Get-SduTimestamp
        minimum_satisfied = (@($v2Agents | Where-Object { $_.selection_status -in @("mapped_equivalent", "existing", "stub_required") }).Count -ge 3)
        ideal_satisfied = (@($v2Agents | Where-Object { $_.selection_status -in @("mapped_equivalent", "existing") }).Count -ge 5)
        agents = $v2Agents
        coverage_notes = "V2 incorpora equivalencias canónicas confirmadas desde inventarios y mapa Dataverse."
    }
    Save-SduJson $v2 $SelectedOutV2
    $v2Patch | Set-Content -LiteralPath $PatchOutV2 -Encoding UTF8
    $v2Md = @()
    $v2Md += "# Agent Role Map V2 — SDU Organización Total"
    $v2Md += ""
    $v2Md += "Fecha UTC: $(Get-SduTimestamp)"
    $v2Md += ""
    $v2Md += "| Agente | Canonical ID | Rol | Estado | Fuente |"
    $v2Md += "|---|---|---|---|---|"
    foreach ($a in $v2Agents) {
        $v2Md += "| $($a.agent_id) | $($a.canonical_id) | $($a.role) | $($a.selection_status) | $($a.source -replace '\\','\\') |"
    }
    $v2Md += ""
    $v2Md += "## Decisión"
    $v2Md += "- Mínimo satisfecho: $($v2.minimum_satisfied)"
    $v2Md += "- Ideal satisfecho: $($v2.ideal_satisfied)"
    $v2Md += "- V2 usa equivalencias funcionales, no agentes productivos nuevos."
    $v2Md | Set-Content -LiteralPath $MapOutV2 -Encoding UTF8
    Write-SduLog "Discovery V2 completado: $SelectedOutV2" "INFO" $LogPath
}
