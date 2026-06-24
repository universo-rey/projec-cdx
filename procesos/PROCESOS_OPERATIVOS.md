# Procesos Operativos

## PR-001 - Abrir Hilo Con Contexto

- Entrada: nuevo hilo sobre `PROJEC CDX`.
- Pasos: leer `README.md`, `MAPA_MAESTRO.md`, `operativa/archive/legacy-root/undated/START_HERE.md`, `operativa/CONTROL.md`, `CURRENT`, `NEXT`, `BLOCKERS`.
- Salida: semaforo, superficie y proximo movimiento unico.
- Validador: `playbooks/00-preflight-gobernado.md`.
- Stop condition: `workspace_root_mismatch`.

## PR-002 - Ejecutar Delta Gobernado

- Entrada: objetivo acotado.
- Pasos: iniciar con `01`, ejecutar con `02`, cerrar con `03`, validar con `04`.
- Salida: cambio minimo, reversible, enlazado y validado.
- Validador: `tools/validate_proj_cdx_workbench.ps1`.
- Stop condition: `rollback_missing`, `postcheck_missing`.

## PR-003 - Cerrar Ronda Durable

- Entrada: delta completado con valor durable.
- Pasos: actualizar `TRACE`, crear hito, registrar evidencia, escribir readback, validar links.
- Salida: `hitos/YYYYMMDD-nombre-vN/` y readback.
- Validador: `tools/validate_proj_cdx_workbench.ps1`.
- Stop condition: `no_evidence`.

## PR-004 - Dataverse Sin Inferencia

- Entrada: Dataverse, Power Platform, Power Automate, Microsoft live, ambiente u org.
- Pasos: leer `dataverse/GATE.md`, clasificar estado, exigir target/owner/rollback/postcheck si live.
- Salida: `local_evidence`, `metadata_only`, `prepared_not_executed`, `live_rows_confirmed`, `target_ambiguous` o `blocked`.
- Validador: `playbooks/06-dataverse-gobernado.md`.
- Stop condition: `live_surface_without_order`.

## PR-005 - Regenerar Workbook De Control

- Entrada: cambio en `operativa/`, `dataverse/GATE.md` o estado de cierre.
- Pasos: ejecutar `tools/build_control_workbook.mjs`, revisar `formula_errors.ndjson`, actualizar mapas si aparecen hojas o artefactos nuevos.
- Salida: `workbooks/control_operativo.xlsx`, corrida en `outputs/control_operativo_YYYYMMDD`, `MANIFEST.json`.
- Validador: `tools/validate_proj_cdx_workbench.ps1`.
- Stop condition: `formula_error_detected`.

## PR-006 - Compactar Sin Perder Evidencia

- Entrada: pedido de limpieza, compactacion, mover o borrar.
- Pasos: leer `operativa/archive/legacy-root/undated/RETENCION.md`, listar rutas exactas, declarar rollback y postcheck, no borrar sin orden explicita.
- Salida: evidencia preservada o movimiento documentado.
- Validador: `tools/validate_proj_cdx_workbench.ps1`.
- Stop condition: `unexpected_external_write`.

## PR-007 - Revisar Con Agente Read-Only

- Entrada: cierre con muchos enlaces o riesgo de detalle fino.
- Pasos: delegar pregunta acotada, prohibir ediciones, integrar hallazgo, validar.
- Salida: `PASS` o hueco corregido.
- Validador: revision local posterior.
- Stop condition: `review_scope_ambiguous`.

## PR-008 - Control Total Rapido

- Entrada: cierre, handoff o duda de estado local.
- Pasos: ejecutar `tools/codex-control-total.ps1`, registrar semaforo, separar rojo real de amarillo guardrail.
- Salida: `operativa/CONTROL_TOTAL_YYYYMMDD.md`.
- Validador: lectura de conteos y acciones recomendadas.
- Stop condition: `red_check_present`.

## PR-009 - Procedencia Layout On Demand

- Entrada: configuracion interna, ancla o nota visible que no debe parecer habilitacion live.
- Pasos: clasificar la superficie, mover la procedencia tecnica a referencia, abrir solo por `ANCLAS_ON_DEMAND.md`, validar y registrar.
- Salida: lectura visible compacta y procedencia tecnica aislada.
- Validador: `tools/validate_proj_cdx_workbench.ps1`.
- Stop condition: `live_write_by_inference`, `secret_or_state_touch`.
