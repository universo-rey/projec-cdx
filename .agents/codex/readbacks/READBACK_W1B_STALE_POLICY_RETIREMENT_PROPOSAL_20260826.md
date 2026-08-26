# READBACK W1-B — propuesta de retiro de proyecciones stale

## Estado

```text
ORDER=W1-B_CARRIL_C2_ACTA_DE_RETIRO_PROPUESTO
LOCK_KEY=W1B_POLICY_ACTA_WRITE
STATUS=PENDING_SOURCE_OWNER_ACTION
MODE=READ_ONLY_PROPOSAL
RETIRABLE_COMO_STALE=13
SOURCE_QUEUE_MUTATION=false
CURRENT_BINDING_INFERRED=false
HUMAN_RESERVED=ESCRIBANIA-AUTH-001
COMMIT=false
PUSH=false
```

Este documento propone retirar trece proyecciones de la cola como estados operativos activos. No ejecuta el retiro, no modifica `SDU_WORK_QUEUE_CURRENT.csv`, no materializa `CURRENT_BINDING` y no elimina las fuentes ni la evidencia atemporal.

La propuesta cubre nueve filas previamente clasificadas `STALE_POLICY_PROJECTION` y cuatro tuplas cruzadas previamente `UNRESOLVED / NO_D_RECTOR_ID`. Las cuatro tuplas cruzadas se consideran retirables como proyección porque combinan dominio, objetivo, gate, owner histórico o evidencia sin un rector work-item id único. Esto no convierte sus owners históricos en owners admisibles de runtime.

## Fuentes exactas

- Cola viva leída: `C:/CEO/sdu-control-plane/SDU_WORK_QUEUE_CURRENT.csv`.
- SHA-256 de la cola: `8CF83EE9A3CC8942A79514760D63322A2ED8C2B849EE07998A92CF3DDD553FA7`.
- Adjudicación W1: `.agents/codex/matrices/W1_ISSUE_44_AUTHORIZATION_ADJUDICATION_20260826.csv`.
- Rector de las nueve proyecciones originales: `D:/.agents/codex/matrices/LIVE_DELTA_RECONCILIATION_MATRIX_20260603.csv`.
- Canon downstream: TGE requiere `CURRENT_BINDING`; Seshat declara `runtime_authority=NONE_INFERRED`; Compliance depende de la admisión de `universo-rey/projec-cdx#44`.

## Criterio de retiro propuesto

```text
RETIRABLE_COMO_STALE =
  SOURCE_ROW_IS_DERIVED_PROJECTION
  AND CURRENT_BINDING_MATERIALIZED == false
  AND HUMAN_RESERVED == false
  AND (
    PROJECTION_STATUS == DERIVED_NOT_IMPORTED
    OR EXACT_RECTOR_WORK_ITEM_ID_COUNT == 0
    OR PURPOSE_OWNER_AUTHORITY_SURFACE_CROSS_TUPLE == true
  )
```

El retiro propuesto afecta sólo la proyección de cola. La capacidad, el agente, la matriz, el readback, el schema y el carril rector continúan presentes con su rol documental, histórico o técnico.

## Proyecciones propuestas para retiro

| # | work_item_id | tipo | fuente/provenance preservada | causa | owner de materialización | rollback | postcheck | stop condition |
|---:|---|---|---|---|---|---|---|---|
| 1 | `CONTROL_PLANE-ACTOR-001` | `STALE_POLICY_PROJECTION` | `court.thot_schema/EVIDENCE_LOG.csv`; `lane.integration.shared-index` | `DERIVED_NOT_IMPORTED`; apertura de sesión proyectada desde un carril ya consumido read-only. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Restaurar sólo la fila de proyección si el owner demuestra binding previo válido. | Cola conserva evidencia y deja de presentar la fila como autorización viva. | Detener ante `CURRENT_BINDING` importado, adjudicación posterior o ambigüedad de policy. |
| 2 | `CONTROL_PLANE-ACTOR-002` | `STALE_POLICY_PROJECTION` | `EVIDENCE_AND_VALIDATION_MATRIX.csv`; `lane.integration.shared-index` | Una matriz de evidencia fue proyectada como autorización operativa sin binding. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Igual: revertir sólo el cambio de estado de la proyección. | Matriz preservada; no se crea ejecución ni owner runtime. | Detener ante binding único con authority, target y validator. |
| 3 | `CONTROL_PLANE-ACTOR-003` | `STALE_POLICY_PROJECTION` | `SOURCE_TGE_SDU_CN_SHAREPOINT_GITHUB_CAPABILITY_MATRIX_20260527.csv`; `lane.integration.shared-index` | Declaración de gobierno proyectada por gate cloud; el canon TGE vigente depende de `#44`. | `rey.control_plane_orchestrator`; consulta `universe.escribania_tower` | Restaurar la proyección sólo con lineage y binding TGE probados. | Matriz histórica intacta; canon TGE no alterado. | Detener si TGE admite binding exacto para el mismo propósito. |
| 4 | `ESCRIBANIA-ACTOR-004` | `STALE_POLICY_PROJECTION` | `2026-06-08_seshat_review_s_6_1_readback.md`; `lane.tge.control` | El carril rector actual refiere TGE-02R/Planner y no coincide con `declaracion_evidencia`. | `universe.escribania_tower`; revisión `rey.frontier_guardian` | Restaurar sólo si TGE prueba correspondencia exacta de propósito y binding. | Readback preservado; no se toca Planner ni TGE runtime. | Detener ante decisión institucional, live write o binding admitido por TGE `#82`. |
| 5 | `CONTROL_PLANE-ACTOR-011` | `STALE_POLICY_PROJECTION` | `all_repo_github_alignment_latest.json`; `lane.integration.shared-index` | Receta GitHub proyectada bajo `GATE_SHAREPOINT_WRITE`; purpose, surface y authority no coinciden. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Reponer sólo la proyección, nunca la evidencia fuente. | Alignment preservado; cero GitHub o SharePoint write. | Detener ante binding GitHub exacto y validator-backed. |
| 6 | `CONTROL_PLANE-ACTOR-012` | `STALE_POLICY_PROJECTION` | `CODEX_CLOUD_GOVERNED_LANE.md`; `lane.integration.shared-index` | Contrato Cloud read-only elevado a autorización pendiente sin acción ni binding exactos. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Reponer sólo con una orden Cloud exacta y vigente. | Contrato Cloud preservado; no se crea tarea ni entorno. | Detener ante binding Cloud importado o autoridad humana. |
| 7 | `CONTROL_PLANE-ACTOR-013` | `STALE_POLICY_PROJECTION` | `rey.migration_planner.md`; `lane.integration.shared-index` | `noc_publish` derivado desde persona de agente y gate cloud, sin target ni binding. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Reponer sólo con target, owner y validator materializados. | Capacidad del agente preservada; proyección deja de operar como pendiente. | Detener ante cursor vivo posterior para el mismo ítem. |
| 8 | `CONTROL_PLANE-ACTOR-014` | `STALE_POLICY_PROJECTION` | `2026-06-13_escribania_runtime_baseline_objective_readback.md`; `lane.integration.shared-index` | Readback histórico convertido en tarea `watchdog_bus`; el carril rector registra consumo read-only. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Reponer sólo si un cursor vivo vincula el readback a una tarea actual. | Readback y evidencia de NOC preservados; watchdog no mutado. | Detener ante cambio vivo de NOC o binding exacto. |
| 9 | `CONTROL_PLANE-ACTOR-015` | `STALE_POLICY_PROJECTION` | `EVIDENCE_AND_VALIDATION_MATRIX.csv`; `lane.integration.shared-index` | Duplicación de la matriz como `qa_barrier` bajo gate cloud sin binding. | `rey.control_plane_orchestrator`; revisión `court.thot_schema` | Reponer únicamente la proyección. | Matriz preservada; ningún resultado de validador se reescribe. | Detener ante contradicción de policy no resuelta o binding exacto. |
| 10 | `CODEX_CLOUD-ACTOR-010` | `CROSS_TUPLE_NO_EXACT_BINDING` | `rey.migration_planner.md`; owner histórico `real.agent.rey_migration_planner` | Dominio Codex Cloud, objetivo `planner_write_recipe` y gate Planner sin rector id; `candidate_count=0`. | `rey.control_plane_orchestrator`; owner runtime permanece `UNRESOLVED` | Reponer sólo si el source owner prueba un binding único; no promover el owner histórico. | Agente y receta preservados; no se crea tarea Cloud ni Planner write. | Detener ante owner, authority, target surface o validator ambiguos. |
| 11 | `GITHUB-ACTOR-009` | `CROSS_TUPLE_NO_EXACT_BINDING` | `court.seshat_evidence.md`; owner histórico `real.agent.court_seshat_evidence` | Dominio GitHub, objetivo `sharepoint_write_recipe` y gate Cloud; `candidate_count=0`. | `rey.control_plane_orchestrator`; owner runtime permanece `UNRESOLVED` | Reponer sólo con rector id y binding GitHub únicos. | Agente de evidencia preservado; no se ejecuta GitHub ni SharePoint. | Detener ante live write, autoridad humana o cruce de surfaces no resuelto. |
| 12 | `MICROSOFT_365-ACTOR-006` | `CROSS_TUPLE_NO_EXACT_BINDING` | `2026-06-13_acta_del_dia_con_todos_los_agentes.md`; owner histórico `real.agent.2026_06_13_acta_del_dia_con_todos_los_agentes` | Dominio Microsoft 365 y objetivo `acta_y_readback` proyectados bajo gate Cloud; `candidate_count=0`. | `rey.control_plane_orchestrator`; consulta `universe.escribania_tower`; owner runtime `UNRESOLVED` | Reponer sólo si se demuestra un rector id único; el readback nunca se elimina. | Acta preservada; cero Microsoft 365 write. | Detener ante decisión jurídica/institucional, datos regulados o live write. |
| 13 | `MICROSOFT_365-ACTOR-008` | `CROSS_TUPLE_NO_EXACT_BINDING` | `D:/dataverse/schema/sdu_agent.yml`; owner histórico `real.agent.sdu_agent` | Dominio Microsoft 365, objetivo `dataverse_write_recipe` y gate Cloud sin binding; `candidate_count=0`. | `rey.control_plane_orchestrator`; consulta `universe.escribania_tower`; owner runtime `UNRESOLVED` | Reponer sólo con binding Dataverse exacto, autoridad y validador. | Schema preservado; cero Dataverse o Power Platform mutation. | Detener ante live write, tenant ambiguo, autoridad humana o datos regulados. |

## Reserva humana preservada

`ESCRIBANIA-AUTH-001` no integra las trece propuestas. Permanece:

```text
CLASS=HUMAN_RESERVED
OWNER=ENZO
SCOPE=03C-P031..03C-P034
REQUIRED_ACTION=explicit human decision recorded for each proposal
```

No puede retirarse, importarse ni reclasificarse desde este carril.

## Materialización pendiente

El owner de la cola/control plane debe aplicar, si acepta la propuesta, una operación separada, verificable y limitada a las trece proyecciones. La materialización debe conservar las trece fuentes, registrar lineage y no tocar la reserva humana.

```text
MATERIALIZATION_OWNER=rey.control_plane_orchestrator
TGE_CONCURRENCE_REQUIRED_FOR=ESCRIBANIA-ACTOR-004|MICROSOFT_365-ACTOR-006|MICROSOFT_365-ACTOR-008
MATERIALIZATION_STATE=PENDING_SOURCE_OWNER_ACTION
```

## Rollback, postcheck y stop

Rollback del acta: eliminar únicamente este archivo si su propuesta es rechazada. No existe rollback externo porque `SOURCE_QUEUE_MUTATION=false`.

Postcheck exigido después de una futura materialización:

```text
SOURCE_EVIDENCE_DELETED=0
RETIRED_PROJECTION_IDS=13/13
DUPLICATE_IDS=0
CURRENT_BINDING_INFERRED=false
HUMAN_RESERVED_ESCRIBANIA_AUTH_001=UNCHANGED
LIVE_WRITES=0
```

Stop conditions:

- aparece un `CURRENT_BINDING` importado y más reciente para cualquiera de los trece ítems;
- no puede probarse el owner exacto de la mutación de fuente;
- existe ambigüedad de policy o de autoridad;
- la acción requiere decisión jurídica, institucional o humana;
- la acción cruza a live write, tenant, Planner, SharePoint, Power Platform, Graph, Dataverse, GitHub remoto o producción;
- la acción elimina, reemplaza o desreferencia evidencia fuente.

## Resultado

```text
OUTCOME=PROPOSAL_COMPLETE_NO_SOURCE_MUTATION
NEXT_ACTION=SOURCE_OWNER_REVIEW_AND_SEPARATE_MATERIALIZATION_ORDER
GATE_TGE_ESCRIBANIA_OPERATIVA_GOBERNADA=CANNOT_CLOSE_FROM_THIS_ACTA
```
