# READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618

## Orden
Actualizar el workbook vigente incorporando la consola local `D:\`, el workspace actual y las superficies locales similares de Codex.

## Superficie
- `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`
- `tools/update_codex_config_workbook.py`

## Estado
HECHO_VERIFICADO

## Cambios
- Agregada hoja `Workspace Actual`.
- Agregada hoja `Superficies Locales`.
- Actualizado el builder para regenerar esas hojas de forma idempotente.
- Corregida la lectura de `D:\` como consola rectora gobernada/carril 0.
- Conservado el binding Dataverse en `Dataverse Fuentes`.

## Evidencia
- Workbook regenerado con `55` hojas.
- `Workspace Actual` contiene `22` filas.
- `Superficies Locales` contiene `8` superficies modeladas.
- `Dataverse Fuentes` conserva `1` fila `DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED`.
- Resumen CSV: `operativa/archive/legacy-root/20260618/WORKBOOK_SUPERFICIES_WORKSPACE_20260618.csv`.

## Validadores
- `tools/validate_proj_cdx_workbench.ps1`: PASS.
- `tools/validate_proj_cdx_sync.ps1`: PASS.
- `tools/validate_proj_cdx_operational_chain.ps1`: PASS.

## Rollback
Restaurar el backup:
`workbooks/_backups/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617_before_update_20260618_004636.xlsx`

## Stop Condition
No mover ni borrar `D:\`, `Documents\CodexLocal`, `Documents\Codex`, `Documents\CodexArchives` ni `CodexLocal` desde este delta.

## Proximo Delta
`delta_normalize_codexlocal_live_entrypoint`
