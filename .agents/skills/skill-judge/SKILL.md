---
name: skill-judge
description: Use when skill review, SKILL.md audit, or integration decision work is needed before trusting, integrating, comparing, or assigning skills in D:\.
---

# Skill Judge

## Core Rule

Judge a skill by useful capability delta, activation clarity, boundary safety,
validator coverage, and lack of duplicate canon. Do not adopt a skill just
because it exists.

## Trigger Boundary

Use before integrating external skills into `D:\.agents\skills`, changing
skill metadata, or deciding whether to keep a skill as adapter-only.

## Allowed Actions

- review SKILL.md frontmatter and trigger boundary
- compare against existing D skills and plugins
- classify `CANONIZE_D`, `ADAPTER_ONLY`, `EXTERNAL_RUNTIME`, `DEFER`, or
  `NO_DISPONIBLE`
- propose concise rewrites and validator coverage

## Blocked Actions

- copying broad plugin internals as D canon
- weakening `D:\AGENTS.md`
- adopting duplicate skills without reconciliation
- Microsoft live, production, secrets, or OpenAI API live

## Validator

Use `D:\.agents\codex\tools\local_validate_skill_metadata.ps1`,
`D:\.agents\codex\tools\local_validate_d_skill_availability_and_issue_pr_friction.ps1`,
and `D:\.agents\codex\tools\local_validate_agent_layer.ps1`.

## Evidence

Skill diff, integration decision matrix, metadata matrix, validator result,
and readback.

## Stop Conditions

- `duplicate_skill_without_reconciliation`
- `skill_metadata_missing_or_ambiguous`
- `d_skill_availability_or_issue_pr_friction_guard_failed`
