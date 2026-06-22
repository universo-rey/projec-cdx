[CmdletBinding()]
param(
    [string]$WorkspaceRoot = "C:\CEO\project-cdx",
    [string]$CodeInsidersPath = "C:\Users\enzo1\AppData\Local\Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd",
    [switch]$SkipPytest,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$results = New-Object System.Collections.Generic.List[object]

function Add-CabinaResult {
    param(
        [string]$Step,
        [string]$Status,
        [string]$Detail
    )

    $results.Add([PSCustomObject]@{
        step = $Step
        status = $Status
        detail = $Detail
    })
}

function Invoke-CabinaStep {
    param(
        [string]$Step,
        [scriptblock]$Action,
        [switch]$WarningOnly
    )

    try {
        $output = & $Action 2>&1
        $text = ($output | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($text)) {
            $text = "OK"
        }
        Add-CabinaResult -Step $Step -Status "PASS" -Detail $text
    }
    catch {
        $status = if ($WarningOnly) { "WARN" } else { "FAIL" }
        Add-CabinaResult -Step $Step -Status $status -Detail $_.Exception.Message
    }
}

function Invoke-NativeCommand {
    param(
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $output = & $FilePath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -ne $exitCode -and $exitCode -ne 0) {
        $text = ($output | Out-String).Trim()
        throw "ExitCode=$exitCode`n$text"
    }
    $output
}

$workspace = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$python = Join-Path $workspace ".venv\Scripts\python.exe"

Invoke-CabinaStep -Step "workspace_root" -Action {
    if (-not (Test-Path -LiteralPath $workspace)) {
        throw "Workspace root not found: $workspace"
    }
    $workspace
}

Invoke-CabinaStep -Step "code_insiders_path" -Action {
    if (-not (Test-Path -LiteralPath $CodeInsidersPath)) {
        throw "Code Insiders CLI not found: $CodeInsidersPath"
    }
    Invoke-NativeCommand -FilePath $CodeInsidersPath -Arguments @("--version")
}

Invoke-CabinaStep -Step "code_insiders_status" -WarningOnly -Action {
    $status = Invoke-NativeCommand -FilePath $CodeInsidersPath -Arguments @("--status")
    $needle = "project-cdx"
    if (($status | Out-String) -notmatch [regex]::Escape($needle)) {
        throw "VS Code Insiders is available but project-cdx was not found in status output."
    }
    $status | Select-String -Pattern "Window \[|Folder \(|project-cdx|openai.chatgpt|pwsh.exe|pac.exe"
}

Invoke-CabinaStep -Step "python_runner" -Action {
    if (-not (Test-Path -LiteralPath $python)) {
        throw "Python runner not found: $python"
    }
    Invoke-NativeCommand -FilePath $python -Arguments @("--version")
}

Invoke-CabinaStep -Step "git_status" -Action {
    Invoke-NativeCommand -FilePath "git" -Arguments @("-C", $workspace, "status", "--short", "--branch")
}

Invoke-CabinaStep -Step "metadata_validate" -Action {
    Invoke-NativeCommand -FilePath $python -Arguments @("-m", "tools.validate")
}

Invoke-CabinaStep -Step "sentinel_scan" -Action {
    Invoke-NativeCommand -FilePath $python -Arguments @("tools\sdu_sentinel.py", "scan")
}

Invoke-CabinaStep -Step "auto_remediation_analyze" -Action {
    Invoke-NativeCommand -FilePath $python -Arguments @("tools\sdu_auto_remediation.py", "analyze")
}

Invoke-CabinaStep -Step "sentinel_check" -Action {
    Invoke-NativeCommand -FilePath $python -Arguments @("tools\sdu_sentinel.py", "check")
}

if (-not $SkipPytest) {
    Invoke-CabinaStep -Step "pytest" -Action {
        Invoke-NativeCommand -FilePath $python -Arguments @("-m", "pytest")
    }
}

Invoke-CabinaStep -Step "git_diff_check" -Action {
    Invoke-NativeCommand -FilePath "git" -Arguments @("-C", $workspace, "diff", "--check")
}

$hasFailure = $false
foreach ($result in $results) {
    if ($result.status -eq "FAIL") {
        $hasFailure = $true
    }
}

if ($Json) {
    $results | ConvertTo-Json -Depth 5
}
else {
    $results | Format-Table -AutoSize
}

if ($hasFailure) {
    exit 1
}
