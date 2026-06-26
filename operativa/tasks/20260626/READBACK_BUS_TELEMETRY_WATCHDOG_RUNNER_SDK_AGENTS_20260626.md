# READBACK_BUS_TELEMETRY_WATCHDOG_RUNNER_SDK_AGENTS_20260626

## Estado

HECHO_VERIFICADO:

Barrido local ejecutado el 2026-06-26 sobre el estado congelado posterior a la
reconciliacion de `VERSION_STATE.json`.

No se ejecuto stage, commit, push, fetch, PR, workflow dispatch, servicio,
scheduler, OpenAI API live, Microsoft live, SharePoint, Dataverse, Power
Platform, Codex Cloud, lectura de secretos, cleanup, delete, move ni reset.

Se usaron tres subagentes explorer read-only:

- bus y runner
- telemetria, observabilidad, watchdog y sentinel
- Agents SDK, agentes, skills, recipes y plugins

## Autoridad Canonica

La autoridad repo-local para este corte es:

- `SYSTEM_NERVOUS_INDEX.json`
- `SDU_SYSTEM_CONTRACT.md`
- `contracts/agent-map.json`
- `contracts/contract-map.json`
- `contracts/schemas/event-envelope.schema.json`
- `tools/ceo-suite-common.ps1`
- `operativa/CURRENT.md`
- `operativa/NEXT.md`
- `operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json`

Estado general:

- sistema: `EVENT_DRIVEN_MULTI_AGENT_RUNTIME`
- agentes declarados en SNS: 14
- rutas declaradas en SNS: 15
- politica SNS: `failClosed=true`, `liveWrite=false`, `secretAccess=false`
- estado operativo: `LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC`
- ejecucion automatica: deshabilitada

## Mapa Vivo

| superficie | autoridad/evidencia | capacidad | estado | gate/riesgo |
|---|---|---|---|---|
| Bus G2 persistente | `tools/ceo-event-publish.ps1`, `ceo-event-dispatcher.ps1`, `ceo-event-worker.ps1`, `ceo-event-runner.ps1`, `ceo-event-replay.ps1`, `.cabina/runtime/event-bus/state/event-bus-state.json` | publish, dispatch, worker, retry/replay dry-run, traces, evidence | presente; raiz local validada por evidencia previa | runners escriben estado; no ejecutar sin owner gate local |
| Bus suite activo | `.cabina/runtime/suite/bus/queue.jsonl`, `processed.jsonl`, `failed.jsonl`, `invalid-events.log` | cola JSONL local y evidencia de procesamiento | presente; subagente reporta `queue=1`, `processed=40`, `failed=0`, `invalid=0` | drenar cola muta evidencia; requiere orden explicita |
| Runner/adaptador | `tools/ceo-execution-adapter.ps1`, `tools/ceo-runtime-router.ps1` | consume cola, valida evento, aplica policy, despacha, genera `AGENT_DECISION` | activo como capacidad local | no es inocuo: mueve eventos y escribe `processed/failed` |
| Contratos de evento | `contracts/contract-map.json`, `contracts/schemas/event-envelope.schema.json`, `contracts/event.schema.json` | envelope, payloads, tipos de evento, policy y retry | formalizado | contract tests pueden generar outputs; gate antes de correr |
| Telemetria IDE | `tools/ceo-ide-telemetry-status.ps1`, `.vscode/tasks.json`, `VERSION_STATE.json` | estado runtime, tasks telemetry/watchdog/evidence | task READY y comando READY | `ceo-runtime-state.ps1` escribe `VERSION_STATE.json`; no tratar como read-only |
| Trace/observabilidad | `tools/ceo-trace-export.ps1`, `ceo-trace-indexer.ps1`, `ceo-trace-query.ps1`, `ceo-trace-dashboard.ps1`, `web/data.json`, `web/index.html` | export, query, dashboard, anomalies, alerts, timeline | presente; `web/data.json` existe | dashboard puede estar stale; generar dashboard escribe archivos |
| Sentinel repo-local | `tools/sdu_sentinel.py`, `operativa/SDU_SENTINEL_CONFIG_20260622.json`, `operativa/sentinel/SENTINEL_REPORT.json`, `operativa/sentinel/DRIFT_LOG.json` | scan drift, guard, report/check, blocked patterns, external surface guard | presente; ultimo `SENTINEL_REPORT` es `WARN` con drift | report/check escriben; reporte stale frente al dirty set actual |
| Watchdog externo documental | `.agileagentcanvas-context/sdu/artifacts/watchdog.json`, `docs/watchdogs/*`, `08_READBACKS/SDU_NOC_WEB.md` | watchdog/NOC documental externo y SharePoint link watchdog | referencia declarada a `C:\CEO\watchdog` | autoridad viva no resuelta dentro del repo; no confundir con sentinel local |
| Agents SDK local | `pyproject.toml`, `src/projec_cdx_cloud/*`, `src/launch_desk/*`, `tools/ceo-sdk-*.ps1` | `openai-agents`, `Agent`, `Runner`, `function_tool`, seis SDK-SDU agents | instalado localmente: `openai-agents 0.17.7`; seis agentes construibles metadata-only | live SDK requiere `OPENAI_API_KEY` y gate; no API call ejecutada |
| Skills/recipes/plugins | `.agents/skills/agileagentcanvas-help/SKILL.md`, `recipes/*`, `operativa/tasks/20260626/.../plugin-gate-matrix.json` | router AAC, recetas, plugin gate matrix | presente | plugins/cache no implican permiso live |

## Agents SDK

HECHO_VERIFICADO:

El repo contiene dos superficies SDK reales:

- `src/launch_desk`: agente `Launch Desk`, `Runner.run_streamed`,
  `Runner.run` y herramientas `@function_tool`.
- `src/projec_cdx_cloud`: agente Codex Cloud, cloud bridge, seis perfiles
  SDK-SDU y reporte gobernado.

Validacion local por import, sin `.env`, sin secretos y sin API:

- `openai_api_key_present=false`
- `agents_sdk_installed=true`
- `agents_sdk_version=0.17.7`
- `sdu_sdk_agents_defined=6`
- agentes SDK-SDU:
  - `seshat-normativa`
  - `thot-tecnico`
  - `anubis-gate`
  - `maat-cumplimiento`
  - `horus-riesgo`
  - `narrador-normativo`

Riesgo detectado:

- Las variables `CODEX_CLOUD_REPO_ROOT`, `CODEX_CLOUD_WORKTREE` y
  `CODEX_CLOUD_BRANCH` heredadas no coinciden con el repo actual.
- Antes de cualquier run live SDK hay que normalizar contexto o ejecutar con
  entorno limpio y gate explicito.

## Watchdog / Sentinel

Dictamen:

- `sentinel` repo-local esta presente y gobernado.
- `watchdog` externo `C:\CEO\watchdog` aparece como evidencia documental y NOC,
  no como autoridad viva resuelta dentro de este repo.
- No se puede fusionar `watch`, `watchdog`, `sentinel` y `NOC` como una sola
  superficie sin una reconciliacion explicita de runtime.

## Stop Conditions

Este carril queda cerrado si aparece cualquiera de estas condiciones:

- necesidad de correr `ceo-execution-adapter.ps1`
- necesidad de drenar bus suite
- necesidad de regenerar sentinel report o dashboard
- necesidad de leer `.env` o `OPENAI_API_KEY`
- necesidad de llamar OpenAI API live
- necesidad de tocar `C:\CEO\watchdog`
- necesidad de activar MCP, plugin server, scheduler, service o workflow
- necesidad de stage, commit, push, fetch, PR o remote write

## Siguiente Gate Tecnico

1. `VERSION_STATE_RECONCILE_AFTER_SURFACE_SCAN`
2. `WATCHDOG_AUTHORITY_RECONCILIATION_READ_ONLY`
3. `BUS_DRAIN_OWNER_GATE_OPTIONAL`
4. `SDK_CONTEXT_NORMALIZATION_NO_SECRET`
5. `TRACE_DASHBOARD_REFRESH_OWNER_GATE_OPTIONAL`

## Postcheck

HECHO_VERIFICADO:

`VERSION_STATE.json` fue reconciliado despues de crear este readback:

- `VERSION_STATE.status`: 52
- `git status --porcelain=v1 --untracked-files=all`: 52
- faltantes vivos en `VERSION_STATE.status`: 0
- stale en `VERSION_STATE.status`: 0
- `delta_count`: 52
- `integrity`: `RECONCILED_DIRTY_PENDING_STAGE`
- `reconciliation.state`:
  `OWNER_GATE_RECONCILED_AFTER_SURFACE_SCAN_NO_STAGE`

Validaciones:

- JSON parse `VERSION_STATE.json`: PASS
- JSON parse `SYSTEM_NERVOUS_INDEX.json`: PASS
- JSON parse `operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json`: PASS
- JSON parse `operativa/sentinel/SENTINEL_REPORT.json`: PASS
- JSON parse `sdk-assets-map.json`: PASS
- Agents SDK metadata-only import: PASS
  - `openai-agents`: `0.17.7`
  - `OPENAI_API_KEY`: ausente
  - SDK-SDU agents construibles: 6
  - external writes: false
- `git diff --check`: PASS con warnings conocidos LF -> CRLF.

## Contrato De Cierre

- agente: `narrador-normativo`
- orden: `buscar_bus_telemetria_watchdog_runner_agents_sdk`
- superficie: `repo-local`
- skill: `governed-readback-closeout`, `repo-agent-tool-governance`, `parallel-agentic-repo-audit`, `openai-developers:agents-sdk`
- receta: `agentes-atomicos-algoritmicos-en-waves`, `cierre-wave-documental`
- tool: PowerShell local, subagentes explorer, import Python metadata-only
- estado: `SURFACES_IDENTIFIED_LOCAL_ONLY`
- evidencia: este archivo
- validador: lectura local, parse JSON, import SDK metadata-only, subagent fan-in
- riesgo: `TOOLS_WITH_STATUS_NAMES_CAN_WRITE_VERSION_STATE_OR_RUNTIME_EVIDENCE`
- rollback: borrar este readback y reconciliar `VERSION_STATE.json`
- stop_condition: no live/no secrets/no remote/no services/no cleanup/no runner drain
- proximos_carriles: version-state reconcile, watchdog authority, sdk context normalization
