Set-StrictMode -Version Latest

function Get-G6RepoRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function New-G6TestLiveRoot {
    param([string] $Name = "g6")

    $root = Get-G6RepoRoot
    $testRoot = $env:SDU_TEST_OUTPUT
    if ([string]::IsNullOrWhiteSpace($testRoot)) {
        $testRoot = Join-Path (Join-Path (Join-Path $root ".cabina") "runtime") "live-operations\tests"
    }

    return (Join-Path $testRoot ("$Name-" + [guid]::NewGuid().ToString()))
}

function Start-G6TestLiveSession {
    param(
        [Parameter(Mandatory = $true)]
        [string] $LiveRoot,
        [string] $Owner = "OWNER_CONTROL"
    )

    $root = Get-G6RepoRoot
    return (& (Join-Path $root "tools\ceo-live-session.ps1") -Action start -Owner $Owner -Reason "g6-test-session" -LiveRoot $LiveRoot) | ConvertFrom-Json
}

function New-G6FormalLiveAction {
    param(
        [string] $SessionId = "",
        [switch] $MissingDireccion,
        [string] $ApprovalStatus = "COMPLETE",
        [bool] $RollbackRequired = $true,
        [bool] $EvidenceRequired = $true,
        [string] $Target = "<SANITIZED_TARGET>"
    )

    $approvalRows = @(
        [ordered]@{ role = "OWNER_OPERATIONAL"; approved = $true; evidence_path = "<EVIDENCE_PATH>" },
        [ordered]@{ role = "OWNER_CONTROL"; approved = $true; evidence_path = "<EVIDENCE_PATH>" }
    )
    if (-not $MissingDireccion) {
        $approvalRows += [ordered]@{ role = "DIRECCION"; approved = $true; evidence_path = "<EVIDENCE_PATH>" }
    }

    return [ordered]@{
        live_action_id = [guid]::NewGuid().ToString()
        action_id = [guid]::NewGuid().ToString()
        event_id = [guid]::NewGuid().ToString()
        environment = "LIVE_CONTROLLED"
        action_type = "CONTROLLED_LIVE_FORMAL"
        requested_at = (Get-Date).ToUniversalTime().ToString("o")
        requested_by = "g6-test"
        source = "run-g6-tests"
        risk = "CRITICAL"
        mode = "LIVE_CONTROLLED_REAL"
        target = $Target
        policy = [ordered]@{
            live_write = $true
            formal_authorization = $true
            allow_live_real = $true
            external = $false
            delete = $false
            strict = $true
        }
        rollback = [ordered]@{
            required = $RollbackRequired
            strategy = "manual-compensating-action"
            compensating_action = "manual-controlled-rollback"
            manual_procedure = "<ROLLBACK_PROCEDURE>"
        }
        evidence = [ordered]@{ required = $EvidenceRequired; path = "<EVIDENCE_PATH>" }
        approvals = [ordered]@{
            approval_status = $ApprovalStatus
            required_roles = @("OWNER_OPERATIONAL", "OWNER_CONTROL", "DIRECCION")
            approvals = @($approvalRows)
        }
        live_session = [ordered]@{ session_id = $SessionId }
        trace = [ordered]@{ trace_id = [guid]::NewGuid().ToString() }
    }
}
