# CODEX Idempotency Policy

## Purpose

Define how Codex re-runs actions without duplicating work, corrupting state, or creating hidden drift.

## Core Rule

Every atomic action must be safe to re-run unless it explicitly declares otherwise.

## Minimum Requirements

An action is idempotent only if it can declare:

- a stable `action_id`
- a stable `transaction_id`
- a stable `target_surface`
- a stable identity rule for the resource being touched
- a reconcile-before-create rule
- a no-op condition when the desired state already exists
- a conflict detection rule
- a replay-safe validation rule

## Idempotency Patterns

### 1. Reconcile Before Create

Check whether the target already exists before creating anything new.

Use this when the surface can contain duplicates or equivalent entities.

### 2. Update by Stable Identity

Prefer immutable IDs, canonical keys, or explicit markers over display names.

### 3. No-Op on Desired State

If the target already matches the expected state, declare `NOOP` and record evidence.

### 4. Replace by Snapshot

When a file or matrix must be rewritten, overwrite from a known snapshot instead of appending blindly.

### 5. Compensate Instead of Duplicate

If a prior action partially applied, compensate or revert before re-applying.

## Replay Rules

On re-run:

1. verify current state
2. compare against expected state
3. decide `NOOP`, `APPLY`, `REVERTED`, or `BLOCKED`
4. never assume the previous run succeeded

## Conflict Rules

If identity is ambiguous or the surface has concurrent drift:

- do not create a second copy
- do not overwrite silently
- do not promote
- block or escalate with evidence

## Evidence Requirements

Each idempotent action must leave evidence showing:

- the target identity
- the pre-state
- the chosen decision path
- the final state

## Non-Idempotent Cases

If true idempotency is impossible, the action must explicitly declare:

- why it is not idempotent
- how duplicates are prevented
- what rollback or compensation exists
- how the state is validated after execution

