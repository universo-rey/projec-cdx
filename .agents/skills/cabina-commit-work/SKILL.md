---
name: cabina-commit-work
description: Use when durable repo work in cabina-universal-d or registered repos must move through GitHub branch, explicit staging, commit, push, draft PR, checks, and readback under cabina governance.
---

# Cabina Commit Work

## Core Rule

Every durable change must be small, intentional and reviewable in GitHub. Do
not use `git add .` in the root wrapper repo.

## Trigger Boundary

Use this skill when a local change is meant to become durable through GitHub.
It applies to the root wrapper repo and registered repos, while preserving each
nested repo's own `.git`, remote, branch and PR.

## Allowed Actions

- inspect repo, branch, remote and worktree scope
- create or use a scoped `codex/*` branch
- stage explicit files only
- commit, push, open or update a draft PR under an approved GitHub lifecycle
- merge with fixed HEAD only when the lifecycle or merge has approval and
  checks are green
- record validator and PR evidence

## Blocked Actions

- `git add .` in the root wrapper repo
- staging unrelated files
- merge without approval and precheck, force push, remote branch deletion or
  permission changes without separate order
- production, Microsoft live, OpenAI API live, secrets or regulated data
  without separate governed order

## Validator

Primary: `.agents\codex\tools\local_validate_operational_chain.ps1`.
Companion: `.agents\codex\tools\local_validate_agent_layer.ps1`.

## Workflow

1. Confirm current repo, branch, remote and clean or classified worktree.
2. Start from the base branch required by the repo policy, normally `main`.
3. Create a `codex/*` branch for new work.
4. Stage only explicit files in scope.
5. Run local validators before commit and again before final closeout when the
   commit changes governance, agents, skills, recipes, tools or workflows.
6. Commit with a narrow message.
7. Push the branch and open a draft PR.
8. Merge only when the operator-approved lifecycle includes merge, the PR is
   non-draft, targets `main`, uses `codex/*`, has green checks and the HEAD
   matches the validated commit.

## Required Evidence

- branch name
- explicit staged file list
- commit id
- push target
- PR URL
- merge commit when merge is performed
- validator result

## Stop Conditions

- unclassified dirty worktree
- unrelated file in stage
- missing validator
- merge without approved precheck, force push, permission, production,
  Microsoft live, OpenAI API live, secret or regulated-data request without
  separate order
