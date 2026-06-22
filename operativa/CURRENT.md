# Current

Estado vivo resumido de `PROJEC CDX`.

## Fuente Maestra
- La secuencia completa vive en [CRONOLOGIA_MAESTRA_20260617.md](CRONOLOGIA_MAESTRA_20260617.md).

## Vigente
- Estado: `WORKBOOK_SURFACES_WORKSPACE_REFRESHED`.
- Consumidor aplicado: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](../workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx).
- Hojas nuevas: `Workspace Actual`, `Superficies Locales` y `Ramas Organizadas`.
- Evidencia viva: [DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json](DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json).
- Evidencia de binding: [READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md](READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md).
- Evidencia de superficies/workspace: [READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md](READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md).
- Evidencia de ramas: [READBACK_BRANCH_ORGANIZATION_20260618.md](READBACK_BRANCH_ORGANIZATION_20260618.md).
- Evidencia corta: [READBACK_CIERRE_PESO_REDUCIDO_20260617.md](READBACK_CIERRE_PESO_REDUCIDO_20260617.md).

## Regla
- Dataverse y los paquetes se consumen desde evidencia vigente antes de abrir una nueva preparacion.
- `D:\`, `CodexLocal` y `Documents\Codex*` son superficies con owner-gate.
- Si hace falta historia, abrir la cronologia maestra; no duplicarla aca.
