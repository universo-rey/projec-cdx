---
name: dataverse-metadata-only-provisioning
description: Use when a Dataverse DEV metadata-only schema, seed, manifest, or postcheck package must be prepared or reviewed without secrets, PROD, TEST, Default, or blind writes.
---

# Dataverse Metadata-Only Provisioning

## Core Rule

Dataverse provisioning is safe only when the environment is exact, the payload
is metadata-only, rollback and postcheck are declared, and PROD/TEST/Default
are out of scope.

## Trigger Boundary

Use this skill for DEV Dataverse table metadata, seed manifests, drift reports,
postchecks, and rollback evidence. It does not authorize live apply by itself.

## Allowed Actions

- validate Dataverse manifests and seed CSVs
- prepare metadata-only apply evidence
- record drift and postcheck results
- document rollback by batch or metadata invalidation
- block unresolved target or environment ambiguity

## Blocked Actions

- PROD, TEST, or Default
- secrets, connection strings, personal data, or documents
- blind writes or inferred target updates
- flow activation
- OpenAI API or Batch API execution

## Validator

Use the Dataverse manifest validator when available, then the Change-Aware
Full-Coverage Orchestrator for repo gates.

## Evidence

Manifest, seed matrix, drift report, postcheck, rollback plan, PR checks.

## Stop Conditions

- `wrong_environment_or_default`
- `secret_detected`
- `rollback_missing`
- `postcheck_missing`
- `target_identity_ambiguous`
