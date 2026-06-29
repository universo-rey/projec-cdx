---
name: rey-modo-gobernador-capacidades
description: Use when capability discovery, skill adoption, NO_DISPONIBLE marking, or integration decisions are needed for skills, recipes, plugins, tools, or capabilities in D:\ canon.
---

# Rey Modo Gobernador Capacidades

## Core Rule

A capability is real only if it resolves to an available skill, recipe, plugin,
tool, validator, surface, evidence path, and stop condition. External runtime
skills are not durable D canon unless explicitly integrated.

## Trigger Boundary

Use before adopting capabilities, resolving duplicates, marking
`NO_DISPONIBLE`, or deciding between `CANONIZE_D`, `ADAPTER_ONLY`,
`EXTERNAL_RUNTIME`, and `DEFER`.

## Allowed Actions

- inspect local D skill folders and catalogs
- compare external skills against repo-local needs
- classify capability gaps
- update local decision matrices and catalogs when ordered
- prefer existing D skills before creating new ones

## Blocked Actions

- inventing unavailable capabilities
- copying plugin/live connector internals as D canon
- Microsoft live, production, permissions, secrets, or OpenAI API live
- adopting duplicate skills without reconciliation

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools`
and `C:\CEO\project-cdx\.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Skill catalog rows, D skill folder presence, integration decision matrix, and
validator output.

## Stop Conditions

- `capability_use_preflight_missing`
- `duplicate_skill_without_reconciliation`
- `default_skill_missing`
- `d_skill_availability_or_issue_pr_friction_guard_failed`


