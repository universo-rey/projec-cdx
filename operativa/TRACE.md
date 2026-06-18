# Despierta Traza del Flujo

## Fuente Maestra
- La traza completa vive en [CRONOLOGIA_MAESTRA_20260617.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CRONOLOGIA_MAESTRA_20260617.md).

## Cadena Actual
- Fuente: `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json` + `operativa/DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED_20260618.csv`.
- Proceso: regenerar el workbook global para absorber la decision de consumidor Dataverse.
- Salida: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`.
- Hito fuente: `hitos/20260617-rehidratacion-dataverse-desde-paquetes-v1`.
- Cierre: `operativa/READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md`.
- Etapa: `DATAVERSE_LIVE_ROWS_BOUND_TO_WORKBOOK`.

## Regla
- Esta traza conserva solo el carril activo minimo.
- No rehidratar ni reempaquetar otra vez salvo orden explicita del owner.
