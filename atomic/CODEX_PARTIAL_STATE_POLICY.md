# CODEX Partial State Policy

## Purpose

Define what Codex must do when an action does not complete cleanly and leaves residual state.

## Core Rule

Codex must not leave partial state ambiguous.

If partial state exists, it must be recorded, classified, and either reverted, compensated, or escalated.

## Required Partial State Report

When a failure or interruption occurs, record:

- `transaction_id`
- `action_id`
- target surface
- what applied successfully
- what failed
- what remains unknown
- whether rollback is safe
- whether compensation is available
- whether the surface is frozen

## Partial State Classification

### 1. No Residual State

The action failed before any mutation.

Terminal state: `FAILED_SAFE`

### 2. Reverted Residual State

The action partially applied but was fully rolled back.

Terminal state: `REVERTED`

### 3. Compensated Residual State

The action partially applied and was corrected through an explicit compensating action.

Terminal state: `DONE` or `REVERTED`, depending on the net effect

### 4. Frozen Residual State

The action partially applied and cannot be safely reverted or compensated immediately.

Terminal state: `ESCALATED`

## Mandatory Response to Partial State

If partial state is detected:

1. stop dependent actions
2. do not widen scope
3. record the residual delta
4. attempt rollback if safe
5. attempt compensation if rollback is unavailable
6. freeze the surface if neither is safe
7. escalate with evidence

## Freeze Rule

When a surface is frozen:

- no further writes are allowed on that surface
- the freeze reason must be recorded
- the next permitted step must be explicit

## Evidence Requirements

Every partial-state outcome must record:

- pre-state
- applied delta
- remaining delta
- validation result
- chosen terminal state

## Stop Conditions

Stop immediately if:

- the initial state cannot be verified
- the surface cannot be isolated
- the residual delta cannot be described
- rollback could cause more damage
- compensation is undefined

## Terminal Handling

Partial state is only acceptable if it ends in one of these outcomes:

- `REVERTED`
- `ESCALATED`
- `FAILED_SAFE`

No silent ambiguity.

