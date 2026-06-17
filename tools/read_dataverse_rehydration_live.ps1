param(
    [string]$EnvironmentUrl = "https://org084965d9.crm.dynamics.com",
    [string]$TenantId = "858a0852-44a1-413e-a0fe-f053949797d6",
    [string]$EnvironmentId = "7f65fc04-c27a-ea0d-bd2d-266aa9203c1e",
    [string]$OutputPath = "operativa\DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json"
)

$ErrorActionPreference = "Stop"

function Get-Token {
    $token = & az account get-access-token --resource $EnvironmentUrl --query accessToken -o tsv
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "AZ_TOKEN_NOT_AVAILABLE"
    }
    return $token.Trim()
}

function Invoke-DataverseGet {
    param(
        [string]$RelativeUrl,
        [string]$Token
    )

    $headers = @{
        Authorization      = "Bearer $Token"
        Accept             = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version"    = "4.0"
    }

    $uri = "$EnvironmentUrl/api/data/v9.2/$RelativeUrl"
    return Invoke-RestMethod -Method GET -Uri $uri -Headers $headers -ErrorAction Stop
}

function Get-ByCanonicalId {
    param(
        [string]$EntitySet,
        [string]$IdColumn,
        [string]$CanonicalId,
        [string]$Token
    )

    $escaped = $CanonicalId.Replace("'", "''")
    $filter = [System.Uri]::EscapeDataString("mon_canonical_id eq '$escaped'")
    $select = "$IdColumn,mon_canonical_id,mon_display_name,mon_status,mon_stop_condition,createdon,modifiedon"
    return Invoke-DataverseGet -RelativeUrl "${EntitySet}?`$select=$select&`$filter=$filter" -Token $Token
}

$pairs = @(
    [pscustomobject]@{
        label             = "sdu_manifesto_owner_approved"
        source_canonical  = "sdu:manifesto:escribania-bitsch:20260616:v1"
        evidence_canonical = "evidence:sdu:manifesto:escribania-bitsch:20260616:v1"
    },
    [pscustomobject]@{
        label             = "sharepoint_seshat_home"
        source_canonical  = "sharepoint:seshat-home:20260616:v1"
        evidence_canonical = "evidence:sharepoint:seshat-home:20260616:v1"
    },
    [pscustomobject]@{
        label             = "sharepoint_corte_proposito"
        source_canonical  = "sharepoint:corte-proposito:20260616:v1"
        evidence_canonical = "evidence:sharepoint:corte-proposito:20260616:v1"
    },
    [pscustomobject]@{
        label             = "sharepoint_corte_agent_index"
        source_canonical  = "sharepoint:corte-agent-index:20260617:v1"
        evidence_canonical = "evidence:sharepoint:corte-agent-index:20260617:v1"
    },
    [pscustomobject]@{
        label             = "sharepoint_binding_ui_seshat_home_atomos"
        source_canonical  = "sharepoint:binding-ui-seshat-home-atomos:20260617:v1"
        evidence_canonical = "evidence:sharepoint:binding-ui-seshat-home-atomos:20260617:v1"
    }
)

$token = Get-Token
$results = @()

foreach ($pair in $pairs) {
    $source = Get-ByCanonicalId -EntitySet "mon_sdu_source_artifacts" -IdColumn "mon_sdu_source_artifactid" -CanonicalId $pair.source_canonical -Token $token
    $evidence = Get-ByCanonicalId -EntitySet "mon_sdu_evidences" -IdColumn "mon_sdu_evidenceid" -CanonicalId $pair.evidence_canonical -Token $token

    $sourceRows = @($source.value)
    $evidenceRows = @($evidence.value)

    $results += [pscustomobject]@{
        label              = $pair.label
        source_canonical   = $pair.source_canonical
        source_count       = $sourceRows.Count
        source_id          = if ($sourceRows.Count -eq 1) { $sourceRows[0].mon_sdu_source_artifactid } else { $null }
        source_status      = if ($sourceRows.Count -eq 1) { $sourceRows[0].mon_status } else { $null }
        evidence_canonical = $pair.evidence_canonical
        evidence_count     = $evidenceRows.Count
        evidence_id        = if ($evidenceRows.Count -eq 1) { $evidenceRows[0].mon_sdu_evidenceid } else { $null }
        evidence_status    = if ($evidenceRows.Count -eq 1) { $evidenceRows[0].mon_status } else { $null }
    }
}

$allConfirmed = @($results | Where-Object { $_.source_count -eq 1 -and $_.evidence_count -eq 1 }).Count -eq $results.Count

$result = [pscustomobject]@{
    read_at_local       = (Get-Date).ToString("s")
    mode                = "LIVE_READ_ONLY"
    environment_url     = $EnvironmentUrl
    environment_id      = $EnvironmentId
    tenant_id           = $TenantId
    entity_sets         = @("mon_sdu_source_artifacts", "mon_sdu_evidences")
    pair_count          = $results.Count
    all_pairs_confirmed = $allConfirmed
    live_state          = if ($allConfirmed) { "live_rows_confirmed" } else { "target_ambiguous" }
    pairs               = $results
    writes_executed     = $false
    flows_executed      = $false
    secrets_printed     = $false
    postcheck           = "Each source/evidence canonical id must return exactly one Dataverse row."
}

$outFullPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $PWD $OutputPath }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outFullPath) | Out-Null
$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outFullPath -Encoding UTF8
$result | ConvertTo-Json -Depth 8
