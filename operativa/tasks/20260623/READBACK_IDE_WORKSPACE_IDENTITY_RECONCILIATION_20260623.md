---
artifact_id: operativa/tasks/20260623/READBACK_IDE_WORKSPACE_IDENTITY_RECONCILIATION_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_WORKSPACE_IDENTITY_RECONCILIATION
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_WORKSPACE_IDENTITY_RECONCILIATION_20260623.md
etiquetas:
  - vscode-insiders
  - workspace-identity
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_WORKSPACE_IDENTITY_RECONCILIATION_MATRIX_20260623.csv
  - tools/ceo-ide-workspace-reconcile.ps1
  - tools/ceo-vscode-insiders-open.ps1
  - tools/ceo-vscode-insiders-status.ps1
descripcion: Readback breve de reconciliacion de identidad VS Code Insiders para fijar C:\CEO\project-cdx como entrada canonica y degradar la ruta fisica a alias tecnico.
---

# READBACK IDE WORKSPACE IDENTITY RECONCILIATION

## Estado

IDE_WORKSPACE_IDENTITY_RECONCILED

## Capacidad producida

Workspace Identity Reconciliation.

## Comando candidato

- `tools/ceo-ide-workspace-reconcile.ps1 -Json`

## Resultado

- Workspace rector: `C:\CEO\project-cdx`.
- Alias fisico: `C:\Users\enzo1\PROJEC CDX`.
- Politica: `CANONICAL_ENTRY_ONLY_PHYSICAL_ALIAS_TARGET_ONLY`.
- WorkspaceStorage activo mas reciente: `d1189e3f74ed584ac0f8a0774b0a5a57`.
- WorkspaceStorage activo apunta a: `file:///c%3A/CEO/project-cdx`.
- WorkspaceStorage fisico residual observado: `a08e048810505f7c83eb13d5ce3b297d`.
- Residual fisico queda en `HOLD`, no borrado.
- `ceo-vscode-insiders-open` abre `C:\CEO\project-cdx` con `--reuse-window`.
- `ceo-vscode-insiders-status` reporta `root = C:\CEO\project-cdx`.
- Task agregada: `CEO IDE: Workspace Reconcile`.
- Task `CEO IDE: Control Plane G1` actualizada para incluir reconciliacion.
- Matriz rectora actualizada: `CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.csv`.

## Superficie visible para SRA

- Portada operativa: `READBACK_CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.md`.
- Matriz rectora: `CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.csv`.
- Readback especifico: `READBACK_IDE_WORKSPACE_IDENTITY_RECONCILIATION_20260623.md`.
- Matriz especifica: `IDE_WORKSPACE_IDENTITY_RECONCILIATION_MATRIX_20260623.csv`.

## Validaciones ejecutadas

- `ceo-ide-workspace-reconcile`: `IDE_WORKSPACE_IDENTITY_RECONCILED`.
- `ceo-ide-command-test`: `IDE_COMMAND_SURFACE_READY`.
- `ceo-ide-tasks-status`: `IDE_TASKS_PRODUCTIVE_READY`.
- `python -m tools.validate`: `OK: 179 metadatos validos`.
- `python tools\sdu_chain_resolver.py --no-external --dry-run --json`: `PASS`.
- `pytest`: `54 passed, 1 skipped`.
- `git diff --check`: `PASS`.

## Frontera

- No cache cleanup.
- No workspaceStorage delete.
- No DB mutation.
- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.

## Proxima accion ejecutable

Ejecutar task `CEO IDE: Workspace Reconcile` desde VS Code Insiders antes de abrir frentes nuevos.
