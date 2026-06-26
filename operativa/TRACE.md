# Despierta Traza del Flujo

## Fuente Maestra
- La traza historica completa vive en [CRONOLOGIA_MAESTRA_20260617.md](archive/legacy-root/20260617/CRONOLOGIA_MAESTRA_20260617.md).
- La fuente rectora actual del maximo nivel alcanzado vive en [SDU_SYSTEM_CERTIFICATION.md](../docs/SDU_FINAL_PACKAGE/SDU_SYSTEM_CERTIFICATION.md).

## Cadena Actual
- Fuente: `docs/SDU_FINAL_PACKAGE/*` + `08_READBACKS/20260625_182615_SDU_G8_5_FINAL_NORMALIZATION.md` + `SDU_STATE_G10.md`.
- Proceso: promover el maximo nivel certificado a marcadores operativos locales.
- Salida: `operativa/CURRENT.md`, `operativa/NEXT.md`, `operativa/CONTROL.md`, `operativa/TRACE.md`, `VERSION_STATE.json` y `08_READBACKS/20260626_SDU_MAX_LEVEL_PROMOTION.md`.
- Hito fuente: paquete institucional SDU final.
- Cierre: `08_READBACKS/20260626_SDU_MAX_LEVEL_PROMOTION.md`.
- Etapa: `SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED_G10_BOUNDARY`.
- Siguiente delta: `G11_REVIEW_NO_APPLY` o `DOMAIN_SOURCE_CONTRACTS`, bajo owner gate.

## Regla
- Esta traza conserva el carril activo minimo y eleva solo estado local/documental.
- No rehidratar, reempaquetar, ejecutar live, limpiar residuales ni activar scheduler salvo orden explicita del owner.
- `docs/` certifica y orienta; `operativa/` gobierna; `C:\CEO\watchdog` conserva evidencia viva.
