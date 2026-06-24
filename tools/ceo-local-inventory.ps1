param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode inventory -Json
}
else {
    & $Script -Mode inventory
}

$global:LASTEXITCODE = 0
