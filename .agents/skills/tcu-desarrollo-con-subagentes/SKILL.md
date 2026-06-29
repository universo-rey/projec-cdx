---
name: tcu-desarrollo-con-subagentes
description: Use when a D:\ task needs subagent, parallel, lane, or lock key governance for delegated local work with owners, reviewers, validators, evidence, and stop conditions.
---

# TCU Desarrollo Con Subagentes

## Core Rule

Parallel or delegated work is allowed only when lanes have disjoint write
scopes and declare owner, reviewer, lock key, dependency, evidence, validator,
rollback, and stop condition.

## Trigger Boundary

Use for local task-scoped subagent planning or execution inside the current
Cabina Universal session. Do not use it for persistent remote agents unless a
governed order exists.

## Allowed Actions

- split independent local work into lanes
- assign owner and reviewer agents
- declare read scope, write scope, lock key, dependency, and validator
- fan in results into one readback or matrix

## Blocked Actions

- overlapping write scopes
- remote persistent agents without order
- Microsoft live, production, permissions, secrets, or OpenAI API live
- subagent dispatch without capability preflight

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools\local_validate_parallel_order_governance.ps1`
and `C:\CEO\project-cdx\.agents\codex\tools`.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Parallel lane matrix, owner/reviewer assignment, validator output, and fan-in
readback.

## Stop Conditions

- `lane_scope_overlap`
- `parallel_lane_without_validator`
- `autonomous_agent_order_missing`
- `capability_use_preflight_missing`


