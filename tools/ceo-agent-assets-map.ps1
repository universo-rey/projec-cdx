param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode agent-assets -Json
}
else {
    & $Script -Mode agent-assets
}

$global:LASTEXITCODE = 0
