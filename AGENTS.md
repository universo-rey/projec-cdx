# AGENTS.md

## Workspace Topology

This is a local-first hybrid Codex workspace.

The user works across multiple repositories, Microsoft desktop tooling, Visual
Studio Insiders, VS Code Insiders, and GitHub-hosted source control.

## Workspace Roots

- Suite root: `C:/CEO`
- Source tree root: `C:/Users/enzo1/Documents/GitHub`
- Retired source root: `C:/CEO/repos` (does not currently exist; do not assume it exists)
- Active project: `C:/CEO/project-cdx`
- Active repository: `C:/CEO/project-cdx`
- Metadata root: `C:/CEO/.metadata`
- Worktree root: `C:/CEO/worktrees`
- Workspace profile: `ceo-project-cdx`

`project-cdx` is the active project, not the entire operating universe.

## Execution Authority

- Local desktop runtime is the authoritative write/execute environment.
- Codex Cloud may connect only for read-observe workflows.
- Treat `CODEX_CLOUD_GATE=read-observe` as a hard operational boundary.
- Codex Cloud must not write files, install dependencies, run migrations, push
  branches, open pull requests, deploy, or mutate repository, GitHub,
  Microsoft, Dataverse, SharePoint, Teams, Planner, OneDrive, OpenAI, or other
  external service state.
- GitHub Actions are separate from Codex Cloud: CI may execute in workflows;
  promotion remains manual, owner-gated, and evidence-backed.

Windows absolute paths such as `C:/CEO`, `C:/Users/...`, PowerShell profiles,
local tool caches, PAC CLI, NOC files, watchdog files, and localhost endpoints
are local evidence references only for Codex Cloud. Cloud must use repo-relative
paths only and must not depend on any local Windows path existing.

## Cloud Restrictions

When operating in cloud mode, do not:

- write files;
- delete files;
- install dependencies;
- run migrations;
- push branches;
- open pull requests;
- deploy;
- mutate repository state.

Cloud mode may only inspect, summarize, compare and report.

## Multi-Repository Behavior

Before making changes, identify the active repository and confirm its root.

Do not assume `C:/CEO/project-cdx` is the only repository in the workspace. Do
not assume `C:/CEO/repos` exists.

When a task may span repositories, first map the relevant repository boundaries
and report which repository each proposed change belongs to.

Do not absorb nested repos into `project-cdx`. Each repository keeps its own
branch, validation, evidence and promotion path.

## GitHub Behavior

Use GitHub as the source-control authority.

Before branch, commit, pull request or remote operations:

- inspect current branch;
- inspect remote;
- inspect working tree status;
- avoid force-pushes unless explicitly authorized.

Do not merge individual dependency PRs when the operator requested a batch.
Do not skip CI or promote a batch that did not pass.

## Microsoft Tooling

This workspace may use Microsoft 365, OneDrive, Visual Studio Insiders, VS Code
Insiders, PowerShell, Windows tooling and GitHub.

Do not assume Linux-style paths.

Prefer PowerShell-compatible commands unless the user explicitly requests
another shell.

SharePoint, Dataverse, Teams, Planner, OneDrive and Power Platform require a
governed order for writes. Read-only observation still requires exact target
identity when it affects evidence or decisions.

## Visual Studio Insiders

When working on .NET, C#, Visual Studio, MSBuild, Windows-native projects or
enterprise Microsoft tooling, consider Visual Studio Insiders and related
toolchains part of the local development environment.

Do not assume VS Code is the only editor or IDE.

Current path status:

- VS Code Insiders command: confirmed.
- Visual Studio Insiders root: candidate only, not confirmed on this machine.

## SDU Runtime

The SDU runtime is live and suite-aware:

- `execution_mode = LIVE`
- `runtime_mode = OPERATIONAL`
- `noc_mode = REALTIME`
- `workspace_mode = suite`
- `execution_surface = hybrid`
- watchdog: suite-aware
- NOC: still points to `C:/CEO/project-cdx`

Authoritative NOC paths remain:

- `C:/CEO/project-cdx/noc/noc-state.json`
- `C:/CEO/project-cdx/noc/operacion-en-vivo.json`
- `http://localhost:8081`

## Guardrails

- Do not modify `C:/Users/enzo1/.codex/config.toml` from suite profile work.
- Do not move existing files.
- Do not rebuild runtime.
- Do not touch `noc-state.json`, `operacion-en-vivo.json`, `risk-policy` or
  watchdog unless a separate exact order authorizes it.
- Do not execute live writes outside an approved promotion.
- Close with evidence, validator and postcheck.

## CEO Codex Operating Gates

All work starts at Gate 0 unless the user explicitly authorizes a higher gate.

- Gate 0: read-only inspection, comparison, triage and reporting.
- Gate 1: patch only approved local files.
- Gate 2: stage only approved files.
- Gate 3: commit only approved staged scope.
- Gate 4: push branches or open pull requests only by exact order.
- Gate 5: merge remains owner-gated unless explicitly delegated.

Do not skip gates. If scope changes, stop and report the new required gate.

## Agent Roles

- Auditor: inspect current facts and produce risks, blockers and next actions.
- Planner: prepare file-by-file plans without editing.
- Patch executor: edit only approved files and print the resulting diff.
- Staged reviewer: review only staged changes and approve or block.
- Commit executor: stage/commit only approved scope.
- PR executor: create or update PRs only when ordered.
- Merge auditor: check checks, reviews, threads, protection and owner action.
- Cloud backlog auditor: use Codex Cloud only for list/status/diff observation.
- MCP/tooling diagnostician: inspect Doctor, MCP, PATH and tool resolution.

## Artifact Handling

Classify generated artifacts, readbacks, evidence JSONL, coverage, logs, NOC
monitor output, experimental frontends and local runtime files before staging.
Default action is defer or ignore unless the user explicitly approves inclusion.

Do not stage generated evidence, reports, caches, logs or deferred experiments
as part of runtime, source or documentation commits without exact approval.

## Codex Cloud Read-Observe Rules

Codex Cloud is read-observe only. Agents may use Cloud list/status/diff for
triage, but must not use `codex cloud apply`, execute Cloud tasks, open PRs from
Cloud output, or mutate any local, remote or external state.

Cloud diffs are source material only. If useful, they must be manually ported
locally under CEO governance after comparison against current `main`.

## PR Review And Merge Discipline

Before PR work, confirm branch, status, remote and changed files. PRs should
state the runtime boundary and validation performed. Do not resolve review
threads, approve, close or merge unless explicitly ordered.

Merge readiness requires clean CI, no blocking reviews, no unresolved required
threads, correct head/base branches and owner approval.

## MCP And Doctor Diagnostics

For Codex tooling issues, inspect `codex doctor`, `codex mcp get`, effective
config, PATH and concrete tool paths. `agent-skills`, Node, ripgrep, GitHub CLI,
Git, PowerShell and Python must resolve deterministically and Doctor should pass
before declaring the runtime healthy.
