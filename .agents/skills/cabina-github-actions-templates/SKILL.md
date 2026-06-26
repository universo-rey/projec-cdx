---
name: cabina-github-actions-templates
description: Use when creating or reviewing GitHub Actions, Copilot instructions, issue forms, PR templates, workflow permissions, checks, or repo automation templates for cabina-governed repos.
---

# Cabina GitHub Actions Templates

## Core Rule

GitHub automation is repo-scoped validation by default. Workflows must be
read-only unless a separate governed order opens a write surface.

## Trigger Boundary

Use this skill for GitHub-native templates and automation surfaces inside a
cabina-governed repo. It covers workflow validation, Copilot instructions,
issue forms and PR templates, not deployments or external live runtimes.

## Allowed Actions

- add or review read-only validation workflows
- align issue forms, PR templates and Copilot instructions
- check workflow triggers, permissions and blocked surfaces
- prepare repo-scoped GitHub automation evidence

## Blocked Actions

- workflow secrets, deployments or write permissions without separate order
- production, Microsoft live, OpenAI API live, force push, merge or permission
  changes without separate order
- templates that omit agent, skill, recipe, tool, validator, evidence or
  stop_condition fields

## Validator

Primary: `.agents\codex\tools\local_validate_github_automation_preflight.ps1`.
Companion: `.agents\codex\tools\local_validate_operational_chain.ps1`.

## Workflow

1. Confirm repo id, owner agent and GitHub base policy.
2. Use existing `.github` templates before adding another workflow.
3. Require `contents: read` for validation workflows unless a specific order
   states otherwise.
4. Include operational chain fields in templates: agent, skill, recipe, tool,
   validator, evidence and stop_condition.
5. Run the GitHub automation preflight and operational chain validators.

## Allowed By Default

- local validation commands
- PR and issue templates
- Copilot instructions
- draft PR checks with no secrets

## Stop Conditions

- workflow asks for secrets, write permissions, deployment, production,
  Microsoft live, OpenAI API live, force push, merge or permission changes
  without separate governed order
- workflow omits validator evidence
