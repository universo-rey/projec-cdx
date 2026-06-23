param(
    [string]$PlanCsv = ".\out\move-plan.csv",
    [string]$ClassificationCsv = ".\out\classification.csv",
    [string]$ValidationOut = ".\out\validation-readback.md",
    [string]$LogPath = ".\logs\validate.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
if (-not (Test-Path $PlanCsv)) { throw "Plan no encontrado: $PlanCsv" }
if (-not (Test-Path $ClassificationCsv)) { throw "Clasificación no encontrada: $ClassificationCsv" }
Write-SduLog "Validación iniciada" "INFO" $LogPath

$plan = Import-Csv $PlanCsv
$class = Import-Csv $ClassificationCsv
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

# No delete/no overwrite/no apply real enforced by plan dry-run.
$nonDry = @($plan | Where-Object { $_.DryRunOnly -ne "True" })
if ($nonDry.Count -gt 0) { $errors.Add("Hay acciones no marcadas como DryRunOnly.") }

$danger = @($plan | Where-Object { $_.Action -match "DELETE|OVERWRITE|APPLY|MOVE_REAL" })
if ($danger.Count -gt 0) { $errors.Add("Hay acciones peligrosas en el plan.") }

$highSensitiveWithoutReview = @($class | Where-Object { $_.DataClassification -in @("D3", "D4", "D5", "D6", "D7") -and $_.ReviewRequired -ne "True" })
if ($highSensitiveWithoutReview.Count -gt 0) { $errors.Add("Hay D3-D7 sin revisión obligatoria.") }

$multiUniverse = @($class | Where-Object { $_.Universe -eq "MULTIPLE" })
if ($multiUniverse.Count -gt 0) { $warnings.Add("Hay archivos con múltiples universos detectados: $($multiUniverse.Count).") }

$unknown = @($class | Where-Object { $_.Universe -eq "UNKNOWN" })
if ($unknown.Count -gt 0) { $warnings.Add("Hay archivos sin universo determinado: $($unknown.Count).") }

$md = @()
$md += "# Validation Readback — SDU Organización Total"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += ""
$md += "## Resultado"
$md += "- Errores: $($errors.Count)"
$md += "- Warnings: $($warnings.Count)"
$md += "- Plan items: $($plan.Count)"
$md += "- Classification items: $($class.Count)"
$md += ""
$md += "## Errores"
if ($errors.Count -eq 0) { $md += "- Ninguno." } else { foreach ($e in $errors) { $md += "- $e" } }
$md += ""
$md += "## Warnings"
if ($warnings.Count -eq 0) { $md += "- Ninguno." } else { foreach ($w in $warnings) { $md += "- $w" } }
$md += ""
$md += "## Dictamen"
if ($errors.Count -eq 0) { $md += "VALIDATION_PASS_DRYRUN" } else { $md += "VALIDATION_BLOCKED" }

$md | Set-Content -LiteralPath $ValidationOut -Encoding UTF8
Write-SduLog "Validación completada. Errors=$($errors.Count); Warnings=$($warnings.Count)" "INFO" $LogPath
if ($errors.Count -gt 0) { exit 2 }
