# Excel Al Frente

Indice visible de los libros Excel principales de `PROJEC CDX`.

## Fuentes Vivas

- [CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx) - configuracion vigente con agentes, entornos, colas y Dataverse.
- [control_operativo.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx) - tablero operativo actual.
- [inicio.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/inicio.xlsx) - libro fuente de inicio.
- [tracker.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx) - libro fuente de tracker.

## Salidas Generadas

- [CABINA_RELATIONSHIP_AUDIT_EXECUTIVE.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/cabina_relationship_audit_20260614/CABINA_RELATIONSHIP_AUDIT_EXECUTIVE.xlsx) - auditoria ejecutiva.
- [CABINA_RELATIONSHIP_AUDIT_DEEP.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/cabina_relationship_audit_20260614/CABINA_RELATIONSHIP_AUDIT_DEEP.xlsx) - auditoria profunda.
- [control_operativo.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/control_operativo_20260615/control_operativo.xlsx) - copia generada del tablero.
- [dataverse_blocker_frontier.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/dataverse_blocker_frontier_20260614/dataverse_blocker_frontier.xlsx) - frontera Dataverse.
- [excel_inicio.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/inicio_workbook_20260613/excel_inicio.xlsx) - corrida de inicio.
- [tracker.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/tracker_general_20260613/tracker.xlsx) - corrida tracker general.
- [tracker_workbook.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/tracker_workbook_20260613/tracker_workbook.xlsx) - variante tracker workbook, distinta por diseño.
- [UNIVERSE_RELATIONSHIP_AUDIT.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/universe_relationship_audit_20260614/UNIVERSE_RELATIONSHIP_AUDIT.xlsx) - auditoria universo.
- [workbook_base.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/workbook_base_20260613/workbook_base.xlsx) - corrida workbook base.

## Regla

- `workbooks/` contiene fuentes vivas o libros de uso operativo.
- `outputs/` contiene corridas fechadas y evidencia generada.
- Si un Excel de `outputs/` pasa a ser fuente viva, debe copiarse o regenerarse en `workbooks/` y quedar declarado aca.
- `tracker_workbook.xlsx` no es espejo de `workbooks/tracker.xlsx`; es una variante alterna y debe leerse como derivado separado.
