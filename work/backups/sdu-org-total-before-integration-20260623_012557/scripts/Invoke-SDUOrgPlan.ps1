param(
    [string]$ClassificationCsv = ".\out\classification.csv",
    [string]$TargetRoot = "$env:USERPROFILE\Documents\CABINA_ORGANIZADA_SDU_DRYRUN",
    [string]$OutCsv = ".\out\move-plan.csv",
    [string]$OutJson = ".\out\move-plan.json",
    [string]$LogPath = ".\logs\plan.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
if (-not (Test-Path $ClassificationCsv)) { throw "Clasificación no encontrada: $ClassificationCsv" }
Write-SduLog "Plan iniciado" "INFO" $LogPath

$rows = Import-Csv $ClassificationCsv
$plan = New-Object System.Collections.Generic.List[object]
$seenTargets = @{}

foreach ($r in $rows) {
    $safeName = ConvertTo-SduSafeFileName $r.Name
    $bucket = if ([string]::IsNullOrWhiteSpace($r.TargetBucket)) { "98_REVISION_MANUAL" } else { $r.TargetBucket }
    $assetType = if ([string]::IsNullOrWhiteSpace($r.AssetType)) { "UNKNOWN" } else { $r.AssetType }
    $targetDir = Join-Path (Join-Path $TargetRoot $bucket) $assetType
    $target = Join-Path $targetDir $safeName
    $action = "PLAN_ONLY"
    $planRisk = ""

    if ($seenTargets.ContainsKey($target.ToLowerInvariant())) {
        $action = "CONFLICT_REVIEW"
        $planRisk = "TARGET_COLLISION_IN_PLAN"
        $targetDir = Join-Path $TargetRoot "99_CONFLICTOS"
        $target = Join-Path $targetDir $safeName
    } else {
        $seenTargets[$target.ToLowerInvariant()] = $true
    }

    if ($r.ReviewRequired -eq "True") { $action = "MANUAL_REVIEW_REQUIRED" }

    $plan.Add([pscustomobject]@{
        Action = $action
        Source = $r.FullName
        Target = $target
        Universe = $r.Universe
        AssetType = $assetType
        DataClassification = $r.DataClassification
        Hash = $r.Hash
        Reason = $r.Reason
        RiskFlags = (($r.RiskFlags, $planRisk) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ';'
        DryRunOnly = $true
    })
}

$plan | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $OutCsv
Save-SduJson ([pscustomobject]@{ generated_at=Get-SduTimestamp; target_root=$TargetRoot; dry_run_only=$true; items=$plan }) $OutJson
Write-SduLog "Plan completado. Count=$($plan.Count). Out=$OutCsv" "INFO" $LogPath
