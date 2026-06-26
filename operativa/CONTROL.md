# Control

Estado compacto para continuar sin arrastrar historico pesado.

## Desde Aca Se Controla Todo
- Identidad operativa: `CEO`; perfil fisico/ruta tecnica: `C:/Users/enzo1`.
- Estado vivo: [CURRENT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CURRENT.md)
- Siguiente paso: [NEXT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/NEXT.md)
- Trazabilidad: [TRACE.md](C:/Users/enzo1/PROJEC%20CDX/operativa/TRACE.md)
- Certificacion SDU: [SDU_SYSTEM_CERTIFICATION.md](C:/Users/enzo1/PROJEC%20CDX/docs/SDU_FINAL_PACKAGE/SDU_SYSTEM_CERTIFICATION.md)
- Contrato SDU: [SDU_CONTRACT_FORMAL.md](C:/Users/enzo1/PROJEC%20CDX/docs/SDU_FINAL_PACKAGE/SDU_CONTRACT_FORMAL.md)
- Estado G10: [SDU_STATE_G10.md](C:/Users/enzo1/PROJEC%20CDX/SDU_STATE_G10.md)
- Evidencia corta: [READBACK_CIERRE_PESO_REDUCIDO_20260617.md](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/20260617/READBACK_CIERRE_PESO_REDUCIDO_20260617.md)
- Workbook vigente: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx)
- Hitos: [INDICE_MAESTRO.md](C:/Users/enzo1/PROJEC%20CDX/hitos/INDICE_MAESTRO.md)

## Regla Atomica
Una sola unidad activa por vez:

1. declarar el trabajo en `NEXT.md`
2. moverlo a `CURRENT.md`
3. ejecutar con receta o tool gobernada
4. registrar salida en workbook o evidencia corta
5. cerrar en `TRACE.md`
6. versionar en `hitos/` solo si no existe paquete vigente
7. validar con `tools/validate_proj_cdx_workbench.ps1`

## Estado
- Maximo nivel vivo: `SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED`.
- Live total: armado y gobernado, no automatico.
- Runtime externo: bloqueado sin gate literal.
- Evidencia rectora: `docs/SDU_FINAL_PACKAGE` + `08_READBACKS` + `C:\CEO\watchdog\evidence`.
- Un solo delta vivo: promocion local de marcadores operativos.
- No stage, no commit, no push, no PR por defecto.
