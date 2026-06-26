---
name: parallel-order-governance
description: Use when parallel agents, subagents, order preparation, lock keys, local OpenAI design, or lane governance must be coordinated in D-drive.
---

# Parallel Order Governance

## Core Rule

Parallel work is allowed only when each lane has a named owner, reviewer,
disjoint write scope, lock key, declared evidence, validator, and stop
condition. Any live, production, permission, secret, cost, or broad
regulated-data surface becomes an order preparation task, not an execution
task.

## Trigger Boundary

Use this skill for local D-drive parallel lane design, subagent coordination,
order packet preparation, lock-key assignment, and OpenAI-local design planning.
It does not authorize Microsoft live, OpenAI API live, production, permissions,
or persistent remote agents.

## Allowed Actions

- Classify lanes as blocking, sidecar, serial, or forbidden.
- Assign `lead_agent`, `owner_agent`, `reviewer_agent`, read scope, write scope,
  `lock_key`, dependency, `max_parallel`, evidence, validator, and stop
  condition.
- Prepare governed order packets for live or production surfaces.
- Dispatch independent local reads and validations when file sets do not
  overlap.
- Integrate results through a single owner and validate before closeout.

## Blocked Actions

- `microsoft_live`
- `openai_api_live`
- `production`
- `secrets`
- Self-approval for live, production, permission, cost, or tenant action.
- Shared writes without a serial integration lane.

## Required Sequence

1. Read `.agents\codex\matrices\PARALLEL_OPERATION_CRITERIA_MATRIX.csv`.
2. Read `.agents\codex\matrices\ORDER_PREPARATION_ASSIGNMENT_MATRIX.csv`.
3. Declare `lead_agent`, `owner_agent`, `reviewer_agent`, `read_scope`,
   `write_scope`, `lock_key`, `dependency`, `max_parallel`, evidence,
   validator, and stop condition.
4. Select recipe: parallel operation, governed order preparation, or OpenAI
   local design.
5. Dispatch only sidecar lanes that can finish without blocking the main path.
6. Integrate results through the owner agent and validate before closeout.

## Quick Reference

| Surface | Allowed | Required stop |
| --- | --- | --- |
| Read-only scouting | independent questions | `parallel_lane_without_validator` |
| Shared file family | serialize by `lock_key` | `lane_scope_overlap` |
| Live, API, cost, permission, production | prepare order packet | `order_packet_missing_required_fields` |
| OpenAI design | local prompts, docs, synthetic evals | `openai_api_live_requested_without_order` |

## Validator

Run:

```powershell
.agents\codex\tools\local_validate_parallel_order_governance.ps1
.agents\codex\tools\local_validate_skill_metadata.ps1
```

If a named validator is not available, record it as `NO_DISPONIBLE` and run the
closest local validator that covers the same matrix.

## Stop Conditions

- Same file set assigned to multiple workers without a serial owner.
- Agent can approve its own live, production, permission, or tenant action.
- Order lacks rollback, postcheck, evidence, validator, or stop condition.
- OpenAI API, Microsoft live, production, cost, or permission is treated as
  already open.
- Parallel lane has no validator or stop condition.

## Output Contract

Every closeout must include `agente`, `orden`, `superficie`, `skill`,
`receta`, `tool`, `estado`, `evidencia`, `validador`, `riesgo`, `rollback`,
`stop_condition`, and `proximos_carriles`.
