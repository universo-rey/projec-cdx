[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Root = 'C:\Users\enzo1\.codex',
    [string]$PlanPath = 'C:/Users/enzo1/PROJEC CDX/CODEX_ROOT_MOVE_PLAN.json',
    [string]$ResultsPath = 'C:/Users/enzo1/PROJEC CDX/CODEX_ROOT_MOVE_RESULTS.json'
)

$ErrorActionPreference = 'Stop'

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

$plan = Get-Content -LiteralPath $PlanPath -Raw | ConvertFrom-Json
$results = New-Object System.Collections.Generic.List[object]

foreach ($item in $plan.move_safe) {
    $source = $item.source
    $destinationDir = Join-Path $Root $item.destination
    $target = Join-Path $destinationDir $item.name

    if (-not (Test-Path -LiteralPath $source)) {
        $results.Add([pscustomobject]@{
            name     = $item.name
            status   = 'NOOP'
            reason   = 'source missing'
            source   = $source
            target   = $target
        }) | Out-Null
        continue
    }

    Ensure-Directory -Path $destinationDir

    if (Test-Path -LiteralPath $target) {
        $results.Add([pscustomobject]@{
            name     = $item.name
            status   = 'NOOP'
            reason   = 'target already exists'
            source   = $source
            target   = $target
        }) | Out-Null
        continue
    }

    if ($PSCmdlet.ShouldProcess($source, "Move to $target")) {
        Move-Item -LiteralPath $source -Destination $target
        $results.Add([pscustomobject]@{
            name     = $item.name
            status   = 'DONE'
            reason   = $item.reason
            source   = $source
            target   = $target
        }) | Out-Null
    }
}

$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ResultsPath -Encoding utf8
Write-Host "Wrote: $ResultsPath"
