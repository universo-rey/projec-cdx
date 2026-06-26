# Tcu Redactor Planes Operativos

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the open VS Code Insiders window for `cabina-universal-d` into the governed workbench for local agent discovery, runtime triage, and safe next-lane execution.

**Architecture:** Keep `cabina-universal-d` as the active repo-scoped control plane and treat VS Code Insiders as a local workbench surface. All live provider runtimes observed in VSI remain metadata-only until an exact target, owner, rollback, postcheck, validator, evidence path, and gate are present.

**Tech Stack:** VS Code Insiders, PowerShell, Git, local Codex governance matrices, `code-insiders --status`, local validators, optional provider CLIs in read-only or dry-run mode only.

---

## File Structure

- Modify: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_EXECUTION_PLAN_20260606.csv`
  - Purpose: task-level control table for this plan.
- Modify: `.agents/codex/matrices/MATRIX_INDEX.csv`
  - Purpose: index the execution plan matrix so the cabina router can find it.
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_DISCOVERY_20260606.csv`
  - Purpose: current proof that the active VSI window is `cabina-universal-d`.
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_RUNTIME_OBSERVED_20260606.csv`
  - Purpose: observed extension/runtime processes and their gates.
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_SURFACE_DEEP_MAP_20260606.csv`
  - Purpose: extension, settings-key, and storage layer evidence.
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_STORAGE_REVIEW_QUEUE_20260606.csv`
  - Purpose: storage candidates that require explicit destructive gate before cleanup.

## Task 1: Refresh Our Cabina Baseline

**Files:**
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_DISCOVERY_20260606.csv`
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_RUNTIME_OBSERVED_20260606.csv`
- Evidence: `C:\Users\enzo1\CodexLocal\OPTIMIZACION_PC\vscode-insiders-our-cabina-discovery-20260606-003415`

- [ ] **Step 1: Verify the repo and branch**

Run:

```powershell
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d status -sb
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d rev-parse --short HEAD
```

Expected: branch is `codex/local-tooling-continuity-handoff`; only pre-existing `.gitignore` is dirty unless a later task has staged explicit plan files.

- [ ] **Step 2: Re-read the active VS Code Insiders status**

Run:

```powershell
code-insiders --status
```

Expected: output includes `Window (Extension: Docker DX - cabina-universal-d - Visual Studio Code - Insiders)` and `Folder (cabina-universal-d)`.

- [ ] **Step 3: Stop if the active window is no longer our cabina**

If Step 2 does not show `cabina-universal-d`, stop with `PENDING_TARGET_ONLY` and reopen the correct VS Code Insiders window before continuing.

## Task 2: Build a Current Local Runtime Readback

**Files:**
- Create or update local evidence only under: `C:\Users\enzo1\CodexLocal\OPTIMIZACION_PC\`
- Do not modify settings, storage, extensions, processes, or provider accounts.

- [ ] **Step 1: Create a fresh evidence folder**

Run:

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$dir = "C:\Users\enzo1\CodexLocal\OPTIMIZACION_PC\vscode-insiders-our-cabina-refresh-$stamp"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$dir
```

Expected: a new folder path is printed under `C:\Users\enzo1\CodexLocal\OPTIMIZACION_PC\`.

- [ ] **Step 2: Capture sanitized process roles**

Run:

```powershell
Get-CimInstance Win32_Process |
  Where-Object { $_.CommandLine -match 'Code - Insiders|vscode-insiders|globalStorage|workspaceStorage|cabina-universal-d|codex|pac|codeql|cloudcode|gemini|pixelpilot' } |
  Select-Object ProcessId, ParentProcessId, Name, ExecutablePath |
  Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath "$dir\processes-sanitized.csv"
```

Expected: `processes-sanitized.csv` exists and contains no command-line secrets or setting values.

- [ ] **Step 3: Capture current extension list**

Run:

```powershell
code-insiders --list-extensions --show-versions | Set-Content -Encoding UTF8 -LiteralPath "$dir\extensions.txt"
```

Expected: `extensions.txt` exists and lists extensions by id/version only.

## Task 3: Classify Observed Runtime Helpers

**Files:**
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_RUNTIME_OBSERVED_20260606.csv`
- Modify only if counts or roles changed: `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_RUNTIME_OBSERVED_20260606.csv`

- [ ] **Step 1: Compare observed roles**

Run:

```powershell
Import-Csv C:\Users\enzo1\Documents\GitHub\cabina-universal-d\.agents\codex\matrices\VSCODE_INSIDERS_OUR_CABINA_RUNTIME_OBSERVED_20260606.csv |
  Select-Object runtime_id, observed_role, surface, status, gate, stop_condition |
  Format-Table -AutoSize
```

Expected: provider helpers remain `OBSERVED_NOT_ACTIVATION_ORDER`; local analyzers remain `OBSERVED`.

- [ ] **Step 2: Confirm no live action is inferred**

Decision rule:

```text
If a helper is observed, classify it as runtime evidence only.
If a helper would perform cloud, Microsoft, Power Platform, OpenAI, secret, cost, or tenant work, keep its stop condition as PENDING_APPROVAL_ONLY or PENDING_TARGET_ONLY.
```

Expected: no runtime helper is treated as authorized live execution.

## Task 4: Resolve the First Local Lane

**Files:**
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_STORAGE_REVIEW_QUEUE_20260606.csv`
- Read: `.agents/codex/matrices/VSCODE_INSIDERS_EXTENSION_GROUP_MATRIX_20260606.csv`
- Read: `.agents/codex/matrices/AGENT_SURFACE_INFORMATION_BACKLOG_20260606.csv`

- [ ] **Step 1: Choose the first non-live lane**

Use this order:

```text
1. CodeQL local analysis health for current cabina.
2. OpenAI/Codex local app-server boundary and no-live policy.
3. Power Platform local-only desktop smoke plan.
4. GCP local package skeleton with no deploy.
5. Storage cleanup decision package with no deletion.
```

Expected: selected lane does not require cloud write, Microsoft live write, OpenAI live call, production, secrets, cost, or destructive action.

- [ ] **Step 2: Record the selected lane before execution**

If editing repo matrices, use an explicit path and stage only that path:

```powershell
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d add -- .agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_EXECUTION_PLAN_20260606.csv
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d diff --cached --name-only
```

Expected: only `.agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_EXECUTION_PLAN_20260606.csv` is staged for that task.

## Task 5: Validate Before Any Commit

**Files:**
- Validate repo-level changes only.

- [ ] **Step 1: Run whitespace validation**

Run:

```powershell
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d diff --check
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d diff --cached --check
```

Expected: both commands exit cleanly.

- [ ] **Step 2: Run governance validators**

Run:

```powershell
pwsh -NoLogo -NoProfile -File C:\Users\enzo1\Documents\GitHub\cabina-universal-d\.agents\codex\tools\local_validate_agent_layer.ps1
pwsh -NoLogo -NoProfile -File C:\Users\enzo1\Documents\GitHub\cabina-universal-d\.agents\codex\tools\local_validate_operational_chain.ps1
pwsh -NoLogo -NoProfile -File C:\Users\enzo1\Documents\GitHub\cabina-universal-d\.agents\codex\tools\local_validate_capability_use_hardening.ps1
pwsh -NoLogo -NoProfile -File C:\Users\enzo1\Documents\GitHub\cabina-universal-d\.agents\codex\tools\local_validate_parallel_order_governance.ps1
```

Expected: all report `"status": "PASS"` and `secret_hit_count` is `0` where reported.

## Task 6: Commit the Plan or Selected Lane

**Files:**
- Stage explicit paths only.

- [ ] **Step 1: Stage explicit files**

Run:

```powershell
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d add -- .agents/codex/plans/2026-06-06-vscode-insiders-our-cabina-plan.md .agents/codex/matrices/VSCODE_INSIDERS_OUR_CABINA_EXECUTION_PLAN_20260606.csv .agents/codex/matrices/MATRIX_INDEX.csv
```

Expected: `.gitignore` remains unstaged if it is still a pre-existing unrelated change.

- [ ] **Step 2: Commit**

Run:

```powershell
git -C C:\Users\enzo1\Documents\GitHub\cabina-universal-d commit -m "Add VS Code Insiders our cabina execution plan"
```

Expected: a small local commit is created on `codex/local-tooling-continuity-handoff`.

## Self-Review

- Spec coverage: This plan covers active-cabina verification, metadata refresh, runtime classification, first lane selection, validation, and commit.
- Placeholder scan: Passed; the plan contains only concrete commands and defined stop conditions.
- Type consistency: Matrix names, validator names, branch name, repo path, and evidence paths match the current cabina artifacts.

## Execution Handoff

Plan complete and saved to `.agents/codex/plans/2026-06-06-vscode-insiders-our-cabina-plan.md`.

Recommended first execution lane: CodeQL local analysis health for current cabina, because it is already active in the open VSI window and does not require cloud, Microsoft, OpenAI live, secrets, production, or destructive cleanup.
