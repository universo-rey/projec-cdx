# PLANNER INCIDENT CASE AUDIT - 2026-06-27

version: FINAL
mode: READ_ONLY
scope: Planner incident matrix INC-001..INC-007
rule: no asumir perdida de datos sin evidencia estructural
final_loss_rule: DATA_LOSS_CONFIRMED solo si PlannerTask=NOT_FOUND AND Teams=NOT_FOUND AND Outlook=NOT_FOUND AND snapshot=NOT_FOUND

## Estado de entrada

- Matriz formal `INC-001..INC-007`: no localizada en repos locales ni busqueda Teams por IDs.
- Evidencia validada: 3 reportes con `taskId` explicito; 1 reporte general; 1 referencia a "resto de incidencias 2004"; 2 filas no mapeables sin matriz formal.
- Fuentes consultadas: PlannerTask via Teams connector, Teams messages, Outlook notifications, snapshot SDU.
- Revalidacion critica `INC-002/LABROCA`: Teams FOUND y Outlook FOUND; por criterio final no puede clasificarse como perdida real de datos.

## Resultado por caso

| Caso | Task / reporte | plannerTask | Teams | Outlook | snapshot SDU | Causa | Riesgo |
|---|---|---:|---:|---:|---:|---|---|
| INC-001 | Reporte general: "Otra vez me estan desapareciendo los comentarios en planner" | NO_TASK_ID | FOUND | NOT_FOUND | NOT_FOUND | TRACEABILITY_GAP | MEDIO |
| INC-002 | Venta e Hipoteca - LABROCA - SALAS - BBVA - Carpeta A125 - 0000000067865 | NOT_FOUND | FOUND | FOUND | NOT_FOUND | SYNC_FAILURE | ALTO |
| INC-003 | Protocolizacion Expediente Judicial - ALLOLIO - Carpeta No A117 | EXISTS | FOUND | FOUND | NOT_FOUND | READ_INCONSISTENCY | MEDIO |
| INC-004 | INCIDENCIA BAHIA SAN MARTIN S.A | EXISTS | FOUND | FOUND | NOT_FOUND | READ_INCONSISTENCY | MEDIO |
| INC-005 | Fila INC no mapeable: matriz formal no encontrada | NO_TASK_ID | NOT_FOUND | NOT_CHECKABLE | NOT_FOUND | TRACEABILITY_GAP | MEDIO |
| INC-006 | Referencia Teams: "Lo propio en el resto de las incidencias 2004" | NO_TASK_ID | FOUND | NOT_CHECKABLE | NOT_FOUND | TRACEABILITY_GAP | ALTO |
| INC-007 | Fila INC no mapeable: matriz formal no encontrada | NO_TASK_ID | NOT_FOUND | NOT_CHECKABLE | NOT_FOUND | TRACEABILITY_GAP | MEDIO |

## Evidencia concreta

### INC-002 LABROCA

- Teams message: 2026-06-22T21:13:44.217Z, claim: no aparece historial de comentarios; comentario realizado 5 mins antes.
- Teams workflow: 2026-06-22T21:12:53Z, "Tarea creada en Microsoft Planner", link al mismo plan/task.
- Planner link: plan `BrccwJEcAU26c7bC4qKL2mUADUWA`, task `hoQ581qKWkWHh8i46wm_HWUADOoZ`.
- PlannerTask fetch: `404 NOT_FOUND`, request date `2026-06-27T09:20:58`, request-id `b713830b-530f-400b-8be9-ede0821a1ac2`.
- Planner visible plans: `Escrituraciones` revisado y sin tarjeta LABROCA visible en la pagina maxima retornada; planes visibles principales revisados sin match por titulo. Esto no cambia la regla final porque Teams/Outlook son FOUND.
- Outlook: asignacion de tarea recibida 2026-06-22T21:12:52Z..21:12:54Z con el mismo titulo.
- Snapshot SDU: no aparece en `PLANNER_TASK_LEVEL_READBACK_20260627.jsonl` ni `PLANNER_TASK_LEVEL_READBACK_HYBRID_20260627.jsonl`.
- Clasificacion final: `SYNC_FAILURE`. Hay desalineacion entre el readback actual de Planner y las trazas Teams/Outlook; no hay perdida real confirmada bajo el criterio final.

### INC-003 ALLOLIO

- Teams message: 2026-06-23T19:54:02.033Z, claim: comentarios desaparecidos.
- Planner link: plan `BrccwJEcAU26c7bC4qKL2mUADUWA`, task `MLvaTmyT5ECtcmjVzQ_VhGUAP7_9`.
- PlannerTask fetch: EXISTS, created `2025-10-06T19:13:09.5084393Z`, percent_complete `50`, etag `W/"JzEtVGFzayAgQEBAQEBAQEBAQEBAQEBEUCc="`.
- Outlook: mensajes `RE: Comentarios sobre la tarea` entre 2026-02-20 y 2026-03-21 vinculados a la tarea/plan.
- Snapshot SDU: no aparece en los snapshots task-level actuales.

### INC-004 BAHIA

- Teams message: 2026-06-23T19:58:50.635Z, claim: verificar desaparicion de comentarios.
- Planner link: plan `BrccwJEcAU26c7bC4qKL2mUADUWA`, task `8rWdrvtjc0KvVnGx6NJ822UAFKEE`.
- PlannerTask fetch: EXISTS, created `2026-04-17T20:46:11.4359995Z`, percent_complete `0`, etag `W/"JzEtVGFzayAgQEBAQEBAQEBAQEBAQEBCSCc="`.
- Outlook: asignacion 2026-04-17T20:46:37Z y comentario 2026-05-05T21:13:17Z sobre la misma tarea.
- Snapshot SDU: no aparece en los snapshots task-level actuales.

## Conteo

- DATA_LOSS_CONFIRMED: 0
- READ_INCONSISTENCY: 2
- SYNC_FAILURE: 1
- TRACEABILITY_GAP: 4
- USER_PERCEPTION_ERROR: 0

## Conclusion

NO hubo perdida real de datos confirmada bajo el criterio final. `INC-002/LABROCA` no aparece por `taskId` en Planner actual, pero Teams y Outlook estan FOUND, incluyendo creacion/asignacion historica con el mismo titulo y taskId; por lo tanto se reclasifica como `SYNC_FAILURE`, no como `DATA_LOSS_CONFIRMED`. No hubo evidencia estructural suficiente para confirmar perdida real de comentarios; los casos ALLOLIO y BAHIA prueban que la tarea existe y que hay actividad historica en Outlook/Teams, por lo que se clasifican como inconsistencia de lectura/visibilidad. La falla principal es observabilidad incompleta: la matriz INC formal no fue localizada y los snapshots task-level no cubren estos incidentes, aun cuando hay evidencia externa.

## Eventos requeridos

- SDU_CASE_AUDIT_STARTED
- SDU_CASE_VALIDATED
- SDU_CASE_AUDIT_COMPLETE
