param(
    [Parameter(Mandatory = $true)]
    [string]$OperationId,

    [Parameter(Mandatory = $true)]
    [string]$Mode,

    [string]$Target = "",

    [string]$Gate = "",

    [switch]$DryRun,

    [string]$OwnerApprovalRef = ""
)

$operations = @{
    READ_STATUS = @{
        Modes = @("OBSERVE")
        RequiredGate = "none"
        Agents = @("SESHAT", "HORUS", "MAAT")
        Evidence = @("status_readback")
        Rollback = $false
    }
    CLASSIFY_LOCAL_SURFACES = @{
        Modes = @("PLAN")
        RequiredGate = "none"
        Agents = @("SESHAT", "THOT", "ANUBIS")
        Evidence = @("triage_matrix")
        Rollback = $false
    }
    GENERATE_EVIDENCE = @{
        Modes = @("PLAN")
        RequiredGate = "none"
        Agents = @("MAAT", "HORUS")
        Evidence = @("output_path_list")
        Rollback = $false
    }
    REPAIR_LOCAL_CONFIG = @{
        Modes = @("LOCAL_CONFIG_REPAIR")
        RequiredGate = "backup_and_validation"
        Agents = @("THOT", "ANUBIS", "MAAT")
        Evidence = @("backup_path", "diff_check", "validation_readback")
        Rollback = $true
    }
    UPDATE_VSCODE_TASKS = @{
        Modes = @("LOCAL_CONFIG_REPAIR")
        RequiredGate = "workspace_only"
        Agents = @("THOT", "ANUBIS")
        Evidence = @("backup_path", "task_parse", "workspace_scope")
        Rollback = $true
    }
    UPDATE_AGENT_SKILLS = @{
        Modes = @("LOCAL_CONFIG_REPAIR")
        RequiredGate = "declarative_only"
        Agents = @("SESHAT", "THOT", "MAAT")
        Evidence = @("registry_readback")
        Rollback = $false
    }
    GENERATE_MOVE_PLAN = @{
        Modes = @("PLAN")
        RequiredGate = "none"
        Agents = @("SESHAT", "THOT", "ANUBIS", "HORUS")
        Evidence = @("move_plan_dry_run")
        Rollback = $false
    }
    LOCAL_COMMIT = @{
        Modes = @("LOCAL_COMMIT")
        RequiredGate = "pathspec_and_staging_scope"
        Agents = @("THOT", "ANUBIS", "MAAT")
        Evidence = @("staged_path_list", "forbidden_path_scan", "diff_check")
        Rollback = $true
        OwnerRequired = $true
    }
    APPLY_LOCAL_MOVE_PLAN = @{
        Modes = @("LOCAL_APPLY")
        RequiredGate = "owner_apply_gate"
        Agents = @("ANUBIS", "MAAT", "HORUS")
        Evidence = @("owner_approval_ref", "target", "rollback", "postcheck")
        Rollback = $true
        OwnerRequired = $true
    }
    REMOTE_PUSH = @{
        Modes = @("REMOTE_PREP")
        RequiredGate = "remote_gate"
        Agents = @("ANUBIS", "MAAT")
        Evidence = @("owner_approval_ref", "remote_target", "pr_plan")
        Rollback = $true
        OwnerRequired = $true
    }
    OPEN_PR = @{
        Modes = @("PR_GOVERNED")
        RequiredGate = "owner_pr_gate"
        Agents = @("ANUBIS", "MAAT", "NARRADOR")
        Evidence = @("owner_approval_ref", "branch", "pr_body")
        Rollback = $true
        OwnerRequired = $true
    }
    LIVE_WRITE = @{
        Modes = @("LIVE_GATED")
        RequiredGate = "G4_G5_live_gate"
        Agents = @("ANUBIS", "MAAT", "HORUS")
        Evidence = @("owner_approval_ref", "tenant_env_site", "rollback", "postcheck")
        Rollback = $true
        OwnerRequired = $true
    }
}

$operationKey = $OperationId.ToUpperInvariant()
$modeKey = $Mode.ToUpperInvariant()
$gateKey = if ([string]::IsNullOrWhiteSpace($Gate)) { "none" } else { $Gate }
$missing = New-Object System.Collections.Generic.List[string]
$stops = New-Object System.Collections.Generic.List[string]
$decision = "BLOCK_PENDING_GATE"
$allowed = $false
$requiredGate = ""
$evidenceRequired = @()
$rollbackRequired = $false

if (-not $operations.ContainsKey($operationKey)) {
    $missing.Add("unknown_operation")
    $stops.Add("operation_not_registered")
    $decision = "BLOCK_SCOPE"
} else {
    $op = $operations[$operationKey]
    $requiredGate = $op.RequiredGate
    $evidenceRequired = @($op.Evidence)
    $rollbackRequired = [bool]$op.Rollback

    if ($modeKey -notin @($op.Modes)) {
        $missing.Add("mode_not_allowed_for_operation")
        $stops.Add("mode_scope_mismatch")
        $decision = "BLOCK_SCOPE"
    }

    if ($Target -match "(?i)(sk-proj-|sk-[A-Za-z0-9]{20,}|BEGIN .*PRIVATE KEY|authorization\s*:\s*bearer)") {
        $missing.Add("secret_like_target")
        $stops.Add("secret_detected")
        $decision = "BLOCK_SECRET"
    }

    $localScoped = $true
    if (-not [string]::IsNullOrWhiteSpace($Target)) {
        $normalized = $Target -replace '\\', '/'
        $localScoped = (
            $normalized -like ".cabina/organizacion-total/*" -or
            $normalized -like "./.cabina/organizacion-total/*" -or
            $normalized -like "C:/CEO/project-cdx/.cabina/organizacion-total/*" -or
            $normalized -like "C:/Users/enzo1/PROJEC CDX/.cabina/organizacion-total/*"
        )
        if (-not $localScoped -and $operationKey -notin @("READ_STATUS", "CLASSIFY_LOCAL_SURFACES", "GENERATE_EVIDENCE", "GENERATE_MOVE_PLAN", "REMOTE_PUSH", "OPEN_PR", "LIVE_WRITE")) {
            $missing.Add("target_outside_local_cabina_scope")
            $stops.Add("scope_outside_contract")
            $decision = "BLOCK_SCOPE"
        }
    }

    if ($missing.Count -eq 0) {
        if ($requiredGate -eq "none") {
            $allowed = $true
            $decision = if ($DryRun) { "ALLOW_DRYRUN" } else { "ALLOW" }
        } elseif ($gateKey -ne $requiredGate) {
            $missing.Add("required_gate:$requiredGate")
            $decision = "BLOCK_PENDING_GATE"
        } elseif ($op.ContainsKey("OwnerRequired") -and [bool]$op.OwnerRequired -and [string]::IsNullOrWhiteSpace($OwnerApprovalRef)) {
            $missing.Add("owner_approval_ref")
            $decision = "BLOCK_PENDING_GATE"
        } else {
            $allowed = $true
            $decision = if ($DryRun) { "ALLOW_DRYRUN" } else { "ALLOW" }
        }
    }
}

[pscustomobject]@{
    operation_id = $operationKey
    mode = $modeKey
    target = $Target
    dry_run = [bool]$DryRun
    allowed = $allowed
    required_gate = $requiredGate
    provided_gate = $gateKey
    required_agents = if ($operations.ContainsKey($operationKey)) { @($operations[$operationKey].Agents) } else { @() }
    missing_conditions = @($missing)
    evidence_required = @($evidenceRequired)
    rollback_required = $rollbackRequired
    stop_conditions = @($stops)
    decision = $decision
} | ConvertTo-Json -Depth 8
