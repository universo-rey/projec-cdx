param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode noise-plan -Json
}
else {
    & $Script -Mode noise-plan
}

$global:LASTEXITCODE = 0
