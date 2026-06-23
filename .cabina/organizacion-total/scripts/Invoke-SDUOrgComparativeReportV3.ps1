param(
    [string]$SelectedV2 = ".\out\selected-agents.v2.json",
    [string]$CoverageJson = ".\out\agent-coverage-analysis.json",
    [string]$ClassificationV2 = ".\out\classification.csv",
    [string]$ManualReviewV2 = ".\out\manual-review.csv",
    [string]$RiskV2 = ".\out\risk-register.csv",
    [string]$PlanV2 = ".\out\move-plan.csv",
    [string]$ClassificationV3 = ".\out\classification.v3.csv",
    [string]$ManualReviewV3 = ".\out\manual-review.v3.csv",
    [string]$RiskV3 = ".\out\risk-register.v3.csv",
    [string]$PlanV3 = ".\out\move-plan.v3.csv",
    [string]$ComparativeMd = ".\out\G1_V2_V3_COMPARATIVE_REPORT.md",
    [string]$ComparativeJson = ".\out\G1_V2_V3_COMPARATIVE_REPORT.json",
    [string]$LogPath = ".\logs\comparative-v3.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
Write-SduLog "Comparativa V2/V3 iniciada" "INFO" $LogPath

function Get-CountCsv {
    param([string]$Path)
    if (Test-Path $Path) { return (Import-Csv $Path).Count }
    return 0
}

function Get-CountJsonAgents {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return 0 }
    $data = Read-SduJson $Path
    if ($data.agents) { return @($data.agents).Count }
    return 0
}

$coverage = if (Test-Path $CoverageJson) { Read-SduJson $CoverageJson } else { $null }
$selectedLegacy = if (Test-Path ".\out\selected-agents.json") { Read-SduJson ".\out\selected-agents.json" } else { $null }
$selectedV3 = if (Test-Path $SelectedV2) { Read-SduJson $SelectedV2 } else { $null }

$v2 = [pscustomobject]@{
    inventory = Get-CountCsv ".\out\inventory.csv"
    classified = Get-CountCsv $ClassificationV2
    manual_review = Get-CountCsv $ManualReviewV2
    risks = Get-CountCsv $RiskV2
    conflicts = @((Import-Csv $PlanV2 | Where-Object { $_.Action -eq 'CONFLICT_REVIEW' })).Count
    ideal_satisfied = if ($selectedLegacy) { $selectedLegacy.ideal_satisfied } else { $false }
    agents_covered = if ($selectedLegacy) { @($selectedLegacy.agents).Count } else { 0 }
    unknown = @((Import-Csv $ClassificationV2 | Where-Object { $_.Universe -eq 'UNKNOWN' })).Count
    multiple = @((Import-Csv $ClassificationV2 | Where-Object { $_.Universe -eq 'MULTIPLE' })).Count
}

$v3 = [pscustomobject]@{
    inventory = Get-CountCsv ".\out\inventory.csv"
    classified = Get-CountCsv $ClassificationV3
    manual_review = Get-CountCsv $ManualReviewV3
    risks = Get-CountCsv $RiskV3
    conflicts = @((Import-Csv $PlanV3 | Where-Object { $_.Action -eq 'CONFLICT_REVIEW' })).Count
    ideal_satisfied = if ($coverage) { [bool]$coverage.ideal_satisfied } elseif ($selectedV3) { [bool]$selectedV3.ideal_satisfied } else { $false }
    agents_covered = if ($coverage) { @($coverage.coverage).Count } elseif ($selectedV3) { @($selectedV3.agents).Count } else { 0 }
    unknown = if (Test-Path $ClassificationV3) { @((Import-Csv $ClassificationV3 | Where-Object { $_.Universe -eq 'UNKNOWN' })).Count } else { 0 }
    multiple = if (Test-Path $ClassificationV3) { @((Import-Csv $ClassificationV3 | Where-Object { $_.Universe -eq 'MULTIPLE' })).Count } else { 0 }
}

$comparative = [pscustomobject]@{
    generated_at = Get-SduTimestamp
    v2 = $v2
    v3 = $v3
    deltas = [pscustomobject]@{
        manual_review = $v3.manual_review - $v2.manual_review
        risks = $v3.risks - $v2.risks
        conflicts = $v3.conflicts - $v2.conflicts
        unknown = $v3.unknown - $v2.unknown
        multiple = $v3.multiple - $v2.multiple
    }
}
Save-SduJson $comparative $ComparativeJson

$md = @()
$md += "# G1 V2 vs V3 Comparative Report"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += ""
$md += "## V2"
$md += "- Inventory: $($v2.inventory)"
$md += "- Classified: $($v2.classified)"
$md += "- Manual review: $($v2.manual_review)"
$md += "- Risks: $($v2.risks)"
$md += "- Conflicts: $($v2.conflicts)"
$md += "- Ideal satisfied: $($v2.ideal_satisfied)"
$md += "- Agents covered: $($v2.agents_covered)"
$md += "- UNKNOWN: $($v2.unknown)"
$md += "- MULTIPLE: $($v2.multiple)"
$md += ""
$md += "## V3"
$md += "- Inventory: $($v3.inventory)"
$md += "- Classified: $($v3.classified)"
$md += "- Manual review: $($v3.manual_review)"
$md += "- Risks: $($v3.risks)"
$md += "- Conflicts: $($v3.conflicts)"
$md += "- Ideal satisfied: $($v3.ideal_satisfied)"
$md += "- Agents covered: $($v3.agents_covered)"
$md += "- UNKNOWN: $($v3.unknown)"
$md += "- MULTIPLE: $($v3.multiple)"
$md += ""
$md += "## Delta"
$md += "- Manual review delta: $($comparative.deltas.manual_review)"
$md += "- Risks delta: $($comparative.deltas.risks)"
$md += "- Conflicts delta: $($comparative.deltas.conflicts)"
$md += "- UNKNOWN delta: $($comparative.deltas.unknown)"
$md += "- MULTIPLE delta: $($comparative.deltas.multiple)"
$md += ""
$md += "## Lectura"
$md += "- V3 solo se considera mejor si baja UNKNOWN o manual review sin relajar D3-D7, secretos o MULTIPLE."
$md += "- La cobertura ideal debe quedar explicada por equivalencias canónicas, no por agentes productivos nuevos."
$md | Set-Content -LiteralPath $ComparativeMd -Encoding UTF8

Write-SduLog "Comparativa V2/V3 completada: $ComparativeMd" "INFO" $LogPath
