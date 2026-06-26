---
name: parallel-agentic-repo-audit
description: Use when a repo-wide or multi-file audit must optimize AGENTS.md, skills, workflows, conventions, risks, or validation through a parallel audit chain, fan-in evidence, and no-live local governance.
---

# Parallel Agentic Repo Audit

## Core Rule

Start broad audits with independent read-only lanes, then integrate findings
before editing shared files. Do not let one slow search block structure,
history, workflow, standards, risk or validation evidence.

## Trigger Boundary

Use for repo-wide or multi-file audits of `AGENTS.md`, skills, workflows,
tools, connectors, validators, conventions, risk posture and repeated repo
procedures. Do not use for Microsoft live, OpenAI API live, production,
secrets, tenant writes or destructive cleanup.

## Allowed Actions

- Split read-only evidence into independent lanes before deep investigation.
- Simulate the named chain when real subagents are not available.
- Compare findings against `AGENTS.md`, `MANIFEST.yaml`, matrices, readbacks,
  workflows and validators.
- Propose short `AGENTS.md` rules and separate skills for repeatable workflows.
- Use `.agents\codex\recipes\recipe.parallel_tooling_validation_chain.md` when
  the audit must choose tools, commands, validators or rollback.
- Prefer specialized connectors, repo scripts and specific CLIs before shell or
  PowerShell, and mark unavailable connectors as `NO_DISPONIBLE`.
- Fan-in findings before editing shared files or matrices.

## Blocked Actions

- Writing files before presenting findings, opportunities, chain, proposed
  changes, target files and evidence.
- Inventing history, commands, agents, validators, checks or prior results.
- Running live Microsoft, OpenAI, Power Platform, Dataverse, SharePoint,
  production, permission, cost or secret operations.
- Editing shared matrices from multiple lanes without a serial integration
  owner.

## Chain

Use this order and require one concrete finding, evidence item and
recommendation per lane:

1. Repo Mapper: map root, branch, remotes, folders, files and duplicate
   capability candidates.
2. Execution Historian: review git log, PRs, readbacks and available sanitized
   history.
3. Workflow Extractor: extract repeatable commands, workflows and success
   criteria.
4. Standards Auditor: compare against `AGENTS.md`, `MANIFEST.yaml`, matrices and
   validators.
5. Instruction Architect: propose minimal instruction and skill deltas.
6. Validation Planner: choose validators, checks, rollback and PR/update path.

## Commands

Prefer these read-only commands first:

```powershell
git status -sb
git rev-parse --show-toplevel
git branch --show-current
git rev-parse --short HEAD
git remote -v
gh pr list --state open --json number,title,headRefName,baseRefName,isDraft,mergeStateStatus,url
rg --files -g 'AGENTS.md' -g 'SKILL.md' -g '*.ps1' -g '*.yml' -g '*.yaml' -g '*.json' -g '*.csv'
git log --oneline --decorate -n 30
```

## Validator

Run:

- `.agents\codex\tools\local_validate_parallel_order_governance.ps1`
- `.agents\codex\tools\local_validate_skill_metadata.ps1`
- `.agents\codex\tools\local_validate_agents_instruction_hierarchy.ps1`
- `.agents\codex\tools\local_validate_operational_chain.ps1`
- `git diff --check`

## Evidence

Record the six lane findings, commands run, files inspected, proposed edits,
validators selected, branch/PR posture, skipped live surfaces and rollback.

## Stop Conditions

- `parallel_lane_without_validator`
- `lane_scope_overlap`
- `skill_metadata_missing_or_ambiguous`
- `capability_use_preflight_missing`
- `secret_detected`
