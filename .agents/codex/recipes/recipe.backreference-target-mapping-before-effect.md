# Backreference Target Mapping Before Effect

## Purpose

Resolve the exact target for a processed queue item before any effectful action is admitted.

## Inputs

- processed queue item identity
- current governed order or complete system envelope
- promoted selector / binding
- exact candidate set
- rollback and postcheck contract

## Procedure

1. Consume the current envelope/order and promoted selector.
2. Resolve exact candidate identities without fuzzy matching.
3. Require exactly one admissible candidate for the requested target.
4. Preserve target identity, correlation and parent correlation.
5. If exactness is unresolved, return `BINDING_NOT_RESOLVED` or the narrower current gap.
6. If exactness is resolved, pass the exact target to the current governed action lane.
7. Record evidence and postcheck only for the material delta.

## Stop Conditions

- `candidate_count_not_one`
- `identity_field_missing`
- `rollback_missing`
- `postcheck_missing`
- `secret_detected`

## Output

`backreference_target_decision`
