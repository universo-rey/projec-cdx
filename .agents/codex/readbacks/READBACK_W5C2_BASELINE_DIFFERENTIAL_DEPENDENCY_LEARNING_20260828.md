# READBACK W5C2 baseline differential dependency learning

## CONFIRMED

- Source frontier: W5C dependency remediation split into independently validated dependency-only PRs.
- Reusable pattern: compare the same contract on immutable base and head before attributing a failure to a dependency delta.
- Canonical decisions: `REGRESSION_INTRODUCED`, `BASELINE_DEBT_REPRODUCED`, `HARNESS_DEFECT`, `COMPATIBLE`, and `INSUFFICIENT_EVIDENCE`.
- Recipe and validator are local, deterministic, evidence-consuming, and READ-ONLY.
- File-byte SHA-256 is explicitly distinct from any domain `global_hash`.
- No skill was created because the learning belongs to the existing retrospective and repository-governance capabilities.
- No merge, close, rebase, autofix, lock regeneration, GitHub write, network installation, secret access, Microsoft live call, or production action is performed by the new validator.

## INFERRED

- None. A baseline failure becomes `BASELINE_DEBT_REPRODUCED` only when the normalized failure fingerprint is identical on base and head.

## PENDING

- `.agents/codex/tools/local_validate_skill_recipe_agent_learning.ps1` is indexed by the active matrices but absent from the repository tree at the W5C2 base. This is an existing generic retrospective-validator gap; W5C2 neither creates nor modifies it.
- `.agents/codex/tools/local_run_change_aware_full_coverage_orchestrator.ps1` is also absent from this repository tree, so it was recorded as not applicable rather than invented.
- The default nested `local_validate_agent_layer.ps1` route reaches an existing operational-chain check for `.github/PULL_REQUEST_TEMPLATE.md`, which is absent from the W5C2 base and outside this nine-file order. The same agent-layer validator passes with `-SkipWorkflowNestedValidators`; the operational-chain validator and skill-metadata validator pass independently.
- The differential learning PR requires independent review and separate merge authority.

## BLOCKED

- Any candidate with an unfixed repository/base/head, a diff outside its allowlist, missing paired results, a changed original PR state, missing byte hashes, or conflated `file_sha256` and `global_hash` is blocked from a compatible decision.

## Validation contract

The new validator requires a checked-out exact head plus a local JSON packet. It reads local Git objects and local files only, derives the decision, and emits parseable JSON. It records zero mutation counters and does not execute the commands named in the evidence packet.

Validation at materialization:

- `local_validate_baseline_differential_dependency.ps1 -SelfTest`: `PASS`.
- `local_validate_agent_layer.ps1 -SkipWorkflowNestedValidators`: `PASS`, `secret_hit_count=0`.
- `local_validate_operational_chain.ps1`: `PASS`.
- `local_validate_skill_metadata.ps1`: `PASS`.
- `git diff --check`: `PASS`.
- Targeted secret-safe diff scan: `SECRET_HITS=0`.

## Rollback

Revert the W5C2 learning commit. No runtime or remote operational state is created by the recipe or validator.

## Next lane

Review the learning PR. Keep the generic retrospective-validator absence as a separate, explicitly scoped repair lane rather than expanding W5C2.
