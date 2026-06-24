param(
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$state = Initialize-CeoSuiteState -StateRoot $StateRoot
$metrics = Get-CeoBusMetrics -StateRoot $state.StateRoot
New-Item -ItemType Directory -Force -Path $state.PanelDir | Out-Null

$panel = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    mode = "ACTIVE_GOVERNED_EXECUTION_BY_DEFAULT"
    bus = $metrics
    boundary = [ordered]@{
        repoScoped = $true
        liveWrite = $false
        secrets = $false
        sensitiveMutation = $false
    }
}

$panelFile = Join-Path $state.PanelDir ("panel-$((Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss')).json")
$panel | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $panelFile -Encoding UTF8
$panel | ConvertTo-Json -Depth 20
exit 0
