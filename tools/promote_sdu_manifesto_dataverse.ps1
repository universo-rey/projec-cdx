	param(
    [string]$EnvironmentUrl = "https://org084965d9.crm.dynamics.com",
    [string]$TenantId = "858a0852-44a1-413e-a0fe-f053949797d6",
    [string]$EnvironmentId = "7f65fc04-c27a-ea0d-bd2d-266aa9203c1e",
    [string]$ManifestoPath = "operativa/archive/legacy-root/20260616/MANIFIESTO_SDU_ESCRIBANIA_BITSCH_BORRADOR_20260616.md",
    [string]$ReadbackPath = "operativa/archive/legacy-root/20260616/READBACK_FAN_IN_MANIFIESTO_SDU_ESCRIBANIA_BITSCH_20260616.md",
    [string]$OutputPath = "operativa/archive/legacy-root/20260616/DATAVERSE_PROMOTION_MANIFESTO_SDU_20260616.json"
)

# MANUAL-ONLY LIVE WRITE: Dataverse POST/PATCH capable. Requires explicit target, rollback, postcheck, and operator approval.

$ErrorActionPreference = "Stop"

function Get-Token {
    $token = & az account get-access-token --resource $EnvironmentUrl --query accessToken -o tsv
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "AZ_TOKEN_NOT_AVAILABLE"
    }
    return $token.Trim()
}

function Invoke-DataverseJson {
    param(
        [ValidateSet("GET", "POST", "PATCH")]
        [string]$Method,
        [string]$RelativeUrl,
        [object]$Body = $null,
        [string]$Token
    )

    $headers = @{
        Authorization    = "Bearer $Token"
        Accept           = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }

    $uri = "$EnvironmentUrl/api/data/v9.2/$RelativeUrl"
    $invoke = @{
        Method      = $Method
        Uri         = $uri
        Headers     = $headers
        ErrorAction = "Stop"
    }

    if ($null -ne $Body) {
        $headers["Content-Type"] = "application/json; charset=utf-8"
        $headers["Prefer"] = "return=representation"
        $invoke["Body"] = ($Body | ConvertTo-Json -Depth 8)
    }

    return Invoke-RestMethod @invoke
}

function Get-ExistingByCanonicalId {
    param(
        [string]$EntitySet,
        [string]$CanonicalId,
        [string]$Token
    )

    $escaped = $CanonicalId.Replace("'", "''")
    $filter = [System.Uri]::EscapeDataString("mon_canonical_id eq '$escaped'")
    $select = "mon_canonical_id,mon_display_name,mon_status"
    if ($EntitySet -eq "mon_sdu_source_artifacts") {
        $select = "mon_sdu_source_artifactid,$select"
    }
    elseif ($EntitySet -eq "mon_sdu_evidences") {
        $select = "mon_sdu_evidenceid,$select"
    }

    return Invoke-DataverseJson -Method GET -RelativeUrl "$EntitySet?`$select=$select&`$filter=$filter" -Token $Token
}

function New-Hash {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

$manifestFullPath = Join-Path $PWD $ManifestoPath
$readbackFullPath = Join-Path $PWD $ReadbackPath
if (!(Test-Path -LiteralPath $manifestFullPath)) { throw "MANIFESTO_NOT_FOUND: $ManifestoPath" }
if (!(Test-Path -LiteralPath $readbackFullPath)) { throw "READBACK_NOT_FOUND: $ReadbackPath" }

$sourceCanonicalId = "sdu:manifesto:escribania-bitsch:20260616:v1"
$evidenceCanonicalId = "evidence:sdu:manifesto:escribania-bitsch:20260616:v1"
$batchId = "20260616_sdu_manifesto_owner_approved_v1"
$now = (Get-Date).ToUniversalTime().ToString("o")
$manifestHash = New-Hash -Path $manifestFullPath
$readbackHash = New-Hash -Path $readbackFullPath

$token = Get-Token

$beforeSource = Get-ExistingByCanonicalId -EntitySet "mon_sdu_source_artifacts" -CanonicalId $sourceCanonicalId -Token $token
$beforeEvidence = Get-ExistingByCanonicalId -EntitySet "mon_sdu_evidences" -CanonicalId $evidenceCanonicalId -Token $token

$created = @()
$updated = @()
$skipped = @()

if (($beforeSource.value | Measure-Object).Count -eq 0) {
    $sourceBody = @{
        mon_canonical_id       = $sourceCanonicalId
        mon_display_name       = "Manifiesto SDU Escribania Bitsch - Huella atomica owner approved v1"
        mon_source_path        = "PROJEC CDX/$ManifestoPath"
        mon_source_hash        = $manifestHash
        mon_source_system      = "PROJEC_CDX_LOCAL_CANON"
        mon_tenant_scope       = "escribaniabitsch.sharepoint.com"
        mon_environment_scope  = "HUBDesarrollo|$EnvironmentId"
        mon_environment_id     = $EnvironmentId
        mon_environment_url    = $EnvironmentUrl
        mon_gate_required      = $true
        mon_risk_level         = "medium"
        mon_owner              = "Enzo Figueroa / SDU Owner Operativo"
        mon_status             = "Completed"
        mon_stop_condition     = "delta_governed_by_human_authority; live_requires_exact_target_for_mutation"
        mon_notes              = "Owner approved atomic footprint. Stop conditions are treated as governed deltas and next steps; only human authority establishes or derogates real blockers. Metadata pointer only; no sensitive payload."
        mon_seed_batch_id      = $batchId
    }
    $createdSource = Invoke-DataverseJson -Method POST -RelativeUrl "mon_sdu_source_artifacts" -Body $sourceBody -Token $token
    $created += [pscustomobject]@{
        entity_set = "mon_sdu_source_artifacts"
        canonical_id = $sourceCanonicalId
        id = $createdSource.mon_sdu_source_artifactid
    }
}
else {
    $skipped += [pscustomobject]@{
        entity_set = "mon_sdu_source_artifacts"
        canonical_id = $sourceCanonicalId
        reason = "candidate_already_exists"
        count = ($beforeSource.value | Measure-Object).Count
    }
}

if (($beforeEvidence.value | Measure-Object).Count -eq 0) {
    $evidenceBody = @{
        mon_canonical_id       = $evidenceCanonicalId
        mon_display_name       = "Evidencia promocion Manifiesto SDU - owner approved v1"
        mon_source_path        = "PROJEC CDX/$ReadbackPath"
        mon_evidence_hash      = $readbackHash
        mon_evidence_type      = "metadata_pointer_only"
        mon_source_system      = "PROJEC_CDX_LOCAL_CANON"
        mon_gate_required      = $true
        mon_environment_scope  = "HUBDesarrollo|$EnvironmentId"
        mon_status             = "Completed"
        mon_stop_condition     = "delta_governed_by_human_authority; postcheck_required"
        mon_seed_batch_id      = $batchId
    }
    $createdEvidence = Invoke-DataverseJson -Method POST -RelativeUrl "mon_sdu_evidences" -Body $evidenceBody -Token $token
    $created += [pscustomobject]@{
        entity_set = "mon_sdu_evidences"
        canonical_id = $evidenceCanonicalId
        id = $createdEvidence.mon_sdu_evidenceid
    }
}
else {
    $skipped += [pscustomobject]@{
        entity_set = "mon_sdu_evidences"
        canonical_id = $evidenceCanonicalId
        reason = "candidate_already_exists"
        count = ($beforeEvidence.value | Measure-Object).Count
    }
}

$afterSource = Get-ExistingByCanonicalId -EntitySet "mon_sdu_source_artifacts" -CanonicalId $sourceCanonicalId -Token $token
$afterEvidence = Get-ExistingByCanonicalId -EntitySet "mon_sdu_evidences" -CanonicalId $evidenceCanonicalId -Token $token

$result = [pscustomobject]@{
    promoted_at_local = (Get-Date).ToString("s")
    environment_url = $EnvironmentUrl
    environment_id = $EnvironmentId
    tenant_id = $TenantId
    mode = "LIVE_METADATA_POINTER_WRITE"
    source_canonical_id = $sourceCanonicalId
    evidence_canonical_id = $evidenceCanonicalId
    batch_id = $batchId
    before = [pscustomobject]@{
        source_count = ($beforeSource.value | Measure-Object).Count
        evidence_count = ($beforeEvidence.value | Measure-Object).Count
    }
    after = [pscustomobject]@{
        source_count = ($afterSource.value | Measure-Object).Count
        evidence_count = ($afterEvidence.value | Measure-Object).Count
    }
    created = $created
    updated = $updated
    skipped = $skipped
    rollback = "Patch created rows by canonical_id back to Pending/retired, or delete only the exact ids recorded in created if owner orders reversal."
    postcheck = "Counts by canonical_id must be exactly 1 for source and evidence; no payload or secrets were written."
}

$outFullPath = Join-Path $PWD $OutputPath
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outFullPath) | Out-Null
$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outFullPath -Encoding UTF8
$result | ConvertTo-Json -Depth 8
