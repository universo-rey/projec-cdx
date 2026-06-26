---
name: agent-retrospective-learning
description: Use when a completed governed frontier must be converted into reusable skills, recipes, validator candidates, agent deltas, prompt improvements, and reviewable readbacks without new live execution.
---

# Agent Retrospective Learning

## Core Rule

Retrospective learning is a local no-live lane. It converts verified evidence
into reusable capabilities without reopening the execution surface.

## Trigger Boundary

Use this after a PR chain or runtime frontier closes and the user asks to turn
lessons into skills, recipes, agents, validators, matrices, prompts, or
readbacks.

## Allowed Actions

- read local evidence and GitHub PR metadata
- create candidate skill and recipe matrices
- canonize only non-duplicative local skills or recipes
- record agent assignment deltas
- create no-live validators and prompt packs
- open a PR for review

## Blocked Actions

- Dataverse live
- Power Automate live
- OpenAI API
- Batch API
- PROD, TEST, Default
- SharePoint, Planner, broad Graph
- secrets or `.env.local`

## Validator

Primary: `.agents\codex\tools\local_validate_skill_recipe_agent_learning.ps1`.

Companion: Change-Aware Full-Coverage Orchestrator.

## Evidence

Timeline, operational retrospective, skill/recipe matrices, agent deltas,
validator matrix, prompt pack, readback and PR checks.

## Stop Conditions

- `retrospective_source_missing`
- `secret_detected`
- `live_execution_requested`
- `duplicate_skill_without_reconciliation`
- `validator_failed`
