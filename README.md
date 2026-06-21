# Despierta PROJEC CDX: Circuito Vivo

Snapshot liviano de la cabina.

## Launch Desk

- App de planificacion de lanzamientos: [launch-desk/MAPA.md](launch-desk/MAPA.md)

## Entrada
- [Current](operativa/CURRENT.md)
- [Next](operativa/NEXT.md)
- [Trace](operativa/TRACE.md)

## Vigente
- Estado: `WORKBOOK_SURFACES_WORKSPACE_REFRESHED`.
- Workbook: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx).
- Control operativo: [control_operativo.xlsx](workbooks/control_operativo.xlsx).
- Tracker: [tracker.xlsx](workbooks/tracker.xlsx).
- Evidencia Dataverse viva: [DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json](operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json).
- Evidencia de binding: [READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md](operativa/READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md).
- Evidencia superficies/workspace/ramas: [READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md](operativa/READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md), [READBACK_BRANCH_ORGANIZATION_20260618.md](operativa/READBACK_BRANCH_ORGANIZATION_20260618.md).
- Evidencia corta: [READBACK_CIERRE_PESO_REDUCIDO_20260617.md](operativa/READBACK_CIERRE_PESO_REDUCIDO_20260617.md).

## Regla
- No rehidratar, no reempaquetar y no releer SGIN si ya existe evidencia vigente.
- Consumir el workbook, `Workspace Actual` y `Superficies Locales` para decidir el proximo delta.

## Metadatos canonicos

Este repositorio ahora usa metadatos canonicos para recuperacion por Copilot:

- `schema.json`: contrato de metadatos (artifact_id, categoria, tipo, estado, origen, trazabilidad).
- Front matter YAML en Markdown (`--- ... ---`).
- Archivos hermanos `*.meta.json` para CSV/JSON.
- `index.json` y `operativa/index.json` como catalogos generados.
- `live-manifest.json` para artefactos `aprobado|live`.

Convencion de `artifact_id`:

- Markdown (`.md`): `artifact_id` **con extension** (ej. `operativa/MAPA.md`).
- Datasets (`.csv`/`.json` con `*.meta.json`): `artifact_id` **sin extension** (ej. `operativa/BRANCH_ORGANIZATION_20260618`).

Comandos principales:

- `python main.py validate`
- `python main.py build-index`
- `python -m tools.validate`
- `python -m tools.build_index`

Promocion de estado (actualiza `live-manifest.json`):

- `python main.py promote <artifact_id> <borrador|en_revision|aprobado|live>`

## CLI cloud + metadata

La CLI de cloud y la de metadata conviven:

- Cloud: `projec-cdx-cloud ...` (entrypoint actual de cloud).
- Metadata por modulo: `python -m tools.validate` y `python -m tools.build_index`.
- Metadata unificada: `python main.py validate|build-index|graph|promote ...` o `cdx validate|build-index|graph|promote ...`.
