param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode cleanup-gate-status -Json
}
else {
    & $Script -Mode cleanup-gate-status
}

$global:LASTEXITCODE = 0
