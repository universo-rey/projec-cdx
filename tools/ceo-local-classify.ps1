param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode classify -Json
}
else {
    & $Script -Mode classify
}

$global:LASTEXITCODE = 0
