---
name: cabina-naming-analyzer
description: Use when agent ids, repo ids, matrix ids, skill ids, recipe ids, tool ids, aliases, folders, or stop conditions need canonical naming, alias mapping, cross-matrix synchronization, or vocabulary checks in cabina-universal-d.
---

# Cabina Naming Analyzer

## Core Rule

Names are contracts. A rename is only valid when every index, matrix, recipe,
tool, agent profile and validator reference continues to resolve.

## Trigger Boundary

Use this skill for local identifier and vocabulary work: agent ids, skill ids,
recipe ids, tool ids, matrix ids, aliases, folders and stop conditions. Do not
use it as authority to rename evidence history or remote repos.

## Allowed Actions

- compare candidate ids with existing indexes
- register aliases instead of erasing historical names
- synchronize names across matrices, recipes, tools and profiles
- validate stop-condition vocabulary

## Blocked Actions

- orphaning evidence, PR history, workpapers or source lineage
- replacing canonical ids without an alias map
- introducing unregistered stop conditions
- moving folders or clones as part of a naming cleanup

## Validator

Primary: `.agents\codex\tools\local_validate_agent_layer.ps1`.
Companion: `.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Workflow

1. Identify the object class: repo, agent, subagent, skill, subskill, recipe,
   subrecipe, tool, matrix, plugin, stop condition or folder.
2. Prefer existing canonical ids over new aliases.
3. If an alias is needed, register it instead of replacing history.
4. Check the matching index first, then all crosswalk matrices.
5. Validate with the local agent layer validator.

## Naming Rules

- Skill ids: lowercase kebab case.
- Agent ids: namespace plus role, such as `court.thot_schema`.
- Repo ids: uppercase snake case.
- Recipe ids: `recipe.<purpose>`.
- Tool ids: `tool.<purpose>`.
- Subskills and subrecipes: `subskill.<purpose>` and `subrecipe.<purpose>`.

## Stop Conditions

- The rename would orphan evidence, PR history, workpapers or source lineage.
- Two ids would refer to the same authority without an alias map.
- A stop condition is not in the glossary.
