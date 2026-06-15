# Matriz Skills Tools Recetas 20260615

## Estado

`MATRIZ_CORTA_VISIBLE`

## Alcance

Inventario corto de la capa de capacidades de `PROJEC CDX`.
No inventa capacidades: cruza lo visible, lo soportado y lo derivado.

## Foto Rapida

- Skills locales visibles: `73` carpetas en [`.codex/skills`](C:/Users/enzo1/.codex/skills) y `25` carpetas en [`.agents/skills`](C:/Users/enzo1/.agents/skills).
- Tools locales visibles: `15` artefactos en [`tools/`](C:/Users/enzo1/PROJEC%20CDX/tools).
- Recipes visibles: `5` archivos en [`recipes/`](C:/Users/enzo1/PROJEC%20CDX/recipes).

## Mapa Corto

| Capa | Donde vive | Que gobierna | Canon de lectura | Evidencia o validacion |
| --- | --- | --- | --- | --- |
| Skills | [`.codex/skills`](C:/Users/enzo1/.codex/skills) | Carriles, capacidades y orden de uso | [README.md](C:/Users/enzo1/.codex/skills/README.md), [STACK.md](C:/Users/enzo1/.codex/skills/STACK.md), [MATRIZ_OPERATIVA.md](C:/Users/enzo1/.codex/skills/MATRIZ_OPERATIVA.md), [PROMPT_ARRANQUE.md](C:/Users/enzo1/.codex/skills/PROMPT_ARRANQUE.md) | [SKILLS_INDEX.csv](C:/Users/enzo1/.codex/skills/SKILLS_INDEX.csv), [SKILLS_UNIFIED_TABLE.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.csv), `NO_DISPONIBLE` |
| Tools | [`tools/`](C:/Users/enzo1/PROJEC%20CDX/tools) | Generacion, normalizacion y validacion | [README.md](C:/Users/enzo1/PROJEC%20CDX/tools/README.md), [MAPA.md](C:/Users/enzo1/PROJEC%20CDX/tools/MAPA.md), [RESOLUCION_TOOLS_20260615.md](C:/Users/enzo1/PROJEC%20CDX/tools/RESOLUCION_TOOLS_20260615.md) | [validate_proj_cdx_workbench.ps1](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_workbench.ps1), [validate_proj_cdx_sync.ps1](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_sync.ps1), [validate_proj_cdx_operational_chain.ps1](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_operational_chain.ps1) |
| Recipes | [`recipes/`](C:/Users/enzo1/PROJEC%20CDX/recipes) | Regla derivada y cruzamiento de capa | [README.md](C:/Users/enzo1/PROJEC%20CDX/recipes/README.md), [MAPA.md](C:/Users/enzo1/PROJEC%20CDX/recipes/MAPA.md) | [CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv), [SKILLS_UNIFIED_TABLE.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.csv), [matrix-recipe-skill-sync](C:/Users/enzo1/.codex/skills/matrix-recipe-skill-sync/SKILL.md) |

## Reglas Cortas

- Si cambia una skill, una receta o un tool, actualizar la matriz y el índice asociado.
- Si una capacidad no aparece en índice, marcarla `NO_DISPONIBLE` o `NO_CONSTA`.
- Si la tarea pide ordenar, preservar links o reducir ruido, usar [codex-surface-map](C:/Users/enzo1/.codex/skills/codex-surface-map/SKILL.md).
- Si la tarea pide owner, surface, validator o stop condition, usar [repo-agent-tool-governance](C:/Users/enzo1/.codex/skills/repo-agent-tool-governance/SKILL.md).
- Si el mismo cierre documental vuelve a aparecer, abrir primero [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md) y luego usar [recipes/cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/recipes/cierre-wave-documental.md) y [procesos/cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/procesos/cierre-wave-documental.md) antes de rehacer el trabajo a mano.
- Si el mismo ajuste de procedencia/layout vuelve a aparecer, abrir primero [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md) y luego usar [recipes/procedencia-layout-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/recipes/procedencia-layout-on-demand.md) y [procesos/procedencia-layout-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/procesos/procedencia-layout-on-demand.md) antes de rehacer el trabajo a mano.
- Si falta acceso a un complemento, plugin o MCP directo, abrir primero [operativa/COMPLEMENTOS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/COMPLEMENTOS_ON_DEMAND.md) y luego usar [recipes/complementos-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/recipes/complementos-on-demand.md) y [procesos/complementos-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/procesos/complementos-on-demand.md) antes de inventar disponibilidad.
- Si la delegacion se hace por waves, abrir primero [operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md) y luego usar [recipes/agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/recipes/agentes-atomicos-algoritmicos-en-waves.md) y [procesos/agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/procesos/agentes-atomicos-algoritmicos-en-waves.md) para no abrir frentes paralelos.

## Relaciones Minimas

- [tcu-descubridor-capacidades](C:/Users/enzo1/.codex/skills/tcu-descubridor-capacidades/SKILL.md) para descubrir capacidades.
- [cabina-mini-router](C:/Users/enzo1/.codex/skills/cabina-mini-router/SKILL.md) para elegir carril minimo.
- [matrix-recipe-skill-sync](C:/Users/enzo1/.codex/skills/matrix-recipe-skill-sync/SKILL.md) para sincronizar cambios.
- [governed-readback-closeout](C:/Users/enzo1/.codex/skills/governed-readback-closeout/SKILL.md) para cierre con evidencia.
- Si un validador solo existe en un worktree ajeno, no se enlaza como si fuera local: se marca `NO_DISPONIBLE`.

## Cierre

La capa queda legible en una pasada:
`skill` ejecuta,
`tool` materializa,
`recipe` cruza,
`matrix` mantiene alineacion.
