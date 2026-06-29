---
name: cabina-github-plugin-adapter
description: Use when GitHub plugin or gh CLI work in D:\ needs issue, PR, branch, commit, push, check, or merge handling under Cabina governance.
---

# Cabina GitHub Plugin Adapter

## Core Rule

GitHub is enabled repo-scoped, but every write needs the D cabina lifecycle:
target repo, branch, explicit files, rollback, postcheck, evidence, validator,
and stop condition. Read-only triage can proceed with bounded scope.

## Trigger Boundary

Use when work mentions GitHub issues, PRs, branches, commits, pushes, checks,
merge, `gh`, or the GitHub plugin.

## Allowed Actions

- read issues, PRs, checks, branches, remotes, and PR metadata
- prepare GitHub order packets and draft PR plans
- use `gh` read-only when plugin context is insufficient
- execute branch, commit, push, PR, or merge only when the governed lifecycle
  is approved

## Blocked Actions

- force push
- permission changes
- secrets
- Microsoft live
- OpenAI API live
- production
- merge without approved precheck

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools`,
`C:\CEO\project-cdx\.agents\codex\tools\local_validate_operational_chain.ps1`, and
`C:\CEO\project-cdx\.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Repo, branch, PR or issue URL, check status, fixed HEAD when merging,
validator output, rollback, and readback.

## Stop Conditions

- `github_order_missing_checks`
- `merge_without_approved_precheck`
- `automated_merge_precheck_failed`
- `secret_detected`


