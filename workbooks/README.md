# Workbooks

Libros de trabajo visibles de `PROJEC CDX`.

La wave visible mas reciente queda absorbida en [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

La cobertura atomica energetica entra cuando el workbook representa una superficie gobernada.

- [MAPA.md](C:/Users/enzo1/PROJEC%20CDX/workbooks/MAPA.md)
- [EXCEL_AL_FRENTE.md](C:/Users/enzo1/PROJEC%20CDX/workbooks/EXCEL_AL_FRENTE.md)

## Contenido

- [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx)
- [RESOLUCION_WORKBOOKS_20260615.md](C:/Users/enzo1/PROJEC%20CDX/workbooks/RESOLUCION_WORKBOOKS_20260615.md)
- [control_operativo.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx)
- [inicio.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/inicio.xlsx)
- [tracker.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx)

## Nota

`CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx` es el workbook de configuracion vigente: consolida global state, agentes, entornos, colas, conexiones y fuentes Dataverse.
Desde `DATAVERSE_LIVE_ROWS_BOUND_TO_WORKBOOK`, este workbook contiene la decision `DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED` en la hoja `Dataverse Fuentes`.
`control_operativo.xlsx` se regenera desde `tools/build_control_workbook.mjs` leyendo `operativa/`, `dataverse/GATE.md`, `dataverse/REGISTRO_BLOQUEOS.md`, `playbooks/07-dataverse-fronteras.md`, `hitos/20260615-hilo-origen-v1/README.md`, `operativa/ACTA_SEMAFORO_VERDE_HISTORICOS_20260615.md` y `outputs/live_repo_review_20260615/READBACK.md`. Los artefactos generados equivalentes viven en `outputs/` por fecha y corrida.
