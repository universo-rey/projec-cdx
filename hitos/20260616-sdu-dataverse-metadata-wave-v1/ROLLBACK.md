# Rollback

## Estado Actual

No hubo writes vivos. El rollback actual consiste en retirar o archivar este paquete antes de cualquier apply futuro.

## Si Se Aplica En El Futuro

1. Buscar cada fila por `canonical_id`.
2. Confirmar candidate count exacto.
3. Marcar la fila como retirada o revertida por batch.
4. Ejecutar postcheck read-only por canonical id.
5. Registrar evidencia de rollback sin borrar fisicamente salvo orden separada.
