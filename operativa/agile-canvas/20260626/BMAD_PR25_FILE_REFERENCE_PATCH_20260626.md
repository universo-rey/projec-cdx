# BMAD PR25 File Reference Patch 20260626

## Decision
BMAD_PR25_FILE_REFERENCE_PATCH

## PR
- PR: #25
- URL: https://github.com/universo-rey/projec-cdx/pull/25
- Branch: codex/version-agile-canvas-bmad-schema-normalization-mainline-20260626
- Head before: 3da4257a7a7bd8f7e551574925c2c227b45acbbe
- Base: main @ 441e150408c7dc4d27f25028ca27f4b9804645cf

## Scope
- Touched: .agileagentcanvas-context/sdu/artifacts/sdu-system.json
- Evidence: operativa/agile-canvas/20260626/BMAD_PR25_FILE_REFERENCE_PATCH_20260626.md
- Evidence JSON: operativa/agile-canvas/20260626/BMAD_PR25_FILE_REFERENCE_PATCH_20260626.json

## Patch
- `content.references[0].location`
- Before: `../../../SYSTEM_NERVOUS_INDEX.json`
- After: `SYSTEM_NERVOUS_INDEX.json`

## Rule
All `type: "file"` references in `sdu-system.json` use repo-root-relative paths. No absolute local paths and no mixed artifact-relative `../` base.

## Targets Confirmed
- `SYSTEM_NERVOUS_INDEX.json`: exists in PR head and origin/main.
- `CEO_CONTROL_PLANE.code-workspace`: exists in PR head and origin/main.

## Validators
- JSON parse: PASS for patched `sdu-system.json`, `graph-layer.json`, `system-state.json`.
- BMAD shape: PASS for `metadata`, `content.overview`, `content.decisions`.
- File reference validation: PASS.
- `architecture.schema.json`: not found in branch; no explicit file-reference base was available there.
- `schema.json`: found, but it is repo metadata schema and does not define `content.references.location`.
- `git diff --check`: pending post-commit validation.
- Sensitive scan: pending post-commit validation.

## Thread
- Path: .agileagentcanvas-context/sdu/artifacts/sdu-system.json
- Line: 67
- Topic: `type=file` references with inconsistent base.
- Status before patch: unresolved.


## Mutation Retry Note
- Intermediate commit: e78952e896773b3d0082cbf6e4af4e659a65f76
- Cause: PowerShell split the --cacheinfo argument by comma on first attempt.
- Resolution: no history rewrite, no force push; patch applied as fast-forward child commit.
## Rollback
Set branch `codex/version-agile-canvas-bmad-schema-normalization-mainline-20260626` back to `3da4257a7a7bd8f7e551574925c2c227b45acbbe`.

## Exclusions
- No `graphify-out/**`.
- No `graph.json`, `GRAPH_REPORT.md`, `graph.html`.
- No live, no G11, no tag, no release.
