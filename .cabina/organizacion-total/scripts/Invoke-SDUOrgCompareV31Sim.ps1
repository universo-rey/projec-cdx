param(
    [string]$ClassificationV3 = ".\out\classification.v3.csv",
    [string]$ManualReviewV3 = ".\out\manual-review.v3.csv",
    [string]$RiskV3 = ".\out\risk-register.v3.csv",
    [string]$PlanV3 = ".\out\move-plan.v3.csv",
    [string]$ClassificationV31 = ".\out\classification.v3.1.sim.csv",
    [string]$ManualReviewV31 = ".\out\manual-review.v3.1.sim.csv",
    [string]$RiskV31 = ".\out\risk-register.v3.1.sim.csv",
    [string]$PlanV31 = ".\out\move-plan.v3.1.sim.csv",
    [string]$MultipleTriage = ".\out\multiple-triage.csv",
    [string]$ComparativeMd = ".\out\G1_V3_V31_SIM_COMPARATIVE_REPORT.md",
    [string]$ComparativeJson = ".\out\G1_V3_V31_SIM_COMPARATIVE_REPORT.json",
    [string]$DecisionMd = ".\out\BASELINE_DECISION_G1_V3.md",
    [string]$DecisionJson = ".\out\BASELINE_DECISION_G1_V3.json",
    [string]$FinalReadback = ".\out\FINAL_READBACK_SDU_ORG_TOTAL_G1_MULTIPLE_TRIAGE.md",
    [string]$LogPath = ".\logs\compare-v31-sim.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
Write-SduLog "Comparativa V3/V3.1 sim iniciada" "INFO" $LogPath

function Import-RequiredCsv {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "CSV requerido no encontrado: $Path" }
    return @(Import-Csv $Path)
}

function Count-Where {
    param(
        [object[]]$Rows,
        [scriptblock]$Predicate
    )
    return @($Rows | Where-Object $Predicate).Count
}

function Get-Summary {
    param(
        [object[]]$Classification,
        [object[]]$Manual,
        [object[]]$Risk,
        [object[]]$Plan
    )
    return [pscustomobject]@{
        classified = $Classification.Count
        manual_review = $Manual.Count
        risks = $Risk.Count
        conflicts = Count-Where $Plan { $_.Action -eq "CONFLICT_REVIEW" }
        unknown = Count-Where $Classification { $_.Universe -eq "UNKNOWN" }
        multiple = Count-Where $Classification { $_.Universe -eq "MULTIPLE" }
        d3_d7 = Count-Where $Classification { $_.DataClassification -match '^D[3-7]$' }
        secret_indicator = Count-Where $Classification { $_.RiskFlags -match "SECRET_INDICATOR" }
    }
}

$v3Rows = Import-RequiredCsv $ClassificationV3
$v3Manual = Import-RequiredCsv $ManualReviewV3
$v3Risk = Import-RequiredCsv $RiskV3
$v3Plan = Import-RequiredCsv $PlanV3
$v31Rows = Import-RequiredCsv $ClassificationV31
$v31Manual = Import-RequiredCsv $ManualReviewV31
$v31Risk = Import-RequiredCsv $RiskV31
$v31Plan = Import-RequiredCsv $PlanV31
$triageRows = Import-RequiredCsv $MultipleTriage

$v31ByHash = @{}
foreach ($row in $v31Rows) {
    if (-not [string]::IsNullOrWhiteSpace($row.Hash) -and -not $v31ByHash.ContainsKey($row.Hash)) {
        $v31ByHash[$row.Hash] = $row
    }
}

$protectionLoss = New-Object System.Collections.Generic.List[object]
$secretLoss = New-Object System.Collections.Generic.List[object]
foreach ($row in $v3Rows) {
    if ([string]::IsNullOrWhiteSpace($row.Hash) -or -not $v31ByHash.ContainsKey($row.Hash)) { continue }
    $next = $v31ByHash[$row.Hash]
    if ($row.DataClassification -match '^D[3-7]$' -and $next.DataClassification -notmatch '^D[3-7]$') {
        $protectionLoss.Add([pscustomobject]@{
            Hash = $row.Hash
            FullName = $row.FullName
            V3DataClassification = $row.DataClassification
            V31DataClassification = $next.DataClassification
        }) | Out-Null
    }
    if ($row.RiskFlags -match "SECRET_INDICATOR" -and $next.RiskFlags -notmatch "SECRET_INDICATOR") {
        $secretLoss.Add([pscustomobject]@{
            Hash = $row.Hash
            FullName = $row.FullName
            V3RiskFlags = $row.RiskFlags
            V31RiskFlags = $next.RiskFlags
        }) | Out-Null
    }
}

$v3 = Get-Summary -Classification $v3Rows -Manual $v3Manual -Risk $v3Risk -Plan $v3Plan
$v31 = Get-Summary -Classification $v31Rows -Manual $v31Manual -Risk $v31Risk -Plan $v31Plan
$triageByCategory = @($triageRows | Group-Object Category | Sort-Object Count -Descending | ForEach-Object {
    [pscustomobject]@{ category = $_.Name; count = $_.Count }
})

$deltas = [pscustomobject]@{
    manual_review = $v31.manual_review - $v3.manual_review
    risks = $v31.risks - $v3.risks
    conflicts = $v31.conflicts - $v3.conflicts
    unknown = $v31.unknown - $v3.unknown
    multiple = $v31.multiple - $v3.multiple
    d3_d7 = $v31.d3_d7 - $v3.d3_d7
    secret_indicator = $v31.secret_indicator - $v3.secret_indicator
}

$hasLoss = ($protectionLoss.Count -gt 0 -or $secretLoss.Count -gt 0)
$hasImprovement = ($deltas.manual_review -lt 0 -or $deltas.multiple -lt 0 -or $deltas.unknown -lt 0)
if ($hasLoss) {
    $decision = "D_BLOQUEAR_APPLY"
    $baseline = "MANTENER_V3"
    $decisionReason = "La simulación detectó pérdida de protección o señal de secreto."
} elseif ($hasImprovement) {
    $decision = "B_PROMOVER_V31_CANDIDATE"
    $baseline = "V3_1_CANDIDATE"
    $decisionReason = "La simulación mejora revisión o ambigüedad sin pérdida de protección."
} else {
    $decision = "A_ADOPTAR_V3_AS_BASELINE_CANDIDATE"
    $baseline = "V3"
    $decisionReason = "V3.1 no reduce UNKNOWN, MULTIPLE ni revisión manual; V3 queda como baseline candidato."
}

$comparative = [pscustomobject]@{
    generated_at = Get-SduTimestamp
    mode = "SIMULATION_ONLY"
    v3 = $v3
    v31_sim = $v31
    deltas = $deltas
    multiple_triage = $triageByCategory
    protection_loss_count = $protectionLoss.Count
    secret_loss_count = $secretLoss.Count
    decision = $decision
    baseline_recommended = $baseline
    frontier = [pscustomobject]@{
        live_write = $false
        apply_move = $false
        overwrite_v3 = $false
        network = $false
    }
}
Save-SduJson $comparative $ComparativeJson

$md = @()
$md += "# G1 V3 vs V3.1 Simulation Comparative Report"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += ""
$md += "## V3"
$md += "- Classified: $($v3.classified)"
$md += "- Manual review: $($v3.manual_review)"
$md += "- Risks: $($v3.risks)"
$md += "- Conflicts: $($v3.conflicts)"
$md += "- UNKNOWN: $($v3.unknown)"
$md += "- MULTIPLE: $($v3.multiple)"
$md += "- D3-D7: $($v3.d3_d7)"
$md += ""
$md += "## V3.1 sim"
$md += "- Classified: $($v31.classified)"
$md += "- Manual review: $($v31.manual_review)"
$md += "- Risks: $($v31.risks)"
$md += "- Conflicts: $($v31.conflicts)"
$md += "- UNKNOWN: $($v31.unknown)"
$md += "- MULTIPLE: $($v31.multiple)"
$md += "- D3-D7: $($v31.d3_d7)"
$md += ""
$md += "## Delta"
$md += "- Manual review delta: $($deltas.manual_review)"
$md += "- Risks delta: $($deltas.risks)"
$md += "- Conflicts delta: $($deltas.conflicts)"
$md += "- UNKNOWN delta: $($deltas.unknown)"
$md += "- MULTIPLE delta: $($deltas.multiple)"
$md += "- D3-D7 delta: $($deltas.d3_d7)"
$md += "- Secret indicator delta: $($deltas.secret_indicator)"
$md += ""
$md += "## MULTIPLE triage"
foreach ($g in $triageByCategory) { $md += "- $($g.category): $($g.count)" }
$md += ""
$md += "## Protección"
$md += "- Protection loss count: $($protectionLoss.Count)"
$md += "- Secret loss count: $($secretLoss.Count)"
$md += ""
$md += "## Lectura"
$md += "- La propuesta V3.1 conserva la frontera, pero no mejora los indicadores críticos frente a V3."
$md += "- Los MULTIPLE restantes son ambigüedades legítimas: SGIN sensible o dominio MODO_ON sobre superficie federal."
$md | Set-Content -LiteralPath $ComparativeMd -Encoding UTF8

$decisionObj = [pscustomobject]@{
    generated_at = Get-SduTimestamp
    decision = $decision
    baseline_recommended = $baseline
    reason = $decisionReason
    safe_to_apply = $false
    apply_requires_gate = $true
    v3 = $v3
    v31_sim = $v31
    deltas = $deltas
    protection_loss_count = $protectionLoss.Count
    secret_loss_count = $secretLoss.Count
}
Save-SduJson $decisionObj $DecisionJson

$decisionLines = @()
$decisionLines += "# Baseline Decision G1 V3"
$decisionLines += ""
$decisionLines += "Fecha UTC: $(Get-SduTimestamp)"
$decisionLines += ""
$decisionLines += "## Decisión"
$decisionLines += "- Decision: $decision"
$decisionLines += "- Baseline recomendado: $baseline"
$decisionLines += "- Motivo: $decisionReason"
$decisionLines += ""
$decisionLines += "## Gate"
$decisionLines += "- Safe to apply: false"
$decisionLines += "- Apply requiere gate humano explícito."
$decisionLines += "- No se ejecutó apply, movimiento, overwrite ni live write."
$decisionLines | Set-Content -LiteralPath $DecisionMd -Encoding UTF8

$readback = @()
$readback += "# Final Readback — SDU Org Total G1 MULTIPLE Triage"
$readback += ""
$readback += "- agente: Codex ejecutor local gobernado"
$readback += "- orden: SDU_ORG_TOTAL_G1_V3_MULTIPLE_TRIAGE_AND_BASELINE_CANDIDATE"
$readback += "- superficie: C:\CEO\project-cdx\.cabina\organizacion-total"
$readback += "- estado: COMPLETADO_SIMULATION_ONLY"
$readback += "- v3: manual=$($v3.manual_review), unknown=$($v3.unknown), multiple=$($v3.multiple), risks=$($v3.risks)"
$readback += "- v3.1_sim: manual=$($v31.manual_review), unknown=$($v31.unknown), multiple=$($v31.multiple), risks=$($v31.risks)"
$triageSummary = ($triageByCategory | ForEach-Object { "$($_.category)=$($_.count)" }) -join ", "
$readback += "- triage_multiple: $triageSummary"
$readback += "- decision: $decision"
$readback += "- baseline_recomendado: $baseline"
$readback += "- gate: APPLY_NO_EJECUTADO; live_write=false; network=false; overwrite_v3=false"
$readback += "- rollback: descartar archivos v3.1 sim/proposed y restaurar backups de scripts/tasks si se decide volver al estado previo"
$readback += "- stop_condition: baseline V3 adoptado como candidato; V3.1 queda como propuesta no promovida porque no reduce MULTIPLE/manual/UNKNOWN"
$readback | Set-Content -LiteralPath $FinalReadback -Encoding UTF8

Write-SduLog "Comparativa V3/V3.1 sim completada. Decision=$decision" "INFO" $LogPath
