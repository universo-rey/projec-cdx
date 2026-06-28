# Patrones Operativos

## P-001 - Delta Gobernado

- Senal: el pedido puede partirse en una entrega chica.
- Accion: declarar objetivo, superficie, salida, rollback y postcheck; si el trabajo se va a delegar, convertir la wave en plantilla de entrenamiento para el siguiente agente.
- Fuente: `playbooks/00-preflight-gobernado.md`, `playbooks/01-iniciar-delta.md`.
- Salida: cambio reversible y validable.
- Stop condition: `rollback_missing`, `postcheck_missing`.

## P-002 - Mapa Visible Corto

- Senal: una carpeta crece o aparecen archivos huerfanos.
- Accion: crear o actualizar `README.md` y `MAPA.md`; subir solo entradas clave a `MAPA_MAESTRO.md`.
- Fuente: `codex-surface-map`, `MAPA_MAESTRO.md`.
- Salida: navegacion corta con links reales.
- Stop condition: `required_map_missing`, `link_broken`.

## P-003 - Fuente Proceso Salida Hito Cierre

- Senal: un cierre puede perderse en chat.
- Accion: registrar la cadena en `operativa/TRACE.md`.
- Fuente: `operativa/TRACE.md`, `governed-readback-closeout`.
- Salida: continuidad retomable por otro hilo.
- Stop condition: `operational_chain_missing`.

## P-004 - Gate Antes De Live

- Senal: aparece Dataverse, Power Platform, Microsoft live, ambiente u org.
- Accion: leer `dataverse/GATE.md` y clasificar local, metadata-only, prepared, live read o live write.
- Fuente: `dataverse/GATE.md`, `playbooks/06-dataverse-gobernado.md`.
- Salida: no hay inferencia de live sin evidencia.
- Stop condition: `live_surface_without_order`, `target_identity_ambiguous`.

## P-005 - Workbook Al Frente

- Senal: el control ya no cabe solo en markdown.
- Accion: regenerar workbook desde fuentes documentales y guardar corrida en `outputs/`.
- Fuente: `tools/build_control_workbook.mjs`, `workbooks/EXCEL_AL_FRENTE.md`.
- Salida: tablero legible con manifest y formula scan.
- Stop condition: `workbook_invalid`, `formula_error_detected`.

## P-006 - Hito Versionado

- Senal: una ronda queda durable.
- Accion: crear carpeta fechada con `README.md`, `MANIFEST.yaml`, `REGISTRO_HITOS.md`, `INDICE.csv` y evidencia.
- Fuente: `hitos/README.md`, `hitos/20260615-cierre-workbench-v1`.
- Salida: cierre versionado sin depender de git.
- Stop condition: `no_evidence`.

## P-007 - Retencion Gobernada

- Senal: se pide compactar, limpiar, mover o borrar.
- Accion: aplicar `operativa/RETENCION.md` y exigir orden explicita.
- Fuente: `operativa/RETENCION.md`, `outputs/RETENCION.md`.
- Salida: evidencia preservada o movimiento con rollback.
- Stop condition: `unexpected_external_write`.

## P-008 - Validador Antes De Cierre

- Senal: se va a declarar `PASS` o verde.
- Accion: ejecutar `tools/validate_proj_cdx_workbench.ps1`.
- Fuente: `playbooks/04-validar-delta.md`.
- Salida: `PASS`, `OBSERVED` o `FAIL`.
- Stop condition: `validator_not_run`.

## P-009 - Agente Revisor Read-Only

- Senal: hay muchas conexiones o riesgo de hueco fino.
- Accion: lanzar agente con tarea acotada y sin ediciones.
- Fuente: hallazgo sobre `operativa/MAPA.md` corregido en este hilo.
- Salida: segundo par de ojos sin conflictos de escritura.
- Stop condition: `review_scope_ambiguous`.

## P-010 - Amarillo Guardrail

- Senal: control total devuelve `YELLOW` sin rojos.
- Accion: registrar como guardrail, no como bloqueo, si la accion recomendada es preventiva.
- Fuente: `operativa/CONTROL_TOTAL_20260615.md`.
- Salida: semaforo honesto: `GREEN_LOCAL / GREEN_OPERABLE`.
- Stop condition: `red_check_present`.

## P-014 - Canon Documental

- Senal: un frente documental crece y deja varios puntos de entrada.
- Accion: clasificar fuente, evidencia, patron, proceso, hito, indice y salida, y promover solo lo durable.
- Fuente: `docs/README.md`, `docs/referencia/README.reference.md`, `operativa/TRACE.md`, `hitos/INDICE_MAESTRO.md`.
- Salida: canon navegable, reusable y sin duplicar fuentes de verdad.
- Stop condition: `evidence_missing`, `link_broken`, `duplicate_source_of_truth`.

## P-015 - Dataverse Rehidratacion

- Senal: un hilo largo vuelve a tocar Dataverse y el contexto ya se disperso.
- Accion: abrir el hito de sincronizacion, el indice Dataverse y el gate antes de decidir cualquier siguiente delta.
- Fuente: `dataverse/ANCLA_REHIDRATACION.md`, `dataverse/PLAN_SEGUNDA_PASADA.md`, `dataverse/MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md`.
- Salida: estado rehidratado y siguiente paso reducido.
- Stop condition: `missing_gate`, `missing_evidence`, `missing_target`, `live_by_inference`.
