---
artifact_id: operativa/NEXT.md
categoria: operativa
tipo: plan
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-26'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/NEXT.md
etiquetas:
  - next
  - production-ready
  - live-total-governed
  - next
relacionados:
  - operativa/CURRENT.md
  - docs/SDU_FINAL_PACKAGE/SDU_OPERATION_PLAYBOOK.md
  - docs/SDU_FINAL_PACKAGE/SDU_RISK_MODEL.md
  - policy-adjustment-proposal.json
descripcion: Siguiente movimiento vivo tras elevar el estado al maximo nivel SDU certificado.
---

# Next

Movimiento unico:

```text
ADOPT_SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED_AND_PREPARE_MULTI_DOMAIN_EXPANSION
```

## Estado de Entrada

```text
SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED
LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC
REPO_CANONICAL_BOUNDARY_ESTABLISHED_G10
```

## Objetivo

Sostener el maximo nivel alcanzado sin abrir ejecucion automatica:

1. mantener `PRODUCTION READY` como estado institucional del carril documental;
2. operar NOC/watchdog/intelligence como observacion y recomendacion;
3. revisar G11 policy tuning sin aplicar automaticamente;
4. preparar expansion multi-dominio con fuente de estado, rollback, postcheck y evidencia por dominio;
5. dejar `PRE_FIX_DUPLICATE` solo bajo decision `CLEANUP GATE`;
6. cerrar versionado/snapshot/stage solo si el owner lo ordena.

## Carriles Delegados

```text
Seshat -> contrato y estado vivo CURRENT/NEXT
Anubis -> gates, rollback y owner decision
Horus -> evidencia watchdog/NOC/intelligence
Maat -> validacion fail-closed y no-inference guard
Narrador -> readback y trazabilidad institucional
```

## Siguiente Orden Tecnica

```text
G11_REVIEW_NO_APPLY
DOMAIN_SOURCE_CONTRACTS
CLEANUP_GATE_DECISION_OPTIONAL
SNAPSHOT_VERSION_DECISION_OWNER_ONLY
```

No hay accion live implicita en este `NEXT`.

## Frontera

- No live.
- No secretos.
- No DB/cache.
- No scheduler.
- No flows.
- No cleanup automatico.
- No Microsoft/Dataverse/SharePoint/Power Platform por inferencia.
- No push.
- No PR.
- No stage/commit sin decision.
