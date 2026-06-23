param(
    [string]$ClassificationV3 = ".\out\classification.v3.csv",
    [string]$ManualReviewV3 = ".\out\manual-review.v3.csv",
    [string]$RiskV3 = ".\out\risk-register.v3.csv",
    [string]$RulesV3Path = ".\config\classification-rules.v3.json",
    [string]$RulesV31Path = ".\config\classification-rules.v3.1.proposed.json",
    [string]$LogPath = ".\logs\multiple-triage-v31.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
if (-not (Test-Path $ClassificationV3)) { throw "classification.v3.csv no encontrado: $ClassificationV3" }
if (-not (Test-Path $ManualReviewV3)) { throw "manual-review.v3.csv no encontrado: $ManualReviewV3" }
if (-not (Test-Path $RiskV3)) { throw "risk-register.v3.csv no encontrado: $RiskV3" }
if (-not (Test-Path $RulesV3Path)) { throw "classification-rules.v3.json no encontrado: $RulesV3Path" }
Write-SduLog "Triage MULTIPLE V3 iniciado" "INFO" $LogPath

function Get-MultipleMatches {
    param([string]$Reason)
    $parsedMatches = New-Object System.Collections.Generic.List[object]
    if ([string]::IsNullOrWhiteSpace($Reason)) { return @() }
    $payload = $Reason -replace '^Múltiples universos:\s*', ''
    foreach ($part in ($payload -split ',')) {
        $trimmed = $part.Trim()
        if ($trimmed -match '^([^:]+):(.+)$') {
            $universe = $Matches[1].Trim()
            $token = $Matches[2].Trim()
            $parsedMatches.Add([pscustomobject]@{ Universe=$universe; Token=$token }) | Out-Null
        }
    }
    return @($parsedMatches.ToArray())
}

function Get-ParentBucket {
    param([string]$Path)
    $repoRoot = "C:\CEO\project-cdx\"
    $relative = $Path
    if ($relative.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $relative.Substring($repoRoot.Length)
    }
    $first = ($relative -split '[\\/]')[0]
    if ([string]::IsNullOrWhiteSpace($first)) { return "." }
    return $first
}

function Get-MultipleCategory {
    param(
        [string[]]$Universes,
        [string[]]$Tokens,
        [string]$ParentBucket,
        [string]$AssetType
    )
    $hasSgin = $Universes -contains "ESCRIBANIA_SGIN"
    $hasModo = $Universes -contains "MODO_ON"
    $hasFederal = $Universes -contains "FEDERAL_SDU"
    $technicalRoot = $ParentBucket -in @(".cabina", ".codex", ".github", ".vscode", "operativa", "inventarios", "dataverse", "docs", "scripts", "tools", "recipes", "outputs", "hitos", "work")
    $technicalAsset = $AssetType -in @("CONFIGURATION", "SCRIPT", "SPREADSHEET", "DOCUMENT", "UNKNOWN")
    $genericTokens = @("cliente", "runtime", "evidence", "canon", "canonical", "governance", "sdu", "dataverse", "cdf", "ruc", "ced", "biblioteca", "listas")
    $genericHit = @($Tokens | Where-Object { $_ -in $genericTokens }).Count -gt 0

    if ($hasSgin -and $hasModo) { return "MULTIPLE_LEGITIMO_SENSIBLE" }
    if ($hasSgin -and $hasFederal) { return "MULTIPLE_LEGITIMO_SENSIBLE" }
    if ($hasSgin) { return "MULTIPLE_LEGITIMO_SENSIBLE" }
    if ($hasModo -and $hasFederal) { return "MULTIPLE_LEGITIMO_DOMINIO" }
    if ($technicalRoot -and $technicalAsset -and $hasFederal -and -not $hasSgin -and -not $hasModo) { return "MULTIPLE_TECNICO_SANO" }
    if ($technicalRoot -and $hasFederal) { return "MULTIPLE_POR_RUTA" }
    if ($genericHit) { return "MULTIPLE_POR_TOKEN_GENERICO" }
    return "MULTIPLE_NO_RESOLUBLE"
}

$classification = Import-Csv $ClassificationV3
$manual = Import-Csv $ManualReviewV3
$multiple = @($classification | Where-Object {
    $_.Universe -eq "MULTIPLE" -and
    $_.RiskFlags -match "MULTIPLE_UNIVERSES_DETECTED" -and
    $_.TargetBucket -eq "98_REVISION_MANUAL"
})

$triageRows = New-Object System.Collections.Generic.List[object]
foreach ($row in $multiple) {
    $matches = Get-MultipleMatches -Reason $row.Reason
    $universes = @($matches | ForEach-Object { $_.Universe } | Select-Object -Unique)
    $tokens = @($matches | ForEach-Object { $_.Token } | Select-Object -Unique)
    $pair = (($universes | Sort-Object) -join "+")
    $parent = Get-ParentBucket -Path $row.FullName
    $category = Get-MultipleCategory -Universes $universes -Tokens $tokens -ParentBucket $parent -AssetType $row.AssetType
    $action = switch ($category) {
        "MULTIPLE_LEGITIMO_SENSIBLE" { "mantener_revision_manual" }
        "MULTIPLE_LEGITIMO_DOMINIO" { "mantener_revision_manual" }
        "MULTIPLE_POR_RUTA" { "proponer_precedencia_por_ruta_con_revision" }
        "MULTIPLE_POR_TOKEN_GENERICO" { "proponer_ajuste_contextual_de_token" }
        "MULTIPLE_TECNICO_SANO" { "proponer_federal_sdu_con_revision_si_sensible" }
        default { "mantener_revision_manual" }
    }
    $triageRows.Add([pscustomobject]@{
        FullName = $row.FullName
        Name = $row.Name
        ParentBucket = $parent
        Extension = $row.Extension
        AssetType = $row.AssetType
        DataClassification = $row.DataClassification
        UniversePair = $pair
        Tokens = ($tokens -join ";")
        HasSGIN = ($universes -contains "ESCRIBANIA_SGIN")
        HasModoOn = ($universes -contains "MODO_ON")
        HasFederalSdu = ($universes -contains "FEDERAL_SDU")
        Category = $category
        ProposedAction = $action
        Hash = $row.Hash
        Reason = $row.Reason
        RiskFlags = $row.RiskFlags
    })
}

$triageRows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path ".\out\multiple-triage.csv"
$triageRows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path ".\out\multiple-classification.csv"

$byPair = $triageRows | Group-Object UniversePair | Sort-Object Count -Descending
$byCategory = $triageRows | Group-Object Category | Sort-Object Count -Descending
$byParent = $triageRows | Group-Object ParentBucket | Sort-Object Count -Descending

$triageMd = @()
$triageMd += "# MULTIPLE Triage — SDU Organización Total V3"
$triageMd += ""
$triageMd += "Fecha UTC: $(Get-SduTimestamp)"
$triageMd += ""
$triageMd += "## Resumen"
$triageMd += "- MULTIPLE total: $($triageRows.Count)"
foreach ($g in $byCategory) { $triageMd += "- $($g.Name): $($g.Count)" }
$triageMd += ""
$triageMd += "## Pares de universos"
$triageMd += "| Par | Count |"
$triageMd += "|---|---:|"
foreach ($g in $byPair) { $triageMd += "| $($g.Name) | $($g.Count) |" }
$triageMd += ""
$triageMd += "## Rutas padre"
$triageMd += "| Ruta padre | Count |"
$triageMd += "|---|---:|"
foreach ($g in ($byParent | Select-Object -First 20)) { $triageMd += "| $($g.Name) | $($g.Count) |" }
$triageMd | Set-Content -LiteralPath ".\out\multiple-triage.md" -Encoding UTF8

$resolutionMd = @()
$resolutionMd += "# MULTIPLE Resolution Candidates — SDU Organización Total V3"
$resolutionMd += ""
$resolutionMd += "Fecha UTC: $(Get-SduTimestamp)"
$resolutionMd += ""
$resolutionMd += "## Candidatos"
$resolutionMd += "- Los casos `MULTIPLE_LEGITIMO_SENSIBLE` quedan en revisión manual."
$resolutionMd += "- Los casos `MULTIPLE_LEGITIMO_DOMINIO` quedan en revisión manual porque cruzan dominio cliente/proyecto con superficie federal."
$resolutionMd += "- Los casos `MULTIPLE_TECNICO_SANO` pueden resolverse por precedencia de ruta hacia `FEDERAL_SDU`, manteniendo revisión si hay señal sensible."
$resolutionMd += "- Los casos `MULTIPLE_POR_TOKEN_GENERICO` requieren ajuste contextual, no eliminación global de tokens."
$resolutionMd += ""
$resolutionMd += "## Distribución"
foreach ($g in $byCategory) { $resolutionMd += "- $($g.Name): $($g.Count)" }
$resolutionMd | Set-Content -LiteralPath ".\out\multiple-resolution-candidates.md" -Encoding UTF8

$rules3 = Read-SduJson $RulesV3Path
$rules31 = ($rules3 | ConvertTo-Json -Depth 60 | ConvertFrom-Json)
$rules31 | Add-Member -NotePropertyName ruleset_id -NotePropertyValue "classification-rules.v3.1.proposed" -Force
$pathRules = @(
    [pscustomobject]@{
        rule_id = "FEDERAL_TECHNICAL_RUNNER_SURFACE"
        path_contains = @("\.cabina\", "\scripts\", "\config\", "\templates\", "\.vscode\")
        universe = "FEDERAL_SDU"
        asset_types = @("CONFIGURATION", "SCRIPT", "DOCUMENT", "SPREADSHEET", "UNKNOWN")
        data_classification = "D2"
        review_required = $false
        keep_multiple_on_sensitive_conflict = $true
        reason = "Runner local y metadata saneada bajo G1"
    },
    [pscustomobject]@{
        rule_id = "FEDERAL_GOVERNANCE_REPO_SURFACE"
        path_contains = @("\operativa\", "\inventarios\", "\docs\", "\dataverse\", "\tools\", "\recipes\", "\outputs\", "\hitos\", "\work\")
        universe = "FEDERAL_SDU"
        asset_types = @("CONFIGURATION", "SCRIPT", "DOCUMENT", "SPREADSHEET", "UNKNOWN")
        data_classification = "D2"
        review_required = $false
        keep_multiple_on_sensitive_conflict = $true
        reason = "Superficie de gobierno repo-local; SGIN/MODO_ON conflictivo permanece MULTIPLE"
    }
)
$rules31 | Add-Member -NotePropertyName path_precedence_rules -NotePropertyValue $pathRules -Force
$rules31 | Add-Member -NotePropertyName cross_universe_policy -NotePropertyValue "DENY_BY_DEFAULT" -Force
$rules31 | Add-Member -NotePropertyName sgin_policy -NotePropertyValue ([pscustomobject]@{
    protective_classification = "D5"
    review_required = $true
    never_downgrade_on_path_precedence = $true
}) -Force
$rules31 | Add-Member -NotePropertyName modo_on_sgin_policy -NotePropertyValue ([pscustomobject]@{
    cross_universe_requires_manual_review = $true
    no_auto_merge = $true
}) -Force
Save-SduJson $rules31 $RulesV31Path

$proposalMd = @()
$proposalMd += "# Rules V3 to V3.1 Proposal"
$proposalMd += ""
$proposalMd += "Fecha UTC: $(Get-SduTimestamp)"
$proposalMd += ""
$proposalMd += "## Cambios propuestos"
$proposalMd += "- Agregar precedencia por ruta para superficies técnicas y de gobierno `FEDERAL_SDU`."
$proposalMd += "- Mantener `keep_multiple_on_sensitive_conflict=true` para SGIN y MODO_ON."
$proposalMd += "- No eliminar tokens globales; documentar tokens genéricos como causa de ajuste contextual."
$proposalMd += "- Mantener `CROSS_UNIVERSE_DENY_BY_DEFAULT`."
$proposalMd += ""
$proposalMd += "## Seguridad"
$proposalMd += "- SGIN conserva `D5` y revisión manual."
$proposalMd += "- Secretos conservan D6 y revisión manual por el clasificador base."
$proposalMd += "- D3-D7 no pierde revisión obligatoria."
$proposalMd | Set-Content -LiteralPath ".\out\rules-v3-to-v3.1-proposal.md" -Encoding UTF8

Write-SduLog "Triage MULTIPLE V3 completado. Count=$($triageRows.Count)" "INFO" $LogPath
