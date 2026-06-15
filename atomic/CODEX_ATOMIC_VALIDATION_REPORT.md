# CODEX Atomic Validation Report

**Gate:** `GATE_CODEX_ATOMIC_OPERATING_MACHINE_V2`  
**Final state:** `CODEX_ATOMIC_OPERATING_MACHINE_READY`

## Report Metadata

- `transaction_id`: `TX-0001`
- `action_id`: `ACT-0001`
- `objective`: ``
- `target_surface`: ``
- `report_date`: ``
- `report_owner`: `codex.atomic_operating_machine`

## Validation Checklist

### 1. Identity

- `action_id` verified
- `transaction_id` verified
- `target_surface` verified

### 2. Precheck

- surface verified
- permissions verified
- dependencies verified
- concurrency verified
- minimum viability verified

### 3. Plan

- objective declared
- expected output declared
- rollback or compensation declared
- idempotency rule declared
- stop condition declared

### 4. Apply

- minimum unit executed only
- no undeclared batch mutation
- no hidden side effects

### 5. Verify

- real state checked
- delta checked
- idempotency checked
- integrity checked
- conflict check completed

### 6. Evidence

- command output captured
- artifact hashes or paths captured
- readback captured
- no secrets included

### 7. Terminal State

- one terminal state declared
- no ambiguous closure
- no partial state left unclassified

## Validation Result

- `status`: ``
- `terminal_state`: ``
- `summary`: ``

## Evidence Log

| Item | Detail |
| --- | --- |
| pre_state |  |
| post_state |  |
| delta |  |
| validation_notes |  |
| residual_risks |  |
| references |  |

## Rollback / Compensation

- `rollback_or_compensation`: ``
- `applied`: `false`
- `notes`: ``

## Idempotency Review

- `idempotent`: `false`
- `rule`: ``
- `replay_outcome`: ``

## Final Decision

- `DONE`
- `NOOP`
- `BLOCKED`
- `REVERTED`
- `ESCALATED`
- `FAILED_SAFE`

Selected: ``

