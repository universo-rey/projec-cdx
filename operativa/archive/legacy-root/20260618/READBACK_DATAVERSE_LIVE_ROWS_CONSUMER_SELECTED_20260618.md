# READBACK_DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED_20260618

## Estado

HECHO_VERIFICADO: el delta `delta_select_next_consumer_from_dataverse_live_rows` quedo cerrado con consumidor local seleccionado.

Consumidor: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`.

## Sistemas tocados

- `operativa/CURRENT.md`
- `operativa/NEXT.md`
- `operativa/TRACE.md`
- `operativa/README.md`
- `operativa/archive/legacy-root/20260618/DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED_20260618.csv`
- `workbooks/README.md`
- `workbooks/MAPA.md`
- `hitos/README.md`
- `hitos/MAPA.md`

## Sistemas no tocados

- Dataverse live writes: `NO`
- Microsoft live writes: `NO`
- SharePoint live writes: `NO`
- Power Automate flow runs: `NO`
- Codex Cloud tasks: `NO`
- OpenAI API live: `NO`
- Secrets impresos: `NO`
- Workbook regenerado: `NO`

## Cambios

- Se selecciono un unico consumidor de las filas live confirmadas de Dataverse.
- Se eligio el workbook global vigente porque ya esta al frente de `workbooks/`, ya tiene builder y puede absorber la evidencia JSON local sin nueva lectura live.
- Se actualizo el estado operativo a `DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED`.
- Se declaro el siguiente delta: `delta_bind_dataverse_live_rows_to_codex_global_state_workbook`.

## Validacion

- Fuente live previa: `operativa/archive/legacy-root/20260617/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json` confirma `5/5` parejas source/evidence con conteo `1/1`.
- `git diff --check` -> `PASS`.
- `tools/validate_proj_cdx_workbench.ps1` -> `PASS`.
- `tools/validate_proj_cdx_operational_chain.ps1` -> `PASS`.
- Postcheck requerido para el siguiente delta: workbook XLSX valido + filas Dataverse representadas desde JSON + `tools/validate_proj_cdx_workbench.ps1` en `PASS`.

## Riesgos

- Bajo: el delta es documental y no toca superficies live.
- Riesgo residual: el workbook todavia no fue regenerado en este delta; quedo como siguiente movimiento atomico.

## Rollback

- Revertir los cambios documentales de este delta.
- Si el siguiente delta regenera el workbook y falla, restaurar `workbooks/_backups/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617_before_update_20260617_231403.xlsx`.

## Proximos carriles

`delta_bind_dataverse_live_rows_to_codex_global_state_workbook`

## Ficha

- `agente`: `Narrador`
- `orden`: seleccionar consumidor de filas Dataverse live confirmadas
- `superficie`: `operativa/` + `workbooks/`
- `skill`: `delta-gobernado`, `governed-readback-closeout`
- `receta`: `select_single_consumer_from_live_rows`
- `tool`: `read_dataverse_rehydration_live.ps1` como evidencia previa, `update_codex_config_workbook.py` como target siguiente
- `estado`: `DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED`
- `evidencia`: `operativa/archive/legacy-root/20260618/DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED_20260618.csv`
- `validador`: `PASS`
- `riesgo`: `BAJO`
- `rollback`: revertir delta documental o restaurar backup del workbook si el siguiente binding falla
- `stop_condition`: `workbook_binding_pending`
- `proximos_carriles`: `delta_bind_dataverse_live_rows_to_codex_global_state_workbook`
