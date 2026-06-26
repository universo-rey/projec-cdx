---
name: sdu-ejecutor-gates
description: Use when executing or closing SDU gates in D:\ with canon, evidence, validator, rollback, and one formal outcome.
---

# SDU Ejecutor Gates

## Core Rule

Every SDU gate closes in one formal outcome: `NO_OP_LISTO`,
`DELTA_APLICADO`, `BLOQUEADO_CON_CAUSA_REAL`, or
`REQUIERE_REVISION_HUMANA`.

## Trigger Boundary

Use when a request mentions SDU gates, execution queues, frontiers, gate
closure, or canonical decision packets in the Cabina Universal.

## Allowed Actions

- read local canon, queue, readback, and validator evidence
- decide whether a gate is local-only or requires governed live order
- update local draft evidence when ordered
- declare outcome, risk, rollback, and next lane

## Blocked Actions

- simulating live evidence
- Microsoft live writes without exact order
- production, permissions, secrets, OpenAI API live, or broad regulated data
- closing a gate without validator evidence

## Validator

Use `D:\.agents\codex\tools\local_validate_order_packets.ps1`,
`D:\.agents\codex\tools\local_validate_operational_chain.ps1`, and any
surface-specific validator.

## Evidence

Gate packet, queue state, validator output, readback, rollback, and postcheck.

## Stop Conditions

- `order_packet_missing_required_fields`
- `validator_failed`
- `target_identity_ambiguous`
- `human_review_required`
