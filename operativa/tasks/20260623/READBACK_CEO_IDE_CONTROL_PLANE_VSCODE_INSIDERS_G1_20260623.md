---
artifact_id: operativa/tasks/20260623/READBACK_CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: CABINA_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.md
etiquetas:
  - vscode-insiders
  - ide-control-plane
  - productiva
  - local-only
relacionados:
  - operativa/tasks/20260623/CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.csv
  - operativa/tasks/20260623/READBACK_IDE_WORKSPACE_IDENTITY_RECONCILIATION_20260623.md
  - operativa/tasks/20260623/IDE_WORKSPACE_IDENTITY_RECONCILIATION_MATRIX_20260623.csv
  - tools/ceo-ide-workspace-reconcile.ps1
  - tools/ceo-vscode-insiders-status.ps1
  - tools/ceo-vscode-insiders-open.ps1
descripcion: Readback breve del control plane IDE G1 para operar VS Code Insiders como sistema nervioso de cabina con identidad reconciliada en C:\CEO\project-cdx.
---

# CABINA_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1 - READBACK

## 1. Dictamen ejecutivo

`CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_READY_LOCAL_ONLY`

VS Code Insiders quedo promovido de editor/terminal a superficie operativa de cabina:

- IDE Control Plane.
- Command Center.
- Agent Orchestration Surface.
- Local Runtime Console.
- Evidence Capture Point.
- MCP / Toolchain Workbench observado sin ejecucion.

Workspace rector visible: `C:\CEO\project-cdx`.
Alias fisico: `C:\Users\enzo1\PROJEC CDX`, tratado como target tecnico, no segundo workspace.

## 2. Capacidades producidas

- Workspace Governance.
- Workspace Identity Reconciliation.
- Governed IDE Terminal.
- IDE Command Surface.
- Task Runner Governance.
- Extension Policy.
- IDE Agent Tool Hub.
- IDE Evidence Capture.

## 3. Control aumentado sobre VS Code Insiders

Workspace:
- `IDE_WORKSPACE_CONTROL_READY`.
- `IDE_WORKSPACE_IDENTITY_RECONCILED`.
- WorkspaceStorage activo: `file:///c%3A/CEO/project-cdx`.
- Residual fisico: `PHYSICAL_ALIAS_RESIDUAL_HOLD`.

Terminal:
- `IDE_TERMINAL_GOVERNED_READY`.
- Terminal default: `CEO PowerShell`.
- CWD canonico: `C:\CEO\project-cdx`.

Comandos:
- `IDE_COMMAND_SURFACE_READY`.
- 28 herramientas `ceo-*` detectadas.
- 0 failures.
- 1 candidato remoto pendiente por gate.

Tasks:
- `IDE_TASKS_PRODUCTIVE_READY`.
- 31 tasks productivas.
- 0 rotas.
- Task compuesta: `CEO IDE: Control Plane G1`.

Extensiones:
- `IDE_EXTENSION_CONTROL_READY`.
- 137 extensiones observadas.
- 8 duplicados detectados.
- 0 desinstalaciones automaticas.
- Allow/support/holdlist operativa preparada.

Agentes/MCP:
- `IDE_AGENT_MAP_READY`.
- `IDE_MCP_STATUS_READY`.
- MCP `agent-pipeline` observado/configurado.
- MCP execution bloqueado por gate.

Evidencia/telemetria:
- `IDE_EVIDENCE_CAPTURE_READY`.
- `IDE_TELEMETRY_STATUS_READY`.
- Evidencia clasificada por runtime, command, agent, mcp, git, watchdog, telemetry, remote y decision.
- `VERSION_STATE.json` usado como telemetria runtime; no se creo `telemetry.json` ruidoso.

## 4. Comandos candidatos

- comando: `tools\ceo-ide-workspace-status.ps1 -Json`
  proposito: confirmar raiz, workspaces, repos anidados y politica no-absorb.
  estado: `IDE_WORKSPACE_CONTROL_READY`
  ruta: `tools\ceo-ide-workspace-status.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-workspace-status`.

- comando: `tools\ceo-ide-workspace-reconcile.ps1 -Json`
  proposito: confirmar que el workspace activo de Insiders es `C:\CEO\project-cdx`.
  estado: `IDE_WORKSPACE_IDENTITY_RECONCILED`
  ruta: `tools\ceo-ide-workspace-reconcile.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-workspace-reconcile`.

- comando: `tools\ceo-ide-terminal-status.ps1 -Json`
  proposito: validar terminal gobernada, PATH y procesos relevantes.
  estado: `IDE_TERMINAL_GOVERNED_READY`
  ruta: `tools\ceo-ide-terminal-status.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-terminal-status`.

- comando: `tools\ceo-ide-command-index.ps1 -Json`
  proposito: indexar comandos visibles desde IDE.
  estado: `IDE_COMMAND_SURFACE_READY`
  ruta: `tools\ceo-ide-command-index.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-command-index`.

- comando: `tools\ceo-ide-command-test.ps1 -Json`
  proposito: validar superficie de comandos.
  estado: `IDE_COMMAND_SURFACE_READY`
  ruta: `tools\ceo-ide-command-test.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-command-test`.

- comando: `tools\ceo-ide-tasks-status.ps1 -Json`
  proposito: validar tasks productivas, dependencias y roturas.
  estado: `IDE_TASKS_PRODUCTIVE_READY`
  ruta: `tools\ceo-ide-tasks-status.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-tasks-status`.

- comando: `tools\ceo-ide-extension-list.ps1 -Json`
  proposito: listar extensiones instaladas de Insiders.
  estado: `IDE_EXTENSION_LIST_READY`
  ruta: `tools\ceo-ide-extension-list.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-extension-list`.

- comando: `tools\ceo-ide-extension-policy.ps1 -Json`
  proposito: clasificar extensiones por funcion, impacto y politica.
  estado: `IDE_EXTENSION_CONTROL_READY`
  ruta: `tools\ceo-ide-extension-policy.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-extension-policy`.

- comando: `tools\ceo-ide-agent-map.ps1 -Json`
  proposito: mapear agentes, carriles, runners y conexiones del IDE.
  estado: `IDE_AGENT_MAP_READY`
  ruta: `tools\ceo-ide-agent-map.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-agent-map`.

- comando: `tools\ceo-ide-mcp-status.ps1 -Json`
  proposito: mapear MCP observado/configurado sin ejecutar servidores.
  estado: `IDE_MCP_STATUS_READY`
  ruta: `tools\ceo-ide-mcp-status.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-mcp-status`.

- comando: `tools\ceo-ide-evidence-status.ps1 -Json`
  proposito: clasificar evidencia reutilizable desde IDE.
  estado: `IDE_EVIDENCE_CAPTURE_READY`
  ruta: `tools\ceo-ide-evidence-status.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-evidence-status`.

- comando: `tools\ceo-ide-telemetry-status.ps1 -Json`
  proposito: validar telemetria runtime/watchdog desde IDE.
  estado: `IDE_TELEMETRY_STATUS_READY`
  ruta: `tools\ceo-ide-telemetry-status.ps1`
  salida esperada: JSON.
  promocion: `ceo-ide-telemetry-status`.

## 5. Tasks candidatas

- task: `CEO IDE: Workspace Control`
  comando: `tools\ceo-ide-workspace-status.ps1 -Json`
  uso: verificar raiz y superficie workspace.
  evidencia: `READBACK_IDE_WORKSPACE_CONTROL_20260623.md`.

- task: `CEO IDE: Workspace Reconcile`
  comando: `tools\ceo-ide-workspace-reconcile.ps1 -Json`
  uso: confirmar identidad abierta en Insiders.
  evidencia: `READBACK_IDE_WORKSPACE_IDENTITY_RECONCILIATION_20260623.md`.

- task: `CEO IDE: Terminal Status`
  comando: `tools\ceo-ide-terminal-status.ps1 -Json`
  uso: validar terminal gobernada.
  evidencia: `READBACK_IDE_TERMINAL_CONTROL_20260623.md`.

- task: `CEO Command: Index`
  comando: `tools\ceo-ide-command-index.ps1 -Json`
  uso: ver paleta de comandos.
  evidencia: `READBACK_IDE_COMMAND_CONTROL_20260623.md`.

- task: `CEO Command: Test`
  comando: `tools\ceo-ide-command-test.ps1 -Json`
  uso: validar comandos candidatos.
  evidencia: `READBACK_IDE_COMMAND_CONTROL_20260623.md`.

- task: `CEO IDE: Extension Control`
  comando: `CEO IDE: Extension List` + `CEO IDE: Extension Policy`.
  uso: clasificar extensiones y ruido.
  evidencia: `READBACK_IDE_EXTENSION_CONTROL_20260623.md`.

- task: `CEO IDE: Agent MCP Hub`
  comando: `CEO IDE: Agent Map` + `CEO IDE: MCP Status`.
  uso: mapear agentes, herramientas y MCP.
  evidencia: `READBACK_IDE_AGENT_MCP_CONTROL_20260623.md`.

- task: `CEO IDE: Evidence Telemetry Control`
  comando: `CEO IDE: Evidence Status` + `CEO IDE: Telemetry Status`.
  uso: capturar evidencia minima reutilizable.
  evidencia: `READBACK_IDE_EVIDENCE_TELEMETRY_CONTROL_20260623.md`.

- task: `CEO IDE: Control Plane G1`
  comando: task compuesta completa.
  uso: ejecutar la superficie IDE gobernada.
  evidencia: este readback.

## 6. Skills / recetas promovibles

- skill: `ide-workspace-governance`
  receta: `recipe-open-cabina-in-governed-ide`
  agente dueño: `THOT_IDE_CONTROL`.

- skill: `ide-terminal-runtime-control`
  receta: `recipe-repair-ide-terminal-runtime`
  agente dueño: `RUN_SUPPORT_IDE`.

- skill: `ide-command-surface-management`
  receta: `recipe-promote-script-to-vscode-task`
  agente dueño: `THOT_IDE_CONTROL`.

- skill: `ide-task-runner-governance`
  receta: `recipe-promote-script-to-vscode-task`
  agente dueño: `MAAT_IDE_COMPLIANCE`.

- skill: `ide-extension-policy`
  receta: `recipe-classify-vscode-extensions`
  agente dueño: `HORUS_IDE_SIGNAL`.

- skill: `ide-agent-mcp-routing`
  receta: `recipe-map-agent-tools-in-ide`
  agente dueño: `ANUBIS_IDE_GATE`.

- skill: `ide-evidence-capture`
  receta: `recipe-capture-ide-operation-evidence`
  agente dueño: `SESHAT_IDE_EVIDENCE`.

## 7. Cambios realizados

- Se fijo `C:\CEO\project-cdx` como entrada visible y operativa de VS Code Insiders.
- Se agregaron comandos `ceo-ide-*` para workspace, terminal, comandos, tasks, extensiones, agentes/MCP y evidencia/telemetria.
- Se agregaron tasks productivas en `.vscode\tasks.json`.
- Se agregaron matrices y readbacks minimos en `operativa\tasks\20260623`.
- Se ajustaron comandos para reportar `C:\CEO\project-cdx` y no la ruta fisica como workspace principal.
- Se incorporo `CEO IDE: Workspace Reconcile` a la cadena `CEO IDE: Control Plane G1`.

## 8. Cambios no realizados

- No se borraron caches.
- No se borro `workspaceStorage`.
- No se desinstalaron extensiones.
- No se ejecuto MCP.
- No se leyeron secretos.
- No se hizo push.
- No se abrio PR.
- No se hizo live.
- No se modificaron repos hijos.

## 9. Riesgos bloqueados

- Doble identidad `C:\CEO\project-cdx` versus `C:\Users\enzo1\PROJEC CDX`.
- Workspace fisico abierto como segundo proyecto.
- Tasks decorativas sin evidencia.
- Comandos no invocables desde IDE.
- MCP configurado ejecutado sin gate.
- Logs ruidosos o telemetria duplicada.
- Extensiones con impacto no clasificado.

## 10. Proxima accion ejecutable

Ejecutar desde VS Code Insiders:

```text
Tasks: Run Task
CEO IDE: Control Plane G1
```

O en terminal:

```powershell
Set-Location 'C:\CEO\project-cdx'
.\tools\ceo-ide-tasks-status.ps1 -Json
```

## Validaciones ejecutadas

- `IDE_WORKSPACE_CONTROL_READY`.
- `IDE_WORKSPACE_IDENTITY_RECONCILED`.
- `IDE_TERMINAL_GOVERNED_READY`.
- `IDE_COMMAND_SURFACE_READY`.
- `IDE_TASKS_PRODUCTIVE_READY`.
- `IDE_EXTENSION_CONTROL_READY`.
- `IDE_AGENT_MAP_READY`.
- `IDE_MCP_STATUS_READY`.
- `IDE_EVIDENCE_CAPTURE_READY`.
- `IDE_TELEMETRY_STATUS_READY`.
- `python -m tools.validate`: `OK: 179 metadatos validos`.
- `git diff --check`: `PASS` en superficie tocada.

## Frontera

- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.
- No borrado.
- No cache cleanup.
- No workspaceStorage delete.
