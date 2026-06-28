---
name: tcu-redactor-planes-operativos
description: Use when a multi-step D:\ task needs a governed plan, order, rollback, or postcheck before execution, especially with live, repo, migration, or parallel risk.
---

# TCU Redactor Planes Operativos

## Core Rule

Plans must be executable, scoped, reversible, and validated. Do not let a plan
become permission for live writes, production, secrets, or broad data access.

## Trigger Boundary

Use when a task needs a written operational plan, migration preflight, live
order packet, or multi-lane execution design.

## Allowed Actions

- define objective, scope, owner, reviewer, surfaces, and stop conditions
- list exact files or surfaces to read and write
- define rollback, postcheck, evidence, and validator
- separate local draft work from governed live execution

## Blocked Actions

- moving clones without migration inventory
- GitHub writes without order
- Microsoft live, production, permission changes, secrets, or API live without
  exact governed order
- vague plans with no validator

## Validator

Use `D:\.agents\codex\tools\local_validate_order_packets.ps1`,
`D:\.agents\codex\tools\local_validate_operational_chain.ps1`, or the
surface-specific validator.

## Evidence

Plan packet, order matrix, rollback, postcheck, validator result, and readback.

## Stop Conditions

- `order_packet_missing_required_fields`
- `operational_chain_missing`
- `target_identity_ambiguous`
- `rollback_missing`
