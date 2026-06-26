param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$ListCommand = Join-Path $Root 'tools\ceo-ide-extension-list.ps1'

if (-not (Test-Path -LiteralPath $ListCommand)) {
    $payload = [PSCustomObject]@{
        command = 'ceo-ide-extension-policy'
        status = 'IDE_EXTENSION_POLICY_BLOCKED_LIST_COMMAND_MISSING'
    }
    if ($Json) { $payload | ConvertTo-Json -Depth 5 } else { $payload }
    exit 0
}

$list = & $ListCommand -Json | ConvertFrom-Json
$extensions = @($list.extensions)
$allow = @($extensions | Where-Object { $_.policy -eq 'ALLOW' } | Sort-Object id)
$support = @($extensions | Where-Object { $_.policy -eq 'SUPPORT' } | Sort-Object id)
$hold = @($extensions | Where-Object { $_.policy -eq 'HOLD' } | Sort-Object id)
$review = @($extensions | Where-Object { $_.policy -eq 'REVIEW' } | Sort-Object id)
$noise = @($extensions | Where-Object { $_.policy -eq 'NOISE' } | Sort-Object folder)

$impactSummary = foreach ($impact in @('terminal', 'git', 'python', 'node', 'markdown', 'agents', 'mcp')) {
    [PSCustomObject]@{
        impact = $impact
        count = @($extensions | Where-Object { $_.impacts -contains $impact }).Count
        allow = @($allow | Where-Object { $_.impacts -contains $impact }).Count
        hold = @($hold | Where-Object { $_.impacts -contains $impact }).Count
    }
}

$profileRecommendation = [PSCustomObject]@{
    name = 'CEO Governed Minimal'
    allowlist = @($allow | ForEach-Object { $_.id })
    support_available = @($support | ForEach-Object { $_.id })
    holdlist = @($hold | ForEach-Object { $_.id })
    review = @($review | ForEach-Object { $_.id })
    noise = @($noise | ForEach-Object { $_.folder })
    rule = 'No desinstalar automaticamente; usar allowlist para perfil operativo y holdlist para reducir ruido bajo decision owner.'
}

$riskNotes = @()
if ($hold.Count -gt 8) {
    $riskNotes += 'Muchas extensiones AGENT/MCP/AI en paralelo; riesgo de ruido, comandos duplicados y procesos de fondo.'
}
if (@($extensions | Where-Object { $_.impacts -contains 'terminal' }).Count -gt 0) {
    $riskNotes += 'Hay extensiones que pueden afectar terminal o shells; mantener CEO PowerShell como perfil default gobernado.'
}
if (@($extensions | Where-Object { $_.impacts -contains 'python' }).Count -gt 0) {
    $riskNotes += 'Hay extensiones Python/Jupyter; mantener interpreter .venv desde settings del workspace.'
}
if (@($extensions | Where-Object { $_.impacts -contains 'mcp' }).Count -gt 0) {
    $riskNotes += 'Hay extension MCP; no ejecutar servidores MCP sin gate.'
}

$payload = [PSCustomObject]@{
    command = 'ceo-ide-extension-policy'
    status = 'IDE_EXTENSION_CONTROL_READY'
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    extension_count = $extensions.Count
    allow_count = $allow.Count
    support_count = $support.Count
    hold_count = $hold.Count
    review_count = $review.Count
    noise_count = $noise.Count
    duplicate_count = $list.duplicate_count
    by_class = $list.by_class
    by_policy = $list.by_policy
    impact_summary = $impactSummary
    profile_recommendation = $profileRecommendation
    risk_notes = $riskNotes
    frontera = @{
        no_uninstall = $true
        no_profile_mutation = $true
        no_secret_read = $true
        no_live = $true
        no_push = $true
        no_pr = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
