param(
    [string]$InventoryCsv = ".\out\inventory.csv",
    [string]$RulesPath = ".\config\classification-rules.v2.json",
    [string]$SelectedAgentsPath = ".\out\selected-agents.json",
    [string]$OutCsv = ".\out\classification.csv",
    [string]$ManualReviewCsv = ".\out\manual-review.csv",
    [string]$RiskCsv = ".\out\risk-register.csv",
    [string]$LogPath = ".\logs\classification.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
if (-not (Test-Path $InventoryCsv)) { throw "Inventario no encontrado: $InventoryCsv" }
$rules = Read-SduJson $RulesPath
$agents = if (Test-Path $SelectedAgentsPath) { Read-SduJson $SelectedAgentsPath } else { $null }
Write-SduLog "Clasificación multiagente iniciada" "INFO" $LogPath

function Test-ContainsAnyToken {
    param([string]$Text, [object[]]$Tokens)
    foreach ($t in $Tokens) {
        if ([string]::IsNullOrWhiteSpace([string]$t)) { continue }
        if ($Text.IndexOf([string]$t, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return [string]$t }
    }
    return $null
}

$rows = Import-Csv $InventoryCsv
$classRows = New-Object System.Collections.Generic.List[object]
$manual = New-Object System.Collections.Generic.List[object]
$risks = New-Object System.Collections.Generic.List[object]

foreach ($r in $rows) {
    $text = "$($r.FullName) $($r.Name) $($r.Extension)"
    $votes = @()
    $universeMatches = @()
    $dataClass = "D1"
    $assetType = "UNKNOWN"
    $riskFlags = New-Object System.Collections.Generic.List[string]

    # ANUBIS: secret indicators first
    $secretHit = Test-ContainsAnyToken -Text $text -Tokens $rules.secret_indicators
    if ($secretHit) {
        $riskFlags.Add("SECRET_INDICATOR:$secretHit")
        $dataClass = "D6"
    }

    # SESHAT: universe semantic classification
    foreach ($uProp in $rules.universes.PSObject.Properties) {
        $hit = Test-ContainsAnyToken -Text $text -Tokens $uProp.Value.tokens
        if ($hit) {
            $universeMatches += [pscustomobject]@{ Universe=$uProp.Name; Token=$hit; DefaultClass=$uProp.Value.default_classification; ProtectiveClass=$uProp.Value.protective_classification }
        }
    }

    $universe = "UNKNOWN"
    $reason = "Sin match suficiente"
    if ($universeMatches.Count -eq 1) {
        $universe = $universeMatches[0].Universe
        $reason = "SESHAT token: $($universeMatches[0].Token)"
        if ($universeMatches[0].ProtectiveClass) { $dataClass = $universeMatches[0].ProtectiveClass } else { $dataClass = $universeMatches[0].DefaultClass }
    } elseif ($universeMatches.Count -gt 1) {
        $universe = "MULTIPLE"
        $reason = "Múltiples universos: " + (($universeMatches | ForEach-Object { $_.Universe + ':' + $_.Token }) -join ', ')
        $riskFlags.Add("MULTIPLE_UNIVERSES_DETECTED")
    }

    # THOT: asset type
    foreach ($aProp in $rules.asset_type_rules.PSObject.Properties) {
        $hit = Test-ContainsAnyToken -Text $text -Tokens $aProp.Value
        if ($hit) { $assetType = $aProp.Name; break }
    }

    # HORUS: noise
    $noiseHit = Test-ContainsAnyToken -Text $text -Tokens $rules.noise_indicators
    if ($noiseHit) { $riskFlags.Add("NOISE_CANDIDATE:$noiseHit") }

    # MAAT: evidence policy marker
    $evidenceMode = if ($dataClass -in @("D3", "D4", "D5", "D6", "D7")) { "metadata_hash_only" } else { "standard_metadata" }

    $reviewRequired = $false
    if ($universe -in @("UNKNOWN", "MULTIPLE")) { $reviewRequired = $true }
    if ($dataClass -in @("D3", "D4", "D5", "D6", "D7")) { $reviewRequired = $true }
    if ($riskFlags.Count -gt 0) { $reviewRequired = $true }

    $targetBucket = if ($reviewRequired) { "98_REVISION_MANUAL" } elseif ($noiseHit) { "97_RUIDO_CANDIDATO" } else { $universe }

    $obj = [pscustomobject]@{
        FullName = $r.FullName
        Name = $r.Name
        Extension = $r.Extension
        Length = $r.Length
        Hash = $r.Hash
        Universe = $universe
        AssetType = $assetType
        DataClassification = $dataClass
        TargetBucket = $targetBucket
        ReviewRequired = $reviewRequired
        Reason = $reason
        RiskFlags = ($riskFlags -join ';')
        EvidenceMode = $evidenceMode
        AgentVotes = "SESHAT=$universe;THOT=$assetType;ANUBIS=$dataClass;MAAT=$evidenceMode;HORUS=$($riskFlags -join '|')"
    }
    $classRows.Add($obj)

    if ($reviewRequired) { $manual.Add($obj) }
    if ($riskFlags.Count -gt 0) {
        $risks.Add([pscustomobject]@{
            FullName=$r.FullName; Hash=$r.Hash; RiskFlags=($riskFlags -join ';'); DataClassification=$dataClass; Universe=$universe; RequiredAction="manual_review"
        })
    }
}

$classRows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $OutCsv
$manual | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $ManualReviewCsv
$risks | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $RiskCsv
Write-SduLog "Clasificación completada. Count=$($classRows.Count); Manual=$($manual.Count); Risks=$($risks.Count)" "INFO" $LogPath
