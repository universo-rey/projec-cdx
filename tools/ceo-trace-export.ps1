param(
    [string] $EventId,
    [string] $CorrelationId,
    [string] $EventStoreRoot,
    [string] $StateRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "ceo-suite-common.ps1")

$bus = Initialize-CeoEventBusState -EventStoreRoot $EventStoreRoot -StateRoot $StateRoot

function Get-TraceLines {
    param([string] $Id)
    $path = Join-Path $bus.Traces "$Id.trace.jsonl"
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        return @(Get-Content -LiteralPath $path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }
    return @()
}

function Export-OneTrace {
    param([string] $Id)

    $lines = @(Get-TraceLines -Id $Id)
    $records = @()
    foreach ($line in $lines) {
        try {
            $records += ($line | ConvertFrom-Json)
        }
        catch {
        }
    }

    $first = if ($records.Count -gt 0) { $records[0] } else { $null }
    $trace = [ordered]@{
        trace_id = $(if ($null -ne $first) { [string](Get-CeoEventBusProperty -InputObject $first -Name "trace_id" -Default ([guid]::NewGuid().ToString())) } else { [guid]::NewGuid().ToString() })
        event_id = $Id
        correlation_id = $(if ($null -ne $first) { [string](Get-CeoEventBusProperty -InputObject $first -Name "correlation_id" -Default "") } else { "" })
        nodes = @($records | ForEach-Object { [ordered]@{ id = (Get-CeoEventBusProperty -InputObject $_ -Name "state" -Default "UNKNOWN"); label = (Get-CeoEventBusProperty -InputObject $_ -Name "state" -Default "UNKNOWN"); timestamp = (Get-CeoEventBusProperty -InputObject $_ -Name "timestamp" -Default "") } })
        edges = @()
        policy_decision = $(if ($records.Count -gt 0) { [string](Get-CeoEventBusProperty -InputObject ($records | Select-Object -Last 1) -Name "policy_decision" -Default "") } else { "" })
        evidence = @($records | ForEach-Object { Get-CeoEventBusProperty -InputObject $_ -Name "evidence" -Default $null } | Where-Object { $null -ne $_ })
    }

    $dir = Join-Path $bus.Traces $Id
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Save-CeoEventBusJson -Path (Join-Path $dir "trace.json") -InputObject $trace

    $stateLines = @($records | ForEach-Object {
        $timestamp = Get-CeoEventBusProperty -InputObject $_ -Name "timestamp" -Default ""
        $state = Get-CeoEventBusProperty -InputObject $_ -Name "state" -Default "UNKNOWN"
        $message = Get-CeoEventBusProperty -InputObject $_ -Name "message" -Default ""
        "- $timestamp $state $message"
    })

    $md = @(
        "# G2 Event Trace",
        "",
        "event_id: $Id",
        "correlation_id: $($trace.correlation_id)",
        "policy_decision: $($trace.policy_decision)",
        "",
        "states:",
        $stateLines
    )
    $md | Set-Content -LiteralPath (Join-Path $dir "trace.md") -Encoding UTF8

    $graph = [ordered]@{
        event_id = $Id
        nodes = $trace.nodes
        edges = $trace.edges
    }
    Save-CeoEventBusJson -Path (Join-Path $dir "trace.graph.json") -InputObject $graph
    return $trace
}

$ids = @()
if (-not [string]::IsNullOrWhiteSpace($EventId)) {
    $ids += $EventId
}
elseif (-not [string]::IsNullOrWhiteSpace($CorrelationId)) {
    foreach ($lineFile in @(Get-ChildItem -LiteralPath $bus.Traces -Filter "*.trace.jsonl" -File -ErrorAction SilentlyContinue)) {
        $lines = @(Get-Content -LiteralPath $lineFile.FullName -ErrorAction SilentlyContinue)
        foreach ($line in $lines) {
            try {
                $record = $line | ConvertFrom-Json
                if ([string]$record.correlation_id -eq $CorrelationId) {
                    $ids += $lineFile.BaseName.Replace(".trace", "")
                    break
                }
            }
            catch {
            }
        }
    }
}
else {
    $ids = @(Get-ChildItem -LiteralPath $bus.Traces -Filter "*.trace.jsonl" -File -ErrorAction SilentlyContinue | ForEach-Object { $_.BaseName.Replace(".trace", "") })
}

$exported = @()
foreach ($id in @($ids | Select-Object -Unique)) {
    $exported += Export-OneTrace -Id $id
}

[ordered]@{
    exported = $exported.Count
    traces = @($exported)
} | ConvertTo-Json -Depth 20
