---
artifact_id: operativa/tasks/20260623/READBACK_IDE_TERMINAL_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_TERMINAL_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_TERMINAL_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - terminal-governance
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_TERMINAL_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-terminal-status.ps1
  - tools/ceo-ide-terminal-enter.ps1
descripcion: Readback breve del carril IDE_TERMINAL_CONTROL para abrir terminales VS Code Insiders en runtime CEO gobernado.
---

# READBACK IDE TERMINAL CONTROL

## Estado

IDE_TERMINAL_GOVERNED_READY

## Capacidad producida

Governed IDE Terminal.

## Comandos candidatos

- `tools/ceo-ide-terminal-status.ps1 -Json`
- `tools/ceo-ide-terminal-enter.ps1`

## Resultado

- Perfil default de VS Code Insiders: `CEO PowerShell`.
- PowerShell usado: `C:\Program Files\PowerShell\7\pwsh.exe`.
- Perfil global de PowerShell: no cargado por la terminal IDE (`-NoProfile`).
- Working directory inicial: `C:\CEO\project-cdx`.
- Runtime marker: `CEO_RUNTIME_MODE=GOVERNED`.
- Python efectivo de terminal: `.venv\Scripts\python.exe`.
- Codex CLI efectivo: AppData local de OpenAI Codex.
- Node efectivo: WinGet OpenJS Node LTS.
- WindowsApps queda detras del runtime para esta terminal.
- Procesos Codex desktop y extension observados, sin mutacion.

## Task agregada

- `CEO IDE: Terminal Status`.

## Frontera

- No perfil global editado.
- No PATH global editado.
- No procesos cerrados.
- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.

## Proxima accion ejecutable

Abrir una terminal nueva desde VS Code Insiders y verificar la linea `CEO GOVERNED RUNTIME: READY`.
