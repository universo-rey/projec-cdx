param(
    [string]$RulesV2Path = ".\config\classification-rules.v2.json",
    [string]$CoverageJson = ".\out\agent-coverage-analysis.json",
    [string]$ManualReviewCsv = ".\out\manual-review.csv",
    [string]$ClassificationCsv = ".\out\classification.csv",
    [string]$RulesV3Path = ".\config\classification-rules.v3.json",
    [string]$RulesDiffOut = ".\out\rules-v3-diff.md",
    [string]$ManualAnalysisMd = ".\out\manual-review-analysis.md",
    [string]$ManualAnalysisCsv = ".\out\manual-review-analysis.csv",
    [string]$LogPath = ".\logs\rules-v3.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
if (-not (Test-Path $RulesV2Path)) { throw "Rules V2 no encontrado: $RulesV2Path" }
if (-not (Test-Path $ManualReviewCsv)) { throw "manual-review.csv no encontrado: $ManualReviewCsv" }
if (-not (Test-Path $ClassificationCsv)) { throw "classification.csv no encontrado: $ClassificationCsv" }
Write-SduLog "Refinamiento de reglas V3 iniciado" "INFO" $LogPath

$rules = Read-SduJson $RulesV2Path
$manual = Import-Csv $ManualReviewCsv
$classification = Import-Csv $ClassificationCsv
$coverage = if (Test-Path $CoverageJson) { Read-SduJson $CoverageJson } else { $null }

function Add-UniqueTokens {
    param(
        [System.Collections.IList]$List,
        [string[]]$Tokens
    )
    foreach ($token in $Tokens) {
        if ([string]::IsNullOrWhiteSpace($token)) { continue }
        if (-not (@($List) | Where-Object { ([string]$_).ToLowerInvariant() -eq $token.ToLowerInvariant() })) {
            [void]$List.Add($token)
        }
    }
}

function Get-ReviewCause {
    param([pscustomobject]$Row)
    $flags = [string]$Row.RiskFlags
    if ($flags -match 'SECRET_INDICATOR') { return 'SECRET_INDICATOR' }
    if ($flags -match 'MULTIPLE_UNIVERSES_DETECTED' -or [string]$Row.Reason -like 'Múltiples universos*') { return 'MULTIPLE' }
    if ([string]$Row.DataClassification -in @('D3','D4','D5','D6','D7')) { return 'D3-D7' }
    if ($flags -match 'NOISE_CANDIDATE') { return 'NOISE_CANDIDATE' }
    if ([string]$Row.Universe -eq 'UNKNOWN' -and [string]$Row.AssetType -eq 'UNKNOWN') { return 'falta de tokens' }
    if ([string]$Row.Universe -eq 'UNKNOWN' -and [string]$Row.AssetType -ne 'UNKNOWN') { return 'archivo técnico sin universo' }
    if ([string]::IsNullOrWhiteSpace([string]$Row.Extension) -or [string]$Row.Extension -eq '.local' -or [string]$Row.Extension -eq '') { return 'extensión no reconocida' }
    if ([string]$Row.Universe -eq 'UNKNOWN') { return 'ruta ambigua' }
    return 'otra'
}

$reviewRows = foreach ($row in $manual) {
    [pscustomobject]@{
        Cause = Get-ReviewCause -Row $row
        FullName = $row.FullName
        Name = $row.Name
        Extension = $row.Extension
        AssetType = $row.AssetType
        Universe = $row.Universe
        DataClassification = $row.DataClassification
        Hash = $row.Hash
        Reason = $row.Reason
        RiskFlags = $row.RiskFlags
    }
}

$grouped = $reviewRows | Group-Object Cause | Sort-Object Count -Descending
$reviewRows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $ManualAnalysisCsv

$md = @()
$md += "# Manual Review Analysis — SDU Organización Total"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += ""
$md += "## Resumen"
foreach ($g in $grouped) {
    $md += "- $($g.Name): $($g.Count)"
}
$md += ""
$md += "## Causas"
$md += "| Causa | Count | Muestras |"
$md += "|---|---:|---|"
foreach ($g in $grouped) {
    $sample = @($g.Group | Select-Object -First 3 | ForEach-Object { $_.Name })
    $md += "| $($g.Name) | $($g.Count) | $($sample -join '; ') |"
}
$md += ""
$md += "## Lectura"
$md += "- La mayor parte de la revisión manual proviene de `UNKNOWN` sin señales suficientes en ruta/nombre."
$md += "- `MULTIPLE` concentra cruces reales de universo y se conserva en revisión."
$md += "- `D3-D7` y `SECRET_INDICATOR` siguen bloqueados por diseño."
$md | Set-Content -LiteralPath $ManualAnalysisMd -Encoding UTF8

$analysisSummary = [pscustomobject]@{
    generated_at = Get-SduTimestamp
    total_manual_review = $manual.Count
    causes = @{}
}
foreach ($g in $grouped) { $analysisSummary.causes[$g.Name] = $g.Count }
Save-SduJson $analysisSummary ".\out\manual-review-analysis.json"

# Build v3 rules conservatively from v2 base
$rules3 = ($rules | ConvertTo-Json -Depth 40 | ConvertFrom-Json)
$rules3.universes.FEDERAL_SDU | Add-Member -NotePropertyName tokens -NotePropertyValue ([System.Collections.ArrayList]@($rules3.universes.FEDERAL_SDU.tokens)) -Force
$rules3.universes.ESCRIBANIA_SGIN | Add-Member -NotePropertyName tokens -NotePropertyValue ([System.Collections.ArrayList]@($rules3.universes.ESCRIBANIA_SGIN.tokens)) -Force
$rules3.universes.MODO_ON | Add-Member -NotePropertyName tokens -NotePropertyValue ([System.Collections.ArrayList]@($rules3.universes.MODO_ON.tokens)) -Force
$fedTokens = @(
    "cabina","codex","operativa","docs","inventarios","outputs","recipes","procesos","dataverse","tools",
    "workbooks","work","packages","patrones","playbooks","scripts","config","templates","src","tests",
    "hitos","launch-desk",".cabina",".codex",".agent",".bookmarks",".cursor",".github",".vscode",
    "manifest","report","readback","inventory","classification","validation","plan","risk","evidence",
    "workflow","registry","workspace","queue","workqueue","runner","dryrun","dry run","governance","control plane",
    "sharepoint","vscode","markdown","csv","json","yaml","xml","txt","md"
)
$sginTokens = @(
    "escribania bitsch","registro notarial","registro notarial n8","home-canonica","home canonical",
    "sitepages","documentos compartidos","canonical","protocolo","testimonio","escritura","uif","kyc",
    "ruc","expediente","cliente","interviniente","acto","acta","biblioteca","bibliotecas","listas",
    "site pages","hubregistro","bitsch"
)
$modoTokens = @(
    "modo on","modo_on","consultoria","consultoría","cliente comercial","estrategia","producto","cdf","jara",
    "portfolio","propuesta","servicio","ventas"
)

Add-UniqueTokens -List $rules3.universes.FEDERAL_SDU.tokens -Tokens $fedTokens
Add-UniqueTokens -List $rules3.universes.ESCRIBANIA_SGIN.tokens -Tokens $sginTokens
Add-UniqueTokens -List $rules3.universes.MODO_ON.tokens -Tokens $modoTokens

if (-not $rules3.universes.FEDERAL_SDU.PSObject.Properties["protective_classification"]) {
    $rules3.universes.FEDERAL_SDU | Add-Member -NotePropertyName protective_classification -NotePropertyValue "D2"
}
if (-not $rules3.universes.MODO_ON.PSObject.Properties["protective_classification"]) {
    $rules3.universes.MODO_ON | Add-Member -NotePropertyName protective_classification -NotePropertyValue "D3"
}

Save-SduJson $rules3 $RulesV3Path

$diff = @()
$diff += "# Rules V3 Diff — SDU Organización Total"
$diff += ""
$diff += "Fecha UTC: $(Get-SduTimestamp)"
$diff += ""
$diff += "## Agregados"
$diff += "- FEDERAL_SDU: $(($fedTokens | Select-Object -Unique) -join ', ')"
$diff += "- ESCRIBANIA_SGIN: $(($sginTokens | Select-Object -Unique) -join ', ')"
$diff += "- MODO_ON: $(($modoTokens | Select-Object -Unique) -join ', ')"
$diff += ""
$diff += "## Impacto esperado"
$diff += "- Menos `UNKNOWN` por rutas/documentos repo-locales y superficies técnicas."
$diff += "- Menos revisión manual por archivos de control plane, docs, outputs y manifestos."
$diff += "- `D3-D7`, secretos y MULTIPLE siguen en revisión obligatoria."
if ($coverage) {
    $diff += ""
    $diff += "## Cobertura"
    $diff += "- Ideal satisfecho en cobertura: $($coverage.ideal_satisfied)"
    $diff += "- Mapeados como equivalencia: $(@($coverage.coverage | Where-Object { $_.status -eq 'mapped_equivalent' }).Count)"
}
$diff | Set-Content -LiteralPath $RulesDiffOut -Encoding UTF8

Write-SduLog "Refinamiento de reglas V3 completado: $RulesV3Path" "INFO" $LogPath
