# Next

Movimiento unico:
`delta_consume_bound_workbook_for_next_governed_decision`

## Etapa Actual
- `DATAVERSE_LIVE_ROWS_BOUND_TO_WORKBOOK`.

## Consumidor Aplicado
- `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`.
- Hoja: `Dataverse Fuentes`.
- Fila viva: `DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED`.

## Regla Anti-Ruido
- No rehidratar Dataverse otra vez.
- No reempaquetar paquetes ya existentes.
- No releer SGIN por inercia.
- Si hace falta historia, abrir `operativa/CRONOLOGIA_MAESTRA_20260617.md`.

## Proximo Movimiento
Consumir el workbook vigente como superficie de decision para el siguiente delta gobernado, con target, owner, rollback, postcheck y evidencia.
