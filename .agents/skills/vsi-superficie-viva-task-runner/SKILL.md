---
name: vsi-superficie-viva-task-runner
description: Use when an agent must execute a prepared VSI VS Code Insiders superficie viva agent task queue row from VSCODE_INSIDERS_AGENT_TASK_QUEUE_20260606.csv while preserving agent contracts and gating external live writes.
---

# VSI Superficie Viva Task Runner

## Core Rule

Execute prepared VS Code Insiders task-queue rows as local, repo-scoped work.
Do not wait for a new gate when the row already declares owner, reviewer,
read scope, write scope, lock key, rollback, postcheck, evidence, validator
and stop condition. Gate only external live writes, secrets, tenants, costs,
production, destructive actions or remote mutations outside the approved repo
branch lifecycle.

## Runtime Bootstrap

If the task is meant to run as a live surface, start by declaring a traceable
runtime header before any execution step. The header should name the runtime,
surface, task row, exact target, owner, identity, data boundary, branch, lock
key, rollback, postcheck, validator, evidence placeholder and stop condition.
If any field is unknown, mark the exact `PENDING_*_ONLY` state instead of
stalling or guessing.

The runtime begins with the declared surface and traceability contract, not
with a provider call.

## Trigger Boundary

Use this skill when resuming or assigning a row from
`.agents/codex/matrices/VSCODE_INSIDERS_AGENT_TASK_QUEUE_20260606.csv`,
especially tasks involving the local dashboard, Agile Agent Canvas packages,
human-view Spanish labels, local order packets or VS Code Insiders workbench
artifacts.

## Allowed Actions

- read the exact task row and dependency rows
- declare a runtime traceability header when the surface is expected to run
- verify `status=QUEUED_READY` or an executable local status
- execute only the declared local or repo write scope
- preserve machine-facing ids, API contracts, status values and lock keys
- add Spanish labels only in UI copy or existing display fields
- write local order packets, manifests, recipes, skills, tests and readbacks
- run local tests, validators, dry runs and diff checks
- update the task row status only after validation evidence exists

## Blocked Actions

- changing agent-readable ids, status enums or API contracts for display copy
- executing live provider calls from a queue row
- writing Microsoft, OpenAI, Jira, cloud, tenant or production targets without
  a complete governed order
- storing or printing secrets
- editing outside the row write scope
- deleting storage, closing VS Code Insiders processes or mutating Git metadata
- treating a prepared live-gate packet as authorization to execute live

## Workflow

1. Read the queue row, owner agent, reviewer agent, dependency, lock key,
   allowed actions, blocked actions, rollback, postcheck, validator and stop
   condition.
2. Declare the runtime/surface header first when the row is intended to become
   a live or visibly governed surface.
3. If dependency is not complete, stop with the dependency-specific pending
   state and do not execute the row.
4. Confirm the write scope is exact and repo-local. If it is not exact, prepare
   an order packet instead of editing.
5. Execute the smallest local change that satisfies the row.
6. Run the row validator plus `git diff --check`.
7. Record evidence in the row output, readback, PR or validator result.
8. Move the row to `EXECUTED_LOCAL_VALIDATED` only after evidence exists;
   otherwise use the exact pending or blocked state from the real frontier.

## Validator

Primary:

```powershell
.agents\codex\tools\local_validate_agent_layer.ps1
.agents\codex\tools\local_validate_parallel_order_governance.ps1
.agents\codex\tools\local_validate_skill_metadata.ps1
```

Task-specific validators from the queue row remain mandatory.

## Stop Conditions

- `vsi_task_row_missing`
- `vsi_task_dependency_not_ready`
- `vsi_task_write_scope_missing`
- `vsi_task_lock_conflict`
- `vsi_task_validator_missing`
- `human_translation_affects_agent_contract`
- `live_gate_packet_missing_required_fields`
- `secret_detected`
