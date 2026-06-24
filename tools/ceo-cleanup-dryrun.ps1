param(
    [switch] $Json
)

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'ceo-local-reconcile.ps1'
if ($Json) {
    & $Script -Mode cleanup-dryrun -Json
}
else {
    & $Script -Mode cleanup-dryrun
}

$global:LASTEXITCODE = 0
