---
artifact_id: operativa/tasks/20260623/READBACK_IDE_SKILL_RECIPE_PROMOTION_PACK_G1_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: CABINA_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_SKILL_RECIPE_PROMOTION_PACK_G1_20260623.md
etiquetas:
  - vscode-insiders
  - skills
  - recetas
  - ide-control-plane
  - productiva
  - local-only
relacionados:
  - operativa/tasks/20260623/IDE_SKILL_RECIPE_PROMOTION_PACK_G1_20260623.csv
  - operativa/tasks/20260623/IDE_SKILL_RECIPE_PROMOTION_PACK_G1_INDEX_20260623.json
  - inventarios/AGENTES_SKILLS_RECETAS_20260616.md
  - inventarios/SKILLS_UNIFIED_TABLE.csv
  - recipes/INDICE_RECETAS.md
  - docs/referencia/semantic-layer.md
descripcion: Readback de reconciliacion y promocion candidata de skills y recetas para VS Code Insiders como control plane de cabina.
---

# IDE SKILL RECIPE PROMOTION PACK G1

## Estado

`IDE_CONTROL_PLANE_SKILLS_RECIPES_PACK_G1_READY`

## Dictamen

El adjunto queda absorbido como paquete promovible, no como lista canonica paralela.

La fuente canonica de fondo sigue siendo:

1. `docs\referencia\semantic-layer.md`
2. `inventarios\AGENTES_SKILLS_RECETAS_20260616.md`
3. `inventarios\SKILLS_UNIFIED_TABLE.csv`
4. `recipes\INDICE_RECETAS.md`
5. `operativa\archive\legacy-root\20260615\MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md`

## Capacidades producidas

- Skill and recipe promotion pack para VS Code Insiders.
- Indice JSON operativo para lectura directa por Codex.
- Cruce normalizado `skill -> receta -> comando -> task -> agente -> capability`.
- Separacion entre `READY_FROM_EXISTING`, `POLICY_READY`, `READY_MAP_ONLY` y `CANDIDATE_ONLY`.
- Gate explicito para comandos no existentes o con superficie remota.

## Skills normalizadas

- `ide-workspace-governance`
- `ide-terminal-runtime-control`
- `ide-command-surface-management`
- `ide-task-runner-governance`
- `ide-extension-policy`
- `ide-agent-mcp-routing`
- `ide-evidence-capture`
- `ide-telemetry-readback`
- `ide-git-guard`
- `ide-profile-standardisation`
- `detect-ide-drift`
- `repair-ide-terminal-runtime`
- `promote-script-to-ide-task`
- `classify-ide-extensions`
- `map-ide-command-surface`
- `capture-ide-operation-evidence`
- `route-agent-work-from-ide`
- `prepare-ide-remote-gate`
- `ide-no-bypass-gate`
- `ide-secret-exposure-check`
- `ide-repo-boundary-control`
- `ide-evidence-minimum-standard`
- `ide-runbook-alignment`
- `ide-capability-promotion`

## Recetas normalizadas

- `recipe-open-cabina-in-governed-ide`
- `recipe-repair-ide-terminal-runtime`
- `recipe-build-ide-command-surface`
- `recipe-promote-script-to-vscode-task`
- `recipe-classify-vscode-insiders-extensions`
- `recipe-map-agent-tools-in-ide`
- `recipe-capture-ide-operation-evidence`
- `recipe-ide-remote-readiness-without-push`
- `recipe-ide-drift-detection`
- `recipe-promote-ide-pattern-to-capability`

## Decision de canon

No se actualizo `inventarios\SKILLS_UNIFIED_TABLE.csv` porque estas entradas aun son skills promovibles del hito IDE, no carpetas `SKILL.md` instaladas ni plugins versionados.

No se actualizo `recipes\INDICE_RECETAS.md` porque las recetas aun no existen como archivos de receta canonica. Quedan en matriz de promocion hasta que una orden posterior autorice materializarlas.

## Evidencia generada

- `operativa\tasks\20260623\IDE_SKILL_RECIPE_PROMOTION_PACK_G1_20260623.csv`
- `operativa\tasks\20260623\IDE_SKILL_RECIPE_PROMOTION_PACK_G1_20260623.csv.meta.json`
- `operativa\tasks\20260623\IDE_SKILL_RECIPE_PROMOTION_PACK_G1_INDEX_20260623.json`
- `operativa\tasks\20260623\IDE_SKILL_RECIPE_PROMOTION_PACK_G1_INDEX_20260623.json.meta.json`
- `operativa\tasks\20260623\READBACK_IDE_SKILL_RECIPE_PROMOTION_PACK_G1_20260623.md`

## Gate pendiente

- `remote_publication_gate` para `ceo-remote-ready`.
- `owner_gate_for_new_task` para crear nuevos shims o tasks que no esten respaldados por script existente.
- `owner_gate_for_capability_promotion` para convertir candidatos en skills instaladas o recetas canonicas.
- `mcp_execution_gate` para cualquier ejecucion MCP.

## Siguiente accion ejecutable

Ejecutar:

```powershell
.\tools\ceo-ide-command-test.ps1 -Json
```

Si sigue `IDE_COMMAND_SURFACE_READY`, el siguiente delta productivo es:

```text
PROMOTE_IDE_SKILL_RECIPE_PACK_TO_CANON_OR_KEEP_AS_BACKLOG
```

## Frontera

- No push.
- No PR.
- No live.
- No MCP execution.
- No secretos.
- No stage.
- No commit.
