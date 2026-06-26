# BMAD Schema Normalization Mainline Rebase 20260626

## Decision

BMAD Agile Canvas normalization is re-applied on top of remote mainline without touching live.

## Base

- remote main: 441e150408c7dc4d27f25028ca27f4b9804645cf
- source BMAD branch: codex/version-agile-canvas-bmad-schema-normalization-20260626
- source BMAD commit: ba79c48f02c7e418bcd66f88e8e9728a69f22ab6
- target branch: codex/version-agile-canvas-bmad-schema-normalization-mainline-20260626

## Artifacts Applied

- .agileagentcanvas-context/sdu/artifacts/graph-layer.json
- .agileagentcanvas-context/sdu/artifacts/sdu-system.json
- .agileagentcanvas-context/sdu/artifacts/system-state.json

## Graphify

- classification: GRAPHIFY_LOCAL_GENERATED_DO_NOT_VERSION
- review note: GRAPHIFY_REVIEW_REQUIRED_NON_IDEMPOTENT
- graphify-out was not versioned.

## Boundaries

- no live
- no G11
- no tag
- no release
- no graphify-out
- no PR in this gate

## Validation Plan

- JSON parseable for all three artifacts
- architecture.schema.json PASS for all three artifacts
- diff limited to the three artifacts plus this evidence pair
- sensitive scan PASS
