# Despierta PROJEC CDX: Circuito Vivo

Snapshot liviano de la cabina.

## Entrada
- [Current](operativa/CURRENT.md)
- [Next](operativa/NEXT.md)
- [Trace](operativa/TRACE.md)

## Vigente
- Estado: `DATAVERSE_LIVE_ROWS_BOUND_TO_WORKBOOK`.
- Workbook: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx).
- Control operativo: [control_operativo.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx).
- Tracker: [tracker.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx).
- Evidencia Dataverse viva: [DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json](operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json).
- Evidencia de binding: [READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md](operativa/READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md).
- Evidencia corta: [READBACK_CIERRE_PESO_REDUCIDO_20260617.md](operativa/READBACK_CIERRE_PESO_REDUCIDO_20260617.md).

## Regla
- No rehidratar, no reempaquetar y no releer SGIN si ya existe evidencia vigente.
- Consumir el workbook y la cronologia maestra para decidir el proximo delta.
