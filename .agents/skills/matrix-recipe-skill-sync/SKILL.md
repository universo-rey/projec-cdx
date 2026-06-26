---
name: matrix-recipe-skill-sync
description: Use when a D-drive matrix, recipe, skill, tool, map, eval, or agent assignment changes and indexes must stay aligned.
---

# Matrix Recipe Skill Sync

## Core Rule

No local capability is real unless the artifact, its index row, assigned agent,
recipe, tool, validator, evidence, and stop condition agree.

## Trigger Boundary

Use this skill when a D-drive matrix, recipe, skill, tool, map, eval, plugin
reference, template, or agent assignment changes and the local indexes must be
kept aligned.

## Allowed Actions

- Compare artifact paths against matrix and catalog rows.
- Update local indexes and crosswalks for skills, recipes, tools, maps, evals,
  and agent assignments.
- Normalize source labels such as `d_drive_repo_local`, `plugin`,
  `installed_local`, and `system_local`.
- Record validator and evidence paths for changed local artifacts.
- Mark unavailable tools or plugins as `NO_DISPONIBLE` when they do not exist.

## Blocked Actions

- `microsoft_live`
- `openai_api_live`
- `production`
- `secrets`
- Inventing skills, recipes, tools, plugins, or validators.
- Assigning a live or cost surface without governed order fields.

## Sync Checklist

For a skill change:

- Update `.agents\codex\skills\SKILL_USAGE_MATRIX.csv`.
- Ensure the skill folder has `SKILL.md`.
- Update `.agents\codex\skills\SKILL_METADATA_QUALITY_MATRIX.csv` when the
  skill is repo-local.
- Link the skill from the appropriate agent assignment matrix when an agent uses
  it.

For a recipe change:

- Update `.agents\codex\recipes\RECIPE_INDEX.csv`.
- Ensure the recipe file exists.
- Link the recipe from the appropriate agent-tool-recipe-skill matrix.

For a matrix or map change:

- Update `.agents\codex\matrices\MATRIX_INDEX.csv` or the appropriate map
  index.
- Add validation coverage in the evidence and validation matrix when it affects
  closeout.

For a tool change:

- Update `.agents\codex\tools\TOOL_INDEX.csv`.
- Declare allowed and blocked surfaces.
- Keep command paths local unless a governed order opens a live surface.

## Validator

Run:

```powershell
.agents\codex\tools\local_validate_agent_layer.ps1
.agents\codex\tools\local_validate_skill_metadata.ps1
```

If the full validator is unavailable, run the closest local validator and record
the gap as `NO_DISPONIBLE`.

## Stop Conditions

- An index points to a missing local file.
- A skill, recipe, or tool is assigned to an agent without level, owner,
  validator, evidence, or stop condition.
- A live, cost, remote, tenant, or production surface appears without governed
  order fields.
- A closeout lacks readback evidence.

## Output Contract

Every closeout must include `agente`, `orden`, `superficie`, `skill`,
`receta`, `tool`, `estado`, `evidencia`, `validador`, `riesgo`, `rollback`,
`stop_condition`, and `proximos_carriles`.
