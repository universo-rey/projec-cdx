---
name: d-drive-agent-layer-enrichment
description: Use when D-drive matrices, recipes, skills, tools, validators, readbacks, or agent routing overlays need local enrichment under cabina governance.
---

# D Drive Agent Layer Enrichment

## Core Rule

Enrich the existing D-drive agent layer by reconciling first, then adding the
smallest missing local artifact. Do not replace source registries or create
remote agents.

## Trigger Boundary

Use this skill only for local D-drive governance artifacts under
`.agents\codex` and `.agents\skills`, including matrices, recipes,
skills, tools, validators, readbacks, workpapers, maps, or agent routing
overlays.

## Allowed Actions

- Read the cabina manifest, agent layer README, indexes, recipes, tools, and
  validator matrices.
- Add or adjust local governance artifacts that are inside the root wrapper
  allowlist.
- Update affected indexes and crosswalks when an artifact becomes durable.
- Record evidence through a local readback.
- Run local validators and report gaps without inventing missing tools.

## Blocked Actions

- `microsoft_live`
- `openai_api_live`
- `production`
- `secrets`
- Moving local clones or absorbing nested repos.
- Creating remote agents or persistent external runtime.

## Required Reads

1. `AGENTS.md`
2. `.agents\codex\README.md`
3. `.agents\codex\matrices\MATRIX_INDEX.csv`
4. `.agents\codex\recipes\RECIPE_INDEX.csv`
5. `.agents\codex\skills\SKILL_USAGE_MATRIX.csv`
6. `.agents\codex\tools\TOOL_INDEX.csv`

## Workflow

1. Classify the requested enrichment as matrix, recipe, skill, tool, eval, map,
   agent profile, workpaper, or readback.
2. Check existing `SOURCE_*` files and indexes before creating a new local
   overlay.
3. Add or update the primary artifact.
4. Update every affected index or crosswalk.
5. Run the local validator.
6. Close with a readback that states systems touched, systems not touched,
   risk, validator result, rollback, and next lanes.

## Validator

Run the most specific validator for the changed artifact, then run:

```powershell
.agents\codex\tools\local_validate_agent_layer.ps1
.agents\codex\tools\local_validate_skill_metadata.ps1
```

## Stop Conditions

- Secret, token, credential, or raw regulated-data access is required.
- A remote API, Microsoft live surface, Git write, or production surface is
  needed without the required governed order.
- An artifact would duplicate an existing source without adding a local routing
  or validation purpose.
- The validator fails and the failure is not explained.

## Output Contract

Every closeout must include `agente`, `orden`, `superficie`, `skill`,
`receta`, `tool`, `estado`, `evidencia`, `validador`, `riesgo`, `rollback`,
`stop_condition`, and `proximos_carriles`.
