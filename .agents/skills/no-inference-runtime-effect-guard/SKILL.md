---
name: no-inference-runtime-effect-guard
description: Use when an effectful runtime action, target ambiguity, metadata change, or inferred target update must stop unless exact target identity is proven.
---

# No-Inference Runtime Effect Guard

## Core Rule

Effectful runtime actions cannot be inferred. Historical evidence, nearby names, fuzzy matches or probable intent do not select a target.

## Trigger Boundary

Use before target updates, back-reference effects, metadata changes, runtime activation effects, or any action where the exact target identity is not already proven.

## Allowed Actions

- count exact candidates
- record no-op or unresolved-target decisions
- create governed evidence for ambiguity
- proceed only when candidate count is exactly one and rollback/postcheck are present

## Blocked Actions

- fuzzy target selection
- nearest-row selection
- manual guess
- action because historical data merely suggests impact
- hiding ambiguity behind a mapping record

## Validator

Use the most specific target-exactness validator available. If none exists, emit the exact unresolved state and stop without inventing a target.

## Evidence

Candidate count, identity fields used, decision record, rollback, postcheck and stop condition.

## Stop Conditions

- `candidate_count_not_one`
- `rollback_missing`
- `postcheck_missing`
- `identity_field_missing`
- `secret_detected`
