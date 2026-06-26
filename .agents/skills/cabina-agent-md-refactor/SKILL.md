---
name: cabina-agent-md-refactor
description: Use when AGENTS.md, Codex UI prompts, project instructions, or local governance instructions in cabina-universal-d need pruning, normalization, drift review, or instruction precedence checks without weakening AGENTS.md canon.
---

# Cabina Agent MD Refactor

## Core Rule

Never simplify authority. Reduce repetition only after preserving the local
canon, blocked surfaces, required reads and closeout fields.

## Trigger Boundary

Use this skill only for local instruction surfaces: `AGENTS.md`, UI prompts,
project instructions, nested instruction notes, and drift reviews. Do not use
it to approve live surfaces, change global Codex config, or weaken the root
cabina canon.

## Allowed Actions

- prune repeated wording after preserving authority
- normalize local prompt and instruction text
- map instruction precedence and nested surfaces
- prepare local-only draft corrections

## Blocked Actions

- removing `AGENTS.md` as root authority
- absorbing nested repos into the root wrapper repo
- authorizing Microsoft live, OpenAI API live, production, permissions,
  secrets, costs or broad regulated data

## Validator

Primary: `.agents\codex\tools\local_validate_agents_instruction_hierarchy.ps1`.
Companion: `.agents\codex\tools\local_validate_operational_chain.ps1`.

## Required Reads

1. `AGENTS.md`
2. `MANIFEST.yaml`
3. `.agents\codex\README.md`
4. Any prompt or instruction file being edited

## Workflow

1. Classify each instruction as canon, workflow, reminder, duplicate or stale.
2. Preserve canon verbatim when it changes authority, gates or blocked actions.
3. Move repeated workflow detail into a referenced matrix, recipe or skill when
   the repo already has that artifact.
4. Keep the UI prompt short enough to be actionable at chat start.
5. Validate the operational chain before claiming the prompt is aligned.

## Stop Conditions

- A change would remove GitHub branch, validation, explicit stage, commit, push
  or PR requirements.
- A change would blur nested repo boundaries.
- A change would authorize live, production, permission, secret, cost or broad
  regulated-data surfaces.
- The instruction source conflicts with `AGENTS.md`.
