---
name: repo-agent-tool-governance
description: Use when repo, agent, tool, surface, recipe, capability, owner, validator, or stop-condition governance must be assigned in D-drive.
---

# Repo Agent Tool Governance

## Core Rule

Repos, agents, tools, recipes, and execution surfaces are governed assets. None
should be treated as loose folders, free-form assistants, or generic commands.

## Trigger Boundary

Use this skill for local D-drive governance assignment: repo ownership, agent
authority, tool boundaries, surface mapping, recipe selection, evidence fields,
validators, and stop conditions.

## Allowed Actions

- Classify assets as repo, agent, tool, recipe, skill, matrix, map, eval,
  plugin, or external surface.
- Assign owner agent, authority level, surface, allowed actions, blocked
  actions, required recipe, required tool, evidence, validator, and stop
  condition.
- Update local governance matrices and readbacks.
- Mark absent tools or plugins as `NO_DISPONIBLE`.
- Validate that each execution surface has a boundary before use.

## Blocked Actions

- `microsoft_live`
- `openai_api_live`
- `production`
- `secrets`
- Treating folders as repos without metadata.
- Using tools without allowed and blocked surface declarations.
- Any write, cost, live, permission, tenant, or production action without a
  governed order.

## Governance Contract

Every governed asset needs:

- `owner_agent`
- `authority_level`
- `surface`
- `allowed_actions`
- `blocked_actions`
- `required_recipe`
- `required_tool`
- `evidence`
- `validator`
- `stop_condition`

## Required Reads

1. `.agents\codex\matrices\REPO_AGENT_TOOL_GOVERNANCE_MATRIX.csv`
2. `.agents\codex\matrices\REPO_GOVERNANCE_ASSIGNMENT_MATRIX.csv`
3. `.agents\codex\matrices\AGENT_GOVERNANCE_MATRIX.csv`
4. `.agents\codex\matrices\TOOL_GOVERNANCE_MATRIX.csv`
5. `.agents\codex\maps\SURFACE_BOUNDARY_MAP.csv`

## Workflow

1. Classify the asset as repo, agent, tool, recipe, skill, matrix, map, eval,
   plugin, or external surface.
2. Find its owner agent and authority level.
3. Confirm allowed and blocked actions before using it.
4. Select the required recipe and tool.
5. Record evidence locally.
6. Run the governance validator before closeout.

## Validator

Run:

```powershell
.agents\codex\tools\local_validate_agent_layer.ps1
.agents\codex\tools\local_validate_skill_metadata.ps1
```

## Stop Conditions

- Asset has no owner agent.
- Tool has no allowed and blocked surface.
- Repo has no universe or tower assignment.
- Agent has no authority level or escalation target.
- Any write, cost, live, secret, production, permission, or tenant action lacks
  governed order fields.

## Output Contract

Every closeout must include `agente`, `orden`, `superficie`, `skill`,
`receta`, `tool`, `estado`, `evidencia`, `validador`, `riesgo`, `rollback`,
`stop_condition`, and `proximos_carriles`.
