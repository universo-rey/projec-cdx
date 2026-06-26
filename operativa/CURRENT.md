---
artifact_id: operativa/CURRENT.md
categoria: operativa
tipo: reporte
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-26'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/CURRENT.md
etiquetas:
  - current
  - frontdoor
  - convergencia
  - live-total-governed
  - production-ready
relacionados:
  - README.md
  - MAPA_MAESTRO.md
  - MAPA_CAPAS.md
  - operativa/NEXT.md
  - docs/SDU_FINAL_PACKAGE/SDU_SYSTEM_CERTIFICATION.md
  - docs/SDU_FINAL_PACKAGE/SDU_CONTRACT_FORMAL.md
  - SDU_STATE_G10.md
descripcion: Estado vivo actual de PROJEC CDX elevado al maximo nivel documental certificado.
---

# Current

Estado vivo resumido de `PROJEC CDX`.

## Estado Actual

```text
SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED
LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC
SYSTEM_CERTIFICATION_STATUS_PRODUCTION_READY
OPERATION_MODE_GOVERNED
AUTOMATIC_EXECUTION_DISABLED
EXTERNAL_SEND_DISABLED
SCHEDULER_NOT_ENABLED
KNOWN_RESIDUAL_ACCEPTED
REPO_CANONICAL_BOUNDARY_ESTABLISHED_G10
```

## Version

```text
v0.6.0-rc1
```

## Entrada Canonica

```text
C:\CEO\project-cdx
```

Alias fisico:

```text
C:\Users\enzo1\PROJEC CDX
```

Regla:

```text
No tratar el alias fisico como segundo workspace activo.
No crear SDU_RUNTIME_ROOT paralelo.
Usar siempre C:\CEO\project-cdx\.cabina\SDU_RUNTIME_ROOT.
```

## Puertas Vivas

- [README.md](../README.md)
- [MAPA_MAESTRO.md](../MAPA_MAESTRO.md)
- [MAPA_CAPAS.md](../MAPA_CAPAS.md)
- [SDU_SYSTEM_CONTRACT.md](../SDU_SYSTEM_CONTRACT.md)
- [SDU_STATE_G10.md](../SDU_STATE_G10.md)
- [SDU System Certification](../docs/SDU_FINAL_PACKAGE/SDU_SYSTEM_CERTIFICATION.md)
- [SDU Formal Contract](../docs/SDU_FINAL_PACKAGE/SDU_CONTRACT_FORMAL.md)
- [SDU Evidence Index](../docs/SDU_FINAL_PACKAGE/SDU_EVIDENCE_INDEX.md)

## Canon Vivo

- [NEXT.md](NEXT.md)
- [TRACE.md](TRACE.md)
- [SDU_FULL_PACKAGE_READY.md](../08_READBACKS/SDU_FULL_PACKAGE_READY.md)
- [20260625_182615_SDU_G8_5_FINAL_NORMALIZATION.md](../08_READBACKS/20260625_182615_SDU_G8_5_FINAL_NORMALIZATION.md)
- [20260625_170732_SDU_G6_CERTIFICATION.md](../08_READBACKS/20260625_170732_SDU_G6_CERTIFICATION.md)
- [20260626_SDU_MAX_LEVEL_PROMOTION.md](../08_READBACKS/20260626_SDU_MAX_LEVEL_PROMOTION.md)

## Runtime / Cabina

- [.cabina/SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md](../.cabina/SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md)
- [.cabina/SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md](../.cabina/SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md)
- [.cabina/SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/README.md](../.cabina/SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/README.md)

## Maximo Nivel Alcanzado

```text
G8_5_DOCUMENTAL_FINAL_NORMALIZATION_PASS
G10_REPO_CANONICAL_BOUNDARY_ESTABLISHED
PRODUCTION_READY_GOVERNED
LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC
```

Interpretacion:

- El carril documental SDU esta certificado como `PRODUCTION READY` bajo operacion gobernada.
- `cr3c_expediente` es el origen primario; `adx_portalcomment` queda como compatibilidad historica.
- Watchdog/NOC/intelligence operan como observacion, validacion y recomendacion.
- No hay scheduler, flow, envio externo, cleanup ni write live habilitado por defecto.
- El residual `PRE_FIX_DUPLICATE` esta aceptado como historico y solo se toca por `CLEANUP GATE`.

## Pendientes Vivos

```text
G11: revisar policy tuning local-only sin aplicar automaticamente
MULTI_DOMAIN: definir fuente de estado y gate por EXPEDIENTES/FIRMAS/COMUNICACIONES
CLEANUP_GATE: decidir si se interviene el residual PRE_FIX_DUPLICATE
VERSIONING: decidir stage/commit/snapshot del delta local cuando el owner lo ordene
```

## Historico Reubicado / Superado

Los estados historicos `WORKBOOK_SURFACES_WORKSPACE_REFRESHED` y `CABINA_FRONTDOOR_CONVERGED_LOCAL_ONLY` quedan preservados como antecedentes.

Fuente maestra historica:

```text
HOLD_ARCHIVE_REVIEW
```

La cronologia historica no autoriza live ni reempaquetado por inferencia.

## Frontera

- No live por inferencia.
- No secretos.
- No DB/cache mutation.
- No push.
- No PR.
- No stage/commit sin decision.
- No Microsoft/Dataverse/SharePoint/Power Platform/Codex Cloud sin gate literal.
- No scheduler/flow/cleanup/envio externo automatico.
