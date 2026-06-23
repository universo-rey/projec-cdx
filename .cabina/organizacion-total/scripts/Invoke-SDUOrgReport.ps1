param(
    [string]$OutReport = ".\out\org-report.md",
    [string]$ManifestOut = ".\out\evidence-manifest.json",
    [string]$LogPath = ".\logs\report.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
Write-SduLog "Reporte iniciado" "INFO" $LogPath

$paths = [ordered]@{
    selected_agents = ".\out\selected-agents.json"
    inventory = ".\out\inventory.csv"
    classification = ".\out\classification.csv"
    move_plan = ".\out\move-plan.csv"
    risk_register = ".\out\risk-register.csv"
    manual_review = ".\out\manual-review.csv"
    validation = ".\out\validation-readback.md"
}

$counts = @{}
foreach ($k in $paths.Keys) {
    $p = $paths[$k]
    if (Test-Path $p) {
        if ($p.EndsWith(".csv")) { $counts[$k] = (Import-Csv $p).Count } else { $counts[$k] = 1 }
    } else { $counts[$k] = 0 }
}

$hashes = @{}
foreach ($k in $paths.Keys) {
    $p = $paths[$k]
    if (Test-Path $p) { $hashes[$k] = Get-SduFileHashSafe $p }
}

$manifest = [pscustomobject]@{
    manifest_id = "SDU-EVIDENCE-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    runner_id = "SDU_ORGANIZACION_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1"
    generated_at = Get-SduTimestamp
    mode = "G1_LOCAL_REVERSIBLE_DRYRUN"
    outputs = $paths
    hashes = $hashes
    counts = $counts
    policy = [pscustomobject]@{
        dry_run = $true
        no_delete = $true
        no_overwrite = $true
        no_live = $true
        no_push = $true
        no_pr = $true
        evidence_mode = "metadata_hash_redacted"
    }
    warnings = @()
}
Save-SduJson $manifest $ManifestOut

$md = @()
$md += "# Reporte — SDU Organización Total Multiagente"
$md += ""
$md += "Fecha UTC: $(Get-SduTimestamp)"
$md += "Modo: G1_LOCAL_REVERSIBLE_DRYRUN"
$md += ""
$md += "## Conteos"
foreach ($k in $counts.Keys) { $md += "- ${k}: $($counts[$k])" }
$md += ""
$md += "## Evidencia"
foreach ($k in $hashes.Keys) { $md += "- ${k}: $($hashes[$k])" }
$md += ""
$md += "## Dictamen"
$md += "No se aplicaron movimientos reales. El paquete produjo inventario, clasificación, plan, validación y manifiesto de evidencia."
$md += ""
$md += "## Próximo gate"
$md += "Para movimiento real se requiere gate explícito posterior, revisión de manual-review.csv, y aprobación del owner."

$md | Set-Content -LiteralPath $OutReport -Encoding UTF8
Write-SduLog "Reporte completado: $OutReport" "INFO" $LogPath
