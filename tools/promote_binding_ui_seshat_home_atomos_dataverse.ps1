param(
    [string]$EnvironmentUrl = "https://org084965d9.crm.dynamics.com",
    [string]$TenantId = "858a0852-44a1-413e-a0fe-f053949797d6",
    [string]$EnvironmentId = "7f65fc04-c27a-ea0d-bd2d-266aa9203c1e",
    [string]$SourcePath = "operativa\BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md",
    [string]$ReadbackPath = "operativa\READBACK_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md",
    [string]$OutputPath = "operativa\DATAVERSE_PROMOTION_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.json"
)

$ErrorActionPreference = "Stop"

function Resolve-InputPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return (Join-Path $PWD $Path)
}

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
        Authorization      = "Bearer $Token"
        Accept             = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version"    = "4.0"
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
        if ($Method -eq "POST") {
            $headers["Prefer"] = "return=representation"
        }
        $invoke["Body"] = ($Body | ConvertTo-Json -Depth 8)
    }

    try {
        return Invoke-RestMethod @invoke
    }
    catch {
        $status = "unknown"
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $status = [int]$_.Exception.Response.StatusCode
        }
        throw "DATAVERSE_REQUEST_FAILED:${Method}:${RelativeUrl}:status=$status"
    }
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

    return Invoke-DataverseJson -Method GET -RelativeUrl "${EntitySet}?`$select=$select&`$filter=$filter" -Token $Token
}

function New-Hash {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Assert-CountSafe {
    param(
        [string]$Label,
        [object]$Result
    )
    $count = @($Result.value).Count
    if ($count -gt 1) {
        throw "CANDIDATE_COUNT_NOT_ONE:${Label}:$count"
    }
}

$sourceFullPath = Resolve-InputPath -Path $SourcePath
$readbackFullPath = Resolve-InputPath -Path $ReadbackPath
if (!(Test-Path -LiteralPath $sourceFullPath)) { throw "SOURCE_NOT_FOUND: $SourcePath" }
if (!(Test-Path -LiteralPath $readbackFullPath)) { throw "READBACK_NOT_FOUND: $ReadbackPath" }

$sourceCanonicalId = "sharepoint:binding-ui-seshat-home-atomos:20260617:v1"
$evidenceCanonicalId = "evidence:sharepoint:binding-ui-seshat-home-atomos:20260617:v1"
$batchId = "20260617_binding_ui_seshat_home_atomos_dataverse_pointer_v1"
$sourceHash = New-Hash -Path $sourceFullPath
$readbackHash = New-Hash -Path $readbackFullPath
$sharePointUrl = "https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/Documentos%20compartidos/BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md"
$sharePointItemId = "017KTOXDC3JY4I65TK2NHYNU7FHHS3AZC7"
$sharePointDriveId = "b!O3h4VaIAl0G8IAlSWZQfBt6x2B-fiCFLtg4yI57A_sbIqOZZIimRT6k3y6Abfa8A"

$token = Get-Token

$beforeSource = Get-ExistingByCanonicalId -EntitySet "mon_sdu_source_artifacts" -CanonicalId $sourceCanonicalId -Token $token
$beforeEvidence = Get-ExistingByCanonicalId -EntitySet "mon_sdu_evidences" -CanonicalId $evidenceCanonicalId -Token $token
Assert-CountSafe -Label "source_before" -Result $beforeSource
Assert-CountSafe -Label "evidence_before" -Result $beforeEvidence

$created = @()
$skipped = @()

if (@($beforeSource.value).Count -eq 0) {
    $sourceBody = @{
        mon_canonical_id = $sourceCanonicalId
        mon_display_name = "Binding UI Seshat Home Atomos - SeshatHub Registro N8"
        mon_status       = "Completed"
    }
    $createdSource = Invoke-DataverseJson -Method POST -RelativeUrl "mon_sdu_source_artifacts" -Body $sourceBody -Token $token
    $sourceRowId = $createdSource.mon_sdu_source_artifactid
    $created += [pscustomobject]@{
        entity_set   = "mon_sdu_source_artifacts"
        canonical_id = $sourceCanonicalId
        id           = $sourceRowId
    }
}
else {
    $sourceRowId = @($beforeSource.value)[0].mon_sdu_source_artifactid
    $skipped += [pscustomobject]@{
        entity_set   = "mon_sdu_source_artifacts"
        canonical_id = $sourceCanonicalId
        reason       = "candidate_already_exists"
        count        = @($beforeSource.value).Count
    }
}

$sourcePatchBody = @{
    mon_source_path       = "PROJEC CDX/operativa/BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md"
    mon_source_hash       = $sourceHash
    mon_source_system     = "SHAREPOINT_SESHATHUB_BINDING_ATOM"
    mon_tenant_scope      = "escribaniabitsch.sharepoint.com"
    mon_environment_scope = "HUBDesarrollo|$EnvironmentId"
    mon_environment_id    = $EnvironmentId
    mon_environment_url   = $EnvironmentUrl
    mon_gate_required     = $true
    mon_risk_level        = "medium"
    mon_owner             = "Enzo Figueroa / SDU Owner Operativo"
    mon_status            = "Completed"
    mon_stop_condition    = "home_aspx_page_binding_waiting; delta_governed_by_human_authority"
    mon_seed_batch_id     = $batchId
}
Invoke-DataverseJson -Method PATCH -RelativeUrl "mon_sdu_source_artifacts($sourceRowId)" -Body $sourcePatchBody -Token $token | Out-Null

if (@($beforeEvidence.value).Count -eq 0) {
    $evidenceBody = @{
        mon_canonical_id  = $evidenceCanonicalId
        mon_display_name  = "Evidencia Binding UI Seshat Home Atomos - SharePoint readback"
        mon_evidence_type = "metadata_pointer_only"
        mon_status        = "Completed"
    }
    $createdEvidence = Invoke-DataverseJson -Method POST -RelativeUrl "mon_sdu_evidences" -Body $evidenceBody -Token $token
    $evidenceRowId = $createdEvidence.mon_sdu_evidenceid
    $created += [pscustomobject]@{
        entity_set   = "mon_sdu_evidences"
        canonical_id = $evidenceCanonicalId
        id           = $evidenceRowId
    }
}
else {
    $evidenceRowId = @($beforeEvidence.value)[0].mon_sdu_evidenceid
    $skipped += [pscustomobject]@{
        entity_set   = "mon_sdu_evidences"
        canonical_id = $evidenceCanonicalId
        reason       = "candidate_already_exists"
        count        = @($beforeEvidence.value).Count
    }
}

$evidencePatchBody = @{
    mon_source_path       = "PROJEC CDX/$ReadbackPath"
    mon_evidence_hash     = $readbackHash
    mon_evidence_type     = "metadata_pointer_only"
    mon_source_system     = "PROJEC_CDX_LOCAL_CANON"
    mon_gate_required     = $true
    mon_environment_scope = "HUBDesarrollo|$EnvironmentId"
    mon_status            = "Completed"
    mon_stop_condition    = "home_aspx_page_binding_waiting; postcheck_required"
    mon_seed_batch_id     = $batchId
}
Invoke-DataverseJson -Method PATCH -RelativeUrl "mon_sdu_evidences($evidenceRowId)" -Body $evidencePatchBody -Token $token | Out-Null

$afterSource = Get-ExistingByCanonicalId -EntitySet "mon_sdu_source_artifacts" -CanonicalId $sourceCanonicalId -Token $token
$afterEvidence = Get-ExistingByCanonicalId -EntitySet "mon_sdu_evidences" -CanonicalId $evidenceCanonicalId -Token $token

if (@($afterSource.value).Count -ne 1) { throw "POSTCHECK_FAILED:source_count=$(@($afterSource.value).Count)" }
if (@($afterEvidence.value).Count -ne 1) { throw "POSTCHECK_FAILED:evidence_count=$(@($afterEvidence.value).Count)" }

$result = [pscustomobject]@{
    promoted_at_local     = (Get-Date).ToString("s")
    environment_url       = $EnvironmentUrl
    environment_id        = $EnvironmentId
    tenant_id             = $TenantId
    mode                  = "LIVE_METADATA_POINTER_WRITE"
    source_canonical_id   = $sourceCanonicalId
    evidence_canonical_id = $evidenceCanonicalId
    dataverse_source_id   = @($afterSource.value)[0].mon_sdu_source_artifactid
    dataverse_evidence_id = @($afterEvidence.value)[0].mon_sdu_evidenceid
    batch_id              = $batchId
    sharepoint            = [pscustomobject]@{
        url      = $sharePointUrl
        item_id  = $sharePointItemId
        drive_id = $sharePointDriveId
    }
    hashes                = [pscustomobject]@{
        source_sha256   = $sourceHash
        readback_sha256 = $readbackHash
    }
    before                = [pscustomobject]@{
        source_count   = @($beforeSource.value).Count
        evidence_count = @($beforeEvidence.value).Count
    }
    after                 = [pscustomobject]@{
        source_count   = @($afterSource.value).Count
        evidence_count = @($afterEvidence.value).Count
    }
    created               = $created
    skipped               = $skipped
    rollback              = "Patch exact canonical ids to Pending/Retired or delete exact created ids only if owner orders reversal."
    postcheck             = "source_count=1 and evidence_count=1 by canonical_id; no payload, no secrets, no Home.aspx edit, no flow run."
    next_delta            = "delta_home_aspx_page_binding_when_ui_or_pnp_context_available"
}

$outFullPath = Resolve-InputPath -Path $OutputPath
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outFullPath) | Out-Null
$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outFullPath -Encoding UTF8
$result | ConvertTo-Json -Depth 8
