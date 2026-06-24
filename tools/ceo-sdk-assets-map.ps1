param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode sdk-assets -Json
}
else {
    & $Script -Mode sdk-assets
}

$global:LASTEXITCODE = 0
