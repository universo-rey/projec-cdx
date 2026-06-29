# Codex Cloud Backlog Triage — 2026-06-29

## Policy

Codex Cloud remains read-observe only. No Cloud diff may be applied directly. Any useful Cloud output must be manually ported locally under CEO governance.

## Summary

Observed 39 Cloud tasks through authenticated `codex cloud list --json` across two pages.

- 37 ready
- 2 error
- 12 ready tasks had non-zero diffs
- no Cloud diff was applied
- no Cloud task was executed

## Decisions

### Do Not Use

- `task_e_6a0e9294dac4832ebf4154da8af4605d` — broad stale SharePoint audit package with generated/evidence/code/cross-domain materials.
- `task_e_69eae34c2618832eab1b625e673688c9` — stale Cloud operating-contract/test package superseded by PR #33.

### Ignore / Superseded

- `task_e_69e7db9762c8832e8f532eece1c4904a` — duplicate/superseded catalog gap edit.
- `task_e_69e7d6390f44832e9c87ba8e379e544b` — duplicate of VALUE_SETS legacy status edit.

### Manual Local Review Candidates

- `task_e_69e7eacfa344832ea05efaa964f57486` — TABLE_COVERAGE_V4 closure note.
- `task_e_69e7d36e3ae8832ebfb225f4a68406cc` — VALUE_SETS vs OPTION_SETS diagnostic.
- `task_e_69e7c506f344832e9204df60dcc99fbd` — GAP_TO_ACTION issue link enrichment.
- `task_e_69e7b9384718832e9e9c40d4dab06ada` — GAP_TO_ACTION diagnostic.

### Owner Decision Required

- `task_e_69e7e29d1414832e83e130d9802c0b98` — possible `OBJ_Bienes` addition to LISTS_CATALOG.
- `task_e_69e7dcfeaef4832eb6a73ccbd8e8f5e0` — governance gap closure for VALUE_SETS/OPTION_SETS.
- `task_e_69e7d9f785c8832ebe63bd27a915bbb7` — VALUE_SETS status transition to legacy.
- `task_e_69e7cfb38264832e8f18d707407102dd` — PR #16 / issue #5 closure status.

## Next Actions

- Do not use `codex cloud apply`.
- Do not apply Cloud diffs directly.
- If any candidate remains useful, create a local governed manual-port branch.
- Compare each candidate against current `main`.
- Port only narrow, still-valid documentation manually.
