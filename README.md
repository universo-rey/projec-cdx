# Despierta PROJEC CDX: Circuito Vivo

Snapshot liviano de la cabina.

## Launch Desk

- App de planificacion de lanzamientos: [launch-desk/MAPA.md](C:/Users/enzo1/PROJEC%20CDX/launch-desk/MAPA.md)

## Entrada
- [Current](operativa/CURRENT.md)
- [Next](operativa/NEXT.md)
- [Trace](operativa/TRACE.md)

## Vigente
- Estado: `WORKBOOK_SURFACES_WORKSPACE_REFRESHED`.
- Workbook: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx).
- Control operativo: [control_operativo.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx).
- Tracker: [tracker.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx).
- Evidencia Dataverse viva: [DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json](operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json).
- Evidencia de binding: [READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md](operativa/READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md).
- Evidencia superficies/workspace/ramas: [READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md](operativa/READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md), [READBACK_BRANCH_ORGANIZATION_20260618.md](operativa/READBACK_BRANCH_ORGANIZATION_20260618.md).
- Evidencia corta: [READBACK_CIERRE_PESO_REDUCIDO_20260617.md](operativa/READBACK_CIERRE_PESO_REDUCIDO_20260617.md).

## Regla
- No rehidratar, no reempaquetar y no releer SGIN si ya existe evidencia vigente.
- Consumir el workbook, `Workspace Actual` y `Superficies Locales` para decidir el proximo delta.
