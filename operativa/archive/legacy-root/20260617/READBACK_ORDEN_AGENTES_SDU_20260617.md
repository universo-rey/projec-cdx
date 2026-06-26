# READBACK_ORDEN_AGENTES_SDU_20260617

## Estado
HECHO_VERIFICADO: la configuracion vigente quedo al frente y fue asegurada en el orden SDU Seshat -> Thot -> Anubis -> Maat -> Horus -> Narrador.

## Sistemas tocados

- `README.md`
- `workbooks/README.md`
- `workbooks/EXCEL_AL_FRENTE.md`
- `workbooks/MAPA.md`
- `operativa/CONTROL.md`
- validadores locales del repo

## Sistemas no tocados

- Dataverse live writes: `NO`
- SharePoint live writes: `NO`
- Power Platform live writes: `NO`
- OpenAI API live: `NO`
- Secrets impresos: `NO`

## Cambios

- `CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx` quedo declarado como workbook de configuracion vigente.
- `workbooks/` ahora lo muestra al frente junto con `control_operativo.xlsx`, `inicio.xlsx` y `tracker.xlsx`.
- `operativa/CONTROL.md` lo incorpora como referencia unica de configuracion vigente.
- El roster SDU queda alineado con `MAPA_AGENTES_SDU.md` y su orden operativo: Seshat, Thot, Anubis, Maat, Horus, Narrador.

## Validacion

- `git diff --check` -> `PASS`
- `tools/validate_proj_cdx_workbench.ps1` -> `PASS`
- `tools/validate_proj_cdx_sync.ps1` -> `PASS`
- `tools/validate_proj_cdx_operational_chain.ps1` -> `PASS`

## Riesgos

- Riesgo bajo: la pasada fue solo de indices y documentacion.
- Queda un cambio previo sin tocar en `operativa/archive/legacy-root/20260617/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`.

## Rollback

- Revertir los enlaces nuevos en `README.md`, `workbooks/README.md`, `workbooks/EXCEL_AL_FRENTE.md`, `workbooks/MAPA.md` y `operativa/CONTROL.md`.

## Proximos carriles

- Refrescar el workbook si queres un timestamp nuevo.
- Abrir la superficie local y confirmar que el workbook vigente quede visible al frente.

## Ficha

- `agente`: `Narrador`
- `orden`: asegurar la superficie vigente con la secuencia SDU completa
- `superficie`: `README` + `workbooks` + `operativa/CONTROL.md`
- `skill`: `governed-readback-closeout`
- `receta`: `promocion_de_workbook_vigente_con_secuencia_sdu`
- `tool`: `apply_patch` + validadores locales del repo
- `estado`: `HECHO_VERIFICADO`
- `evidencia`: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`, `dataverse/MAPA_AGENTES_SDU.md`, `workbooks/README.md`
- `validador`: `PASS`
- `riesgo`: `BAJO`
- `rollback`: `revertir enlaces y referencias agregadas`
- `stop_condition`: `none`
- `proximos_carriles`: `refresh_workbook_or_open_browser_surface`
