# Control

Estado compacto para continuar sin arrastrar historico pesado.

## Desde Aca Se Controla Todo
- Estado vivo: [CURRENT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CURRENT.md)
- Siguiente paso: [NEXT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/NEXT.md)
- Trazabilidad: [TRACE.md](C:/Users/enzo1/PROJEC%20CDX/operativa/TRACE.md)
- Evidencia corta: [READBACK_CIERRE_PESO_REDUCIDO_20260617.md](C:/Users/enzo1/PROJEC%20CDX/operativa/READBACK_CIERRE_PESO_REDUCIDO_20260617.md)
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
- Rama liviana alineada con el binding Dataverse del workbook.
- Un workbook vigente.
- Un readback corto.
- Un solo delta vivo.
