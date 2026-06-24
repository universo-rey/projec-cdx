---
artifact_id: operativa/tasks/20260623/READBACK_IDE_WORKSPACE_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_WORKSPACE_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_WORKSPACE_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - workspace-governance
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_WORKSPACE_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-workspace-status.ps1
descripcion: Readback breve del carril IDE_WORKSPACE_CONTROL para operar VS Code Insiders desde la raiz canonica sin absorber superficies no core.
---

# READBACK IDE WORKSPACE CONTROL

## Estado

IDE_WORKSPACE_CONTROL_READY

## Capacidad producida

Workspace Governance.

## Comando candidato

- `tools/ceo-ide-workspace-status.ps1 -Json`

## Resultado

- Workspace rector confirmado: `C:\CEO\project-cdx`.
- Alias fisico confirmado: `C:\Users\enzo1\PROJEC CDX`.
- VS Code Insiders resoluble desde PATH local.
- `.vscode/settings.json` y `.vscode/tasks.json` validos.
- Task agregada: `CEO IDE: Workspace Control`.
- Workspaces historicos detectados: 2.
- Workspaces historicos clasificados: `OBSERVED_NO_CORE`.
- Repo anidado observado: `.cabina`.
- Politica de repo anidado: `OBSERVED_NO_ABSORB`.

## Frontera

- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.
- No borrado.
- No absorcion de repos anidados.

## Proxima accion ejecutable

Ejecutar task `CEO IDE: Workspace Control` desde VS Code Insiders.
