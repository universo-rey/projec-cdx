param(
    [string]$RoleMapPath = ".\config\agent-role-map.yaml",
    [string]$SelectedOut = ".\out\selected-agents.json",
    [string]$MapOut = ".\out\agent-role-map.md",
    [string]$PatchOut = ".\out\AGENT_REGISTRY.patch.yaml",
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
    $sources = @($found[$agent]) | Select-Object -Unique
    $status = if ($sources.Count -gt 0) { "existing" } else { "stub_required" }
    $source = if ($sources.Count -gt 0) { ($sources -join "; ") } else { "AGENT_REGISTRY.patch.yaml" }
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

$minimum = ($agents | Where-Object { $_.selection_status -in @("existing", "stub_required", "mapped_equivalent") }).Count -ge 3
$ideal = ($agents | Where-Object { $_.selection_status -eq "existing" }).Count -ge 5

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
