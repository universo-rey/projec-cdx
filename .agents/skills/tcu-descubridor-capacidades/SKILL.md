---
name: tcu-descubridor-capacidades
description: Use when starting, assigning, deriving, dispatching, executing, or closing any Cabina Universal task to run skill discovery, capability assignment, NO_DISPONIBLE marking, and preflight for the real available skill, recipe, plugin, and tool set.
---

# TCU Descubridor Capacidades

## Core Rule

Every task starts by discovering and assigning real capabilities. A skill,
recipe, plugin, or tool is not available just because its name appears in text.
It must exist in the active runtime, repo-local catalog, plugin list, or
governed matrix. If it does not resolve, mark it `NO_DISPONIBLE`.

## Trigger Boundary

Use this skill before intake classification, agent assignment, handoff,
parallel dispatch, Codex Cloud delegation, local execution, GitHub automation,
or closeout.

## Allowed Actions

- inspect available skills, recipes, tools, plugins, and agent assignments
- select the smallest real capability chain for the task
- map capability gaps as `NO_DISPONIBLE`
- update local governance matrices and readbacks when capability assignments
  change
- route to Codex Cloud only when the repo, branch, data boundary, owner,
  rollback, validator, and stop condition are declared

## Blocked Actions

- inventing unavailable skills, recipes, plugins, tools, or validators
- using Codex Cloud for secrets, broad regulated data, Microsoft live,
  production, OpenAI API live, permission changes, or tenant writes
- activating persistent remote agents without a governed order
- replacing human or institutional authority

## Workflow

1. Read the current capability-use matrix and assigned agent contract.
2. Verify the requested skill, recipe, plugin, and tool against local catalogs.
3. Assign the capability chain to the owner agent and reviewer agent.
4. If the task can run autonomously, classify it as local task-scoped,
   GitHub task-scoped, or Codex Cloud task-scoped.
5. If any capability cannot be proven, record `NO_DISPONIBLE` and stop or
   prepare a governed order.
6. Close with evidence, validator, rollback, and stop condition.

## Validator

Primary:
`.agents\codex\tools\local_validate_capability_use_hardening.ps1`.

Companion:
`.agents\codex\tools\local_validate_autonomous_agent_execution.ps1`.

## Stop Conditions

- `capability_use_preflight_missing`
- `default_skill_missing`
- `codex_cloud_environment_missing`
- `autonomous_agent_order_missing`
- `secret_detected`
