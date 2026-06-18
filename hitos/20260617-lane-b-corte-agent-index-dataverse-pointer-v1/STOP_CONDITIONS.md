# Stop Conditions Como Deltas

- `target_identity_ambiguous`: resolver identidad exacta del target antes de escribir.
- `candidate_count_not_one`: reconciliar duplicado o ausencia por `canonical_id`.
- `secret_detected`: detener y sanear evidencia.
- `payload_or_document_required`: no escribir contenido documental; usar puntero.
- `rollback_missing`: no promover.
- `postcheck_missing`: no promover.
- `home_page_binding_pending`: queda como siguiente delta, no como bloqueo humano.
