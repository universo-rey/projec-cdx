param(
    [switch]$Execute,
    [switch]$AsJson,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# ====================================
# CEO STATUS - FINAL COMPLETE VERSION
# ====================================

if ($Help) {
    Write-Host ""
    Write-Host "CEO STATUS - HELP"
    Write-Host "Uso:"
    Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\ceo-status.ps1"
    Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\ceo-status.ps1 -Execute"
    Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\ceo-status.ps1 -AsJson"
    Write-Host ""
    Write-Host "Opciones:"
    Write-Host "  -Execute  Ejecuta la inspección sugerida (solo lectura)"
    Write-Host "  -AsJson   Devuelve salida en JSON"
    Write-Host "  -Help     Muestra esta ayuda"
    Write-Host ""
    return
}

# -----------------------------
# PATHS
# -----------------------------
$projectRoot = Split-Path -Parent $PSScriptRoot
$fedPath = Join-Path $projectRoot "contracts\federation-map.json"

if (-not (Test-Path -LiteralPath $fedPath)) {
    Write-Error "federation-map.json no encontrado en $fedPath"
    return
}

# -----------------------------
# LOAD FEDERATION
# -----------------------------
$fed = Get-Content -LiteralPath $fedPath -Raw | ConvertFrom-Json
$repos = $fed.repos

if (-not $repos -or $repos.Count -eq 0) {
    Write-Error "No se encontraron repos en federation-map.json"
    return
}

$activeRepo = $repos | Where-Object { $_.status -eq "active" } | Select-Object -First 1
if (-not $activeRepo) {
    Write-Error "No se encontró repo activo en federation-map.json"
    return
}

$runtimeRoot = $activeRepo.runtimePointer.canonicalRuntimeRoot

# -----------------------------
# COUNTS
# -----------------------------
$aligned   = ($repos | Where-Object { $_.alignmentStatus -eq "aligned" }).Count
$partial   = ($repos | Where-Object { $_.alignmentStatus -eq "partial" }).Count
$pending   = ($repos | Where-Object { $_.alignmentStatus -eq "pending" }).Count
$reference = ($repos | Where-Object { $_.status -eq "reference" }).Count
$totalRepos = $repos.Count

# -----------------------------
# ALERTAS (CONFIGURABLES)
# Sustituye estos 0 por contadores reales cuando estén conectados
# -----------------------------
$AlertState = [ordered]@{
    MetadatosIncompletos      = 0
    VencidasRevision          = 0
    ConPII                    = 0
    EnlacesODependenciasRotos = 0
    DuplicidadesMadreAlias    = 0

    GateLTOkKO                = 0
    GateEvidenciaInsuficiente = 0
    MitigacionesVencidas      = 0
    AlertasCriticasAbiertas   = 0
    CalendarioRegulatorio     = 0
    MetadataDocumentalKO      = 0
}

$alerts = @(
    [PSCustomObject]@{ Name="Metadatos incompletos";      Count=[int]$AlertState.MetadatosIncompletos;      Severity="Alta";    Area="RFA-U"; Action="Completar metadatos núcleo" }
    [PSCustomObject]@{ Name="Vencidas de revisión";        Count=[int]$AlertState.VencidasRevision;          Severity="Media";   Area="RFA-U"; Action="Revisar vigencia editorial" }
    [PSCustomObject]@{ Name="Contenidos con PII";          Count=[int]$AlertState.ConPII;                    Severity="Crítica"; Area="RFA-U"; Action="Revisar permisos y sensibilidad" }
    [PSCustomObject]@{ Name="Enlaces/dependencias rotos";  Count=[int]$AlertState.EnlacesODependenciasRotos; Severity="Alta";    Area="RFA-U"; Action="Remediar enlaces y dependencias" }
    [PSCustomObject]@{ Name="Duplicidades Madre-Alias";    Count=[int]$AlertState.DuplicidadesMadreAlias;    Severity="Alta";    Area="RFA-U"; Action="Consolidar fuente única / alias" }

    [PSCustomObject]@{ Name="Gate LT OK KO";               Count=[int]$AlertState.GateLTOkKO;                Severity="Alta";    Area="CMP";   Action="Bloquear salida" }
    [PSCustomObject]@{ Name="Evidencia insuficiente";      Count=[int]$AlertState.GateEvidenciaInsuficiente; Severity="Crítica"; Area="CMP";   Action="No permitir cierre" }
    [PSCustomObject]@{ Name="Mitigaciones vencidas";       Count=[int]$AlertState.MitigacionesVencidas;      Severity="Alta";    Area="CMP";   Action="Escalar mitigación" }
    [PSCustomObject]@{ Name="Alertas críticas";            Count=[int]$AlertState.AlertasCriticasAbiertas;   Severity="Crítica"; Area="CMP";   Action="Escalar inmediatamente" }
    [PSCustomObject]@{ Name="Calendario regulatorio";      Count=[int]$AlertState.CalendarioRegulatorio;     Severity="Media";   Area="CMP";   Action="Recordar y escalar vencimientos" }
    [PSCustomObject]@{ Name="Metadata documental KO";      Count=[int]$AlertState.MetadataDocumentalKO;      Severity="Media";   Area="CMP";   Action="Asignar responsable y completar" }
) | Where-Object { $_.Count -gt 0 }

$totalAlerts    = ($alerts | Measure-Object).Count
$criticalAlerts = ($alerts | Where-Object { $_.Severity -eq "Crítica" } | Measure-Object).Count

# -----------------------------
# TOP DECISIONES
# -----------------------------
$decisions = @()

# Decisiones por alineación
if ($pending -gt 5) {
    $decisions += [PSCustomObject]@{
        Name      = "Alinear repos de dominio"
        Source    = "Alignment"
        Impact    = 3
        Frequency = 3
        Blocker   = 2
        Why       = "Hay más de 5 repos pending"
    }
}

if ($partial -gt 0) {
    $decisions += [PSCustomObject]@{
        Name      = "Cerrar partial críticos"
        Source    = "Alignment"
        Impact    = 2
        Frequency = 2
        Blocker   = 2
        Why       = "Persisten repos partial"
    }
}

# Decisiones por alertas
foreach ($a in $alerts) {
    $impact = 1
    $blocker = 1
    if ($a.Severity -eq "Alta")    { $impact = 2; $blocker = 2 }
    if ($a.Severity -eq "Crítica") { $impact = 3; $blocker = 3 }

    $frequency = 1
    if ($a.Count -ge 5)  { $frequency = 2 }
    if ($a.Count -ge 10) { $frequency = 3 }

    $decisions += [PSCustomObject]@{
        Name      = $a.Action
        Source    = $a.Name
        Impact    = $impact
        Frequency = $frequency
        Blocker   = $blocker
        Why       = "$($a.Count) caso(s) en '$($a.Name)'"
    }
}

$ranked = $decisions | ForEach-Object {
    $score = $_.Impact + $_.Frequency + $_.Blocker
    $_ | Add-Member -NotePropertyName Score -NotePropertyValue $score -PassThru
} | Sort-Object -Property @{Expression='Score';Descending=$true}, @{Expression='Name';Descending=$false}

$topDecision = $null
if ($ranked.Count -gt 0) {
    $topDecision = $ranked | Select-Object -First 1
}

# -----------------------------
# FOCO / AUTO-ACCIÓN / CHECKLIST
# -----------------------------
$focus        = $null
$actionName   = $null
$actionReason = $null
$commandText  = $null
$actionScript = $null
$checklist    = @()

if ($pending -gt 0) {
    $focus        = "Fase 3.1 dominio (sgin / sgin-cumplimiento)"
    $actionName   = "Alinear repos de dominio"
    $actionReason = "Hay repos con alignmentStatus = pending; el foco actual es sgin / sgin-cumplimiento."
    $commandText  = '$repos | Where-Object { $_.repoId -in @(''sgin'',''sgin-cumplimiento'') } | Select-Object repoId, remote, status, alignmentStatus, role, canonicalPath, @{N=''mode'';E={$_.runtimePointer.mode}}, @{N=''copyRuntime'';E={$_.runtimePointer.copyRuntime}} | Format-Table -AutoSize'

    $actionScript = {
        param($reposInput)
        $reposInput |
            Where-Object { $_.repoId -in @('sgin','sgin-cumplimiento') } |
            Select-Object repoId, remote, status, alignmentStatus, role, canonicalPath,
                @{N='mode';E={$_.runtimePointer.mode}},
                @{N='copyRuntime';E={$_.runtimePointer.copyRuntime}} |
            Format-Table -AutoSize
    }

    $checklist = @(
        "SGIN — verificar que cada operación tenga expediente identificable",
        "SGIN — verificar que cada expediente tenga estado explícito",
        "SGIN — verificar rastro de acciones (fecha / responsable / cambio)",
        "SGIN-Cumplimiento — verificar evidencia asociada por operación",
        "SGIN-Cumplimiento — verificar que no exista cierre sin evidencia suficiente",
        "Cruce — recorrer decisión → expediente → documento/evidencia → control → cierre"
    )
}
elseif ($partial -gt 0) {
    $focus        = "Fase 3.2 RFA-U / Panel"
    $actionName   = "Cerrar partial críticos"
    $actionReason = "No hay pending, pero persisten repos partial; conviene revisar capability roots y disciplina RFA-U."
    $commandText  = '$repos | Where-Object { $_.repoId -in @(''agents-root'',''codex-root'',''cabina-universal-d'') } | Select-Object repoId, remote, status, alignmentStatus, role, canonicalPath, @{N=''mode'';E={$_.runtimePointer.mode}}, @{N=''copyRuntime'';E={$_.runtimePointer.copyRuntime}} | Format-Table -AutoSize'

    $actionScript = {
        param($reposInput)
        $reposInput |
            Where-Object { $_.repoId -in @('agents-root','codex-root','cabina-universal-d') } |
            Select-Object repoId, remote, status, alignmentStatus, role, canonicalPath,
                @{N='mode';E={$_.runtimePointer.mode}},
                @{N='copyRuntime';E={$_.runtimePointer.copyRuntime}} |
            Format-Table -AutoSize
    }

    $checklist = @(
        "Panel — revisar metadatos incompletos",
        "Panel — revisar vencidas de revisión",
        "Panel — revisar contenidos con PII y permisos",
        "Panel — revisar duplicidades Madre→Alias",
        "Panel — revisar enlaces y dependencias rotas",
        "RFA-U — confirmar cobertura mínima de metadatos requerida"
    )
}
else {
    $focus        = "Sistema alineado"
    $actionName   = "Sin acción prioritaria"
    $actionReason = "No hay pending ni partial; no se requiere inspección prioritaria adicional."
    $commandText  = "Sin comando sugerido."
    $actionScript = $null

    $checklist = @(
        "Mantener runtime único y referencias sin copyRuntime",
        "Usar panel/bitácora para detectar nuevas desviaciones",
        "Conservar observación ligera"
    )
}

# -----------------------------
# SEMÁFORO EJECUTIVO
# -----------------------------
$Semaforo = "🟢 VERDE"
$SemaforoMotivo = "Sin pending, sin partial y sin alertas críticas."

if ($pending -gt 5 -or $criticalAlerts -gt 0) {
    $Semaforo = "🔴 ROJO"
    $SemaforoMotivo = "Hay riesgo estructural/operativo alto: pending elevado y/o alertas críticas."
}
elseif (($pending -gt 0) -or ($partial -gt 0) -or ($totalAlerts -gt 0)) {
    $Semaforo = "🟡 ÁMBAR"
    $SemaforoMotivo = "El sistema está gobernado pero requiere atención: pending/partial y/o alertas activas."
}

# -----------------------------
# OUTPUT OBJECT
# -----------------------------
$outputObject = [PSCustomObject]@{
    FederationId    = $fed.federationId
    SchemaVersion   = $fed.schemaVersion
    RuntimeRoot     = $runtimeRoot
    ActiveRepo      = $activeRepo.repoId
    TotalRepos      = $totalRepos
    ReferenceRepos  = $reference
    Aligned         = $aligned
    Partial         = $partial
    Pending         = $pending
    AlertTotal      = $totalAlerts
    AlertCritical   = $criticalAlerts
    Semaforo        = $Semaforo
    SemaforoMotivo  = $SemaforoMotivo
    Focus           = $focus
    ActionName      = $actionName
    ActionReason    = $actionReason
    CommandSuggested= $commandText
    TopDecision     = $topDecision
    TopDecisions    = $ranked | Select-Object -First 5
    Checklist       = $checklist
}

if ($AsJson) {
    $outputObject | ConvertTo-Json -Depth 6
    return
}

# -----------------------------
# OUTPUT TEXT
# -----------------------------
Write-Host ""
Write-Host "===================================="
Write-Host "CEO STATUS FINAL"
Write-Host "===================================="
Write-Host ("Federation ID : {0}" -f $fed.federationId)
Write-Host ("Schema        : {0}" -f $fed.schemaVersion)
Write-Host ("Runtime Root  : {0}" -f $runtimeRoot)
Write-Host ("Active Repo   : {0}" -f $activeRepo.repoId)

Write-Host ""
Write-Host "SEMAFORO EJECUTIVO"
Write-Host ("{0}" -f $Semaforo)
Write-Host ("Motivo        : {0}" -f $SemaforoMotivo)

Write-Host ""
Write-Host "SYSTEM"
Write-Host ("- Total       : {0}" -f $totalRepos)
Write-Host ("- Active      : 1")
Write-Host ("- Reference   : {0}" -f $reference)

Write-Host ""
Write-Host "ALIGNMENT"
Write-Host ("- Aligned     : {0}" -f $aligned)
Write-Host ("- Partial     : {0}" -f $partial)
Write-Host ("- Pending     : {0}" -f $pending)

Write-Host ""
Write-Host "ALERTAS"
Write-Host ("- Total       : {0}" -f $totalAlerts)
Write-Host ("- Críticas    : {0}" -f $criticalAlerts)

if ($totalAlerts -gt 0) {
    Write-Host ""
    $alerts |
        Sort-Object Count -Descending |
        Select-Object Name, Area, Severity, Count, Action |
        Format-Table -AutoSize
}

Write-Host ""
Write-Host "TOP DECISIONES"
if ($ranked.Count -eq 0) {
    Write-Host "- ✅ No hay decisiones sugeridas"
} else {
    $ranked |
        Select-Object -First 5 |
        Select-Object Name, Source, Score, Why |
        Format-Table -AutoSize
}

Write-Host ""
Write-Host "AUTO-ACCION"
Write-Host ("→ Foco        : {0}" -f $focus)
Write-Host ("→ Sugerencia  : {0}" -f $actionName)
Write-Host ("→ Motivo      : {0}" -f $actionReason)

Write-Host ""
Write-Host "COMANDO SUGERIDO"
Write-Host $commandText

Write-Host ""
Write-Host "CHECKLIST"
$index = 1
foreach ($item in $checklist) {
    Write-Host ("{0}. {1}" -f $index, $item)
    $index++
}

if ($Execute -and $actionScript) {
    Write-Host ""
    Write-Host "EJECUTANDO AUTO-ACCION (READ-ONLY)..."
    & $actionScript $repos
}
elseif ($Execute -and -not $actionScript) {
    Write-Host ""
    Write-Host "No hay acción ejecutable en este momento."
}

Write-Host ""
Write-Host "===================================="
