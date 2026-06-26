---
name: no-inference-runtime-write-guard
description: Use when a runtime write, metadata write, target ambiguity, or inferred target update must be blocked unless exact target identity is proven.
---

# No-Inference Runtime Write Guard

## Core Rule

Runtime writes cannot be inferred. Historical evidence, nearby names, fuzzy
matches, or probable intent do not authorize a write target.

## Trigger Boundary

Use this before target updates, back-reference writes, live metadata changes,
runtime activation effects, or any operation where the exact target identity is
not already proven.

## Allowed Actions

- count exact candidates
- record no-write decisions
- create local evidence for ambiguity
- allow a write only when candidate count is exactly one and rollback/postcheck
  are present

## Blocked Actions

- fuzzy target write
- nearest-row write
- manual guess
- write because historical data suggests impact
- hiding ambiguity behind a mapping record

## Validator

Use the most specific target exactness validator available. If none exists,
write a local decision matrix and block the write.

## Evidence

Candidate count, identity fields used, decision matrix, rollback, postcheck and
stop condition.

## Stop Conditions

- `candidate_count_not_one`
- `rollback_missing`
- `postcheck_missing`
- `identity_field_missing`
- `secret_detected`
