# Despierta PROJEC CDX: Circuito Vivo
![meta-validate](https://github.com/universo-rey/projec-cdx/actions/workflows/meta-validate.yml/badge.svg?branch=main)

Entrada corta de la cabina.

## Frontdoor vivo 20260623

```text
estado: CABINA_FRONTDOOR_CONVERGED_LOCAL_ONLY
version: v0.6.0-rc1
workspace canonico: C:\CEO\project-cdx
alias fisico: C:\Users\enzo1\PROJEC CDX
regla: una raiz viva, sin SDU_RUNTIME_ROOT paralelo
```

## Puertas

- Navegacion: [MAPA_MAESTRO.md](MAPA_MAESTRO.md)
- Sistema nervioso: [MAPA_CAPAS.md](MAPA_CAPAS.md)
- Canon vivo: [operativa/CURRENT.md](operativa/CURRENT.md), [operativa/NEXT.md](operativa/NEXT.md), [operativa/TRACE.md](operativa/TRACE.md)
- Runtime/cabina: [.cabina/SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md](.cabina/SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md)
- Organismo vivo: [.cabina/SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md](.cabina/SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md)
- Versionado continuo: [VERSION_STATE.json](VERSION_STATE.json), [VERSION_POLICY.md](VERSION_POLICY.md)
- Evidencia versionada: [hitos/INDICE_MAESTRO.md](hitos/INDICE_MAESTRO.md)

## Regla de convergencia

```text
README.md        -> entrada humana corta
MAPA_MAESTRO.md  -> navegacion viva unica
MAPA_CAPAS.md    -> sistema nervioso y capas
operativa/       -> canon vivo y decisiones finales
.cabina/SDU_RUNTIME_ROOT -> runtime canonico, VS Code Insiders y organismo vivo
hitos/outputs    -> historia y salidas, no frente principal
work/            -> scratch/backups
```

`.cabina/organizacion-total` y `C:\CEO\project-cdx\SDU_RUNTIME_ROOT` quedan como rutas historicas o de paquete fuente; no son superficies activas.

## Launch Desk

- App de planificacion de lanzamientos: [launch-desk/MAPA.md](launch-desk/MAPA.md)

## Entrada
- [Current](operativa/CURRENT.md)
- [Next](operativa/NEXT.md)
- [Trace](operativa/TRACE.md)

## Vigente
- Estado vigente de esta puerta: `CABINA_FRONTDOOR_CONVERGED_LOCAL_ONLY`.
- Estado historico anterior: `WORKBOOK_SURFACES_WORKSPACE_REFRESHED`.
- Workbook: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx).
- Control operativo: [control_operativo.xlsx](workbooks/control_operativo.xlsx).
- Tracker: [tracker.xlsx](workbooks/tracker.xlsx).
- Evidencia historica: `HOLD_ARCHIVE_REVIEW` hasta reconciliar `operativa/archive`.
- Evidencia versionada vigente: [hitos/INDICE_MAESTRO.md](hitos/INDICE_MAESTRO.md).

## Regla
- No rehidratar, no reempaquetar y no releer SGIN si ya existe evidencia vigente.
- Consumir el workbook, `Workspace Actual` y `Superficies Locales` para decidir el proximo delta.

## Indices canonicos

Este repositorio usa indices canonicos como entrada al SNS y para recuperacion por herramientas locales:

- `schema.json`: contrato de indice/procedencia (artifact_id, categoria, tipo, estado, origen, trazabilidad).
- Front matter YAML en Markdown (`--- ... ---`).
- Archivos hermanos `*.meta.json` para CSV/JSON.
- `index.json` y `operativa/index.json` como catalogos generados.
- `live-manifest.json` para artefactos `aprobado|live`.
- `SYSTEM_NERVOUS_INDEX.json` como fuente operativa obligatoria del sistema nervioso.

Nota de canon: `metadata_source` y `metadata_kind` siguen existiendo como campos de procedencia tecnica, pero ya no nombran la superficie operativa.

Convencion de `artifact_id`:

- Markdown (`.md`): `artifact_id` con extension (ej. `operativa/MAPA.md`).
- Datasets (`.csv`/`.json` con `*.meta.json`): `artifact_id` sin extension (ej. `operativa/BRANCH_ORGANIZATION_20260618`).

Comandos principales:

- `python main.py validate`
- `python main.py build-index`
- `python -m tools.validate`
- `python -m tools.build_index`

Promocion de estado (actualiza `live-manifest.json`):

- `python main.py promote <artifact_id> <borrador|en_revision|aprobado|live>`

## CLI cloud + indices

La CLI de cloud y la de indices conviven:

- Cloud: `projec-cdx-cloud ...` (entrypoint actual de cloud).
- Indices por modulo: `python -m tools.validate` y `python -m tools.build_index`.
- Indices unificados: `python main.py validate|build-index|graph|promote ...` o `cdx validate|build-index|graph|promote ...`. [1] [2]
