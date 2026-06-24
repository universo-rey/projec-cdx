---
artifact_id: operativa/tasks/20260623/READBACK_IDE_EXTENSION_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_EXTENSION_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_EXTENSION_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - extension-policy
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_EXTENSION_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-extension-list.ps1
  - tools/ceo-ide-extension-policy.ps1
descripcion: Readback breve del carril IDE_EXTENSION_CONTROL para gobernar extensiones de VS Code Insiders sin desinstalar ni mutar perfiles.
---

# READBACK IDE EXTENSION CONTROL

## Estado

IDE_EXTENSION_CONTROL_READY

## Capacidad producida

Extension Policy para VS Code Insiders.

## Comandos candidatos

- `tools/ceo-ide-extension-list.ps1 -Json`
- `tools/ceo-ide-extension-policy.ps1 -Json`

## Resultado

- Extensiones detectadas desde la carpeta local de Insiders: 136.
- Clasificacion: AGENT 55, GIT 7, MARKDOWN 18, MCP 1, POWERSHELL 2, PYTHON 11, SUPPORT 29, UNKNOWN 13.
- Politica: ALLOW 44, SUPPORT 27, HOLD 52, REVIEW 13.
- Duplicados/versiones residuales detectadas: 7 grupos.
- Impacto terminal: 12 extensiones.
- Impacto Python/Jupyter: 13 extensiones.
- Impacto MCP: 8 extensiones.
- Impacto agentes: 60 extensiones.

## Allowlist recomendada

Usar como perfil operativo base: Git/GitHub, Python, PowerShell, Markdown/docs, YAML, lint/format y `openai.chatgpt` / `cemkurtulus.agent-pipeline` como agentes permitidos.

## Holdlist recomendada

Mantener en decision owner las extensiones AGENT/MCP/AI paralelas antes de promoverlas al perfil operativo. No desinstalar automaticamente.

## Tasks agregadas

- `CEO IDE: Extension List`.
- `CEO IDE: Extension Policy`.
- `CEO IDE: Extension Control`.

## Brecha controlada

`code-insiders --list-extensions --show-versions` esta disponible y lista extensiones visibles, pero en este sandbox intenta crear logs en AppData y devuelve `EPERM`. El comando canonico evita esa mutacion usando lectura directa de carpeta local.

## Validaciones

- `tools/ceo-ide-extension-list.ps1 -Json`: IDE_EXTENSION_LIST_READY.
- `tools/ceo-ide-extension-policy.ps1 -Json`: IDE_EXTENSION_CONTROL_READY.
- `tools/ceo-ide-command-test.ps1 -Json`: IDE_COMMAND_SURFACE_READY.
- `tools/ceo-ide-tasks-status.ps1 -Json`: IDE_TASKS_PRODUCTIVE_READY.
- `python -m tools.validate`: OK, 175 metadatos validos.
- `tools/sdu_chain_resolver.py --no-external --dry-run --json`: PASS.
- `pytest`: 54 passed, 1 skipped.
- `git diff --check`: PASS en superficie del carril.

## Frontera

- No uninstall.
- No profile mutation.
- No MCP execution.
- No secretos.
- No push.
- No PR.
- No live.
- No stage.
- No commit.

## Proxima accion ejecutable

Ejecutar task `CEO IDE: Extension Control` desde VS Code Insiders.
