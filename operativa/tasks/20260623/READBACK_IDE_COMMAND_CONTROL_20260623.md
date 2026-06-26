---
artifact_id: operativa/tasks/20260623/READBACK_IDE_COMMAND_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_COMMAND_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_COMMAND_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - command-surface
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_COMMAND_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-command-index.ps1
  - tools/ceo-ide-command-test.ps1
descripcion: Readback breve del carril IDE_COMMAND_CONTROL para acceder a comandos CEO/SDU desde VS Code Insiders sin memoria humana.
---

# READBACK IDE COMMAND CONTROL

## Estado

IDE_COMMAND_SURFACE_READY

## Capacidad producida

IDE Command Surface.

## Comandos candidatos

- `tools/ceo-ide-command-index.ps1 -Json`
- `tools/ceo-ide-command-test.ps1 -Json`

## Paleta operativa habilitada

- `CEO Command: Status`
- `CEO Command: Doctor`
- `CEO Command: Watchdog`
- `CEO Command: Telemetry`
- `CEO Command: Validate Metadata`
- `CEO Command: Agent Map`
- `CEO Command: MCP Status`
- `CEO Command: Index`
- `CEO Command: Test`

## Resultado

- Comandos `ceo-*` detectados: 20.
- Tasks visibles en VS Code Insiders: 20.
- Test de superficie: `IDE_COMMAND_SURFACE_READY`.
- Fallos de comandos criticos: ninguno.
- Candidato faltante controlado: `remote-ready`.

## Decision sobre remote-ready

No se creo shim remoto en este carril. Queda como `CANDIDATE_MISSING` porque requiere delta especifico de publicacion remota y gate propio.

## Frontera

- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.
- No stage.
- No commit.

## Proxima accion ejecutable

Ejecutar task `CEO Command: Test` desde VS Code Insiders.
