param(
    [string]$GraphPath = "C:\CEO\project-cdx\graphify-out\graph.json",
    [string]$ReportPath = "C:\CEO\project-cdx\graphify-out\GRAPH_REPORT.md",
    [string]$BaselinePath = "C:\CEO\project-cdx\graphify-out\graph.freeze.json",
    [int]$ThrottleMinutes = 10
)

$ErrorActionPreference = "Stop"

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Read-JsonFile {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

$graphHash = Get-Sha256 -Path $GraphPath
$reportHash = Get-Sha256 -Path $ReportPath
$graph = $null
if (Test-Path -LiteralPath $GraphPath) {
    $graph = Get-Content -LiteralPath $GraphPath -Raw | ConvertFrom-Json
}

$baseline = Read-JsonFile -Path $BaselinePath
$sameHashes = $false
if ($baseline) {
    $sameHashes = ($baseline.graph.sha256 -eq $graphHash -and $baseline.report.sha256 -eq $reportHash)
}

$baselineTime = $null
if (Test-Path -LiteralPath $BaselinePath) {
    $baselineTime = (Get-Item -LiteralPath $BaselinePath).LastWriteTimeUtc
}

$ageMinutes = $null
if ($baselineTime) {
    $ageMinutes = ((Get-Date).ToUniversalTime() - $baselineTime).TotalMinutes
}

$reclusterAllowed = -not $sameHashes
$reason = if ($sameHashes) {
    "graph_unchanged"
} elseif (-not $baseline) {
    "baseline_missing"
} else {
    "graph_changed"
}

$result = [pscustomobject]@{
    status = if ($sameHashes) { "LOCKED" } elseif (-not $baseline) { "BASELINE_MISSING" } else { "STALE_BASELINE" }
    auto_rebuild = "OFF"
    full_scan = "DISABLED"
    viz = "DISABLED"
    recluster_allowed = $reclusterAllowed
    reason = $reason
    throttle_minutes = $ThrottleMinutes
    baseline_age_minutes = $ageMinutes
    graph = [pscustomobject]@{
        path = $GraphPath
        sha256 = $graphHash
        nodes = if ($graph -and $graph.nodes) { @($graph.nodes).Count } else { $null }
        links = if ($graph -and $graph.links) { @($graph.links).Count } else { $null }
    }
    report = [pscustomobject]@{
        path = $ReportPath
        sha256 = $reportHash
    }
    baseline = [pscustomobject]@{
        path = $BaselinePath
        present = [bool]$baseline
        same_hashes = $sameHashes
    }
}

$result | ConvertTo-Json -Depth 10
