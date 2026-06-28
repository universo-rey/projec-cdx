param(
    [Parameter(Mandatory = $true)]
    [string]$InputJson,
    [Parameter(Mandatory = $true)]
    [string]$OutputJsonl,
    [string]$Source = "outlook-planner-notifications",
    [switch]$AllowUntrustedReadback
)

$ErrorActionPreference = "Stop"

function Get-NowIso { (Get-Date).ToUniversalTime().ToString("o") }

function Get-Sha256 {
    param([string]$Value)
    if ($null -eq $Value) { $Value = "" }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return ([System.BitConverter]::ToString($hash) -replace "-", "").ToLowerInvariant()
}

function Get-JsonObjects {
    param([string]$Path)
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }
    $doc = $raw | ConvertFrom-Json
    if ($doc.results) { return @($doc.results) }
    if ($doc.value) {
        $items = @()
        foreach ($prop in $doc.value.PSObject.Properties) { $items += $prop.Value }
        return @($items)
    }
    if ($doc -is [array]) { return @($doc) }
    return @($doc)
}

function Get-BodyText {
    param($Message)
    if ($Message.body -and $Message.body.content) { return [string]$Message.body.content }
    if ($Message.bodyPreview) { return [string]$Message.bodyPreview }
    return ""
}

function Get-PlannerItemsFromText {
    param(
        [string]$Text,
        [string]$ReceivedDateTime,
        [string]$MessageId,
        [string]$Subject
    )

    $items = @()
    $pattern = "https://planner\.cloud\.microsoft/[^)\]\s]+/PlanViews/(?<planId>[^/?\s]+)/(?<taskId>[^/?\s]+)\?"
    foreach ($match in [regex]::Matches($Text, $pattern)) {
        $planId = [System.Uri]::UnescapeDataString($match.Groups["planId"].Value)
        $taskId = [System.Uri]::UnescapeDataString($match.Groups["taskId"].Value)
        $url = $match.Value

        $prefixStart = [Math]::Max(0, $match.Index - 240)
        $prefix = $Text.Substring($prefixStart, $match.Index - $prefixStart)
        $titleMatch = [regex]::Match($prefix, "\[([^\[\]]+)\]\([^\)]*$")
        $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim("* ") } else { $null }

        $items += [pscustomobject]@{
            schema_version = 1
            artifact = "planner-task-level-readback"
            captured_at = Get-NowIso
            source = $Source
            readback_trust = if ($AllowUntrustedReadback) { "FALLBACK_INDIRECT" } else { "UNTRUSTED_INDIRECT" }
            message_id_hash = Get-Sha256 $MessageId
            message_received_at = $ReceivedDateTime
            message_subject_hash = Get-Sha256 $Subject
            plan_id = $planId
            task_id = $taskId
            task_title_hash = Get-Sha256 $title
            task_title_present = -not [string]::IsNullOrWhiteSpace($title)
            etag = $null
            conversation_thread_id = $null
            comment_count = $null
            comments_read_status = "NOT_READ"
            details_read_status = "NOT_READ"
            planner_task_read_status = "NOT_READ"
            fallback_url_hash = Get-Sha256 $url
            external_write = $false
        }
    }
    return @($items)
}

$messages = Get-JsonObjects -Path $InputJson
$records = @()
foreach ($message in $messages) {
    $text = Get-BodyText -Message $message
    $records += Get-PlannerItemsFromText -Text $text -ReceivedDateTime $message.receivedDateTime -MessageId $message.id -Subject $message.subject
}

if (@($records).Count -eq 0) {
    $rawText = Get-Content -LiteralPath $InputJson -Raw -Encoding UTF8
    $records += Get-PlannerItemsFromText -Text $rawText -ReceivedDateTime $null -MessageId "raw:$InputJson" -Subject "raw-planner-readback"
}

$records = @($records | Sort-Object plan_id, task_id, message_received_at -Unique)
$parent = Split-Path -Parent $OutputJsonl
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$records | ForEach-Object { $_ | ConvertTo-Json -Depth 20 -Compress } | Set-Content -LiteralPath $OutputJsonl -Encoding UTF8

[pscustomobject]@{
    status = "PLANNER_TASK_LEVEL_SNAPSHOT_BUILT"
    input = $InputJson
    output = $OutputJsonl
    records = @($records).Count
    readback_trust = if ($AllowUntrustedReadback) { "FALLBACK_INDIRECT" } else { "UNTRUSTED_INDIRECT" }
    external_write = $false
}
