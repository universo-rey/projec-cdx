param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode repo-boundary -Json
}
else {
    & $Script -Mode repo-boundary
}

$global:LASTEXITCODE = 0
