# Total Reading and Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ejecutar una lectura total y reconciliacion gobernada del estado vivo de `PROJEC CDX`, `C:\CEO`, `watch/watchdog`, bus, telemetria, runners, agentes SDK y `VERSION_STATE.json`.

**Architecture:** La reconciliacion se ejecuta por oleadas read-first con fan-in de agentes y un unico cierre narrativo. La escritura queda limitada a artefactos locales de evidencia y a `VERSION_STATE.json` solo bajo `OWNER_GATE_VERSION_STATE_RECONCILE`; no hay stage, commit, remoto, live write, scheduler, cleanup ni G11 apply por inferencia.

**Tech Stack:** PowerShell local, Git read-only, Python local, OpenAI Agents SDK existente, validadores repo-locales, `SYSTEM_NERVOUS_INDEX.json`, `VERSION_STATE.json`, artefactos `operativa/tasks/20260626`.

---

## Current Input Snapshot

Estado confirmado antes de este plan:

- Rama viva: `codex/live-state-g10-governed-20260626`
- Version: `v0.6.0-rc1`
- HEAD local: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- Ahead local contra `origin/main`: `54`
- Dirty set en `VERSION_STATE.json`: `61`
- Maximo declarado: `SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED`
- Nivel: `G10_REPO_CANONICAL_BOUNDARY_WITH_G8_5_DOCUMENTAL_CERTIFICATION`
- Modo: `LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC`
- Agents SDK: `openai-agents 0.17.7`
- Agentes SDK activados por API: `6/6`
- Gate activo: `metadata-only`

## Source Files

Lectura primaria:

- `VERSION_STATE.json`
- `SYSTEM_NERVOUS_INDEX.json`
- `SDU_SYSTEM_CONTRACT.md`
- `SDU_STATE_G10.md`
- `operativa/CURRENT.md`
- `operativa/NEXT.md`
- `operativa/CONTROL.md`
- `operativa/TRACE.md`
- `contracts/agent-map.json`
- `contracts/contract-map.json`
- `contracts/federation-map.json`
- `contracts/schemas/event-envelope.schema.json`
- `operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json`

Lectura de evidencia existente:

- `operativa/tasks/20260626/CONTROL_TOTAL_AGENTES_PLAN_20260626.md`
- `operativa/tasks/20260626/READBACK_LECTURA_47_ENTRADAS_20260626.md`
- `operativa/tasks/20260626/READBACK_VERSION_STATE_RECONCILIATION_20260626.md`
- `operativa/tasks/20260626/READBACK_BUS_TELEMETRY_WATCHDOG_RUNNER_SDK_AGENTS_20260626.md`
- `operativa/tasks/20260626/READBACK_CEO_ROOT_READING_20260626.md`
- `operativa/tasks/20260626/CEO_ROOT_AUTHORITY_MATRIX_20260626.md`
- `operativa/tasks/20260626/CEO_WATCH_WATCHDOG_DELTA_20260626.md`
- `operativa/tasks/20260626/PLAN_OPENAI_API_AGENTS_CELL_20260626.md`

Lectura externa local, sin ejecucion:

- `C:\Users\enzo1\.codex\CARTOGRAFIA_COMPLETA.md`
- `C:\CEO\README.md`
- `C:\CEO\AGENTS.md`
- `C:\CEO\policy.json`
- `C:\CEO\core\70-Watch.ps1`
- `C:\CEO\watch`
- `C:\CEO\watchdog`
- `C:\CEO\.metadata`

Salidas permitidas bajo este plan:

- Crear: `operativa/tasks/20260626/TOTAL_RECONCILIATION_MATRIX_20260626.json`
- Crear: `operativa/tasks/20260626/TOTAL_RECONCILIATION_FANIN_20260626.md`
- Crear: `operativa/tasks/20260626/READBACK_TOTAL_RECONCILIATION_20260626.md`
- Modificar opcional con gate: `VERSION_STATE.json`
- No modificar: `C:\CEO\watch`, `C:\CEO\watchdog`, `C:\CEO\.metadata`, Git remoto, Microsoft, Dataverse, SharePoint, Power Platform, Codex Cloud.

## Agent Lanes

| Lane | Agente | Responsabilidad | Entrada | Salida |
| --- | --- | --- | --- | --- |
| CANON_AUTHORITY | `seshat-normativa` | Resolver fuente de verdad y jerarquia canonica | CURRENT/NEXT/SNS/contratos | dictamen canonico |
| TECH_ROUTE | `thot-tecnico` | Mapear herramientas, runners, scripts y rutas | tools/src/contracts | matriz tecnica |
| GATE_ROLLBACK | `anubis-gate` | Stop conditions, gates, rollback, no-inference guard | plan + riesgos | matriz de permisos |
| VALIDATION | `maat-cumplimiento` | Validadores, schema, JSON/CSV parse, fail-closed | validators + outputs | resultado de checks |
| RISK_OBSERVABILITY | `horus-riesgo` | Watchdog, telemetria, drift, NOC, bus risk | C:\CEO + repo evidence | informe de riesgo |
| READBACK | `narrador-normativo` | Fan-in, cierre, contrato de estado vivo | todas las salidas | readback final |

Uso de OpenAI API:

- Permitido solo para fan-in y critica de plan con resumentes saneados.
- No enviar `.env`, secretos, logs crudos, dumps completos ni CSV masivos.
- Limite por prompt de agente: resumen acotado, rutas, conteos, hashes cortos y decisiones.
- No otorgar a los agentes herramientas que ejecuten scripts, muevan archivos, hagan Git remoto o toquen Microsoft live.

## Task 1: Snapshot Read-Only De Entrada

**Files:**
- Read: `VERSION_STATE.json`
- Read: `SYSTEM_NERVOUS_INDEX.json`
- Read: `operativa/CURRENT.md`
- Read: `operativa/NEXT.md`
- Output: memoria de ejecucion o `TOTAL_RECONCILIATION_MATRIX_20260626.json` si se aprueba escritura local

- [ ] **Step 1: Capturar Git local sin remoto**

Run:

```powershell
git branch --show-current
git rev-parse HEAD
git status --porcelain=v1 --untracked-files=all
git rev-list --count origin/main..HEAD
```

Expected:

```text
branch = codex/live-state-g10-governed-20260626
head = e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
status_count >= 61
ahead_origin_main = 54
```

- [ ] **Step 2: Parsear JSON rector**

Run:

```powershell
.\.venv\Scripts\python.exe -m json.tool VERSION_STATE.json > $null
.\.venv\Scripts\python.exe -m json.tool SYSTEM_NERVOUS_INDEX.json > $null
```

Expected:

```text
exit code 0 en ambos archivos
```

- [ ] **Step 3: Comparar snapshot dinamico**

Calcular:

```text
live_status = git status --porcelain=v1 --untracked-files=all
version_status = VERSION_STATE.status
missing_in_version = live_status - version_status
stale_in_version = version_status - live_status
```

Expected:

```text
faltantes vivos = 0 para cierre PASS
stale = 0 para cierre PASS
si hay delta, marcar VERSION_STATE_DYNAMIC_DRIFT
```

## Task 2: Reconciliacion De Fuentes Canonicas

**Files:**
- Read: `operativa/CURRENT.md`
- Read: `operativa/NEXT.md`
- Read: `SDU_STATE_G10.md`
- Read: `SDU_SYSTEM_CONTRACT.md`
- Read: `docs/SDU_FINAL_PACKAGE/README.md`
- Read: `08_READBACKS/20260626_SDU_MAX_LEVEL_PROMOTION.md`
- Output: `TOTAL_RECONCILIATION_MATRIX_20260626.json`

- [ ] **Step 1: Construir tabla de autoridad**

Clasificar cada fuente como:

```text
CANON_ACTIVE
CANON_SUPPORT
EVIDENCE_READBACK
PLAN_ONLY
REVIEW_ONLY
LEGACY_PRESERVE
STALE_DYNAMIC
```

Expected:

```text
CURRENT/NEXT/SNS/SDU_SYSTEM_CONTRACT = CANON_ACTIVE
G11 policy proposal = REVIEW_ONLY
branch governance = PLAN/AUDIT_ONLY
watch legacy = LEGACY_PRESERVE
```

- [ ] **Step 2: Resolver maximo alcanzado**

Regla:

```text
G10 + G8.5 documental certificado manda sobre planes G11 review-only.
LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC no habilita ejecucion automatica.
```

Expected:

```text
max_level = G10_REPO_CANONICAL_BOUNDARY_WITH_G8_5_DOCUMENTAL_CERTIFICATION
production_ready = true
automatic_execution = false
external_send = false
```

## Task 3: Reconciliacion Del Dirty Set

**Files:**
- Read: `git status`
- Read: `operativa/tasks/20260626/READBACK_LECTURA_47_ENTRADAS_20260626.md`
- Read: `operativa/tasks/20260626/READBACK_VERSION_STATE_RECONCILIATION_20260626.md`
- Optional Modify with gate: `VERSION_STATE.json`

- [ ] **Step 1: Clasificar cada entrada dirty**

Buckets obligatorios:

```text
CORE_G10_VERSIONABLE
EVIDENCE_VERSIONABLE
PLAN_OR_AUDIT_SUPPORT
LOCAL_RUNTIME_SUPPORT
REVIEW_ONLY_G11
SENSITIVE_NO_TOUCH
GENERATED_NOISE
UNKNOWN_REQUIRES_OWNER
```

Expected:

```text
100% de entradas dirty clasificadas
0 entradas UNKNOWN para reconciliacion final
```

- [ ] **Step 2: Decidir reconciliacion de `VERSION_STATE.json`**

Gate requerido:

```text
OWNER_GATE_VERSION_STATE_RECONCILE
```

Si el gate esta aprobado, actualizar solo campos dinamicos:

```text
branch
commit
commits_ahead_baseline
generated_at_utc
status
reconciliation
delta_count
integrity
```

Expected:

```text
max_level_reached, g7, g8, g9, g10 y g11 se preservan salvo evidencia nueva versionada.
```

## Task 4: Bus, Runner Y Contratos

**Files:**
- Read: `SYSTEM_NERVOUS_INDEX.json`
- Read: `contracts/agent-map.json`
- Read: `contracts/contract-map.json`
- Read: `contracts/schemas/event-envelope.schema.json`
- Read: `tools/ceo-event-publish.ps1`
- Read: `tools/ceo-event-dispatcher.ps1`
- Read: `tools/ceo-event-worker.ps1`
- Read: `tools/ceo-event-runner.ps1`
- Read: `tools/ceo-execution-adapter.ps1`
- Read: `tools/ceo-runtime-router.ps1`

- [ ] **Step 1: Verificar mapa SNS**

Expected:

```text
agents = 14
routes = 15
failClosed = true
liveWrite = false
secretAccess = false
```

- [ ] **Step 2: Separar lectura de ejecucion**

Permitido:

```text
Get-Content de contratos y scripts
json parse de schemas
lectura de logs curados si no contienen secretos
```

Bloqueado:

```text
ceo-execution-adapter.ps1
ceo-event-worker.ps1
ceo-event-runner.ps1
ceo-validate-bus.ps1 si inicializa estado
drenar queue.jsonl
replay que escriba processed/failed
```

Expected:

```text
BUS_CAPABILITY_PRESENT
RUNNER_PRESENT_NOT_EXECUTED
CONTRACTS_PARSE_PASS
```

## Task 5: Telemetria, Watchdog, Watch Y NOC

**Files:**
- Read: `operativa/tasks/20260626/CEO_ROOT_AUTHORITY_MATRIX_20260626.md`
- Read: `operativa/tasks/20260626/CEO_WATCH_WATCHDOG_DELTA_20260626.md`
- Read: `C:\CEO\policy.json`
- Read: `C:\CEO\core\70-Watch.ps1`
- Read: `C:\CEO\watchdog\telemetry.json`
- Read: `C:\CEO\watchdog\state\predictive_score.json`
- Read: `C:\CEO\watchdog\state\systems_status.json`
- Read: `C:\CEO\watchdog\logs\alerts.jsonl`
- Read: `C:\CEO\watchdog\logs\action_execution.jsonl`

- [ ] **Step 1: Confirmar autoridad**

Expected:

```text
C:\CEO\watchdog = PRIMARY_ACTIVE
C:\CEO\watch = LEGACY_READONLY_STALE
do_not_start watch = true
do_not_delete watch = true
```

- [ ] **Step 2: Registrar riesgo vivo**

Expected:

```text
predictive_score = 68
health = YELLOW
risk = HIGH
graphOk = true
SYSTEM_AUTO only READ_ONLY observed
```

- [ ] **Step 3: Mantener stops duros**

Bloqueado:

```text
Start-CEO.ps1
CEO-Watchdog.ps1
watchdog.ps1
run-documentlocation-loop.ps1
owner_actions_server.py
serve.ps1
scheduler real del SO
Stop-Process / Kill / restart services
```

Expected:

```text
WATCHDOG_AUTHORITY_RECONCILED_READ_ONLY
NO_SERVICE_STARTED
NO_SCHEDULER_VALIDATED_WITHOUT_GATE
```

## Task 6: Agents SDK Y OpenAI API

**Files:**
- Read: `src/projec_cdx_cloud/agent.py`
- Read: `src/projec_cdx_cloud/cli.py`
- Read: `src/projec_cdx_cloud/cloud_bridge.py`
- Read: `src/launch_desk/agent.py`
- Read: `src/launch_desk/service.py`
- Read: `pyproject.toml`

- [ ] **Step 1: Smoke local sin API**

Run:

```powershell
.\.venv\Scripts\python.exe -m projec_cdx_cloud --smoke --json
.\.venv\Scripts\python.exe -m projec_cdx_cloud --activate-sdu --json
```

Expected:

```text
agents_sdk_installed = true
agents_sdk_version = 0.17.7
sdu_sdk_agents_defined = 6
activate-sdu count = 6
```

- [ ] **Step 2: Fan-in API opcional**

Gate requerido:

```text
OWNER_GATE_OPENAI_API_FANIN_METADATA_ONLY
```

Prompt policy:

```text
solo resumen saneado
sin secretos
sin archivos completos sensibles
sin tool execution de scripts
sin writes
```

Expected:

```text
api_activation_complete
ok_count = 6/6
gate = metadata-only
```

## Task 7: Validacion Local

**Files:**
- Read/execute local validators only:
  - `tools/validate_proj_cdx_sync.ps1`
  - `tools/validate_proj_cdx_workbench.ps1`
  - `tools/validate_proj_cdx_operational_chain.ps1`
  - `tools/validate_sdu_dataverse_metadata_wave.ps1`
  - `tools/sdu_boot.ps1`
  - `tools/ceo-jsonschema-validate.py`

- [ ] **Step 1: Correr validadores permitidos**

Run:

```powershell
.\tools\validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json
.\tools\validate_proj_cdx_workbench.ps1 -Root C:\CEO\project-cdx -Json
.\tools\validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -Json
.\tools\validate_sdu_dataverse_metadata_wave.ps1 -Root C:\CEO\project-cdx
.\tools\sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json
.\.venv\Scripts\python.exe tools\ceo-jsonschema-validate.py SYSTEM_NERVOUS_INDEX.json contracts\schemas\system-nervous-index.schema.json
git diff --check
```

Expected:

```text
sync = PASS
workbench = OBSERVED allowed, 0 FAIL
operational_chain = PASS
dataverse metadata wave = PASS
sdu_boot = PASS
SNS schema = VALID
git diff --check = PASS or PASS_WITH_KNOWN_CRLF_WARNINGS
```

- [ ] **Step 2: No correr validadores con efectos no aceptados**

Bloqueado sin gate:

```text
pytest completo
ceo-validate-bus.ps1
sdu_sentinel.py report/check si escribe
scripts bajo .cabina que generen out/logs/evidence
```

## Task 8: Fan-In Final Y Reconciliacion

**Files:**
- Create: `operativa/tasks/20260626/TOTAL_RECONCILIATION_MATRIX_20260626.json`
- Create: `operativa/tasks/20260626/TOTAL_RECONCILIATION_FANIN_20260626.md`
- Create: `operativa/tasks/20260626/READBACK_TOTAL_RECONCILIATION_20260626.md`
- Optional Modify with gate: `VERSION_STATE.json`

- [ ] **Step 1: Construir matriz total**

Matriz minima:

```json
{
  "schema_version": "1.0",
  "mode": "TOTAL_READING_RECONCILIATION_G1",
  "branch": "codex/live-state-g10-governed-20260626",
  "head": "e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11",
  "max_level": "G10_REPO_CANONICAL_BOUNDARY_WITH_G8_5_DOCUMENTAL_CERTIFICATION",
  "live_mode": "LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC",
  "agents": {},
  "surfaces": {},
  "dirty_classification": {},
  "gates": {},
  "validators": {},
  "stop_conditions": []
}
```

- [ ] **Step 2: Escribir fan-in**

Contenido obligatorio:

```text
estado vivo
que se leyo
que no se ejecuto
dictamen por agente
VERSION_STATE drift o reconciliado
watch/watchdog authority
bus/runner state
agents SDK/API state
validaciones
riesgos
rollback
proximo gate unico
```

- [ ] **Step 3: Cerrar readback final**

Expected:

```text
READBACK_TOTAL_RECONCILIATION_20260626.md creado
no stage
no commit
no push
no fetch
no live
no secrets
```

## Task 9: Gate Opcional De Versionado

**Files:**
- Optional Modify: `VERSION_STATE.json`
- Optional Git only with explicit owner gate: stage/commit

- [ ] **Step 1: Si el owner aprueba, actualizar freeze**

Gate exacto:

```text
OWNER_GATE_VERSION_STATE_RECONCILE_AND_FREEZE
```

Expected:

```text
VERSION_STATE.status == git status vivo posterior al readback
delta_count == status_count
integrity = RECONCILED_DIRTY_PENDING_STAGE
reconciliation.state = TOTAL_READING_RECONCILIATION_G1_NO_STAGE
```

- [ ] **Step 2: Stage/commit solo con gate separado**

Gate exacto:

```text
OWNER_GATE_STAGE_COMMIT_TOTAL_RECONCILIATION
```

Blocked until explicit:

```text
git add
git commit
git push
PR
merge
restore
reset
```

## Stop Conditions

Parar y pedir gate si aparece cualquiera de estos casos:

- Necesidad de leer secretos, `.env`, tokens o backups sensibles.
- Necesidad de ejecutar `Start-CEO.ps1`, `watch`, `watchdog`, scheduler, NOC server o owner actions server.
- Necesidad de drenar bus, replay real, mover eventos a processed/failed o ejecutar runners.
- Necesidad de Microsoft, Dataverse, SharePoint, Power Platform o Codex Cloud live.
- Necesidad de Git remoto, fetch, push, PR, checkout, reset, restore o cleanup.
- Necesidad de aplicar G11 policy tuning.
- Contradiccion entre `CURRENT/NEXT/SNS` y evidencia sin fuente primaria clara.

## Rollback

Rollback documental:

```text
remover TOTAL_RECONCILIATION_MATRIX_20260626.json
remover TOTAL_RECONCILIATION_FANIN_20260626.md
remover READBACK_TOTAL_RECONCILIATION_20260626.md
recalcular VERSION_STATE.json solo si fue modificado y con gate
```

No hay rollback externo porque el plan no autoriza writes fuera del repo.

## Execution Choice

Plan completo y guardado en `docs/superpowers/plans/2026-06-26-total-reading-reconciliation.md`.

Dos opciones de ejecucion:

1. **Subagent-Driven recomendado**: despachar un agente fresco por lane, fan-in y revision entre tareas.
2. **Inline Execution**: ejecutar tareas en esta sesion por oleadas con checkpoints antes de cualquier escritura.

Recomendacion operativa: `Subagent-Driven` para lectura y fan-in; `Inline Execution` solo para el cierre `VERSION_STATE.json` si el owner aprueba el gate.
