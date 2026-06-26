---
artifact_id: operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_PLAN_20260622.md
categoria: operativa
tipo: plan
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_PLAN_20260622.md
etiquetas:
- cabina
- gobierno-total
- plan-first
- local-only
- sdu
relacionados:
- operativa/archive/legacy-root/20260622/READBACK_CABINA_GOBIERNO_TOTAL_PLAN_FIRST_20260622.md
- operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_AGENT_CARRIL_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_FOLDER_REPO_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_CONNECTOR_GATE_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_RUNNER_PLUGIN_SKILL_RECIPE_MATRIX_20260622.csv
descripcion: Plan rector para ordenar ecosistema local, agentes, skills, runners, plugins, conectores y carpetas antes de ejecutar waves.
fecha_evento: '2026-06-22'
---

# CABINA GOBIERNO TOTAL PLAN 20260622

## Estado de entrada

- `CABINA_TOTAL_STACK_WARNINGS_CLOSED_LOCAL_ONLY`
- `CEO_PATH_REPAIRED_CANONICAL_RUNTIME`
- `CABINA_LOCAL_FULL_STACK_CANON_READY_NO_DRIFT`

## Principio

Plan primero. Ejecucion despues. Ningun movimiento de carpetas, mutacion `.codex`, conector live, MCP execution, push, PR o API call sin matriz, owner, rollback, postcheck y evidencia.

## Workspace rector

- Canon: `C:\CEO\project-cdx`
- Alias fisico: `C:\Users\enzo1\PROJEC CDX`
- Identidad operativa: `CEO`

## Fuentes leidas para este plan

- Orden adjunta `CABINA_GOBIERNO_TOTAL_PLAN_PRIMERO_EJECUCION_DESPUES`.
- Data Analytics preflight: fuentes activas `structured_data`, `team_communication`, `company_docs`, `code_repository`; fuentes diferidas `dashboards_bi`, `behavior_signals`, `notebook_lab`, `email_context`, `calendar_context`.
- OpenAI Codex manual local actualizado: skills, plugins, MCP, IDE extension y Windows platform.
- Skills nombradas: `openai-docs`, `openai-developers:chatgpt-app-submission`, `openai-developers:openai-api-troubleshooting`, `data-analytics:index`.
- VS Code Insiders: version `1.126.0-insider`, extensiones totales `126`, agentes/OpenAI/Codex `36`, Microsoft/Azure/M365 `49`, Python/Data/Docs `20`, GitHub `7`.

## Agentes

| agente | carril | criterio |
| --- | --- | --- |
| `rey.control_plane_orchestrator` | coordinacion | integra waves y declara siguiente delta unico |
| `court.maat_governance` | gobierno | exige owner, evidencia, validator, rollback y stop condition |
| `anubis.frontier_guardian` | frontera | bloquea live, MCP, secretos y writes sin gate |
| `thot_schema` | schema | valida metadata, JSON, TOML, YAML, CSV y runners |
| `seshat.canon_librarian` | canon | reduce ruido documental y evita duplicados |
| `codex.workspace_guardian` | workspace | inspecciona filesystem, repos, `.codex`, PATH y comandos |
| `rey.repo_cartographer` | repos | clasifica repos, worktrees, overlays, scratch y archives |
| `tech.reference_librarian` | conectores | separa config persistente de cache efimero |
| `faraday.integration_guard` | integraciones | prepara gates de Microsoft, OpenAI, Dataverse y GitHub |
| `ramanujan.sequence_controller` | secuencia | evita waves con write scopes solapados |

## Waves

| wave | objetivo | resultado esperado |
| --- | --- | --- |
| `W0` | inventario total sin mover | `CABINA_GOBIERNO_TOTAL_INVENTORY_READY` |
| `W1` | clasificacion de carpetas y repos | `CABINA_FOLDER_REPO_CLASSIFICATION_READY` |
| `W2` | nomenclatura y reduccion de ruido | `CABINA_NOISE_REDUCTION_PLAN_READY` |
| `W3` | governance lane de `.codex` | `CODEX_GOVERNANCE_LANE_READY` |
| `W4` | agentes a carriles | `CABINA_AGENT_CARRILS_READY` |
| `W5` | skills, recetas, SDK, runners y plugins | `CABINA_RUNNER_PLUGIN_SKILL_RECIPE_READY` |
| `W6` | conectores on-demand read/preflight | `CABINA_CONNECTOR_GATES_READY` |
| `W7` | Data Analytics + OpenAI Developers | `CABINA_DATA_OPENAI_LANES_READY` |

## Reglas de ejecucion

1. No mover carpetas durante `PLAN_FIRST`.
2. No tocar `.codex` global ni DBs sin backup y owner.
3. No borrar cache, worktrees, workspaceStorage ni logs por inferencia.
4. No ejecutar MCP, Dataverse live, Microsoft live, SharePoint write, Power Platform mutation, OpenAI live ni Codex Cloud.
5. No imprimir secretos ni leer `.env.local`.
6. Cada wave produce matriz, readback y validacion.
7. Cada write local requiere rollback.
8. Cada conector queda `CONNECTED_READ_OK`, `AUTH_PRESENT_NO_WRITE`, `CONFIG_PRESENT_NOT_EXECUTED`, `GATED_NOT_EXECUTABLE`, `BLOCKED_NEEDS_OWNER` o `BLOCKED_NEEDS_SECRET_SAFE_BINDING`.

## Uso de VS Code Insiders

VS Code Insiders se usa como superficie de inspeccion y runner local, no como autoridad canonica. Las extensiones de agentes, GitHub, Azure, Power Platform, Python/Jupyter, Markdown/YAML y OpenAI ChatGPT quedan en la matriz de runners y conectores. Los procesos vivos observados se clasifican antes de cualquier cleanup.

## Uso de OpenAI y Data Analytics

- `openai-docs`: fuente de reglas para Codex, skills, plugins, MCP, IDE y Windows.
- `openai-api-troubleshooting`: carril de diagnostico solo si existe error real de API; no se hace API call en este plan.
- `chatgpt-app-submission`: carril solo para MCP app/server submission; no se genera JSON sin inspeccionar un MCP server real.
- `data-analytics`: carril para reportes, dashboards, source-backed context y semantic layer; no consulta conectores live sin workflow que lo requiera.

## Validacion final por wave

```powershell
python -m tools.validate
python tools/sdu_sentinel.py scan
python tools/sdu_auto_remediation.py analyze
python tools/sdu_sentinel.py check
pytest
git diff --check
git status --short
```

## Estado esperado de este delta

`CABINA_GOBIERNO_TOTAL_PLAN_FIRST_READY`
