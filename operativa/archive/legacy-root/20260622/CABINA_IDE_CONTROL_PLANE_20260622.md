---
artifact_id: operativa/archive/legacy-root/20260622/CABINA_IDE_CONTROL_PLANE_20260622.md
categoria: operativa
tipo: plan
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/CABINA_IDE_CONTROL_PLANE_20260622.md
etiquetas:
- cabina
- ide-control-plane
- vscode-insiders
- sistema-nervioso
- local-only
relacionados:
- operativa/archive/legacy-root/20260622/CABINA_IDE_CONTROL_PLANE_LANES_20260622.csv
- operativa/archive/legacy-root/20260622/CABINA_IDE_RUNNER_COMMAND_INDEX_20260622.csv
- operativa/archive/legacy-root/20260622/READBACK_CABINA_IDE_CONTROL_PLANE_20260622.md
- operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_PLAN_20260622.md
descripcion: Plan de activacion de VS Code Insiders como cabina de mando local del sistema nervioso PROJEC CDX.
fecha_evento: '2026-06-22'
---

# CABINA IDE CONTROL PLANE 20260622

## Estado de entrada

- `CABINA_GOBIERNO_TOTAL_PLAN_FIRST_READY`
- `CEO_PATH_REPAIRED_CANONICAL_RUNTIME`
- `CABINA_LOCAL_FULL_STACK_CANON_READY_NO_DRIFT`

## Decision

El sistema nervioso ya existe. No se reconstruye desde carpetas. VS Code Insiders se promueve como superficie de mando local del sistema operativo agentico, con `C:\CEO\project-cdx` como workspace rector.

## Evidencia local

- VS Code Insiders: `1.126.0-insider`
- Build: `e6f4d6c6f2977850cdae6b9e53f706f3c5faa63b`
- Extensiones totales observadas: `126`
- Extensiones agente/OpenAI/Codex/Copilot: `36`
- Extensiones Microsoft/Azure/M365/Power Platform: `49`
- Extensiones Python/Data/Docs: `20`
- Extensiones GitHub/CodeQL/GitLens: `7`

## Evidencia OpenAI Codex

El manual Codex actualizado localmente confirma:

- La extension IDE usa el mismo agente que Codex CLI y comparte configuracion.
- La extension IDE usa el Codex CLI y la configuracion compartida `~/.codex/config.toml`.
- Las skills estan disponibles en CLI, IDE extension y Codex app.
- Codex soporta MCP en CLI e IDE extension.
- Windows soporta Codex app, CLI e IDE extension como superficies nativas.

## Carriles de mando

| carril | funcion | regla |
| --- | --- | --- |
| `01_RUNTIME` | PATH, Python, Node, Codex CLI, PowerShell, CEO scripts | no mutar entorno sin backup y owner |
| `02_AGENT_CHAIN` | Seshat, Thot, Anubis, Maat, Horus, Narrador, Einstein, Faraday, Ramanujan | agentes con carril y frontera |
| `03_REPOS` | project-cdx, repos hijos, worktrees | no absorber clones ni mover `.git` |
| `04_CODEX_MEMORY` | `.codex`, config, plugins, cache, DBs, memories | no DB mutation ni cache cleanup |
| `05_COMMANDS_RUNNERS` | tools, scripts, pytest, metadata CLI, sentinel | runners versionados y gateados |
| `06_SKILLS_RECIPES_PLUGINS` | skill registry, recipe registry, plugin registry | no duplicar si existe equivalente |
| `07_CONNECTORS` | GitHub, PAC, Dataverse, OpenAI, Microsoft, MCP config | on-demand gated |
| `08_METADATA_EVIDENCE` | schema, front matter, readbacks, matrices, manifests | metadata PASS antes de cierre |

## Accion ahora

Crear indice IDE/control-plane y runner command index. No mover carpetas. No modificar `.codex`. No ejecutar MCP. No abrir conectores live.

## Resultado esperado

`CABINA_IDE_CONTROL_PLANE_READY`
