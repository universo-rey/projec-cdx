# CEO Final Suite

Suite repo-scoped para contratos, validacion fail-closed, event bus local, policy, observabilidad y dashboard SOC.
Fase 3 agrega motor multi-agente ordenado sin introducir runtimes externos.
La variante inteligente agrega prioridad formal, resolucion de conflictos y memoria local por trace.
Fase 4 consolida la superficie visible en `unifiedTrace`.
Fase 5 desacopla el runtime: el motor de decision no depende semanticamente de Codex y ejecuta por `executionSurface` + `adapters\`.
Fase 6 agrega gobierno activo: disciplina de ejecucion obligatoria, sanitizer, diagnostico runtime, federation map y environment contract.
Fase 7 endurece el control plane: path sanitizer, federation enforcer, SNS unificado, VSI guard y Agile Agent Canvas local.
Fase final cierra coherencia fisica: `SYSTEM_NERVOUS_INDEX.json` raiz es fuente obligatoria, VSI opera como control plane y el path sanitizer aplica rewrites canonicos no destructivos.

## Frontera

- Estado generado: `<RUNTIME_PATH>\`.
- Dashboard: `web\index.html` con datos de `<RUNTIME_PATH>\dashboard\data.json`.
- Sin secretos, live writes, Microsoft live, OpenAI API live, SharePoint write, Power Platform mutation, push ni produccion.
- Las herramientas rechazan eventos invalidos antes de encolar y revalidan antes de procesar.
- La decision de agente vuelve al bus como evento `AGENT_DECISION`; no hay llamada directa interdominio.
- Los follow-ups automaticos permitidos se emiten como eventos nuevos y se validan antes de entrar al bus.
- La memoria de cadena vive en `<RUNTIME_PATH>\agents\chain-memory.jsonl`.
- Las superficies de ejecucion viven en `adapters\`: `local` activo, `codex` placeholder read-only y `cloud` placeholder.
- Toda ejecucion exige cadena completa: agente, skill, receta, tool, evidencia, validador y stop condition.
- Federation y environment contract viven en `contracts\federation-map.json` y `contracts\environment-contract.json`.
- El execution adapter bloquea antes de procesar si federation map o environment contract no pasan.
- Indices de entrada al SNS: raiz repo-local `index.json`; subconjunto operativo `operativa\index.json`; builder: `tools\build_index.py`.
- Indice nervioso local: `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\local-nervous-index.v1.yaml`; evidencia: `.cabina\SDU_RUNTIME_ROOT\13_EVIDENCE\READBACKS\20260623\LOCAL_NERVOUS_INDEX.md`.
- SNS raiz obligatorio: `SYSTEM_NERVOUS_INDEX.json`.
- Los campos `metadata_source` y `metadata_kind` son procedencia tecnica del indice; no son superficie operativa ni fuente canonica.
- Rewrites canonicos no destructivos: `<RUNTIME_PATH>\sanitization\canonical-path-rewrites.json`.
- Agile Agent Canvas local: `.agileagentcanvas-context`; mapa exportado: `<RUNTIME_PATH>\control-plane\agile-agent-canvas-map.json`.
- Agile Agent Canvas solo queda `READY` si el sync no detecta contenido demo/quarantine; `demoQuarantine:0` es postcheck obligatorio.
- Workspace VSI control plane: `CEO_CONTROL_PLANE.code-workspace`; tasks: `.vscode\tasks.json`.
- VSI guard valida `code-insiders`, raiz canonica y frontdoor antes del loop activo.
- El execution adapter bloquea si `SYSTEM_NERVOUS_INDEX.json` falta, no valida o no contiene todos los agentes/rutas.

## Flujo

```powershell
.\tools\ceo-event-publish.ps1 -Type RUNTIME_DRIFT -Domain runtime -Priority high -Payload '{"runtimeStatus":"DRIFT","cabinaStatus":"READY","details":"manual"}'
.\tools\ceo-validate-bus.ps1
.\tools\ceo-execution-adapter.ps1
.\tools\ceo-trace-export.ps1
```

El primer `ceo-execution-adapter.ps1` procesa el evento fuente, llama al `ceo-runtime-router.ps1` y encola `AGENT_DECISION`.
Si la cadena lo permite, tambien encola follow-ups validables, por ejemplo `PREDICTIVE_SIGNAL -> OPTIMIZATION_COMMAND`.
Las pasadas siguientes procesan decisiones y follow-ups como eventos locales.
`ceo-event-worker.ps1` y `ceo-agent-dispatcher.ps1` quedan como wrappers de compatibilidad.

Gobierno activo:

```powershell
.\tools\ceo-active-governance.ps1 -MaxFindings 5 -MaxEvents 20
```

Ejecucion expandida equivalente:

```powershell
.\tools\ceo-federation-check.ps1
.\tools\ceo-environment-check.ps1
.\tools\ceo-path-sanitizer.ps1 -MaxFindings 5 -Rewrite
.\tools\ceo-federation-enforcer.ps1
.\tools\ceo-sns-unify.ps1
.\tools\ceo-vsi-execution-guard.ps1
.\tools\ceo-control-plane-sync.ps1
.\tools\ceo-sanitizer-scan.ps1 -MaxFindings 5
.\tools\ceo-runtime-diagnose.ps1
.\tools\ceo-validate-bus.ps1
.\tools\ceo-execution-adapter.ps1 -MaxEvents 10
.\tools\ceo-execution-adapter.ps1 -MaxEvents 10
.\tools\ceo-trace-export.ps1
```

El sanitizer emite `SANITIZATION_FINDING`; el diagnostico emite `RUNTIME_DIAGNOSIS`.
Fase 7 agrega `SANITIZE_REQUIRED`, `FEDERATION_DRIFT`, `SNS_UNIFIED_INDEX`, `VSI_GUARD_RESULT` y `CONTROL_PLANE_SYNC`.
Todos pasan por el bus, producen `AGENT_DECISION` y quedan visibles en `unifiedTrace`.
Los hallazgos legacy no borran archivos: quedan resueltos por ruteo de adapter y router o retenidos por deletion gate explicito.

## Validadores

```powershell
.\tests\run-contract-tests.ps1
.\tests\run-integration-smoke.ps1
.\tools\ceo-federation-check.ps1
.\tools\ceo-environment-check.ps1
.\tools\ceo-active-governance.ps1 -MaxFindings 1 -MaxEvents 10
.\tools\ceo-validate-json.ps1 -JsonFile SYSTEM_NERVOUS_INDEX.json -SchemaFile contracts\schemas\system-nervous-index.schema.json
```

## Gobierno

| Rol | Agente logico | Superficie |
|---|---|---|
| Orchestrator | thot-tecnico | repo local |
| Contratos | seshat-normativa | `contracts\` |
| Validacion | maat-cumplimiento | `tools\ceo-validate-*.ps1` |
| Bus y runtime | sentinel-runtime | `<RUNTIME_PATH>\bus\` |
| Policy y gates | anubis-gate | `<RUNTIME_PATH>\policy\` |
| Observabilidad | horus-riesgo | `web\` y `<RUNTIME_PATH>\watch\` |
| Readback | narrador-normativo | evidencia local |
| Sanitizacion | maat-cumplimiento | `tools\ceo-sanitizer-scan.ps1` |
| Diagnostico | sentinel-runtime | `tools\ceo-runtime-diagnose.ps1` |
| Indices de entrada SNS | seshat-normativa | `index.json`, `operativa\index.json` y `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\local-nervous-index.v1.yaml` |
| Path sanitizer | maat-cumplimiento | `tools\ceo-path-sanitizer.ps1` |
| Federation enforcer | seshat-normativa | `tools\ceo-federation-enforcer.ps1` |
| SNS | seshat-normativa | `tools\ceo-sns-unify.ps1` |
| VSI guard | sentinel-runtime | `tools\ceo-vsi-execution-guard.ps1` |
| Control plane | thot-tecnico | `tools\ceo-control-plane-sync.ps1` |
| SNS raiz | seshat-normativa | `SYSTEM_NERVOUS_INDEX.json` |
| VSI control plane | sentinel-runtime | `CEO_CONTROL_PLANE.code-workspace` y `.vscode\tasks.json` |

## Orquestacion De Agentes

Mapa repo-local: `contracts\agent-map.json`.

| Event type | Cadena |
|---|---|
| `RUNTIME_DRIFT` | `validation_agent -> contracts_agent -> orchestrator_agent -> bus_agent -> observability_agent` |
| `VSCODE_DRIFT` | `validation_agent -> orchestrator_agent -> observability_agent` |
| `ALERT_RAISED` | `observability_agent -> evidence_agent -> orchestrator_agent` |
| `SELF_HEAL_COMMAND` | `validation_agent -> policy gate -> orchestrator_agent -> evidence_agent` |
| `PREDICTIVE_SIGNAL` | `validation_agent -> orchestrator_agent -> optimization_agent -> observability_agent` |
| `OPTIMIZATION_COMMAND` | `validation_agent -> orchestrator_agent -> bus_agent -> observability_agent` |
| `SANITIZATION_FINDING` | `validation_agent -> contracts_agent -> sanitizer_agent -> observability_agent -> evidence_agent` |
| `RUNTIME_DIAGNOSIS` | `validation_agent -> diagnostic_agent -> orchestrator_agent -> observability_agent -> evidence_agent` |
| `SANITIZE_REQUIRED` | `validation_agent -> contracts_agent -> path_sanitizer_agent -> observability_agent -> evidence_agent` |
| `FEDERATION_DRIFT` | `validation_agent -> contracts_agent -> federation_enforcer_agent -> observability_agent -> evidence_agent` |
| `SNS_UNIFIED_INDEX` | `validation_agent -> contracts_agent -> sns_agent -> observability_agent -> evidence_agent` |
| `VSI_GUARD_RESULT` | `validation_agent -> vsi_execution_guard -> orchestrator_agent -> observability_agent -> evidence_agent` |
| `CONTROL_PLANE_SYNC` | `validation_agent -> contracts_agent -> control_plane_agent -> observability_agent -> evidence_agent` |
| `AGENT_DECISION` | `evidence_agent` |

Runtime router: `tools\ceo-runtime-router.ps1`.
Execution adapter local: `tools\ceo-execution-adapter.ps1`.
Wrappers legacy: `tools\ceo-agent-dispatcher.ps1`, `tools\ceo-event-worker.ps1`.

Regla: policy se evalua antes de producir decision automatica; todo resultado de agente incluye `traceId`, `spanId`, `parentSpanId`, `agentId`, rol logico, secuencia, tipo de decision, timestamp, resultado, `executionSurface`, evidencia, validador y stop condition.
Las decisiones incompatibles se resuelven con prioridad formal y quedan en `CONFLICT_HELD` fail-closed; no emiten follow-ups.
`<RUNTIME_PATH>\dashboard\data.json` expone `unifiedTrace` como modelo unico visible por trace, con eventos, cadenas, decisiones, memoria, prioridad, resolucion, `finalState`, motor de decision y camino de ejecucion.

Flujo visible:

```text
trace -> chain -> decisions -> conflictResolution -> finalState -> executionPath
```

## G3_TRACE_INTELLIGENCE_LAYER

G3 agrega observabilidad local sobre el event bus persistente de G2:

- Indexacion: `tools\ceo-trace-indexer.ps1`.
- Consulta: `tools\ceo-trace-query.ps1`.
- Dashboard local: `tools\ceo-trace-dashboard.ps1`.
- Deteccion de anomalias: `tools\ceo-anomaly-detector.ps1`.
- Alertas locales: `tools\ceo-alert-engine.ps1`.
- Control de replay: `tools\ceo-replay-control.ps1`.
- Feedback de policy: `tools\ceo-policy-feedback.ps1`.

Limites:

- Alertas: `LOCAL_ONLY`.
- Recomendaciones: `SUGGESTION_ONLY`.
- Replay: `DRY_RUN_ONLY`.
- Dashboard: solo runtime local, no publica superficie web.
- Rutas visibles: placeholders como `<EVENT_STORE_PATH>`, `<TRACE_INDEX_PATH>`, `<DASHBOARD_DATA_PATH>` y `<EVIDENCE_PATH>`.

Validacion:

```powershell
.\tests\run-trace-indexer-tests.ps1
.\tests\run-trace-query-tests.ps1
.\tests\run-trace-dashboard-smoke.ps1
.\tests\run-anomaly-detection-tests.ps1
.\tests\run-alert-engine-tests.ps1
.\tests\run-replay-control-tests.ps1
.\tests\run-policy-feedback-tests.ps1
```

## G4_CONTROLLED_ACTION_LAYER

G4 habilita accion controlada local sobre recomendaciones y señales de G3:

- Riesgo: `tools\ceo-risk-engine.ps1`.
- Autorizacion: `tools\ceo-action-authorize.ps1`.
- Owner gate local: `tools\ceo-owner-approval.ps1`.
- Ejecucion segura: `tools\ceo-action-executor.ps1`.
- Registry allowlist: `contracts\action-registry.json`.

Reglas:

- Default: `DENY`.
- Acciones desconocidas: `BLOCK`.
- Riesgo alto o critico: `HOLD_OWNER`.
- Ejecucion: `DRY_RUN` por defecto.
- Sin accion externa.
- Sin efectos laterales productivos.
- Evidencia en runtime local.

Validacion:

```powershell
.\tests\run-action-contract-tests.ps1
.\tests\run-authorization-tests.ps1
.\tests\run-owner-gate-tests.ps1
.\tests\run-execution-dry-run-tests.ps1
.\tests\run-policy-block-tests.ps1
```

Skill: `repo-agent-tool-governance`.
Recetas: `agentes-atomicos-algoritmicos-en-waves`, `cierre-wave-documental`.
Stop condition: cualquier secreto, live write, mutacion fuera del repo o perdida de fail-closed.
