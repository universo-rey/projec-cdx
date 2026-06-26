---
name: cabina-superpowers-methodology-adapter
description: Use when Superpowers methodology in D:\ needs planning, debugging, verification, subagent, worktree, or skill-writing guidance under Cabina governance.
---

# Cabina Superpowers Methodology Adapter

## Core Rule

Superpowers is methodology, not authority. Use its patterns only inside the
current D cabina boundaries, with real local tools, validators, evidence, and
stop conditions.

## Trigger Boundary

Use when work mentions Superpowers, planning, systematic debugging,
verification, subagents, worktrees, writing skills, or methodology transfer.

## Allowed Actions

- borrow methodology patterns for planning and verification
- map subagent and worktree ideas to D lane governance
- use D-native skills when they exist
- keep external methodology as adapter-only

## Blocked Actions

- weakening `D:\AGENTS.md`
- remote persistent agents without order
- worktree or branch changes without scope
- secrets
- Microsoft live
- OpenAI API live
- production

## Validator

Use `D:\.agents\codex\tools\local_validate_capability_use_hardening.ps1`,
`D:\.agents\codex\tools\local_validate_parallel_order_governance.ps1`, and
`D:\.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Evidence

Mapped D skill, recipe, tool, lane scope, validator result, and readback.

## Stop Conditions

- `capability_use_preflight_missing`
- `parallel_lane_without_validator`
- `instruction_precedence_missing`
- `secret_detected`
