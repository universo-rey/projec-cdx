# NOISE REDUCTION PLAN

Command: CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1
Generated: 2026-06-26T07:07:32Z
Scope: C:\CEO\project-cdx
Mode: LOCAL_FIRST / GOVERNED / DRY-RUN ONLY

## Safe ignore patterns

These are proposal-only candidates. Nothing was applied in G1.

- .ruff_cache/
- .venv_clean/
- .venv_test/
- .codex_tmp/
- tmp-owner-action-layer/
- out/

## Gate candidates

- Cache/temp quarantine candidates: __pycache__/, .ruff_cache/, .codex_tmp/, out/, graphify-out/.
- Legacy-readonly candidates: operativa/archive/root-dirs/, operativa/archive/root-loose/, .bmad-backup/, workbooks/_backups/.
- Duplicate skill bridge: .agents/skills/agileagentcanvas-help/SKILL.md and .cursor/skills/agileagentcanvas-help/SKILL.md.
- Runtime/sensitive blocked surfaces: .env.local, .cabina/, node_modules/, reparse points, outputs/ceo-suite-test temp repos.

## Repository boundary policy

- Root is a junction to the physical project path and must not be reanchored.
- .cabina is a runtime nested repo boundary and must not be absorbed.
- outputs/ceo-suite-test contains generated temp repos and must not be absorbed.
- node_modules is a dependency junction and was not traversed.

## Decision

No cleanup was applied. The next pass may only apply an owner-gated target list with rollback, postcheck, and evidence.