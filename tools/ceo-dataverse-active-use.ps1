param(
    [ValidateSet('status', 'solutions', 'tables', 'schema', 'records', 'memory', 'canon-delta', 'all')]
    [string] $Mode = 'status',
    [switch] $Json,
    [switch] $Refresh,
    [string] $EnvironmentUrl = 'https://org084965d9.crm.dynamics.com',
    [string] $AzureConfigDir = 'C:\Users\enzo1\AppData\Local\CEO\AzureCli'
)

$Root = 'C:\CEO\project-cdx'
$OutDir = Join-Path $Root '.cabina\dataverse\out'
$InventoryPath = Join-Path $OutDir 'dataverse-live-inventory.json'
$MemoryPath = Join-Path $OutDir 'dataverse-usable-memory.json'
$CanonDeltaPath = Join-Path $OutDir 'dataverse-canon-delta.json'
$AzPath = 'C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd'

$ExpectedCanon = @(
    [PSCustomObject]@{ expected = 'cr3c_spsite'; observed_candidates = @('cr3c_cr3c_spsite') },
    [PSCustomObject]@{ expected = 'cr3c_spcontainer'; observed_candidates = @('cr3c_cr3c_spcontainer', 'cr3c_contenedorsp') },
    [PSCustomObject]@{ expected = 'cr3c_spfield'; observed_candidates = @('cr3c_cr3c_spfield', 'cr3c_camposp') },
    [PSCustomObject]@{ expected = 'cr3c_spcontenttype'; observed_candidates = @('cr3c_tipodecontenidosp', 'cr3c_cr3c_containercontenttype') },
    [PSCustomObject]@{ expected = 'cr3c_spchoiceoption'; observed_candidates = @('cr3c_cr3c_spchoiceoption') }
)

function Save-Json {
    param(
        [string] $Path,
        [object] $Value
    )

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Read-JsonFile {
    param([string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function New-BlockedSnapshot {
    param([string] $Reason)

    $generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $inventory = [PSCustomObject]@{
        artifact = 'dataverse-live-inventory'
        status = 'DATAVERSE_LIVE_DISCOVERY_BLOCKED'
        block_reason = $Reason
        generated_at = $generatedAt
        workspace = $Root
        environment_url = $EnvironmentUrl
        execution_surface = 'Visual Studio Code Insiders Console'
        mode = 'READ_ONLY_NO_MUTATION'
        solutions_observed = @()
        target_solution_found = $false
        tables = @()
        schema = [PSCustomObject]@{ observed = $false; columns_observed = 0; keys_observed = 0 }
        records = [PSCustomObject]@{ observed = $false; live_rows_confirmed = $false; samples = @() }
        frontier = [PSCustomObject]@{
            no_create_tables = $true
            no_delete = $true
            no_rename = $true
            no_data_write = $true
            no_flow_create = $true
            no_push = $true
            no_pr = $true
            no_secret_print = $true
        }
    }

    $memory = [PSCustomObject]@{
        artifact = 'dataverse-usable-memory'
        status = 'DATAVERSE_MEMORY_NOT_USABLE_YET'
        reason = $Reason
        generated_at = $generatedAt
        usable_now = $false
        live_rows_confirmed = $false
        agent_memory_routing = @()
    }

    $canonDelta = [PSCustomObject]@{
        artifact = 'dataverse-canon-delta'
        status = 'DATAVERSE_CANON_DELTA_NOT_COMPUTED'
        reason = $Reason
        generated_at = $generatedAt
        expected_solution = 'cr3c_spgovernancemodel'
        observed_solution = $null
        delta = @($ExpectedCanon | ForEach-Object {
            [PSCustomObject]@{
                expected = $_.expected
                observed = $false
                observed_candidates = $_.observed_candidates
                decision = 'VERIFY_AFTER_LIVE_READ'
            }
        })
    }

    [PSCustomObject]@{ inventory = $inventory; memory = $memory; canon_delta = $canonDelta }
}

function Get-AzureToken {
    if (-not (Test-Path -LiteralPath $AzPath)) {
        throw 'AZURE_CLI_NOT_FOUND'
    }

    $env:AZURE_CONFIG_DIR = $AzureConfigDir
    New-Item -ItemType Directory -Force -Path $AzureConfigDir | Out-Null
    $token = & $AzPath account get-access-token --resource $EnvironmentUrl --query accessToken -o tsv
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw 'AZURE_TOKEN_NOT_AVAILABLE'
    }

    return $token.Trim()
}

function Invoke-DataverseGet {
    param(
        [string] $RelativeUrl,
        [hashtable] $Headers
    )

    $uri = "$EnvironmentUrl/api/data/v9.2/$RelativeUrl"
    Invoke-RestMethod -Method GET -Uri $uri -Headers $Headers -ErrorAction Stop
}

function Get-EntitySafe {
    param(
        [string] $LogicalName,
        [hashtable] $Headers
    )

    try {
        $select = 'LogicalName,SchemaName,EntitySetName,MetadataId,PrimaryIdAttribute,PrimaryNameAttribute,OwnershipType'
        $entity = Invoke-DataverseGet -RelativeUrl "EntityDefinitions(LogicalName='$LogicalName')?`$select=$select" -Headers $Headers
        $attrs = Invoke-DataverseGet -RelativeUrl "EntityDefinitions(LogicalName='$LogicalName')/Attributes?`$select=LogicalName,SchemaName,AttributeType,RequiredLevel,IsPrimaryId,IsPrimaryName&`$top=500" -Headers $Headers
        $keys = Invoke-DataverseGet -RelativeUrl "EntityDefinitions(LogicalName='$LogicalName')/Keys?`$select=LogicalName,KeyAttributes&`$top=100" -Headers $Headers
        $sampleRows = @()
        $sampleError = $null

        if ($entity.EntitySetName) {
            try {
                $sample = Invoke-DataverseGet -RelativeUrl "$($entity.EntitySetName)?`$top=3" -Headers $Headers
                $sampleRows = @($sample.value | ForEach-Object {
                    $sanitized = [ordered]@{}
                    foreach ($property in $_.PSObject.Properties) {
                        if ($property.Name -match '@odata|token|secret|password|email|mail|telephone|phone') {
                            continue
                        }
                        if ($sanitized.Count -lt 12) {
                            $sanitized[$property.Name] = $property.Value
                        }
                    }
                    [PSCustomObject]$sanitized
                })
            }
            catch {
                $sampleError = $_.Exception.Message
            }
        }

        return [PSCustomObject]@{
            logical_name = $LogicalName
            observed = $true
            schema_name = $entity.SchemaName
            entity_set_name = $entity.EntitySetName
            metadata_id = $entity.MetadataId
            primary_id_attribute = $entity.PrimaryIdAttribute
            primary_name_attribute = $entity.PrimaryNameAttribute
            ownership_type = $entity.OwnershipType
            attribute_count = @($attrs.value).Count
            attributes = @($attrs.value | ForEach-Object {
                [PSCustomObject]@{
                    logical_name = $_.LogicalName
                    schema_name = $_.SchemaName
                    type = $_.AttributeType
                    required = $_.RequiredLevel.Value
                    primary_id = $_.IsPrimaryId
                    primary_name = $_.IsPrimaryName
                }
            })
            key_count = @($keys.value).Count
            keys = @($keys.value | ForEach-Object {
                [PSCustomObject]@{
                    logical_name = $_.LogicalName
                    key_attributes = $_.KeyAttributes
                }
            })
            sample_count = $sampleRows.Count
            sample_sanitized = $sampleRows
            sample_error = $sampleError
        }
    }
    catch {
        return [PSCustomObject]@{
            logical_name = $LogicalName
            observed = $false
            error = $_.Exception.Message
        }
    }
}

function Refresh-Snapshot {
    try {
        $token = Get-AzureToken
        $headers = @{
            Authorization      = "Bearer $token"
            Accept             = 'application/json'
            'OData-MaxVersion' = '4.0'
            'OData-Version'    = '4.0'
            Prefer             = 'odata.include-annotations="OData.Community.Display.V1.FormattedValue"'
        }

        $who = Invoke-DataverseGet -RelativeUrl 'WhoAmI()' -Headers $headers
        $solutionsRaw = Invoke-DataverseGet -RelativeUrl "solutions?`$select=solutionid,uniquename,friendlyname,version,ismanaged" -Headers $headers
        $solutions = @($solutionsRaw.value | Where-Object {
            $_.uniquename -match 'cr3c|spgovernance|governance' -or $_.friendlyname -match 'cr3c|SP Governance|Governance'
        } | Sort-Object uniquename | ForEach-Object {
            [PSCustomObject]@{
                solutionid = $_.solutionid
                uniquename = $_.uniquename
                friendlyname = $_.friendlyname
                version = $_.version
                ismanaged = $_.ismanaged
            }
        })

        $solution = @($solutions | Where-Object { $_.uniquename -eq 'SPGovernanceModel' } | Select-Object -First 1)
        $componentCount = $null
        $componentsByType = @()

        if ($solution.Count -gt 0) {
            try {
                $componentsRaw = Invoke-DataverseGet -RelativeUrl "solutioncomponents?`$select=solutioncomponentid,componenttype,objectid&`$filter=_solutionid_value eq $($solution[0].solutionid)" -Headers $headers
                $componentCount = @($componentsRaw.value).Count
                $componentsByType = @($componentsRaw.value | Group-Object componenttype | Sort-Object Name | ForEach-Object {
                    [PSCustomObject]@{ componenttype = $_.Name; count = $_.Count }
                })
            }
            catch {
                $componentCount = $null
            }
        }

        $actualLogicalNames = @($ExpectedCanon | ForEach-Object { $_.observed_candidates } | Select-Object -Unique)
        $tables = @($actualLogicalNames | ForEach-Object { Get-EntitySafe -LogicalName $_ -Headers $headers })
        $generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $recordsObserved = @($tables | Where-Object { $_.sample_count -gt 0 }).Count -gt 0
        $allCanonMapped = @($ExpectedCanon | Where-Object {
            $expected = $_
            @($tables | Where-Object { $_.observed -and $expected.observed_candidates -contains $_.logical_name }).Count -gt 0
        }).Count -eq $ExpectedCanon.Count

        $delta = @($ExpectedCanon | ForEach-Object {
            $expected = $_
            $observed = @($tables | Where-Object { $_.observed -and $expected.observed_candidates -contains $_.logical_name })
            [PSCustomObject]@{
                expected = $expected.expected
                observed = $observed.Count -gt 0
                observed_candidates = $expected.observed_candidates
                observed_logical_names = @($observed | ForEach-Object { $_.logical_name })
                decision = if ($observed.Count -gt 0) { 'CANON_NAME_DRIFT_WITH_REAL_TABLE_PRESENT' } else { 'MISSING_OR_NO_ACCESS' }
            }
        })

        $inventory = [PSCustomObject]@{
            artifact = 'dataverse-live-inventory'
            status = if ($allCanonMapped) { 'DATAVERSE_TABLES_REAL_INDEX' } else { 'DATAVERSE_LIVE_DISCOVERY_PARTIAL' }
            generated_at = $generatedAt
            workspace = $Root
            environment_url = $EnvironmentUrl
            tenant_id = '858a0852-44a1-413e-a0fe-f053949797d6'
            user_id = $who.UserId
            business_unit_id = $who.BusinessUnitId
            organization_id = $who.OrganizationId
            solutions_observed = $solutions
            target_solution_found = $solution.Count -gt 0
            target_solution_unique_name = if ($solution.Count -gt 0) { $solution[0].uniquename } else { $null }
            target_solution_component_count = $componentCount
            target_solution_components_by_type = $componentsByType
            tables = $tables
            schema = [PSCustomObject]@{
                observed = @($tables | Where-Object { $_.observed }).Count -gt 0
                columns_observed = (@($tables | Where-Object { $_.observed } | ForEach-Object { $_.attribute_count }) | Measure-Object -Sum).Sum
                keys_observed = (@($tables | Where-Object { $_.observed } | ForEach-Object { $_.key_count }) | Measure-Object -Sum).Sum
            }
            records = [PSCustomObject]@{
                observed = $recordsObserved
                live_rows_confirmed = $recordsObserved
                samples = @($tables | Where-Object { $_.sample_count -gt 0 } | ForEach-Object {
                    [PSCustomObject]@{
                        table = $_.logical_name
                        sample_count = $_.sample_count
                        sample_sanitized = $_.sample_sanitized
                    }
                })
            }
            writes_executed = $false
            secrets_printed = $false
            frontier = [PSCustomObject]@{
                no_create_tables = $true
                no_delete = $true
                no_rename = $true
                no_data_write = $true
                no_flow_create = $true
                no_push = $true
                no_pr = $true
                no_secret_print = $true
            }
        }

        $memory = [PSCustomObject]@{
            artifact = 'dataverse-usable-memory'
            status = if ($recordsObserved) { 'DATAVERSE_USABLE_MEMORY_MAP' } elseif ($allCanonMapped) { 'DATAVERSE_SCHEMA_USABLE_RECORDS_EMPTY_OR_NOT_CONFIRMED' } else { 'DATAVERSE_MEMORY_PARTIAL' }
            generated_at = $generatedAt
            usable_now = $allCanonMapped
            live_rows_confirmed = $recordsObserved
            agent_memory_routing = @(
                [PSCustomObject]@{ agent = 'DATAVERSE_MEMORY_KEEPER'; consumes = 'SPGovernanceModel solution + cr3c real tables'; status = if ($allCanonMapped) { 'READY' } else { 'PARTIAL' } },
                [PSCustomObject]@{ agent = 'HORUS_SIGNAL'; consumes = 'canon name drift cr3c expected vs cr3c_cr3c observed'; status = 'READY' },
                [PSCustomObject]@{ agent = 'SESHAT_EVIDENCE'; consumes = 'solution/table inventory evidence'; status = 'READY' },
                [PSCustomObject]@{ agent = 'ANUBIS_GATE'; consumes = 'write boundary and safe read checks'; status = 'READY' }
            )
            table_memory = @($tables | ForEach-Object {
                [PSCustomObject]@{
                    table = $_.logical_name
                    observed = $_.observed
                    entity_set = $_.entity_set_name
                    attribute_count = $_.attribute_count
                    sample_count = $_.sample_count
                }
            })
        }

        $canonDelta = [PSCustomObject]@{
            artifact = 'dataverse-canon-delta'
            status = 'DATAVERSE_CANON_DELTA'
            generated_at = $generatedAt
            expected_solution = 'cr3c_spgovernancemodel'
            observed_solution = if ($solution.Count -gt 0) { $solution[0].uniquename } else { $null }
            target_solution_found = $solution.Count -gt 0
            expected_tables = @($ExpectedCanon | ForEach-Object { $_.expected })
            delta = $delta
        }

        Save-Json -Path $InventoryPath -Value $inventory
        Save-Json -Path $MemoryPath -Value $memory
        Save-Json -Path $CanonDeltaPath -Value $canonDelta
        return [PSCustomObject]@{ inventory = $inventory; memory = $memory; canon_delta = $canonDelta }
    }
    catch {
        $snapshot = New-BlockedSnapshot -Reason $_.Exception.Message
        Save-Json -Path $InventoryPath -Value $snapshot.inventory
        Save-Json -Path $MemoryPath -Value $snapshot.memory
        Save-Json -Path $CanonDeltaPath -Value $snapshot.canon_delta
        return $snapshot
    }
}

if ($Refresh -or -not (Test-Path -LiteralPath $InventoryPath) -or -not (Test-Path -LiteralPath $MemoryPath) -or -not (Test-Path -LiteralPath $CanonDeltaPath)) {
    $snapshot = Refresh-Snapshot
}
else {
    $snapshot = [PSCustomObject]@{
        inventory = Read-JsonFile -Path $InventoryPath
        memory = Read-JsonFile -Path $MemoryPath
        canon_delta = Read-JsonFile -Path $CanonDeltaPath
    }
}

$result = switch ($Mode) {
    'status' {
        [PSCustomObject]@{
            command = 'ceo-dataverse-status'
            status = $snapshot.inventory.status
            environment_url = $snapshot.inventory.environment_url
            target_solution_found = $snapshot.inventory.target_solution_found
            tables_observed = @($snapshot.inventory.tables | Where-Object { $_.observed }).Count
            live_rows_confirmed = $snapshot.inventory.records.live_rows_confirmed
            output_files = @(
                '.cabina/dataverse/out/dataverse-live-inventory.json',
                '.cabina/dataverse/out/dataverse-usable-memory.json',
                '.cabina/dataverse/out/dataverse-canon-delta.json'
            )
            frontier = $snapshot.inventory.frontier
        }
    }
    'solutions' { $snapshot.inventory.solutions_observed }
    'tables' { $snapshot.inventory.tables }
    'schema' { $snapshot.inventory.schema }
    'records' { $snapshot.inventory.records }
    'memory' { $snapshot.memory }
    'canon-delta' { $snapshot.canon_delta }
    default { $snapshot }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 20
}
else {
    $result
}
