# VSCODE_INSIDERS_CODEX_CABINA_PREFLIGHT

Fecha: 2026-06-25
Estado: PASS_RUNTIME_BRIDGE_APPLIED

Actualizacion SDU_VSCODE_KEYBINDINGS_SAFE_RESOLUTION:

Keybindings resolved via non-colliding extension strategy.

- `ctrl+alt+shift+c -> SDU.commandC`
- `ctrl+alt+shift+a -> SDU.commandA`
- `Ctrl+N` no fue modificado.
- Telemetria: `.codex\logs\keybindings_resolution.json`
- Backup aplicado: `.codex\backups\vscode-insiders\keybindings_safe_apply_20260625_211459.json`

Actualizacion SDU_KEYBIND_RUNTIME_BRIDGE:

Keybindings bridged to local scripts via `workbench.action.terminal.sendSequence`.

- `ctrl+alt+shift+c -> powershell -NoProfile -ExecutionPolicy Bypass -File C:\CEO\watchdog\commands\commandC.ps1`
- `ctrl+alt+shift+a -> powershell -NoProfile -ExecutionPolicy Bypass -File C:\CEO\watchdog\commands\commandA.ps1`
- Scripts creados:
  - `C:\CEO\watchdog\commands\commandC.ps1`
  - `C:\CEO\watchdog\commands\commandA.ps1`
- Evidencia runtime: `C:\CEO\watchdog\logs\sdu-keybinding-runtime-bridge.jsonl`
- Backup runtime bridge: `.codex\backups\vscode-insiders\keybindings_runtime_bridge_20260625_211855.json`
- Telemetria runtime bridge: `.codex\logs\keybindings_runtime_bridge.json`
- `Ctrl+N` no fue modificado.
- Prueba directa de ambos scripts: PASS.

## Resumen

Preflight local de VS Code Insiders para operar Codex como control-plane. Se inspecciono configuracion, perfiles, extensiones, comandos declarados y MCP local sin tocar produccion, sin push, sin instalar extensiones y sin modificar repositorios.

Se aplico resolucion segura de keybindings con estrategia `SHIFT_EXTENSION`, sin tocar `Ctrl+N` y sin sobrescribir bindings existentes.

## Rutas verificadas

- VS Code Insiders User: `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User`
- Extensiones Insiders: `C:\Users\enzo1\.vscode-insiders\extensions`
- Repos GitHub: `C:\Users\enzo1\Documents\GitHub`
- Repos Codex: `C:\Users\enzo1\Documents\Codex`
- Workspace actual: `C:\CEO\project-cdx`

## Archivos leidos

- `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\settings.json`
- `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\profiles\1710f56f\settings.json`
- `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\profiles\631dd3f8\settings.json`
- `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\profiles\631dd3f8\keybindings.json`
- `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\profiles\631dd3f8\extensions.json`
- `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\profiles\631dd3f8\mcp.json`
- `C:\CEO\project-cdx\.vscode\settings.json`
- `C:\CEO\project-cdx\.cursor\mcp.json`
- `C:\CEO\project-cdx\CEO_CONTROL_PLANE.code-workspace`
- `package.json` de extensiones instaladas bajo `.vscode-insiders\extensions`

## Backups creados

Backup local timestamped:

`C:\CEO\project-cdx\.codex\backups\vscode-insiders\20260625_210957`

Contenido:

- `user-settings.json`
- `user-keybindings.json.MISSING`
- `profile-1710f56f\settings.json`
- `profile-1710f56f\chatLanguageModels.json`
- `profile-631dd3f8\settings.json`
- `profile-631dd3f8\keybindings.json`
- `profile-631dd3f8\extensions.json`
- `profile-631dd3f8\mcp.json`
- `profile-631dd3f8\chatLanguageModels.json`

## Configuracion actual

### Global

- `settings.json`: existe y es JSON valido.
- `keybindings.json`: no existe en el perfil global.
- `extensions.json`: no existe en el perfil global.
- `argv.json`: no existe en el perfil global.

### Perfiles

- Perfil `1710f56f`: contiene `settings.json` minimo con `agileagentcanvas.chatProviderSelected = auto`.
- Perfil `631dd3f8`: contiene `settings.json`, `keybindings.json`, `extensions.json`, `mcp.json` y `chatLanguageModels.json`.
- Perfil `631dd3f8` declara `agileagentcanvas.chatProviderSelected = codex`.
- Perfil `631dd3f8` tiene `keybindings.json` vacio funcionalmente: `[]`.
- `window.newWindowProfile` global apunta a `CABINA_GOVERNED`.

### Terminal

Global:

- `terminal.integrated.defaultProfile.windows = PowerShell 7 (CEO Safe)`
- `terminal.integrated.cwd = C:\`
- `terminal.integrated.env.windows` define `CODEX_PWSH_PATH`, `CODEX_PAC_PATH` y PATH Docker.

Workspace actual:

- `.vscode/settings.json` define `terminal.integrated.defaultProfile.windows = CEO PowerShell`.
- El perfil `CEO PowerShell` llama `tools\ceo-ide-terminal-enter.ps1`.
- El workspace fija `CEO_RUNTIME_MODE = GOVERNED`.

### Git/GitHub

- `git.confirmSync = true`
- `git.autofetch = false`
- Extensiones GitHub presentes: GitHub Pull Requests, GitHub Actions, CodeQL, Codespaces.
- Estado de autenticacion GitHub en VS Code: [POR DEFINIR]. No se leyeron tokens ni bases internas de auth.

### Workspace Trust

- `security.workspace.trust.untrustedFiles = open`
- Lista interna de roots confiados: [POR DEFINIR]. No se forzo lectura de `globalStorage/state.vscdb` por ACL/superficie sensible.

### MCP/LSP

- Perfil `631dd3f8` tiene `mcp.json` con servidor `microsoft/markitdown` via `uvx markitdown-mcp@0.0.1a4`.
- Workspace actual tiene `.cursor\mcp.json` con servidor `agent-pipeline`.
- No existe `.vscode\mcp.json` en `C:\CEO\project-cdx`.
- `.vscode\settings.json` fija `python.defaultInterpreterPath = ${workspaceFolder}\.venv\Scripts\python.exe`.
- Barrido local encontro 73 candidatos MCP/workspace/settings bajo los roots auditados, con exclusiones de `.git`, `node_modules`, `.venv`, caches y backups grandes.

## Extensiones relacionadas

- `openai.chatgpt-26.623.30605`: Codex - OpenAI's coding agent.
- `harukary7518.codex-ui-vscode-extension-0.2.17`: Codex UI.
- `martinortiz.codex-stats-1.0.3`: Codex Stats.
- `ms-azuretools.vscode-azure-mcp-server-3.0.21`: Azure MCP Server.
- `github.vscode-pull-request-github-0.153.2026062504`
- `github.vscode-github-actions-0.32.0`
- `github.vscode-codeql-1.17.7`
- `github.codespaces-1.18.14`
- `PixelPilotAILabs.pixelpilot-copilot-3.0.6`
- `ms-CopilotStudio.vscode-copilotstudio-1.6.22`

## Comandos Codex/OpenAI detectados

Extension oficial `openai.chatgpt`:

- `chatgpt.openSidebar` - Open Codex Sidebar
- `chatgpt.newChat` - New Thread in Codex Sidebar
- `chatgpt.newCodexPanel` - New Codex Agent
- `chatgpt.addFileToThread` - Add File to Codex Thread
- `chatgpt.addToThread` - Add to Codex Thread
- `chatgpt.implementTodo` - Implement with Codex
- `chatgpt.openCommandMenu` - Open Codex Command Menu
- `chatgpt.showLspMcpCliArgs` - Copy Codex CLI args for LSP MCP

Extension `Codex UI`:

- `codex.newSession`
- `codex.openSession`
- `codex.openSessionPanel`
- `codex.showAgents`
- `codex.showSkills`
- `codex.showStatus`
- `codex.startBackend`
- `codex.respondApproval`
- `codex.interruptTurn`
- `codex.openLatestDiff`
- `codex.clearRuntimeCache`

## Keybindings existentes

Usuario/perfil:

- Global `keybindings.json`: ausente.
- Perfil `631dd3f8`: existe, sin entradas activas.

Extension defaults relevantes:

- `ctrl+n -> chatgpt.newChat` cuando `chatgpt.supportsNewChatKeyShortcut`.
- `shift+tab -> codex.cycleCollaborationMode` cuando `view == codex.chatView`.
- `ctrl+n -> pixelpilot-copilot.new.agentManager.newWorktree` solo dentro del webview de PixelPilot.

## Conflictos detectados

### Critico

- `Ctrl+N` esta contribuido por `openai.chatgpt` para `chatgpt.newChat`.
- Riesgo: puede secuestrar "Nuevo archivo" si el contexto `chatgpt.supportsNewChatKeyShortcut` esta activo.
- Decision segura: desactivar ese default con un unbinding explicito antes de considerar el preflight PASS.

### Mapa solicitado

- `Ctrl+Alt+C` colisiona con:
  - `agentic-hub.copyOpenFileUri` cuando `editorTextFocus`.
  - `rest-client.generate-codesnippet` cuando `editorTextFocus && editorLangId == http`.
  - `rest-client.generate-codesnippet` cuando `editorTextFocus && editorLangId == plaintext`.
- `Ctrl+Alt+A` colisiona con:
  - `agentVisualizer.open`.
  - `pixelpilot-copilot.new.toggleAutoApprove`.
- `Ctrl+Alt+T`: sin colisiones estaticas detectadas.
- `Ctrl+Alt+F`: sin colisiones estaticas detectadas.
- `Ctrl+Alt+I`: sin colisiones estaticas detectadas.
- `Ctrl+Alt+P`: sin colisiones estaticas detectadas.

## Diff anterior no aplicado

Este diff corresponde al preflight anterior y queda como referencia historica. No se aplico porque incluia `Ctrl+Alt+C/A` con conflictos y unbinding de `Ctrl+N`, que esta orden prohibio tocar:

```json
[
  {
    "key": "ctrl+n",
    "command": "-chatgpt.newChat",
    "when": "chatgpt.supportsNewChatKeyShortcut"
  },
  {
    "key": "ctrl+alt+c",
    "command": "chatgpt.openSidebar"
  },
  {
    "key": "ctrl+alt+t",
    "command": "chatgpt.newChat"
  },
  {
    "key": "ctrl+alt+a",
    "command": "chatgpt.newCodexPanel"
  },
  {
    "key": "ctrl+alt+f",
    "command": "chatgpt.addFileToThread"
  },
  {
    "key": "ctrl+alt+i",
    "command": "chatgpt.implementTodo"
  },
  {
    "key": "ctrl+alt+p",
    "command": "chatgpt.openCommandMenu"
  }
]
```

No aplicado por conflictos en `Ctrl+Alt+C`, `Ctrl+Alt+A` y porque esta orden prohibio modificar `Ctrl+N`.

## Alternativa aplicada sin colisiones estaticas detectadas

```json
[
  {
    "key": "ctrl+alt+shift+c",
    "command": "SDU.commandC"
  },
  {
    "key": "ctrl+alt+shift+a",
    "command": "SDU.commandA"
  }
]
```

## Validacion

- `settings.json` global: JSON valido.
- `settings.json` de perfiles: JSON valido.
- `keybindings.json` perfil `631dd3f8`: JSONC valido y array vacio.
- `mcp.json` perfil `631dd3f8`: JSON valido.
- `.vscode/settings.json` workspace: JSON valido.
- `.cursor/mcp.json` workspace: JSON valido.
- `Ctrl+N` nativo: no modificado en `keybindings.json` de usuario.
- `ctrl+alt+shift+c` y `ctrl+alt+shift+a`: sin colisiones estaticas detectadas.
- `SDU.commandC` y `SDU.commandA`: reemplazados por puente runtime via `workbench.action.terminal.sendSequence`; no dependen de extension.
- Comandos Codex oficiales: presentes en `openai.chatgpt`.
- Backups: creados.

## Cambios aplicados

- Creado backup local en `.codex\backups\vscode-insiders\20260625_210957`.
- Creado backup obligatorio en `.codex\backups\vscode-insiders\keybindings_safe_apply_20260625_211459.json`.
- Creado/actualizado `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\keybindings.json` solo con:
  - `ctrl+alt+shift+c -> SDU.commandC`
  - `ctrl+alt+shift+a -> SDU.commandA`
- Creado `.codex\logs\keybindings_resolution.json`.
- Creado este readback.

## Cambios no aplicados

- No se modifico `settings.json`.
- No se modificaron perfiles.
- No se instalaron extensiones.
- No se hizo push.
- No se tocaron repositorios.
- No se modifico `Ctrl+N`.
- No se aplicaron overrides sobre `Ctrl+Alt+C` ni `Ctrl+Alt+A`.

## Sistemas tocados

- Filesystem local del workspace: si.
- AppData VS Code Insiders: solo lectura.
- Git remoto: no.
- Produccion: no.
- Microsoft/SharePoint/Dataverse: no.
- Secretos/tokens: no leidos, no impresos.

## Proximo paso

Probar en VS Code Insiders los atajos `Ctrl+Alt+Shift+C` y `Ctrl+Alt+Shift+A` con una terminal integrada abierta o disponible para confirmar la experiencia visual end-to-end.
