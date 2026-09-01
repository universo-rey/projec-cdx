# Mapping Record Before Target Effect

## Purpose

Materialize deterministic source-to-target identity evidence before an exact-target action proceeds.

## Inputs

- deterministic queue keys
- current governed object/order
- source identity
- candidate target identity
- correlation identifiers

## Procedure

1. Consume the current binding and exact source keys.
2. Produce a mapping record with deterministic identity fields.
3. Reject guessed, nearest-name or fuzzy target selection.
4. Link the mapping record to the current order and evidence chain.
5. Run the exact postcheck.
6. Return the mapping evidence and next cursor.

## Stop Conditions

- `missing_keys_or_target_guess`
- `candidate_count_not_one`
- `identity_field_missing`
- `secret_detected`

## Output

`mapping_record_evidence`
