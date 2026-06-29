---
name: rey-modo-evidencia-riesgo-handoff
description: Use when Cabina Universal work needs evidence, risk, rollback, touched-surface, or handoff closeout under D:\AGENTS.md without live writes.
---

# Rey Modo Evidencia Riesgo Handoff

## Core Rule

Close work with evidence, risk, rollback, touched surfaces, validator result,
and one next lane. Do not turn a documentary closeout into live execution.

## Trigger Boundary

Use this when a task needs a readback, handoff, evidence register, risk note,
or continuity package for D-drive cabina work.

## Allowed Actions

- read local evidence, matrices, readbacks, PR metadata, and validator output
- separate verified fact, assumption, risk, and pending action
- record systems touched and systems not touched
- prepare local readback or handoff artifacts when ordered

## Blocked Actions

- Microsoft live writes
- production
- permission changes
- OpenAI API live
- secrets or regulated data dumps
- declaring partial work complete

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools\local_validate_agent_layer.ps1` and the specific
validator for the surface being closed.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Readback, validator output, diff summary, PR or issue metadata, and rollback
statement when changes were made.

## Stop Conditions

- `unverified_completion`
- `secret_detected`
- `rollback_missing`
- `validator_failed`

