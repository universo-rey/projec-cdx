---
artifact_id: operativa/archive/legacy-root/20260622/W4_SKILL_RECIPE_PLUGIN_RECONCILIATION_PLAN_20260622.md
categoria: operativa
tipo: plan
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/W4_SKILL_RECIPE_PLUGIN_RECONCILIATION_PLAN_20260622.md
etiquetas:
- cabina
- sdu
- w4
- skills
- plugins
- recipes
relacionados:
- operativa/archive/legacy-root/20260622/W4_SKILL_RECIPE_PLUGIN_RECONCILIATION_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/W4_SKILL_DEDUPLICATION_ALIAS_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/W4_PLUGIN_CACHE_REFERENCE_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/W4_RECTOR_SKILLS_CHAIN_ASSIGNMENT_20260622.csv
- operativa/archive/legacy-root/20260622/READBACK_W4_SKILL_RECIPE_PLUGIN_INDEX_RECONCILIATION_20260622.md
descripcion: Plan W4 para reconciliar skills, recetas, plugins y asignacion rector de la cabina.
fecha_evento: '2026-06-22'
---

# W4 SKILL RECIPE PLUGIN INDEX RECONCILIATION PLAN

## Estado de entrada

- Repo: C:\CEO\project-cdx / alias fisico C:\Users\enzo1\PROJEC CDX.
- Estado base: VERSION_v0.6.0_CANDIDATE_READY.
- Frontera: local-only, sin live write, sin MCP, sin secretos, sin instalacion y sin mutacion de .codex.

## Objetivo

Reconciliar el indice de skills, recetas y plugins para que la cabina distinga capacidad activa, alias, cache de plugin, superficie bajo gate y carriles rectores.

## Fuentes leidas

- .codex/skills: 82 skills.
- .agents/skills: 36 skills.
- .codex/plugins/cache: 263 skills de plugin/cache.
- recipes/: 17 recetas.
- inventarios/SKILLS_UNIFIED_TABLE.csv como referencia previa.
- Matrices W0/IDE y matriz de gobierno total como referencias vigentes.

## Politica de reconciliacion

1. Skills rectoras quedan como ACTIVE_CANON u ON_DEMAND_GATED segun frontera.
2. Plugin cache no se promueve completo a canon: queda PLUGIN_CACHE_REFERENCE salvo asignacion explicita.
3. Duplicados quedan en matriz de alias y merge_allowed=false hasta decision owner.
4. Cualquier superficie con OpenAI, Microsoft, Dataverse, SharePoint, GitHub, MCP o secretos exige gate.
5. Recetas versionadas en recipes/ quedan ACTIVE_CANON si existen fisicamente.

## Resultado esperado

W4_SKILL_RECIPE_PLUGIN_INDEX_RECONCILIATION_READY
