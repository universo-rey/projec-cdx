# Readback Branch Organization 20260618

- Workbook: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`
- Sheet: `Ramas Organizadas`
- Scope: ramas locales del repo actual `universo-rey/projec-cdx`
- Data rows: `6`
- Clasificacion:
  - `ACTIVA`: `1`
  - `CANON`: `1`
  - `WORKTREE`: `1`
  - `PARALELA`: `3`

## Lectura

La hoja nueva deja la organizacion de ramas dentro del workbook:

- `main` queda como `CANON`
- `codex/consume-bound-workbook-next-delta` queda como `ACTIVA`
- `codex/revisar-procesos-del-equipo` queda como `WORKTREE`
- `codex/cloud-setup-ui-v1`, `codex/dataverse-corte-ejecutora-v1` y `codex/wave-mapas-uniformes-v1` quedan como `PARALELA`

## Validacion

- `py_compile`: PASS
- Regeneracion workbook: PASS
- `Ramas Organizadas`: PASS
- `Navegacion`: PASS
- `Validacion`: PASS

## Rollback

- Revertir `tools/update_codex_config_workbook.py`
- Restaurar el backup del workbook generado en esta pasada si hiciera falta
