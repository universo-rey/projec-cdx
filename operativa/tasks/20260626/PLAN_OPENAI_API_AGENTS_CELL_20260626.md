# Plan - celda de agentes con OpenAI API

Fecha UTC: 2026-06-26
Modo: PLAN_ONLY_NO_API_CALLS
Scope: `C:\CEO\project-cdx`

## Objetivo

Preparar una celda de agentes que use OpenAI API mediante OpenAI Agents SDK, integrada al sistema vivo actual sin exponer secretos, sin tocar Microsoft live, sin ejecutar acciones remotas y sin duplicar la capa de agentes existente.

El primer entregable no es una app nueva aislada: es una capa gobernada que toma los agentes canonicos actuales y los vuelve ejecutables por API con contratos, herramientas locales, gates, evaluacion y evidencia.

## Fuentes Locales Usadas

- `pyproject.toml`: ya declara `openai-agents>=0.17.5` y extra `agents-sdk`.
- `.cabina\SDU_RUNTIME_ROOT\07_RUNTIMES\AGENTS_SDK\FUNCTIONAL_AGENT_RUNTIME.md`
- `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\functional-agent-runtime.v1.yaml`
- `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\agent-role-map.yaml`
- `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\top001-specialized-agents.v1.yaml`
- `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\agent-risk-controls.v1.yaml`
- `SYSTEM_NERVOUS_INDEX.json`
- `operativa/tasks/20260626/CEO_ROOT_AUTHORITY_MATRIX_20260626.md`

## Gate Cero: Credenciales

Antes de escribir codigo que llame a OpenAI API, correr tests con API o levantar un servicio:

- Verificar presencia de `OPENAI_API_KEY` sin imprimir valores.
- Si existe, pedir confirmacion para reutilizarla.
- Si no existe, usar el flujo seguro de OpenAI Platform para crear/provisionar una clave.
- No guardar claves en archivos trackeados.
- No registrar claves en logs, readbacks, traces, prompts ni snapshots.
- No dar instrucciones manuales de pegado de clave si el conector seguro esta disponible.

Estado de este plan: no se inspecciono ni uso ninguna clave; no hubo llamada API.

## Arquitectura Propuesta

```text
usuario / CLI / NOC local
  -> API facade local
  -> Orchestrator Agent
  -> specialist agents
  -> function tools locales whitelisted
  -> evidence/readback local
```

Paquete propuesto:

```text
src/projec_cdx_openai_agents/
  __init__.py
  agent_cell.py
  agents.py
  tools.py
  schemas.py
  guards.py
  runner.py
  server.py
  evidence.py
docs/openai-agents/
  prompt.md
  contracts.md
  validation.md
evals/openai_agents/
  cases.jsonl
  run_local.py
  results/.gitignore
```

Entrada CLI propuesta:

```text
ceo-openai-agents
```

Entrada HTTP opcional:

```text
GET /health
POST /agents/run
POST /agents/eval
```

## Celda De Agentes

| Agente API | Base canonica | Funcion | Modo inicial | Puede escribir |
|---|---|---|---|---|
| `OrchestratorAgent` | `orchestrator_agent` / SESHAT | Recibe pedido, enruta, compone salida | PLAN | No |
| `SeshatAgent` | SESHAT | Canon, mapa, clasificacion semantica | EXPLORE/PLAN | Solo artefactos de plan con gate |
| `ThotAgent` | THOT | Diseno tecnico, contratos, config | DESIGN/PLAN | Solo archivos nuevos bajo `operativa/tasks` con gate |
| `AnubisGuardAgent` | ANUBIS | Riesgo, permisos, rollback, stop conditions | PLAN | No |
| `MaatEvidenceAgent` | MAAT | Evidencia, readback, trazabilidad | PLAN/LEARN | Solo readbacks con gate |
| `HorusObservabilityAgent` | HORUS | Drift, watchdog, telemetria saneada | EXPLORE | No |
| `NarradorAgent` | NARRADOR | Cierre, memoria, handoff | LEARN | Solo readback con gate |

Regla de inicio: construir primero un solo `Agent` orquestador con herramientas locales. Agregar especialistas/handoffs solo cuando el smoke demuestre que la separacion aporta control real.

## Herramientas Locales Permitidas

Todas las herramientas deben ser `@function_tool` con schemas explicitos.

| Tool | Lee | Escribe | Riesgo | Gate |
|---|---|---|---|---|
| `read_version_state_summary` | `VERSION_STATE.json` | No | Bajo | No |
| `read_system_nervous_summary` | `SYSTEM_NERVOUS_INDEX.json` | No | Bajo | No |
| `read_watchdog_health_summary` | archivos curados de `C:\CEO\watchdog\state` | No | Medio | Sanitizer |
| `list_agent_contracts` | `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\agent*.yaml` | No | Bajo | No |
| `propose_plan_artifact` | input saneado | Archivo nuevo en `operativa/tasks/YYYYMMDD` | Medio | Owner local |
| `write_readback_artifact` | input saneado | Archivo nuevo en `operativa/tasks/YYYYMMDD` | Medio | Owner local |
| `validate_artifact_json` | artefactos JSON locales | No | Bajo | No |
| `compute_git_delta_summary` | `git status` local | No | Bajo | No remote |

Bloqueado por defecto:

- Leer `.env*`, secretos, tokens, claves, backups sensibles.
- Enviar logs completos o CSV grandes al modelo.
- Ejecutar `.ps1`, `.cmd`, `.bat` desde herramientas del agente.
- Git push/fetch/PR.
- Microsoft/Dataverse/SharePoint live.
- `Remove-Item`, `Move-Item`, `git reset`, `git clean`.
- Arrancar `Start-CEO.ps1`, `watch`, `watchdog`, NOC web o scheduler.

## Politica De Datos Enviados A OpenAI API

- Solo enviar resúmenes saneados y acotados.
- Limite recomendado por tool output: 8 KB por herramienta y 32 KB por corrida.
- Nunca enviar secretos, `.env`, claves, contenido sensible de cliente, dumps completos, logs crudos, CSV masivos ni rutas personales innecesarias.
- Todo resumen debe declarar `source`, `timestamp`, `truncated`, `sensitive_skipped`.
- El agente debe preferir IDs de archivo y rutas sobre contenido completo.

## Fases

### Fase 0 - Gate de credenciales

Owner: ANUBIS

- Verificar presencia de `OPENAI_API_KEY` sin imprimirla.
- Pedir decision: reutilizar existente o crear nueva.
- Si se crea, usar OpenAI Platform connector.
- Confirmar destino local ignorado si se escribe.

Salida: `SECRET_GATE_READY` o `SECRET_REQUIRED_READBACK`.

### Fase 1 - Contrato API local

Owner: SESHAT + MAAT

- Definir schemas de input/output.
- Declarar limites de datos, tools permitidas y stop conditions.
- Crear contrato `docs/openai-agents/contracts.md`.

Salida: contrato listo, sin codigo API.

### Fase 2 - Orquestador minimo

Owner: THOT

- Crear `agent_cell.py`, `agents.py`, `tools.py`, `schemas.py`.
- Implementar un `Agent` unico con instrucciones estaticas.
- Usar `Runner.run` para prueba local.
- Sin handoffs todavia.

Salida: smoke CLI con una consulta saneada.

### Fase 3 - Tools locales

Owner: THOT + ANUBIS

- Implementar tools read-only.
- Agregar guardrails de path allowlist.
- Agregar redaccion/sanitizacion antes de enviar salida al modelo.
- Registrar evidencia de cada tool call.

Salida: tool summary reproducible.

### Fase 4 - Especialistas y handoffs

Owner: SESHAT

- Separar especialistas solo si el orquestador minimo ya pasa smoke.
- Handoffs: SESHAT -> THOT -> ANUBIS -> MAAT/HORUS/NARRADOR segun objetivo.
- Cada handoff debe tener contrato de entrada/salida.

Salida: multi-agent cell con handoffs gobernados.

### Fase 5 - Evals

Owner: MAAT + HORUS

Casos minimos:

1. Plan simple sin escritura.
2. Solicitud con secreto: debe bloquear.
3. Solicitud de Git remoto: debe bloquear.
4. Solicitud de Microsoft live: debe bloquear.
5. Lectura `watchdog` saneada: debe resumir sin raw logs.
6. Escritura de readback nuevo: exige gate y queda bajo `operativa/tasks`.
7. Conflicto `watch` vs `watchdog`: debe resolver como `WATCHDOG_L6 PRIMARY_ACTIVE` + `watch legacy`.

Salida: `evals/openai_agents/results/latest.json`.

### Fase 6 - Servicio local opcional

Owner: THOT

- `server.py` con FastAPI.
- `/health` sin API call.
- `/agents/run` con credential gate activo.
- No abrir puerto por defecto si no se pide.

Salida: servicio listo para despliegue local.

### Fase 7 - Freeze y promocion

Owner: MAAT

- Actualizar `VERSION_STATE.json`.
- Crear readback final.
- Proponer skill/receta si el patron queda estable.

Salida: `READBACK_OPENAI_API_AGENTS_CELL_YYYYMMDD.md`.

## Criterios De Aceptacion

- No hay plaintext de `OPENAI_API_KEY` en salida, logs, artefactos o Git.
- La primera ejecucion API ocurre solo despues del gate de credenciales.
- El smoke demuestra una respuesta del agente y al menos una tool local read-only.
- Los evals bloquean secretos, remoto, live y acciones destructivas.
- Los agentes no ejecutan scripts PowerShell ni runtime vivo.
- `watchdog` se trata como autoridad primaria y `watch` como legacy preservado.
- `VERSION_STATE.json` refleja el delta posterior.

## Riesgos

- Sobreexponer datos locales al modelo si no se recorta/sanitiza.
- Confundir autorizacion OpenAI API con permiso para Microsoft live o Dataverse.
- Duplicar agentes en vez de reutilizar contratos existentes.
- Convertir NOC/G9 en autoaccion no gobernada.
- Arrancar servicios o scheduler por error durante pruebas.

## Decision Recomendada

Avanzar en dos pasos:

1. Aprobar Fase 0 + Fase 1 para dejar contrato y credential gate.
2. Despues de decidir credencial, implementar Fase 2 con un solo orquestador y tools read-only.

No conviene empezar con todos los especialistas ejecutables. Primero se prueba el camino minimo, luego se separa por handoffs.

## Output Contract

- `PLAN`: OPENAI_API_AGENTS_CELL_G1
- `MODE`: PLAN_ONLY_NO_API_CALLS
- `SDK`: OpenAI Agents SDK
- `LANGUAGE`: Python
- `FIRST_AGENT`: OrchestratorAgent
- `SPECIALISTS`: SESHAT, THOT, ANUBIS, MAAT, HORUS, NARRADOR
- `CREDENTIAL_GATE`: REQUIRED_BEFORE_BUILD_RUN_TEST
- `DATA_POLICY`: SANITIZED_BOUNDED_NO_SECRETS
- `LIVE_WRITE`: false
- `MICROSOFT_LIVE`: false
- `GIT_REMOTE`: false
- `NEXT_GATE`: approve credential gate and local contract phase
