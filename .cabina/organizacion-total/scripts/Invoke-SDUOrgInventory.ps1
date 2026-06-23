param(
    [string]$PolicyPath = ".\config\sdu-org-policy.json",
    [string]$OutCsv = ".\out\inventory.csv",
    [string]$LogPath = ".\logs\inventory.log"
)

. "$PSScriptRoot\lib\SduOrg.Common.ps1"
New-SduOutputDirs
$policy = Read-SduJson $PolicyPath
Write-SduLog "Inventario iniciado" "INFO" $LogPath

$items = New-Object System.Collections.Generic.List[object]
$roots = @($policy.allowed_roots) | ForEach-Object { Resolve-SduPathToken $_ } | Select-Object -Unique
$workspaceRoot = if ($policy.workspace_root) { Resolve-SduPathToken $policy.workspace_root } else { $null }
$safeRoots = @()
foreach ($root in @($roots)) {
    $resolvedRoot = [System.IO.Path]::GetFullPath($root)
    if ($workspaceRoot -and ($resolvedRoot.StartsWith((Resolve-SduPathToken $workspaceRoot), [System.StringComparison]::OrdinalIgnoreCase))) {
        $safeRoots += $resolvedRoot
    } else {
        Write-SduLog "Root descartado por criterio G1 (fuera de workspace): $resolvedRoot" "WARN" $LogPath
    }
}
if ($safeRoots.Count -eq 0) { throw "No hay roots de inventario dentro del workspace seguro." }
$roots = $safeRoots | Select-Object -Unique

foreach ($root in $roots) {
    if (-not (Test-Path $root)) {
        Write-SduLog "Root ausente: $root" "WARN" $LogPath
        continue
    }
    Write-SduLog "Escaneando root: $root" "INFO" $LogPath
    Get-ChildItem -LiteralPath $root -Recurse -Force -File -ErrorAction SilentlyContinue -Attributes !ReparsePoint | ForEach-Object {
        $full = $_.FullName
        if (Test-SduExcludedPath -FullName $full -Policy $policy) { return }
        $hash = Get-SduFileHashSafe $full
        $items.Add([pscustomobject]@{
            FullName = $full
            Directory = $_.DirectoryName
            Name = $_.Name
            Extension = $_.Extension.ToLowerInvariant()
            Length = $_.Length
            CreationTime = $_.CreationTime.ToString("o")
            LastWriteTime = $_.LastWriteTime.ToString("o")
            Hash = $hash
            Root = $root
        })
    }
}

$items | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $OutCsv
Write-SduLog "Inventario completado. Count=$($items.Count). Out=$OutCsv" "INFO" $LogPath
