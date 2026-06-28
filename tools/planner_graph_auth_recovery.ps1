param(
    [string]$TenantId = "858a0852-44a1-413e-a0fe-f053949797d6",
    [string]$ClientId,
    [string]$RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient",
    [string]$OutputJson = "C:\CEO\project-cdx\inventarios\PLANNER_GRAPH_AUTH_RECOVERY_20260627.json"
)

$ErrorActionPreference = "Stop"

$requiredScopes = @(
    "Tasks.Read",
    "Tasks.ReadWrite",
    "Group-Conversation.Read.All",
    "Group.Read.All",
    "Directory.Read.All",
    "Team.ReadBasic.All"
)

$observedScopes = @(
    "Chat.Read",
    "ChannelMessage.Read.All",
    "email",
    "Files.Read.All",
    "Files.ReadWrite.All",
    "openid",
    "profile",
    "Sites.Read.All",
    "User.Read"
)

$deltaValidation = @(
    [pscustomobject]@{
        delta = 1
        name = "list_plans"
        method = "GET"
        endpoint = "https://graph.microsoft.com/v1.0/me/planner/plans"
        expected = 200
        required_scopes = @("Tasks.Read", "Tasks.ReadWrite")
    },
    [pscustomobject]@{
        delta = 2
        name = "list_tasks_by_plan"
        method = "GET"
        endpoint = "https://graph.microsoft.com/v1.0/planner/plans/{plan-id}/tasks"
        expected = 200
        required_scopes = @("Tasks.Read", "Tasks.ReadWrite", "Group.Read.All")
    },
    [pscustomobject]@{
        delta = 3
        name = "get_task"
        method = "GET"
        endpoint = "https://graph.microsoft.com/v1.0/planner/tasks/{task-id}"
        expected = 200
        required_scopes = @("Tasks.Read", "Tasks.ReadWrite")
    },
    [pscustomobject]@{
        delta = 4
        name = "get_task_details"
        method = "GET"
        endpoint = "https://graph.microsoft.com/v1.0/planner/tasks/{task-id}/details"
        expected = 200
        required_scopes = @("Tasks.Read", "Tasks.ReadWrite")
    },
    [pscustomobject]@{
        delta = 5
        name = "list_conversation_posts"
        method = "GET"
        endpoint = "https://graph.microsoft.com/v1.0/groups/{group-id}/threads/{thread-id}/posts"
        expected = 200
        required_scopes = @("Group-Conversation.Read.All", "Group.Read.All", "Directory.Read.All")
    }
)

$scopeParam = [System.Uri]::EscapeDataString(($requiredScopes -join " "))
$redirectParam = [System.Uri]::EscapeDataString($RedirectUri)
$adminConsentUrl = $null
$userConsentUrl = $null

if (-not [string]::IsNullOrWhiteSpace($ClientId)) {
    $adminConsentUrl = "https://login.microsoftonline.com/$TenantId/adminconsent?client_id=$ClientId&redirect_uri=$redirectParam"
    $userConsentUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/authorize?client_id=$ClientId&response_type=code&redirect_uri=$redirectParam&response_mode=query&scope=$scopeParam&prompt=consent"
}

$result = [pscustomobject]@{
    schema_version = 1
    artifact = "planner-graph-auth-recovery"
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    state = [pscustomobject]@{
        READBACK_UNTRUSTED = $true
        GRAPH_ACCESS = "DEGRADED"
        absence_means_absence = $false
    }
    tenant_id = $TenantId
    app_registration = [pscustomobject]@{
        client_id = if ([string]::IsNullOrWhiteSpace($ClientId)) { $null } else { $ClientId }
        status = if ([string]::IsNullOrWhiteSpace($ClientId)) { "CLIENT_ID_NOT_EXPOSED_LOCAL" } else { "CLIENT_ID_PROVIDED" }
    }
    observed_scopes = $observedScopes
    required_scopes = $requiredScopes
    missing_scopes = @($requiredScopes | Where-Object { $observedScopes -notcontains $_ })
    consent = [pscustomobject]@{
        admin_consent_url = $adminConsentUrl
        user_consent_url = $userConsentUrl
        note = "Provide -ClientId to generate concrete consent URLs for the current app registration."
    }
    delta_validation = $deltaValidation
    safety = [pscustomobject]@{
        planner_write_allowed = $false
        destructive_actions_allowed = $false
        readback_mode = "DELTA_PROGRESSIVE"
    }
}

$parent = Split-Path -Parent $OutputJson
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $OutputJson -Encoding UTF8
$result
