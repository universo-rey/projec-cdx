param()

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "SDU Full DryRun V3 iniciado en $root"

& .\scripts\Invoke-SDUOrgAnalyzeAgentCoverage.ps1
& .\scripts\Invoke-SDUOrgRefineRulesV3.ps1
& .\scripts\Invoke-SDUOrgClassifyMultiAgent.ps1 -RulesPath .\config\classification-rules.v3.json -OutCsv .\out\classification.v3.csv -ManualReviewCsv .\out\manual-review.v3.csv -RiskCsv .\out\risk-register.v3.csv -LogPath .\logs\classification-v3.log
& .\scripts\Invoke-SDUOrgPlan.ps1 -ClassificationCsv .\out\classification.v3.csv -OutCsv .\out\move-plan.v3.csv -OutJson .\out\move-plan.v3.json -LogPath .\logs\plan-v3.log
& .\scripts\Invoke-SDUOrgValidate.ps1 -PlanCsv .\out\move-plan.v3.csv -ClassificationCsv .\out\classification.v3.csv -ValidationOut .\out\validation-readback.v3.md -LogPath .\logs\validate-v3.log
& .\scripts\Invoke-SDUOrgComparativeReportV3.ps1 -ClassificationV3 .\out\classification.v3.csv -ManualReviewV3 .\out\manual-review.v3.csv -RiskV3 .\out\risk-register.v3.csv -PlanV3 .\out\move-plan.v3.csv

$v3Selected = Read-SduJson ".\out\selected-agents.v2.json"
$v3Class = Import-Csv ".\out\classification.v3.csv"
$v3Manual = Import-Csv ".\out\manual-review.v3.csv"
$v3Risk = Import-Csv ".\out\risk-register.v3.csv"
$v3Plan = Import-Csv ".\out\move-plan.v3.csv"

$final = @()
$final += "# SDU Organización Total — FINAL READBACK V3"
$final += ""
$final += "- Estado final: operativa V3 completada en dry-run comparativa."
$final += "- Runner integrado: `C:\CEO\project-cdx\.cabina\organizacion-total`."
$final += "- Selección ideal: $($v3Selected.ideal_satisfied)"
$final += "- Selección mínima: $($v3Selected.minimum_satisfied)"
$final += "- Agentes preferidos: $(@($v3Selected.agents).Count)"
$final += "- Agentes de soporte: $(@($v3Selected.supplementary_agents).Count)"
$final += "- Inventario: $(@(Import-Csv '.\out\inventory.csv').Count)"
$final += "- Clasificados V3: $($v3Class.Count)"
$final += "- Revisión manual V3: $($v3Manual.Count)"
$final += "- Riesgos V3: $($v3Risk.Count)"
$final += "- Conflictos V3: $(@($v3Plan | Where-Object { $_.Action -eq 'CONFLICT_REVIEW' }).Count)"
$final += ""
$final += "## Evidencia"
$final += '- Coverage: .\out\agent-coverage-analysis.md'
$final += '- Coverage JSON: .\out\agent-coverage-analysis.json'
$final += '- Equivalence CSV: .\out\agent-equivalence-map.csv'
$final += '- Rules V3: .\config\classification-rules.v3.json'
$final += '- Comparative: .\out\G1_V2_V3_COMPARATIVE_REPORT.md'
$final += '- Validation V3: .\out\validation-readback.v3.md'
$final += ""
$final += "## Frontera"
$final += "- NO_DELETE: true"
$final += "- NO_OVERWRITE: true"
$final += "- NO_APPLY_REAL: true"
$final += "- NO_LIVE: true"
$final += "- NO_PUSH: true"
$final += "- NO_PR: true"
$final += "- NO_SECRET_EXPOSURE: true"
$final += ""
$final += "## Siguiente gate"
$final += "- Revisar si la reducción de UNKNOWN es suficiente sin relajar D3-D7 ni MULTIPLE."
$final += "- Si se quiere, preparar un PR local de documentación del mapeo equivalente."
$final | Set-Content -LiteralPath ".\out\FINAL_READBACK_SDU_ORG_TOTAL_G1_V3.md" -Encoding UTF8

Write-Host "SDU Full DryRun V3 completado. Ver out/FINAL_READBACK_SDU_ORG_TOTAL_G1_V3.md"
