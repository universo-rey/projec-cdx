# READBACK_CIERRE_PESO_REDUCIDO_20260617

## agente
Codex

## orden
Reducir el peso visible dejando un set minimo de superficies activas.

## superficie
`workbooks/` y `operativa/`

## skill
`delta-gobernado` + `governed-readback-closeout`

## receta
Recorte seguro de reconstruibles y mantenimiento de solo evidencia viva.

## tool
`git`, `Get-ChildItem`, `Remove-Item`

## estado
HECHO_VERIFICADO

## evidencia
- Workbook vigente: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`
- Evidencia viva: `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`
- Resumen corto: esta misma nota

## validador
- `git status --short --branch`
- `git diff --shortstat origin/main...HEAD`

## riesgo
Bajo.

## rollback
Volver a `codex/dataverse-corte-ejecutora-v1` o restablecer desde Git history.

## stop_condition
No arrastrar historico pesado a la rama liviana.

## proximos_carriles
`delta_select_next_consumer_from_dataverse_live_rows`
