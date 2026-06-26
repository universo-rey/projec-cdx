---
artifact_id: operativa/archive/legacy-root/20260622/W0_IDE_NERVOUS_SYSTEM_INVENTORY_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/W0_IDE_NERVOUS_SYSTEM_INVENTORY_20260622.md
etiquetas:
- cabina
- w0
- ide-control-plane
- sistema-nervioso
- inventario
relacionados:
- operativa/archive/legacy-root/20260622/W0_IDE_NERVOUS_SYSTEM_LANES_20260622.csv
- operativa/archive/legacy-root/20260622/W0_IDE_NERVOUS_SYSTEM_CONNECTORS_20260622.csv
- operativa/archive/legacy-root/20260622/W0_IDE_NERVOUS_SYSTEM_CODEX_MEMORY_20260622.csv
- operativa/archive/legacy-root/20260622/READBACK_W0_IDE_CONTROLLED_NERVOUS_SYSTEM_INVENTORY_20260622.md
- operativa/archive/legacy-root/20260622/CABINA_IDE_CONTROL_PLANE_20260622.md
descripcion: Inventario W0 del sistema nervioso de la cabina desde VS Code Insiders como control-plane local.
fecha_evento: '2026-06-22'
---

# W0 IDE NERVOUS SYSTEM INVENTORY 20260622

## Estado de entrada

- `CABINA_IDE_CONTROL_PLANE_READY`
- Commit base: `6a19de8b`
- Workspace rector: `C:\CEO\project-cdx`
- Modo: `READ_ONLY / IDE_CONTROLLED`

## Dictamen

El inventario W0 confirma que la cabina ya tiene sistema nervioso operativo. No corresponde mover carpetas ni limpiar por reflejo. El siguiente paso es clasificar carriles y ruido sobre esta base, no reconstruir desde cero.

## Inventario resumido

| carril | evidencia | estado |
| --- | --- | --- |
| `01_RUNTIME` | `C:\CEO\policy.json`, `Start-CEO.ps1`, `Enter-CEOExclusive.ps1`, `core`, Python venv, Node, Codex CLI, Git, gh, pac, pwsh | `ACTIVE_LOCAL` |
| `02_IDE_CONTROL_PLANE` | VS Code Insiders `1.126.0-insider`, 126 extensiones, matrices IDE ya versionadas | `IDE_CONTROLLED` |
| `03_CODEX_MEMORY` | `C:\Users\enzo1\.codex` con config, state, memories, plugins, worktrees, cache, skills, sessions | `RUNTIME_MEMORY` |
| `04_AGENT_CHAIN` | skills locales, plugins, recipes y matrices de agentes/skills | `ACTIVE_CANON` |
| `05_REPOS_SURFACES` | `project-cdx` limpio; repos hijos detectados; `cabina-universal-d` y `Sgin` con dirty propio | `GATED_ON_DEMAND` |
| `06_SKILLS_RECIPES_PLUGINS` | 82 skills en `.codex`, 36 skills en `.agents`, 263 `SKILL.md` bajo plugins cache, 17 archivos en recipes | `ACTIVE_LOCAL` |
| `07_CONNECTORS_ON_DEMAND` | GitHub CLI, PAC, VS Code GitHub, Power Platform, Azure MCP, Data Analytics/OpenAI lanes | `GATED_ON_DEMAND` |
| `08_METADATA_EVIDENCE` | `schema.json`, `index.json`, `live-manifest.json`, `MAPA_CAPAS.md`, `MAPA_MAESTRO.md`, semantic-layer, readbacks y matrices | `ACTIVE_CANON` |

## Hallazgos clave

- `C:\CEO\project-cdx` es junction a `C:\Users\enzo1\PROJEC CDX`.
- `project-cdx` esta limpio al inicio de W0.
- `python` y `code-insiders` no resuelven por nombre corto en el PATH observado, pero existen runners canonicos por ruta.
- `.codex` fue inventariado sin leer DBs ni mutar cache.
- `cabina-universal-d` conserva 21 entradas dirty propias y `Sgin` conserva 2; W0 no las toca.
- VS Code Insiders tiene superficie activa para agentes, OpenAI/Codex, Microsoft/Azure, Power Platform, Python/Jupyter, GitHub, Markdown/YAML.

## No ejecutado

- No se movieron carpetas.
- No se borraron archivos.
- No se mutaron DBs.
- No se limpio cache ni workspaceStorage.
- No se ejecuto MCP.
- No se ejecuto live.
- No se hizo push.
- No se abrio PR.
- No se leyeron ni imprimieron secretos.

## Resultado

`W0_IDE_CONTROLLED_NERVOUS_SYSTEM_INVENTORY_READY`
