---
name: dataverse-workqueue-backreference-mapping
description: Use when a processed Dataverse Work Queue item needs deterministic metadata-only back-reference mapping and target writes must be blocked unless exact target identity is proven.
---

# Dataverse Work Queue Backreference Mapping

## Core Rule

A target back-reference update requires exactly one deterministic target
candidate. If candidate count is 0 or greater than 1, do not update the target.

## Trigger Boundary

Use this for processed Work Queue items with canonical id, correlation id,
idempotency key, batch id, and metadata-only payloads.

## Allowed Actions

- extract deterministic queue item keys
- search exact target candidates from evidence or an authorized DEV order
- create metadata-only mapping evidence when target final is unresolved
- block fuzzy, partial, nearest-row, or manual-guess writes
- document rollback and postcheck

## Blocked Actions

- target write when candidate count is not exactly 1
- fuzzy matching as authority
- PROD, TEST, Default
- flow activation or new item processing without exact order
- secrets, personal data, documents, SharePoint, Planner, broad Graph

## Validator

Use `local_validate_backreference_runtime_closure.ps1` for current PR68
evidence and extend with exactness validators before wider propagation.

## Evidence

Target candidate matrix, mapping write result, safe-state postcheck, rollback
plan and readback.

## Stop Conditions

- `candidate_count_not_one`
- `target_identity_ambiguous`
- `mapping_key_missing`
- `secret_detected`
- `wrong_environment_or_default`
