---
artifact_id: operativa/tasks/20260623/READBACK_IDE_TASK_RUNNER_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_TASK_RUNNER_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_TASK_RUNNER_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - task-runner
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_TASK_RUNNER_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-tasks-status.ps1
  - .vscode/tasks.json
descripcion: Readback breve del carril IDE_TASK_RUNNER_CONTROL para convertir acciones repetidas en tasks reproducibles de VS Code Insiders.
---

# READBACK IDE TASK RUNNER CONTROL

## Estado

IDE_TASKS_PRODUCTIVE_READY

## Capacidad producida

Task Runner Governance.

## Comando candidato

- `tools/ceo-ide-tasks-status.ps1 -Json`

## Resultado

- Tasks totales: 21.
- Tasks productivas: 21.
- Dependencias rotas: 0.
- Labels duplicados: 0.
- Task agregada: `CEO IDE: Tasks Status`.
- Cobertura repetible: status, validate, watchdog, telemetry, command-index, path-doctor, agent-map, mcp-status.
- `agent-dispatch` queda cubierto como `agent-map` local, sin ejecucion live.
- `remote-ready` queda como `CANDIDATE_MISSING` por requerir delta remoto propio.

## Frontera

- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.
- No stage.
- No commit.

## Proxima accion ejecutable

Ejecutar task `CEO IDE: Tasks Status` desde VS Code Insiders.
