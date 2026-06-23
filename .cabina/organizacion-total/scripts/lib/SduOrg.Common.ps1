Set-StrictMode -Version Latest

function Get-SduTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Resolve-SduPathToken {
    param([Parameter(Mandatory=$true)][string]$Path)
    return [Environment]::ExpandEnvironmentVariables($Path.Replace('/', '\'))
}

function Get-SduFileHashSafe {
    param([Parameter(Mandatory=$true)][string]$Path)
    try {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256 -ErrorAction Stop).Hash
    } catch {
        return "HASH_ERROR:$($_.Exception.GetType().Name)"
    }
}

function Write-SduLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [string]$Level = "INFO",
        [string]$LogPath = ".\logs\sdu-org.log"
    )
    $line = "$(Get-SduTimestamp) [$Level] $Message"
    $dir = Split-Path $LogPath -Parent
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $line | Tee-Object -FilePath $LogPath -Append
}

function Read-SduJson {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path $Path)) { throw "JSON no encontrado: $Path" }
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Save-SduJson {
    param(
        [Parameter(Mandatory=$true)]$Object,
        [Parameter(Mandatory=$true)][string]$Path
    )
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $Object | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Test-SduExcludedPath {
    param(
        [Parameter(Mandatory=$true)][string]$FullName,
        [Parameter(Mandatory=$true)]$Policy
    )
    $normalized = $FullName.Replace('/', '\')
    foreach ($root in $Policy.excluded_roots) {
        $r = Resolve-SduPathToken $root
        if ($normalized.StartsWith($r, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    foreach ($fragment in $Policy.excluded_fragments) {
        $f = $fragment.Replace('/', '\')
        if ($normalized.IndexOf($f, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    }
    return $false
}

function Get-SduCommandResolution {
    param([Parameter(Mandatory=$true)][string]$CommandName)
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($null -eq $cmd) {
        return [pscustomobject]@{ Name=$CommandName; Found=$false; Source=$null; Version=$null }
    }
    return [pscustomobject]@{ Name=$CommandName; Found=$true; Source=$cmd.Source; Version=$cmd.Version }
}

function New-SduOutputDirs {
    foreach ($d in @("out", "logs")) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
    }
}

function ConvertTo-SduSafeFileName {
    param([Parameter(Mandatory=$true)][string]$Name)
    return ($Name -replace '[<>:"/\\|?*]', '_')
}
