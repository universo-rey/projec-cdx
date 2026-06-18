# Control

Punto unico de control operativo de `PROJEC CDX`.

## Desde Aca Se Controla Todo

- Estado vivo: [CURRENT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CURRENT.md)
- Metodo corto: [METODO.md](C:/Users/enzo1/PROJEC%20CDX/operativa/METODO.md)
- Arranque: [START_HERE.md](C:/Users/enzo1/PROJEC%20CDX/operativa/START_HERE.md)
- Prompt nuevo hilo: [PROMPT_NUEVO_HILO.md](C:/Users/enzo1/PROJEC%20CDX/operativa/PROMPT_NUEVO_HILO.md)
- Siguiente paso: [NEXT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/NEXT.md)
- Bloqueos: [BLOCKERS.md](C:/Users/enzo1/PROJEC%20CDX/operativa/BLOCKERS.md)
- Trazabilidad: [TRACE.md](C:/Users/enzo1/PROJEC%20CDX/operativa/TRACE.md)
- Plan de completitud: [PLAN_COMPLETAR_ESTRUCTURA.md](C:/Users/enzo1/PROJEC%20CDX/operativa/PLAN_COMPLETAR_ESTRUCTURA.md)
- Manifests: [MANIFESTS.md](C:/Users/enzo1/PROJEC%20CDX/operativa/MANIFESTS.md)
- Retencion: [RETENCION.md](C:/Users/enzo1/PROJEC%20CDX/operativa/RETENCION.md)
- Readback de cierre: [READBACK_CIERRE_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/READBACK_CIERRE_20260615.md)
- Control total: [CONTROL_TOTAL_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CONTROL_TOTAL_20260615.md)
- Dataverse: [dataverse/README.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/README.md)
- Playbooks: [playbooks/README.md](C:/Users/enzo1/PROJEC%20CDX/playbooks/README.md)
- Patrones: [patrones/README.md](C:/Users/enzo1/PROJEC%20CDX/patrones/README.md)
- Procesos: [procesos/README.md](C:/Users/enzo1/PROJEC%20CDX/procesos/README.md)
- Sincronizacion: [procesos/sincronizacion-tiempo-real.md](C:/Users/enzo1/PROJEC%20CDX/procesos/sincronizacion-tiempo-real.md)
- Validador sync: [validate_proj_cdx_sync.ps1](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_sync.ps1)
- Excel al frente: [EXCEL_AL_FRENTE.md](C:/Users/enzo1/PROJEC%20CDX/workbooks/EXCEL_AL_FRENTE.md)
- Workbook: [control_operativo.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx)
- Configuracion vigente: [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx)

## Regla Atomica

Una sola unidad activa por vez:

1. declarar el trabajo en `NEXT.md`
2. moverlo a `CURRENT.md`
3. ejecutar con playbook
4. registrar salida en workbook
5. cerrar en `TRACE.md`
6. si corresponde, versionar en `hitos/`
7. validar con `tools/validate_proj_cdx_workbench.ps1`
8. si aparece aprendizaje estable, levantarlo en `patrones/` o `procesos/`
9. si el cambio mueve una fuente viva, ejecutar `tools/validate_proj_cdx_sync.ps1`
