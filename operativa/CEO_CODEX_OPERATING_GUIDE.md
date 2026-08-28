# CEO Codex Operating Guide

## Runtime Model

The CEO local desktop runtime is the authoritative write/execute surface for
this repository. The active project and repository are `C:/CEO/project-cdx`.

Codex Cloud may be connected, but remains read-observe only:

- cloud mutation is disabled;
- cloud repo and worktree paths are repo-relative (`.`);
- Windows absolute paths are local evidence/reference-only for Cloud;
- Cloud diffs must never be applied directly.

The active local roots are:

- suite root: `C:/CEO`
- source tree root: `C:/Users/enzo1/Documents/GitHub`
- retired source root: `C:/CEO/repos`
- project root: `C:/CEO/project-cdx`
- metadata root: `C:/CEO/.metadata`
- worktree root: `C:/CEO/worktrees`

The `Admin-CEO` Windows Terminal profile should launch
`C:/CEO/Start-CEO.ps1`. The local SDU runtime root
`C:/CEO/project-cdx/.cabina/SDU_RUNTIME_ROOT` is a local runtime directory and
must not be treated as a Cloud path.

## Gates

All tasks start at Gate 0 unless the user explicitly authorizes a higher gate.

- Gate 0: read-only inspection, comparison, triage and reporting.
- Gate 1: patch approved local files only.
- Gate 2: stage approved files only.
- Gate 3: commit approved staged scope only.
- Gate 4: push branches or open PRs only by exact order.
- Gate 5: owner merge.

If an agent discovers that a task requires a higher gate than authorized, it
must stop and report the smallest safe next action.

## Agent Roles

Auditor:
Inspect current state, compare against expected state, and report aligned
values, risks, blockers and next actions. No edits.

Planner:
Prepare file-by-file patch plans, separate runtime-affecting edits from
documentation-only edits, and identify validation steps. No edits.

Patch executor:
Modify only approved files. Print branch and status before editing. Show diffs
after editing. Do not stage or commit unless explicitly authorized.

Staged reviewer:
Review only staged changes. Confirm expected files, generated artifacts
excluded, and validation status. Do not stage, unstage or commit.

Commit executor:
Stage and commit only approved scope. Preserve unrelated dirty files. Do not
push unless separately ordered.

PR executor:
Open or update PRs only when ordered. Confirm pushed branch, base branch,
changed files and PR body. Do not merge.

Merge auditor:
Check PR state, checks, reviews, unresolved conversations, branch protection and
exact owner action required. Read-only unless explicitly delegated.

Cloud backlog auditor:
Use `codex cloud list`, `codex cloud status` and `codex cloud diff` only. Do
not execute tasks or apply diffs.

MCP/tooling diagnostician:
Inspect `codex doctor`, `codex mcp get`, effective config, PATH and concrete
tool paths. Recommend the smallest safe fix.

## Standard Workflow

1. Confirm branch, repo root and `git status --short`.
2. Confirm current gate and authorized scope.
3. Read relevant files/configs before planning.
4. Produce a concise plan if the work is non-trivial.
5. Patch only approved files.
6. Print diffs.
7. Run only approved narrow validation.
8. Stage only approved files.
9. Review staged diff.
10. Commit with a scoped message.
11. Push only by explicit order.
12. Open PR only by explicit order.
13. Monitor CI/reviews read-only.
14. Owner merges after gates are satisfied.

## Cloud Backlog Handling

Codex Cloud remains read-observe only. Allowed Cloud commands are observation
commands such as list, status and diff. `codex cloud apply` is forbidden unless
the owner explicitly changes the operating model in a separate order.

Cloud output may be used as decision input, but any useful change must be
manually recreated locally under CEO governance. Before any manual port:

- compare against current `main`;
- identify whether the Cloud diff is stale, duplicated or superseded;
- exclude generated/evidence files unless approved;
- use a local branch and PR flow.

## GitHub And PR Policy

Main is protected. Durable changes must go through branch and PR unless the
owner gives a separate exact order.

Before branch, commit, push or PR actions, inspect:

- current branch;
- `git status --short`;
- expected changed files;
- upstream/remote state when relevant.

Do not force push, merge, close PRs, approve PRs, resolve review threads or
rerun workflows unless explicitly ordered. GitHub Actions may execute CI, but
promotion remains manual, owner-gated and separate from Codex Cloud.

## Generated And Deferred Artifacts

Classify before staging:

- generated test/coverage artifacts;
- logs and caches;
- evidence/readback files;
- JSONL runtime evidence;
- NOC monitor output;
- experimental frontends;
- deferred local work.

Default action is to defer or ignore. Include only when the owner explicitly
approves the file list and commit purpose.

## Codex Doctor And MCP Diagnostics

Use Codex Doctor as the runtime health check. A healthy local runtime should
have deterministic resolution for:

- Codex CLI;
- `agent-skills` MCP;
- Node;
- ripgrep;
- GitHub CLI;
- Git;
- PowerShell;
- Python.

If Doctor reports tool resolution issues, inspect user config, project config,
MCP config, PATH and concrete executable paths. Prefer narrow, reversible fixes.

## Daily Checklist

- Am I in `C:/CEO/project-cdx`?
- Is the current branch expected?
- Is `git status --short` clean or understood?
- What gate is authorized?
- Is Codex Cloud still read-observe only?
- Are Windows paths being treated as local evidence for Cloud?
- Are generated/evidence files excluded unless approved?
- Are Doctor/MCP warnings understood before declaring runtime healthy?
- Is PR merge readiness owner-gated?

## Stop Rules

Stop and report before doing any of the following unless the user gives an exact
order:

- applying Codex Cloud diffs;
- executing Cloud tasks;
- destructive Git operations;
- force push;
- dependency install;
- build/test/deploy/migration/formatter runs outside approved scope;
- external service mutation;
- cleanup/delete/clean;
- `--admin` behavior;
- touching deferred stash contents;
- editing C:/CEO runtime files;
- editing user Codex config;
- modifying NOC monitors or watchdogs.
