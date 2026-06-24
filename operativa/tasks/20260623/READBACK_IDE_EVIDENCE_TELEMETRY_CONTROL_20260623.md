---
artifact_id: operativa/tasks/20260623/READBACK_IDE_EVIDENCE_TELEMETRY_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_EVIDENCE_TELEMETRY_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_EVIDENCE_TELEMETRY_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - evidence-capture
  - telemetry
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_EVIDENCE_TELEMETRY_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-evidence-status.ps1
  - tools/ceo-ide-telemetry-status.ps1
descripcion: Readback breve del carril IDE_EVIDENCE_TELEMETRY_CONTROL para capturar evidencia minima reutilizable desde VS Code Insiders.
---

# READBACK IDE EVIDENCE TELEMETRY CONTROL

## Estado

IDE_EVIDENCE_TELEMETRY_READY

## Capacidad producida

IDE Evidence Capture.

## Comandos candidatos

- `tools/ceo-ide-evidence-status.ps1 -Json`
- `tools/ceo-ide-telemetry-status.ps1 -Json`

## Resultado

- Categorias de evidencia observadas: runtime, command, agent, mcp, git, watchdog, telemetry, remote, decision.
- `CEO IDE: Evidence Status`: READY.
- `CEO IDE: Telemetry Status`: READY.
- `CEO IDE: Evidence Telemetry Control`: agregado como task compuesta.
- `CEO Command: Watchdog`: READY.
- `CEO Command: Telemetry`: READY.
- Command surface: 28 herramientas `ceo-*`, 0 failures, 1 candidato remoto pendiente por gate.
- Task runner: 31 tasks productivas, 0 rotas, 1 candidato remoto pendiente por gate.

## Telemetria

- Runtime mode: OPERACION_CONTINUA_GOBERNADA.
- Version actual: v0.6.0-rc1.
- Branch observado: codex/runtime-versioning-snapshots.
- Commit observado: 0a8adb06aa948665d089de5f7ecd76c9d19ba883.
- Workspace dirty: true.
- Local changes observados por runtime state: 832.
- `VERSION_STATE.json`: valido y usado como telemetria runtime.
- `telemetry.json` dedicado: no existe; no se crea para evitar ruido.

## Watchdog

- `operativa/sentinel/SENTINEL_REPORT.json`: valido.
- Sentinel status: WARN.
- Causa: dirty workspace preexistente.
- Metadata validate: PASS.
- Snapshot available: PASS.

## Evidencia clasificada

- runtime: 38 archivos observados.
- command: 155 archivos observados.
- agent: 4 archivos observados.
- mcp: 3 archivos observados.
- git: 7 archivos observados.
- watchdog: 5 archivos observados.
- telemetry: 22 archivos observados.
- remote: 76 archivos observados.
- decision: 71 archivos observados.

## Validaciones

- `tools/ceo-ide-evidence-status.ps1 -Json`: IDE_EVIDENCE_CAPTURE_READY.
- `tools/ceo-ide-telemetry-status.ps1 -Json`: IDE_TELEMETRY_STATUS_READY.
- `tools/ceo-ide-command-test.ps1 -Json`: IDE_COMMAND_SURFACE_READY.
- `tools/ceo-ide-tasks-status.ps1 -Json`: IDE_TASKS_PRODUCTIVE_READY.
- `.vscode/tasks.json`: 31 tasks; 4 relacionadas a Evidence/Telemetry.
- `python -m tools.validate`: OK, 179 metadatos validos.
- `tools/sdu_chain_resolver.py --no-external --dry-run --json`: PASS.
- `pytest`: 54 passed, 1 skipped.
- `git diff --check`: PASS en superficie del carril.

## Frontera

- No noisy logs.
- No telemetry externa.
- No MCP execution.
- No secretos.
- No push.
- No PR.
- No live.
- No stage.
- No commit.

## Proxima accion ejecutable

Ejecutar task `CEO IDE: Evidence Telemetry Control` desde VS Code Insiders.
