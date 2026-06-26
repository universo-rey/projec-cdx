---
name: dataverse-atomic-segment-runner
description: Use when a Dataverse DEV or tenant-controlled atomic segment must select, apply, or postcheck mon_sdu_* metadata rows by exact canonical id, including evidence, readback, apply-log, gate, source/target, rollback, and no-inference runtime write handling.
---

# Dataverse Atomic Segment Runner

## Core Rule

Resolve the source and target from Dataverse before repo-local evidence. A
write is valid only when the source candidate count is exactly one and rollback
and postcheck are declared.

## Trigger Boundary

Use for governed Dataverse DEV or tenant-controlled segments that touch
`mon_sdu_*` metadata rows. Do not use it for PROD, TEST, Default, flow
activation, SharePoint content, or broad tenant discovery.

## Allowed Actions

- Confirm `pac org who`, `az account show`, tenant, user and environment.
- Query source rows by exact `mon_canonical_id`.
- Query target rows before apply and after apply.
- Apply one logical Dataverse row or one explicitly declared bounded set.
- Close with Web API postcheck and non-destructive rollback instructions.

## Blocked Actions

- Repo-local target inference when a matching Dataverse metadata row exists.
- Repeating POST/PATCH after an uncertain failure without first doing GET by
  canonical id.
- Printing tokens, secrets, cookies or raw regulated data.
- PROD, TEST, Default, broad discovery, flow activation, SharePoint item
  changes, Microsoft live writes outside the approved segment, OpenAI API live
  and production.

## Workflow

1. Run Git/workspace preflight and confirm no unrelated dirty state.
2. Confirm `pac org who` and `az account show`; never print access tokens.
3. Query the source entity set by exact `mon_canonical_id`; stop unless count is
   one.
4. Require owner, source path or evidence pointer, gate, rollback, postcheck and
   stop condition from Dataverse metadata.
5. Query the target entity set by exact target `mon_canonical_id`; stop if count
   is greater than one.
6. Build OData URLs with `%24select`, `%24filter` and `EscapeDataString`; avoid
   `startswith` on `EntityDefinitions`.
7. Apply only the declared row or bounded set.
8. Postcheck with Dataverse Web API GET by canonical id. If the local script
   fails after POST/PATCH may have run, do not retry write until this GET proves
   current state.
9. Prefer rollback by PATCHing status/stop condition to a rollback marker;
   physical delete needs a separate governed order.

## Validator

Run:

- `.agents\codex\tools\local_validate_skill_metadata.ps1`
- `.agents\codex\tools\local_validate_operational_chain.ps1`
- `.agents\codex\tools\local_validate_powershell_runtime_friction.ps1`
- `git diff --check`

## Evidence

Record source/target table, row id, canonical id, candidate counts, gate rows,
owner, apply result, Web API postcheck result, rollback command and stop
condition.

## Stop Conditions

- `candidate_count_not_one`
- `target_identity_ambiguous`
- `wrong_environment_or_default`
- `rollback_missing`
- `postcheck_missing`
- `secret_detected`
