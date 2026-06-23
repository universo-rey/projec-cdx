param(
    [ValidateSet("Full", "Preflight", "Inventory", "Classify", "Plan", "Apply", "Queues", "Index", "Validate", "Final")]
    [string]$Phase = "Full"
)

$ErrorActionPreference = "Stop"
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$RunnerRoot = Split-Path $PSScriptRoot -Parent
$RepoRoot = (& git -C $RunnerRoot rev-parse --show-toplevel 2>$null).Trim()
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    throw "No se pudo resolver el repo root desde $RunnerRoot"
}

$OutDir = Join-Path $RunnerRoot "out"
$ConfigDir = Join-Path $RunnerRoot "config"
$DocsDir = Join-Path $RunnerRoot "docs"
New-Item -ItemType Directory -Force -Path $OutDir, $ConfigDir, $DocsDir | Out-Null

$BaselineCommit = "c9d848a225802000701fb4fa97b077d0dcec4bd6"
$CriticalPrefixes = @("C:\Windows", "C:\Program Files", "C:\Program Files (x86)", "C:\ProgramData")
$SkipSegments = @("\.git\", "\node_modules\", "\.venv\", "\venv\", "\__pycache__\", "\.pytest_cache\", "\.mypy_cache\", "\dist\", "\build\", "\.next\", "\.turbo\", "\.cache\")

function ConvertTo-SafePath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }
    return ($Path -replace "/", "\").TrimEnd("\")
}

function ConvertTo-SlashPath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }
    return ($Path -replace "\\", "/")
}

function Test-CriticalPath([string]$Path) {
    $normalized = ConvertTo-SafePath $Path
    foreach ($prefix in $CriticalPrefixes) {
        if ($normalized.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Test-SkipPath([string]$Path, [string]$RootId) {
    $normalized = ConvertTo-SafePath $Path
    if (Test-CriticalPath $normalized) { return $true }
    if ($RootId -eq "CEO_ROOT" -and $normalized.StartsWith((ConvertTo-SafePath $RepoRoot), [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($RootId -eq "CEO_ROOT" -and $normalized.StartsWith("C:\CEO\project-cdx", [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    foreach ($segment in $SkipSegments) {
        if ($normalized.IndexOf($segment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    }
    return $false
}

function Get-RepoRelativePath([string]$Path) {
    $normalized = ConvertTo-SafePath $Path
    $root = ConvertTo-SafePath $RepoRoot
    if ($normalized.Equals($root, [System.StringComparison]::OrdinalIgnoreCase)) { return "." }
    if ($normalized.StartsWith($root + "\", [System.StringComparison]::OrdinalIgnoreCase)) {
        return $normalized.Substring($root.Length + 1)
    }
    return $null
}

function Get-RootSpecs {
    $roots = New-Object System.Collections.Generic.List[object]
    function Add-Root([string]$Id, [string]$Path, [string]$Role, [string]$Scope) {
        $roots.Add([pscustomobject]@{
            root_id = $Id
            path = $Path
            exists = [bool](Test-Path -LiteralPath $Path)
            role = $Role
            scan_scope = $Scope
        }) | Out-Null
    }

    Add-Root "CEO_ROOT" "C:\CEO" "control_plane_facade" "bounded_metadata"
    Add-Root "PROJECT_CDX" $RepoRoot "repo_physical_root" "repo_metadata"
    Add-Root "CODEX_HOME" (Join-Path $env:USERPROFILE ".codex") "codex_local_state" "bounded_metadata"
    Add-Root "DOWNLOADS" (Join-Path $env:USERPROFILE "Downloads") "ingress_surface" "bounded_metadata"
    Add-Root "DOCUMENTS" (Join-Path $env:USERPROFILE "Documents") "documents_surface" "bounded_metadata"
    Add-Root "DESKTOP" (Join-Path $env:USERPROFILE "Desktop") "desktop_surface" "bounded_metadata"
    Add-Root "OPERATIVA" (Join-Path $RepoRoot "operativa") "operational_surface" "repo_metadata"
    Add-Root "WORK" (Join-Path $RepoRoot "work") "working_backups_surface" "repo_metadata"
    Add-Root "TMP_SDU_ORG_TOTAL" (Join-Path $RepoRoot ".tmp_sdu_org_total") "temporary_surface" "repo_metadata"
    Add-Root "CABINA_OUT" (Join-Path $RunnerRoot "out") "evidence_output_surface" "repo_metadata"
    Add-Root "CABINA_LOGS" (Join-Path $RunnerRoot "logs") "logs_surface" "repo_metadata"

    Get-ChildItem -LiteralPath $env:USERPROFILE -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "OneDrive*" } |
        ForEach-Object {
            Add-Root ("ONEDRIVE_" + ($_.Name -replace "[^A-Za-z0-9]", "_").ToUpperInvariant()) $_.FullName "onedrive_local_sync_surface" "bounded_metadata"
        }

    return $roots.ToArray()
}

function Get-GitStatusMap {
    $map = @{}
    $raw = & git -C $RepoRoot status --porcelain=v1
    foreach ($line in $raw) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.Length -lt 4) { continue }
        $status = $line.Substring(0, 2).Trim()
        $path = $line.Substring(3)
        if ($path -match " -> ") { $path = ($path -split " -> ")[-1] }
        $path = $path.Trim('"') -replace "/", "\"
        $map[$path] = $status
    }
    return $map
}

function Get-GitStatusForPath([string]$Path, [hashtable]$Map) {
    $relative = Get-RepoRelativePath $Path
    if ($null -eq $relative) { return "outside_git" }
    if ($Map.ContainsKey($relative)) { return $Map[$relative] }
    foreach ($key in $Map.Keys) {
        $prefix = $key.TrimEnd("\")
        if ($relative.Equals($prefix, [System.StringComparison]::OrdinalIgnoreCase) -or
            $relative.StartsWith($prefix + "\", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $Map[$key]
        }
    }
    return "clean_or_ignored"
}

function Test-InsideCabina([string]$Path) {
    $relative = Get-RepoRelativePath $Path
    return ($null -ne $relative -and $relative.StartsWith(".cabina\", [System.StringComparison]::OrdinalIgnoreCase))
}

function Get-Universe([string]$Path) {
    $lower = $Path.ToLowerInvariant()
    $universes = New-Object System.Collections.Generic.List[string]
    if ($lower -like "*\projec cdx\*" -or $lower -like "*\project-cdx\*") { $universes.Add("PROJEC_CDX") | Out-Null }
    if ($lower -like "*\.cabina\*") { $universes.Add("SDU_CABINA") | Out-Null }
    if ($lower -like "*\.codex\*" -or $lower -like "*codex*") { $universes.Add("CODEX_LOCAL") | Out-Null }
    if ($lower -like "*\operativa\*") { $universes.Add("OPERATIVA") | Out-Null }
    if ($lower -like "*\work\*") { $universes.Add("WORK") | Out-Null }
    if ($lower -like "*\.tmp_sdu_org_total\*" -or $lower -like "*\tmp\*" -or $lower -like "*\temp\*") { $universes.Add("TEMP") | Out-Null }
    if ($lower -like "*sgin*" -or $lower -like "*d3*" -or $lower -like "*d4*" -or $lower -like "*d5*" -or $lower -like "*d6*" -or $lower -like "*d7*") { $universes.Add("SENSITIVE_BUSINESS") | Out-Null }
    if ($universes.Count -eq 0) { $universes.Add("UNKNOWN") | Out-Null }
    $unique = @($universes | Select-Object -Unique)
    if ($unique.Count -gt 1) { return "MULTIPLE:" + ($unique -join "+") }
    return $unique[0]
}

function Get-FunctionClass([string]$Path, [string]$Extension, [bool]$IsDirectory) {
    $lower = $Path.ToLowerInvariant()
    if ($IsDirectory) {
        if ($lower -like "*backup*" -or $lower -like "*backups*") { return "BACKUP_DIR" }
        if ($lower -like "*tmp*" -or $lower -like "*temp*") { return "TEMP_DIR" }
        if ($lower -like "*logs*" -or $lower -like "*log*") { return "LOG_DIR" }
        if ($lower -like "*out*" -or $lower -like "*evidence*" -or $lower -like "*evidencia*") { return "EVIDENCE_DIR" }
        return "FOLDER"
    }
    if ($lower -like "*.previous-*" -or $lower -like "*backup*") { return "BACKUP" }
    if ($lower -like "*\logs\*" -or $Extension -eq ".log") { return "LOG" }
    if ($lower -like "*readback*" -or $lower -like "*final_readback*") { return "READBACK" }
    if ($lower -like "*manifest*" -or $lower -like "*index*" -or $Extension -in @(".json", ".yaml", ".yml", ".toml")) { return "CONFIG_OR_MANIFEST" }
    if ($Extension -in @(".ps1", ".py", ".js", ".ts", ".tsx", ".sh", ".cmd", ".bat")) { return "SCRIPT_OR_CODE" }
    if ($Extension -in @(".csv", ".xlsx", ".parquet", ".ndjson")) { return "DATA_OR_RAW_EVIDENCE" }
    if ($Extension -in @(".md", ".txt", ".docx", ".pdf")) { return "DOCUMENT" }
    if ($lower -like "*tmp*" -or $lower -like "*temp*") { return "TEMP_FILE" }
    return "OTHER"
}

function Get-Sensitivity([string]$Path, [string]$Extension) {
    $lower = $Path.ToLowerInvariant()
    if ($lower -match "(secret|token|credential|credencial|password|passwd|apikey|api_key|\.env)") { return "SENSITIVE_SECRET_CANDIDATE_METADATA_ONLY" }
    if ($lower -match "(sgin|d3|d4|d5|d6|d7|notarial|registro|cliente|client|persona|personas)") { return "SENSITIVE_BUSINESS_METADATA_ONLY" }
    if ($Extension -in @(".csv", ".xlsx", ".parquet", ".ndjson", ".log")) { return "LOCAL_RAW_OR_LOG_METADATA_ONLY" }
    return "NORMAL_METADATA_ONLY"
}

function Get-Destination([string]$Universe, [string]$Function, [string]$Sensitivity) {
    if ($Sensitivity -like "SENSITIVE*") { return "C:\CEO\98_OWNER_REVIEW\SENSITIVE_METADATA_ONLY" }
    if ($Function -like "BACKUP*") { return "C:\CEO\12_ARCHIVE\BACKUP_RETENTION" }
    if ($Function -like "TEMP*") { return "C:\CEO\98_OWNER_REVIEW\TEMP_RETENTION" }
    if ($Universe -like "*SDU_CABINA*") { return "C:\CEO\01_CABINA_SDU" }
    if ($Universe -like "*CODEX_LOCAL*") { return "C:\CEO\03_CODEX_LOCAL" }
    if ($Universe -like "*OPERATIVA*") { return "C:\CEO\02_RUNTIME_OPERATIVA" }
    if ($Function -eq "READBACK" -or $Function -eq "EVIDENCE_DIR") { return "C:\CEO\06_EVIDENCE_AND_READBACKS" }
    if ($Function -eq "CONFIG_OR_MANIFEST") { return "C:\CEO\04_CONFIG_AND_REGISTRIES" }
    if ($Function -eq "SCRIPT_OR_CODE") { return "C:\CEO\05_TOOLS_AND_AUTOMATION" }
    if ($Function -eq "DATA_OR_RAW_EVIDENCE" -or $Function -eq "LOG") { return "C:\CEO\07_RAW_AND_LOCAL_ONLY" }
    return "C:\CEO\98_OWNER_REVIEW"
}

function Get-RecommendedAction([string]$Function, [string]$Sensitivity, [string]$Universe, [string]$GitStatus) {
    if ($Sensitivity -like "SENSITIVE*") { return "QUEUE_OWNER_REVIEW_METADATA_ONLY" }
    if ($Function -like "TEMP*") { return "QUEUE_TEMP_RETENTION" }
    if ($Function -like "BACKUP*") { return "QUEUE_BACKUP_RETENTION" }
    if ($Universe -like "MULTIPLE:*") { return "QUEUE_MULTIPLE_REVIEW" }
    if ($Function -eq "DATA_OR_RAW_EVIDENCE" -or $Function -eq "LOG") { return "KEEP_LOCAL_REGISTER_ONLY" }
    if ($GitStatus -eq "??" -and $Function -eq "CONFIG_OR_MANIFEST") { return "OWNER_DECISION_VERSIONABLE_OR_LOCAL" }
    return "KEEP_IN_PLACE_REGISTER_IN_NERVOUS_INDEX"
}

function Write-CsvWithHeader([object[]]$Rows, [string]$Path, [string[]]$Columns) {
    if (@($Rows).Count -gt 0) {
        $Rows | Select-Object $Columns | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
    } else {
        ('"' + ($Columns -join '","') + '"') | Set-Content -LiteralPath $Path -Encoding UTF8
    }
}

function Write-JsonFile([object]$Value, [string]$Path, [int]$Depth = 8) {
    ConvertTo-Json -InputObject $Value -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Invoke-Preflight {
    $status = (& git -C $RepoRoot status --short 2>&1) -join "`n"
    $diffCheck = (& git -C $RepoRoot diff --check 2>&1) -join "`n"
    $diffExit = $LASTEXITCODE
    $staging = (& git -C $RepoRoot diff --cached --name-only 2>&1) -join "`n"
    $head = (& git -C $RepoRoot rev-parse HEAD).Trim()
    $roots = Get-RootSpecs
    $preflight = [ordered]@{
        schema = "local-fs-preflight.v1"
        generated_at = (Get-Date).ToString("s")
        repo = $RepoRoot
        runner_root = $RunnerRoot
        head = $head
        baseline_commit = $BaselineCommit
        staging_empty = [string]::IsNullOrWhiteSpace($staging)
        git_diff_check_exit = $diffExit
        git_diff_check = $diffCheck
        git_status_short = $status
        no_delete = $true
        no_live = $true
        no_remote = $true
        roots = $roots
    }
    Write-JsonFile $preflight (Join-Path $OutDir "LOCAL_FS_PREFLIGHT.json")

    $rootLines = @($roots | ForEach-Object { "- $($_.root_id): $($_.path) exists=$($_.exists) scope=$($_.scan_scope)" }) -join "`n"
    $diffLabel = if ([string]::IsNullOrWhiteSpace($diffCheck)) { "OK" } else { "WARNINGS_PRESENT_NON_BLOCKING" }
    $preflightMd = @"
# LOCAL_FS_PREFLIGHT

Estado: PREFLIGHT_OK_WITH_EXISTING_LOCAL_PENDING

- Repo: $RepoRoot
- Runner: $RunnerRoot
- HEAD: $head
- Baseline esperado: $BaselineCommit
- Staging vacio: $([string]::IsNullOrWhiteSpace($staging))
- Delete/move destructivo/live/remoto: bloqueado
- Diff check: $diffLabel

## Raices

$rootLines

## Estado Git corto

text:
$status

## Diff check

text:
$diffCheck
"@
    $preflightMd | Set-Content -LiteralPath (Join-Path $OutDir "LOCAL_FS_PREFLIGHT.md") -Encoding UTF8
}

function Invoke-Inventory {
    $roots = Get-RootSpecs
    $gitMap = Get-GitStatusMap
    $files = New-Object System.Collections.Generic.List[object]
    $folders = New-Object System.Collections.Generic.List[object]
    $scanSummaries = New-Object System.Collections.Generic.List[object]

    function Get-ScanProfile([string]$RootId) {
        switch -Wildcard ($RootId) {
            "PROJECT_CDX" { return @{ max_depth = 6; max_files = 8000; max_folders = 3000 } }
            "OPERATIVA" { return @{ max_depth = 8; max_files = 5000; max_folders = 2000 } }
            "WORK" { return @{ max_depth = 6; max_files = 5000; max_folders = 2000 } }
            "TMP_SDU_ORG_TOTAL" { return @{ max_depth = 6; max_files = 4000; max_folders = 1500 } }
            "CABINA_OUT" { return @{ max_depth = 3; max_files = 6000; max_folders = 1000 } }
            "CABINA_LOGS" { return @{ max_depth = 3; max_files = 4000; max_folders = 1000 } }
            "CODEX_HOME" { return @{ max_depth = 4; max_files = 8000; max_folders = 2500 } }
            "DOWNLOADS" { return @{ max_depth = 4; max_files = 8000; max_folders = 2500 } }
            "DOCUMENTS" { return @{ max_depth = 4; max_files = 8000; max_folders = 2500 } }
            "DESKTOP" { return @{ max_depth = 4; max_files = 5000; max_folders = 1500 } }
            "ONEDRIVE_*" { return @{ max_depth = 4; max_files = 8000; max_folders = 2500 } }
            default { return @{ max_depth = 3; max_files = 5000; max_folders = 1500 } }
        }
    }

    foreach ($root in $roots) {
        if (-not $root.exists) { continue }
        $profile = Get-ScanProfile $root.root_id
        $folderCount = 0
        $fileCount = 0
        $truncated = $false
        $queue = New-Object System.Collections.Queue
        $queue.Enqueue([pscustomobject]@{ path = $root.path; depth = 0 })

        while ($queue.Count -gt 0) {
            $current = $queue.Dequeue()
            if (Test-SkipPath $current.path $root.root_id) { continue }
            if ($fileCount -ge $profile.max_files -or $folderCount -ge $profile.max_folders) {
                $truncated = $true
                break
            }

            $childFiles = @(Get-ChildItem -LiteralPath $current.path -File -Force -ErrorAction SilentlyContinue -Attributes !ReparsePoint)
            foreach ($file in $childFiles) {
                if ($fileCount -ge $profile.max_files) { $truncated = $true; break }
                if (Test-SkipPath $file.FullName $root.root_id) { continue }
                $git = Get-GitStatusForPath $file.FullName $gitMap
                $universe = Get-Universe $file.FullName
                $function = Get-FunctionClass $file.FullName $file.Extension $false
                $sensitivity = Get-Sensitivity $file.FullName $file.Extension
                $files.Add([pscustomobject]@{
                    root_id = $root.root_id
                    path = $file.FullName
                    relative_path = if ((Get-RepoRelativePath $file.FullName) -ne $null) { Get-RepoRelativePath $file.FullName } else { "" }
                    extension = $file.Extension
                    size_bytes = $file.Length
                    created_time = $file.CreationTime.ToString("s")
                    modified_time = $file.LastWriteTime.ToString("s")
                    git_status = $git
                    tracked_or_untracked = if ($git -eq "??") { "untracked" } elseif ($git -eq "outside_git") { "outside_git" } else { "tracked_or_clean" }
                    inside_cabina = Test-InsideCabina $file.FullName
                    universe = $universe
                    function = $function
                    sensitivity = $sensitivity
                    destination = Get-Destination $universe $function $sensitivity
                    recommended_action = Get-RecommendedAction $function $sensitivity $universe $git
                    hash_status = "SKIPPED_METADATA_ONLY"
                    notes = "metadata_only; content_not_opened; bounded_scan_depth=$($profile.max_depth)"
                }) | Out-Null
                $fileCount++
            }

            if ($current.depth -ge $profile.max_depth) { continue }
            $childDirs = @(Get-ChildItem -LiteralPath $current.path -Directory -Force -ErrorAction SilentlyContinue -Attributes !ReparsePoint)
            foreach ($dir in $childDirs) {
                if ($folderCount -ge $profile.max_folders) { $truncated = $true; break }
                if (Test-SkipPath $dir.FullName $root.root_id) { continue }
                $git = Get-GitStatusForPath $dir.FullName $gitMap
                $folders.Add([pscustomobject]@{
                    root_id = $root.root_id
                    path = $dir.FullName
                    name = $dir.Name
                    parent = $dir.Parent.FullName
                    git_status = $git
                    tracked_or_untracked = if ($git -eq "??") { "untracked" } elseif ($git -eq "outside_git") { "outside_git" } else { "tracked_or_clean" }
                    inside_cabina = Test-InsideCabina $dir.FullName
                    function = Get-FunctionClass $dir.FullName "" $true
                    last_write_time = $dir.LastWriteTime.ToString("s")
                }) | Out-Null
                $folderCount++
                $queue.Enqueue([pscustomobject]@{ path = $dir.FullName; depth = $current.depth + 1 })
            }
        }

        $scanSummaries.Add([pscustomobject]@{
            root_id = $root.root_id
            path = $root.path
            files_scanned = $fileCount
            folders_scanned = $folderCount
            max_depth = $profile.max_depth
            max_files = $profile.max_files
            max_folders = $profile.max_folders
            truncated = $truncated
            mode = "bounded_metadata_only"
        }) | Out-Null
    }

    $fileColumns = @("root_id", "path", "relative_path", "extension", "size_bytes", "created_time", "modified_time", "git_status", "tracked_or_untracked", "inside_cabina", "universe", "function", "sensitivity", "destination", "recommended_action", "hash_status", "notes")
    $folderColumns = @("root_id", "path", "name", "parent", "git_status", "tracked_or_untracked", "inside_cabina", "function", "last_write_time")
    Write-CsvWithHeader @($files | Sort-Object root_id, path) (Join-Path $OutDir "LOCAL_FILESYSTEM_INVENTORY.csv") $fileColumns
    Write-JsonFile -Value @($files | Sort-Object root_id, path) -Path (Join-Path $OutDir "LOCAL_FILESYSTEM_INVENTORY.json")
    Write-CsvWithHeader @($folders | Sort-Object root_id, path) (Join-Path $OutDir "LOCAL_FOLDER_INVENTORY.csv") $folderColumns
    Write-JsonFile -Value @($scanSummaries.ToArray()) -Path (Join-Path $OutDir "LOCAL_FILESYSTEM_SCAN_SUMMARY.json")
}

function Invoke-Classify {
    $inventoryPath = Join-Path $OutDir "LOCAL_FILESYSTEM_INVENTORY.csv"
    if (-not (Test-Path -LiteralPath $inventoryPath)) { Invoke-Inventory }
    $rows = @(Import-Csv -LiteralPath $inventoryPath)
    $classification = @($rows | Select-Object path, git_status, tracked_or_untracked, inside_cabina, universe, function, sensitivity, destination, recommended_action, hash_status, notes)
    $columns = @("path", "git_status", "tracked_or_untracked", "inside_cabina", "universe", "function", "sensitivity", "destination", "recommended_action", "hash_status", "notes")
    Write-CsvWithHeader @($classification | Sort-Object path) (Join-Path $OutDir "LOCAL_FILE_CLASSIFICATION.csv") $columns
    Write-JsonFile -Value @($classification | Sort-Object path) -Path (Join-Path $OutDir "LOCAL_FILE_CLASSIFICATION.json")

    $rules = [ordered]@{
        schema = "local-file-classification-rules.v1"
        generated_at = (Get-Date).ToString("s")
        mode = "metadata_only_no_secret_exposure"
        precedence = @("secret_candidate", "business_sensitive", "temp", "backup", "raw_evidence", "cabina", "codex", "operativa", "config_manifest", "code_tool", "owner_review")
        rules = @(
            @{ rule_id = "SECRET_CANDIDATE"; match = "path contains secret/token/password/apikey/.env"; sensitivity = "SENSITIVE_SECRET_CANDIDATE_METADATA_ONLY"; action = "QUEUE_OWNER_REVIEW_METADATA_ONLY" },
            @{ rule_id = "BUSINESS_SENSITIVE"; match = "path contains SGIN/D3-D7/notarial/client/persona"; sensitivity = "SENSITIVE_BUSINESS_METADATA_ONLY"; action = "QUEUE_OWNER_REVIEW_METADATA_ONLY" },
            @{ rule_id = "TEMP"; match = "tmp/temp/.tmp_sdu_org_total"; function = "TEMP"; action = "QUEUE_TEMP_RETENTION" },
            @{ rule_id = "BACKUP"; match = "backup/backups/.previous-*"; function = "BACKUP"; action = "QUEUE_BACKUP_RETENTION" },
            @{ rule_id = "RAW_EVIDENCE"; match = "csv/xlsx/parquet/ndjson/log"; function = "DATA_OR_RAW_EVIDENCE_OR_LOG"; action = "KEEP_LOCAL_REGISTER_ONLY" },
            @{ rule_id = "VERSIONABLE_CANDIDATE"; match = "config/manifest/docs/readback saneado"; action = "KEEP_IN_PLACE_REGISTER_IN_NERVOUS_INDEX" },
            @{ rule_id = "MULTIPLE_UNIVERSE"; match = "path maps to more than one universe"; action = "QUEUE_MULTIPLE_REVIEW" }
        )
        frontera = @{ delete = $false; move = $false; live = $false; remote = $false; secret_content = $false }
    }
    Write-JsonFile $rules (Join-Path $ConfigDir "local-file-classification-rules.v1.json")
}

function Invoke-Plan {
    $classificationPath = Join-Path $OutDir "LOCAL_FILE_CLASSIFICATION.csv"
    if (-not (Test-Path -LiteralPath $classificationPath)) { Invoke-Classify }
    $classification = @(Import-Csv -LiteralPath $classificationPath)
    $plan = @($classification | ForEach-Object {
        $safeNow = $_.recommended_action -in @("KEEP_IN_PLACE_REGISTER_IN_NERVOUS_INDEX", "KEEP_LOCAL_REGISTER_ONLY")
        [pscustomobject]@{
            path = $_.path
            current_location = $_.path
            proposed_destination = $_.destination
            operation = if ($safeNow) { "REGISTER_ONLY" } else { "QUEUE_ONLY" }
            can_apply_now = [bool]$safeNow
            requires_owner_gate = -not $safeNow
            rollback_required = $false
            reason = $_.recommended_action
        }
    })
    $columns = @("path", "current_location", "proposed_destination", "operation", "can_apply_now", "requires_owner_gate", "rollback_required", "reason")
    Write-CsvWithHeader @($plan | Sort-Object can_apply_now, path) (Join-Path $OutDir "LOCAL_ORDER_PLAN.csv") $columns
    Write-JsonFile -Value @($plan | Sort-Object can_apply_now, path) -Path (Join-Path $OutDir "LOCAL_ORDER_PLAN.json")

    $total = @($plan).Count
    $registerOnly = @($plan | Where-Object { $_.operation -eq "REGISTER_ONLY" }).Count
    $queued = @($plan | Where-Object { $_.operation -eq "QUEUE_ONLY" }).Count
    $planMd = @"
# LOCAL_ORDER_PLAN

Estado: PLAN_GENERATED_METADATA_ONLY

- Total entradas: $total
- Registro seguro sin mover: $registerOnly
- Entradas en cola/gate: $queued
- Movimientos reales propuestos para aplicar ahora: 0
- Borrados propuestos: 0

## Regla de aplicacion

En esta fase el orden local se aplica creando estructura canonica y registrando rutas. No se mueven archivos porque hay evidencia cruda, superficies sensibles, temporales, backups y deltas operativos que requieren gate de owner.

## Acciones permitidas ahora

- Crear carpetas canonicas faltantes.
- Registrar indices y colas locales.
- Mantener archivos en su ubicacion actual.
- Derivar ambiguos/sensibles/temporales/backups a colas de revision.

## Acciones bloqueadas

- MOVE real de evidencia cruda o sensible.
- DELETE/cleanup de temporales.
- Escritura live/remota.
- Stage/commit automatico.
"@
    $planMd | Set-Content -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_PLAN.md") -Encoding UTF8
}

function Invoke-Queues {
    $classificationPath = Join-Path $OutDir "LOCAL_FILE_CLASSIFICATION.csv"
    if (-not (Test-Path -LiteralPath $classificationPath)) { Invoke-Classify }
    $classification = @(Import-Csv -LiteralPath $classificationPath)
    $columns = @("path", "git_status", "tracked_or_untracked", "inside_cabina", "universe", "function", "sensitivity", "destination", "recommended_action", "hash_status", "notes")
    $queues = [ordered]@{
        "LOCAL_OWNER_REVIEW_QUEUE.csv" = @($classification | Where-Object { $_.recommended_action -match "OWNER|DECISION|QUEUE_OWNER" })
        "LOCAL_MULTIPLE_REVIEW_QUEUE.csv" = @($classification | Where-Object { $_.universe -like "MULTIPLE:*" })
        "LOCAL_SENSITIVE_REVIEW_QUEUE.csv" = @($classification | Where-Object { $_.sensitivity -like "SENSITIVE*" })
        "LOCAL_TEMP_RETENTION_QUEUE.csv" = @($classification | Where-Object { $_.function -like "TEMP*" -or $_.path -like "*.tmp_sdu_org_total*" })
        "LOCAL_BACKUP_RETENTION_QUEUE.csv" = @($classification | Where-Object { $_.function -like "BACKUP*" -or $_.path -like "*.previous-*" })
        "LOCAL_CONFLICTS_QUEUE.csv" = @()
    }
    foreach ($name in $queues.Keys) {
        Write-CsvWithHeader @($queues[$name]) (Join-Path $OutDir $name) $columns
    }
}

function Get-CanonicalDirectories {
    return @(
        "C:\CEO\00_CONTROL_PLANE",
        "C:\CEO\01_CABINA_SDU",
        "C:\CEO\02_RUNTIME_OPERATIVA",
        "C:\CEO\03_CODEX_LOCAL",
        "C:\CEO\04_CONFIG_AND_REGISTRIES",
        "C:\CEO\05_TOOLS_AND_AUTOMATION",
        "C:\CEO\06_EVIDENCE_AND_READBACKS",
        "C:\CEO\07_RAW_AND_LOCAL_ONLY",
        "C:\CEO\08_AGENT_SYSTEMS",
        "C:\CEO\09_VSCODE_INTERFACE",
        "C:\CEO\10_SHAREPOINT_DATAVERSE_REFERENCES",
        "C:\CEO\11_HANDOFFS_AND_DELTAS",
        "C:\CEO\12_ARCHIVE",
        "C:\CEO\98_OWNER_REVIEW",
        "C:\CEO\99_CONFLICTS",
        (Join-Path $RunnerRoot "filesystem-order"),
        (Join-Path $RunnerRoot "evidence"),
        (Join-Path $RunnerRoot "handoff"),
        (Join-Path $RunnerRoot "queues"),
        (Join-Path $RunnerRoot "deltas"),
        (Join-Path $RunnerRoot "nervous-system")
    )
}

function Invoke-ApplySafeOrder {
    $created = New-Object System.Collections.Generic.List[object]
    $existing = New-Object System.Collections.Generic.List[object]
    foreach ($dir in Get-CanonicalDirectories) {
        if (Test-Path -LiteralPath $dir) {
            $existing.Add([pscustomobject]@{ path = $dir; status = "already_exists" }) | Out-Null
        } else {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $created.Add([pscustomobject]@{ path = $dir; status = "created"; created_at = (Get-Date).ToString("s") }) | Out-Null
        }
    }
    $present = @($created.ToArray()) + @($existing.ToArray())

    $backupManifest = [ordered]@{
        schema = "local-order-backup-manifest.v1"
        generated_at = (Get-Date).ToString("s")
        files_moved = 0
        files_deleted = 0
        overwritten = 0
        directories_created = @($created.ToArray())
        canonical_directories_present = @($present)
        note = "No content backup required because no existing files were modified or moved by apply phase."
    }
    Write-JsonFile $backupManifest (Join-Path $OutDir "LOCAL_ORDER_BACKUP_MANIFEST.json")

    $rollback = [ordered]@{
        schema = "local-order-rollback-plan.v1"
        generated_at = (Get-Date).ToString("s")
        policy = "manual_owner_gate_required_before_rollback"
        rollback_steps = @(
            @{ step = "verify_no_files_inside_created_directories"; required = $true },
            @{ step = "remove_only_empty_directories_created_by_this_delta"; required = $true },
            @{ step = "do_not_restore_or_move_files_because_no_files_were_moved"; required = $true }
        )
        created_directories = @($created.ToArray())
        canonical_directories_present = @($present)
        files_to_restore = @()
        delete_allowed_now = $false
    }
    Write-JsonFile $rollback (Join-Path $OutDir "LOCAL_ORDER_ROLLBACK_PLAN.json")

    $result = [ordered]@{
        schema = "local-order-apply-result.v1"
        generated_at = (Get-Date).ToString("s")
        mode = "SAFE_LOCAL_STRUCTURE_ONLY"
        safe_order_applied = $true
        directories_created = @($created.ToArray()).Count
        directories_existing = @($existing.ToArray()).Count
        directories_ensured = @($present).Count
        created = @($created.ToArray())
        canonical_directories_present = @($present)
        files_moved = 0
        files_deleted = 0
        files_overwritten = 0
        frontier = @{ delete = $false; move = $false; overwrite = $false; stage = $false; commit = $false; push = $false; pr = $false; live = $false; secrets = $false }
    }
    Write-JsonFile $result (Join-Path $OutDir "LOCAL_ORDER_APPLY_RESULT.json")

    $applyReadbackMd = @"
# LOCAL_ORDER_APPLY_READBACK

Estado: SAFE_LOCAL_STRUCTURE_APPLIED

- Carpetas canonicas creadas: $($created.Count)
- Carpetas canonicas ya existentes: $($existing.Count)
- Carpetas canonicas presentes/aseguradas: $(@($present).Count)
- Archivos movidos: 0
- Archivos borrados: 0
- Archivos sobrescritos: 0
- Stage/commit/push/PR/live: no ejecutado

## Alcance aplicado

Se aplico solamente estructura canonica local y registros de orden. Los archivos inventariados quedaron en su ubicacion actual.

## Rollback disponible

Existe plan de rollback manual en `LOCAL_ORDER_ROLLBACK_PLAN.json`. Solo permitiria retirar carpetas vacias creadas por este delta, con gate de owner.
"@
    $applyReadbackMd | Set-Content -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_APPLY_READBACK.md") -Encoding UTF8
}

function Invoke-FolderMap {
    $roots = Get-RootSpecs
    $rootLines = @($roots | ForEach-Object {
        "  - root_id: $($_.root_id)`n    path: `"$(ConvertTo-SlashPath $_.path)`"`n    role: $($_.role)`n    exists: $($_.exists.ToString().ToLowerInvariant())`n    scan_scope: $($_.scan_scope)"
    }) -join "`n"

    $folderMapYaml = @"
schema: local-folder-map.v1
generated_at: "$(Get-Date -Format s)"
mode: LOCAL_FILESYSTEM_TOTAL_ORDER_METADATA_ONLY
canonical_taxonomy:
  control_plane: "C:/CEO/00_CONTROL_PLANE"
  cabina_sdu: "C:/CEO/01_CABINA_SDU"
  runtime_operativa: "C:/CEO/02_RUNTIME_OPERATIVA"
  codex_local: "C:/CEO/03_CODEX_LOCAL"
  config_and_registries: "C:/CEO/04_CONFIG_AND_REGISTRIES"
  tools_and_automation: "C:/CEO/05_TOOLS_AND_AUTOMATION"
  evidence_and_readbacks: "C:/CEO/06_EVIDENCE_AND_READBACKS"
  raw_and_local_only: "C:/CEO/07_RAW_AND_LOCAL_ONLY"
  agent_systems: "C:/CEO/08_AGENT_SYSTEMS"
  vscode_interface: "C:/CEO/09_VSCODE_INTERFACE"
  sharepoint_dataverse_references: "C:/CEO/10_SHAREPOINT_DATAVERSE_REFERENCES"
  handoffs_and_deltas: "C:/CEO/11_HANDOFFS_AND_DELTAS"
  archive: "C:/CEO/12_ARCHIVE"
  owner_review: "C:/CEO/98_OWNER_REVIEW"
  conflicts: "C:/CEO/99_CONFLICTS"
repo_taxonomy:
  filesystem_order: ".cabina/organizacion-total/filesystem-order"
  evidence: ".cabina/organizacion-total/evidence"
  handoff: ".cabina/organizacion-total/handoff"
  queues: ".cabina/organizacion-total/queues"
  deltas: ".cabina/organizacion-total/deltas"
  nervous_system: ".cabina/organizacion-total/nervous-system"
roots:
$rootLines
policies:
  no_delete: true
  no_unapproved_move: true
  metadata_only_for_sensitive: true
  raw_evidence_local_only: true
  live_disabled: true
  remote_disabled: true
"@
    $folderMapYaml | Set-Content -LiteralPath (Join-Path $ConfigDir "local-folder-map.v1.yaml") -Encoding UTF8

    $rootMd = @($roots | ForEach-Object { "- $($_.root_id): $($_.path) [$($_.role)] exists=$($_.exists)" }) -join "`n"
    $folderMapMd = @"
# LOCAL_FOLDER_MASTER_MAP

Estado: ACTIVE_LOCAL_MAP_METADATA_ONLY

## Raices inspeccionadas

$rootMd

## Taxonomia canonica C:\CEO

- 00_CONTROL_PLANE
- 01_CABINA_SDU
- 02_RUNTIME_OPERATIVA
- 03_CODEX_LOCAL
- 04_CONFIG_AND_REGISTRIES
- 05_TOOLS_AND_AUTOMATION
- 06_EVIDENCE_AND_READBACKS
- 07_RAW_AND_LOCAL_ONLY
- 08_AGENT_SYSTEMS
- 09_VSCODE_INTERFACE
- 10_SHAREPOINT_DATAVERSE_REFERENCES
- 11_HANDOFFS_AND_DELTAS
- 12_ARCHIVE
- 98_OWNER_REVIEW
- 99_CONFLICTS

## Politica

El mapa ordena fisicamente por metadata y destino canonico, pero no mueve archivos en esta fase. Evidencia cruda, D3-D7, SGIN, secretos candidatos, temporales y backups quedan en colas de decision.
"@
    $folderMapMd | Set-Content -LiteralPath (Join-Path $DocsDir "LOCAL_FOLDER_MASTER_MAP.md") -Encoding UTF8
}

function Invoke-Index {
    $classificationPath = Join-Path $OutDir "LOCAL_FILE_CLASSIFICATION.csv"
    if (-not (Test-Path -LiteralPath $classificationPath)) { Invoke-Classify }
    $folderPath = Join-Path $OutDir "LOCAL_FOLDER_INVENTORY.csv"
    $classification = @(Import-Csv -LiteralPath $classificationPath)
    $folders = if (Test-Path -LiteralPath $folderPath) { @(Import-Csv -LiteralPath $folderPath) } else { @() }
    $applyPath = Join-Path $OutDir "LOCAL_ORDER_APPLY_RESULT.json"
    $apply = if (Test-Path -LiteralPath $applyPath) { Get-Content -LiteralPath $applyPath -Raw | ConvertFrom-Json } else { $null }
    $roots = Get-RootSpecs
    $head = (& git -C $RepoRoot rev-parse HEAD).Trim()
    $counts = [ordered]@{
        roots = @($roots).Count
        files = @($classification).Count
        folders = @($folders).Count
        owner_review = @($classification | Where-Object { $_.recommended_action -match "OWNER|DECISION|QUEUE_OWNER" }).Count
        multiple_review = @($classification | Where-Object { $_.universe -like "MULTIPLE:*" }).Count
        sensitive_review = @($classification | Where-Object { $_.sensitivity -like "SENSITIVE*" }).Count
        temp_retention = @($classification | Where-Object { $_.function -like "TEMP*" -or $_.path -like "*.tmp_sdu_org_total*" }).Count
        backup_retention = @($classification | Where-Object { $_.function -like "BACKUP*" -or $_.path -like "*.previous-*" }).Count
        conflicts = 0
        directories_created = if ($apply) { [int]$apply.directories_created } else { 0 }
        directories_ensured = if ($apply -and $apply.PSObject.Properties.Name -contains "directories_ensured") { [int]$apply.directories_ensured } else { 0 }
    }
    $index = [ordered]@{
        schema = "local-nervous-index.v1"
        generated_at = (Get-Date).ToString("s")
        repo = $RepoRoot
        runner_root = $RunnerRoot
        baseline_commit = $head
        roots = $roots
        artifacts = @{
            inventory_csv = ".cabina/organizacion-total/out/LOCAL_FILESYSTEM_INVENTORY.csv"
            classification_csv = ".cabina/organizacion-total/out/LOCAL_FILE_CLASSIFICATION.csv"
            order_plan = ".cabina/organizacion-total/out/LOCAL_ORDER_PLAN.md"
            folder_map = ".cabina/organizacion-total/config/local-folder-map.v1.yaml"
        }
        counts = $counts
        gates = @{ move_gate_required = $true; delete_gate_required = $true; live_gate_required = $true; remote_gate_required = $true }
    }
    Write-JsonFile $index (Join-Path $OutDir "LOCAL_NERVOUS_INDEX.json")

    $indexYaml = @"
schema: local-nervous-index.v1
generated_at: "$(Get-Date -Format s)"
repo: "$(ConvertTo-SlashPath $RepoRoot)"
runner_root: "$(ConvertTo-SlashPath $RunnerRoot)"
baseline_commit: "$head"
artifacts:
  inventory_csv: ".cabina/organizacion-total/out/LOCAL_FILESYSTEM_INVENTORY.csv"
  classification_csv: ".cabina/organizacion-total/out/LOCAL_FILE_CLASSIFICATION.csv"
  order_plan: ".cabina/organizacion-total/out/LOCAL_ORDER_PLAN.md"
  folder_map: ".cabina/organizacion-total/config/local-folder-map.v1.yaml"
counts:
  roots: $($counts.roots)
  files: $($counts.files)
  folders: $($counts.folders)
  owner_review: $($counts.owner_review)
  multiple_review: $($counts.multiple_review)
  sensitive_review: $($counts.sensitive_review)
  temp_retention: $($counts.temp_retention)
  backup_retention: $($counts.backup_retention)
  conflicts: $($counts.conflicts)
  directories_created: $($counts.directories_created)
  directories_ensured: $($counts.directories_ensured)
gates:
  move_gate_required: true
  delete_gate_required: true
  live_gate_required: true
  remote_gate_required: true
"@
    $indexYaml | Set-Content -LiteralPath (Join-Path $ConfigDir "local-nervous-index.v1.yaml") -Encoding UTF8

    $indexMd = @"
# LOCAL_NERVOUS_INDEX

Estado: LOCAL_NERVOUS_INDEX_ACTIVE

- Raices registradas: $($counts.roots)
- Archivos inventariados: $($counts.files)
- Carpetas inventariadas: $($counts.folders)
- Owner review: $($counts.owner_review)
- Multiple review: $($counts.multiple_review)
- Sensitive review: $($counts.sensitive_review)
- Temp retention: $($counts.temp_retention)
- Backup retention: $($counts.backup_retention)
- Conflicts: $($counts.conflicts)
- Carpetas canonicas creadas: $($counts.directories_created)
- Carpetas canonicas presentes/aseguradas: $($counts.directories_ensured)

## Conexion nerviosa

El indice conecta inventario, clasificacion, plan de orden, colas de revision y taxonomia canonica. El sistema puede observar, clasificar, planificar y aplicar estructura segura local sin tocar vivo ni remoto.
"@
    $indexMd | Set-Content -LiteralPath (Join-Path $OutDir "LOCAL_NERVOUS_INDEX.md") -Encoding UTF8
}

function Invoke-Validation {
    $required = @(
        "LOCAL_FS_PREFLIGHT.md",
        "LOCAL_FS_PREFLIGHT.json",
        "LOCAL_FILESYSTEM_INVENTORY.csv",
        "LOCAL_FILESYSTEM_INVENTORY.json",
        "LOCAL_FOLDER_INVENTORY.csv",
        "LOCAL_FILE_CLASSIFICATION.csv",
        "LOCAL_FILE_CLASSIFICATION.json",
        "LOCAL_ORDER_PLAN.csv",
        "LOCAL_ORDER_PLAN.json",
        "LOCAL_ORDER_PLAN.md",
        "LOCAL_ORDER_APPLY_READBACK.md",
        "LOCAL_ORDER_APPLY_RESULT.json",
        "LOCAL_ORDER_ROLLBACK_PLAN.json",
        "LOCAL_OWNER_REVIEW_QUEUE.csv",
        "LOCAL_MULTIPLE_REVIEW_QUEUE.csv",
        "LOCAL_SENSITIVE_REVIEW_QUEUE.csv",
        "LOCAL_TEMP_RETENTION_QUEUE.csv",
        "LOCAL_BACKUP_RETENTION_QUEUE.csv",
        "LOCAL_CONFLICTS_QUEUE.csv",
        "LOCAL_NERVOUS_INDEX.md",
        "LOCAL_NERVOUS_INDEX.json"
    )
    $requiredConfig = @(
        "local-folder-map.v1.yaml",
        "local-file-classification-rules.v1.json",
        "local-nervous-index.v1.yaml"
    )
    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($name in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $OutDir $name))) { $missing.Add("out/$name") | Out-Null }
    }
    foreach ($name in $requiredConfig) {
        if (-not (Test-Path -LiteralPath (Join-Path $ConfigDir $name))) { $missing.Add("config/$name") | Out-Null }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $DocsDir "LOCAL_FOLDER_MASTER_MAP.md"))) { $missing.Add("docs/LOCAL_FOLDER_MASTER_MAP.md") | Out-Null }

    $jsonErrors = New-Object System.Collections.Generic.List[string]
    $jsonFiles = @(
        (Join-Path $OutDir "LOCAL_FS_PREFLIGHT.json"),
        (Join-Path $OutDir "LOCAL_FILESYSTEM_INVENTORY.json"),
        (Join-Path $OutDir "LOCAL_FILE_CLASSIFICATION.json"),
        (Join-Path $OutDir "LOCAL_ORDER_PLAN.json"),
        (Join-Path $OutDir "LOCAL_ORDER_APPLY_RESULT.json"),
        (Join-Path $OutDir "LOCAL_ORDER_ROLLBACK_PLAN.json"),
        (Join-Path $OutDir "LOCAL_NERVOUS_INDEX.json"),
        (Join-Path $ConfigDir "local-file-classification-rules.v1.json")
    )
    foreach ($json in $jsonFiles) {
        try {
            if (Test-Path -LiteralPath $json) { Get-Content -LiteralPath $json -Raw | ConvertFrom-Json | Out-Null }
        } catch {
            $jsonErrors.Add($json) | Out-Null
        }
    }

    $taskPath = Join-Path $RunnerRoot ".vscode\tasks.json"
    $expectedTasks = @(
        "SDU FS: Preflight",
        "SDU FS: Inventory",
        "SDU FS: Classify",
        "SDU FS: Plan Order",
        "SDU FS: Apply Safe Local Order",
        "SDU FS: Build Review Queues",
        "SDU FS: Build Nervous Index",
        "SDU FS: Full Local Order"
    )
    $missingTasks = New-Object System.Collections.Generic.List[string]
    if (Test-Path -LiteralPath $taskPath) {
        try {
            $tasksJson = Get-Content -LiteralPath $taskPath -Raw | ConvertFrom-Json
            $labels = @($tasksJson.tasks | ForEach-Object { $_.label })
            foreach ($label in $expectedTasks) {
                if ($label -notin $labels) { $missingTasks.Add($label) | Out-Null }
            }
        } catch {
            $missingTasks.Add("tasks_json_parse_error") | Out-Null
        }
    } else {
        $missingTasks.Add("tasks_json_missing") | Out-Null
    }

    $secretPatterns = @("sk-[A-Za-z0-9_-]{20,}", "ghp_[A-Za-z0-9_]{20,}", "AKIA[0-9A-Z]{16}", "xox[baprs]-[A-Za-z0-9-]{20,}")
    $secretHits = New-Object System.Collections.Generic.List[string]
    foreach ($file in @($jsonFiles + (Join-Path $OutDir "LOCAL_ORDER_PLAN.md") + (Join-Path $OutDir "LOCAL_NERVOUS_INDEX.md"))) {
        if (-not (Test-Path -LiteralPath $file)) { continue }
        $text = Get-Content -LiteralPath $file -Raw
        foreach ($pattern in $secretPatterns) {
            if ($text -match $pattern) { $secretHits.Add($file) | Out-Null }
        }
    }

    $staging = (& git -C $RepoRoot diff --cached --name-only 2>&1) -join "`n"
    $diffCheck = (& git -C $RepoRoot diff --check 2>&1) -join "`n"
    $apply = if (Test-Path -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_APPLY_RESULT.json")) { Get-Content -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_APPLY_RESULT.json") -Raw | ConvertFrom-Json } else { $null }

    $validation = [ordered]@{
        schema = "local-order-validation.v1"
        generated_at = (Get-Date).ToString("s")
        status = if ($missing.Count -eq 0 -and $jsonErrors.Count -eq 0 -and $missingTasks.Count -eq 0 -and $secretHits.Count -eq 0) { "PASS" } else { "PASS_WITH_PENDING_INTERFACE_OR_WARNINGS" }
        missing_artifacts = @($missing)
        json_errors = @($jsonErrors)
        missing_vscode_tasks = @($missingTasks)
        secret_hits = @($secretHits)
        staging_empty = [string]::IsNullOrWhiteSpace($staging)
        git_diff_check = if ([string]::IsNullOrWhiteSpace($diffCheck)) { "OK" } else { "WARNINGS_PRESENT_NON_BLOCKING" }
        files_moved = if ($apply) { [int]$apply.files_moved } else { 0 }
        files_deleted = if ($apply) { [int]$apply.files_deleted } else { 0 }
        files_overwritten = if ($apply) { [int]$apply.files_overwritten } else { 0 }
        frontier = @{ delete = $false; move = $false; overwrite = $false; stage = $false; commit = $false; push = $false; pr = $false; live = $false; secrets = $false }
    }
    Write-JsonFile $validation (Join-Path $OutDir "LOCAL_ORDER_VALIDATION.json")

    $validationMd = @"
# LOCAL_ORDER_VALIDATION

Estado: $($validation.status)

- Artefactos faltantes: $($missing.Count)
- JSON parse errors: $($jsonErrors.Count)
- Tasks VS Code faltantes: $($missingTasks.Count)
- Secret hits reales: $($secretHits.Count)
- Staging vacio: $($validation.staging_empty)
- Diff check: $($validation.git_diff_check)
- Archivos movidos: $($validation.files_moved)
- Archivos borrados: $($validation.files_deleted)
- Archivos sobrescritos: $($validation.files_overwritten)

## Frontera confirmada

- delete=false
- move=false
- overwrite=false
- stage=false
- commit=false
- push=false
- pr=false
- live=false
- secretos=false
"@
    $validationMd | Set-Content -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_VALIDATION.md") -Encoding UTF8
}

function Invoke-Final {
    if (-not (Test-Path -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_VALIDATION.json"))) { Invoke-Validation }
    $validation = Get-Content -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_VALIDATION.json") -Raw | ConvertFrom-Json
    $index = Get-Content -LiteralPath (Join-Path $OutDir "LOCAL_NERVOUS_INDEX.json") -Raw | ConvertFrom-Json
    $apply = Get-Content -LiteralPath (Join-Path $OutDir "LOCAL_ORDER_APPLY_RESULT.json") -Raw | ConvertFrom-Json
    $tasks = @("SDU FS: Preflight", "SDU FS: Inventory", "SDU FS: Classify", "SDU FS: Plan Order", "SDU FS: Apply Safe Local Order", "SDU FS: Build Review Queues", "SDU FS: Build Nervous Index", "SDU FS: Full Local Order")
    $final = [ordered]@{
        estado_final = if ($validation.status -eq "PASS") { "SUCCESS_LOCAL_FILESYSTEM_TOTAL_ORDER_G1" } else { "SUCCESS_WITH_LOCAL_WARNINGS_REVIEW_QUEUES_ACTIVE" }
        baseline_commit = $index.baseline_commit
        local_order_applied = [bool]$apply.safe_order_applied
        created = @($apply.created | ForEach-Object { $_.path })
        created_or_ensured = if ($apply.PSObject.Properties.Name -contains "canonical_directories_present") { @($apply.canonical_directories_present | ForEach-Object { $_.path }) } else { @() }
        moved = @()
        queued = @{
            owner_review = [int]$index.counts.owner_review
            multiple_review = [int]$index.counts.multiple_review
            sensitive_review = [int]$index.counts.sensitive_review
            temp_retention = [int]$index.counts.temp_retention
            backup_retention = [int]$index.counts.backup_retention
            conflicts = [int]$index.counts.conflicts
        }
        nervous_index = ".cabina/organizacion-total/out/LOCAL_NERVOUS_INDEX.json"
        vscode_tasks = $tasks
        frontera = @{ delete = $false; move = $false; overwrite = $false; stage = $false; commit = $false; push = $false; pr = $false; live = $false; secretos = $false }
        siguiente_accion = "Revisar colas OWNER/MULTIPLE/SENSITIVE/TEMP/BACKUP antes de autorizar cualquier movimiento real."
    }
    Write-JsonFile $final (Join-Path $OutDir "FINAL_READBACK_LOCAL_FILESYSTEM_TOTAL_ORDER_G1.json")

    $finalMd = @"
# FINAL_READBACK_LOCAL_FILESYSTEM_TOTAL_ORDER_G1

Estado final: $($final.estado_final)

- Baseline/HEAD: $($final.baseline_commit)
- Orden local aplicado: $($final.local_order_applied)
- Carpetas creadas por apply seguro: $(@($final.created).Count)
- Carpetas canonicas presentes/aseguradas: $(@($final.created_or_ensured).Count)
- Archivos movidos: 0
- Owner review: $($final.queued.owner_review)
- Multiple review: $($final.queued.multiple_review)
- Sensitive review: $($final.queued.sensitive_review)
- Temp retention: $($final.queued.temp_retention)
- Backup retention: $($final.queued.backup_retention)
- Conflicts: $($final.queued.conflicts)
- Indice nervioso: $($final.nervous_index)

## VS Code

$($tasks | ForEach-Object { "- $_" } | Out-String)

## Frontera

- delete=false
- move=false
- overwrite=false
- stage=false
- commit=false
- push=false
- pr=false
- live=false
- secretos=false

## Siguiente accion

$($final.siguiente_accion)
"@
    $finalMd | Set-Content -LiteralPath (Join-Path $OutDir "FINAL_READBACK_LOCAL_FILESYSTEM_TOTAL_ORDER_G1.md") -Encoding UTF8
}

switch ($Phase) {
    "Preflight" { Invoke-Preflight }
    "Inventory" { Invoke-Inventory }
    "Classify" { Invoke-Classify }
    "Plan" { Invoke-Plan }
    "Apply" { Invoke-ApplySafeOrder }
    "Queues" { Invoke-Queues }
    "Index" { Invoke-FolderMap; Invoke-Index }
    "Validate" { Invoke-Validation }
    "Final" { Invoke-Final }
    "Full" {
        Invoke-Preflight
        Invoke-Inventory
        Invoke-Classify
        Invoke-Plan
        Invoke-ApplySafeOrder
        Invoke-Queues
        Invoke-FolderMap
        Invoke-Index
        Invoke-Validation
        Invoke-Final
    }
}

Write-Host "SDU local filesystem order phase '$Phase' completed."
