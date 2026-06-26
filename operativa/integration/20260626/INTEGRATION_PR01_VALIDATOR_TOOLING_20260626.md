# INTEGRATION_PR01_VALIDATOR_TOOLING_20260626

schema_version: 1.0
mode: OWNER_GATE_INTEGRATE_PR01_VALIDATOR_TOOLING_NO_PR
confirmed_by_owner: INTEGRATE_PR01_VALIDATOR_TOOLING_CONFIRMED
generated_at_utc: 2026-06-26T12:31:52.8874423Z
root: C:/Users/enzo1/PROJEC CDX
live_branch: codex/live-state-g10-governed-20260626
live_head: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
integration_branch: codex/integration-g10-snapshot-20260626
integration_old_head: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
source_branch: codex/version-validator-tooling-20260626
source_head: 8af84c815285253376662b22733c540d2dfa708d
base_commit: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11

## Applied Delta
- M	tools/validate_proj_cdx_sync.ps1
- M	tools/validate_proj_cdx_workbench.ps1

## Guardrails
- No checkout, switch, fetch, pull, merge, rebase, reset, clean or restore.
- No PR, no tag, no live apply and no G11 apply.
- Source blobs applied through GIT_INDEX_FILE and git update-index --cacheinfo.
- update-ref target only: refs/heads/codex/integration-g10-snapshot-20260626
- push target only: refs/heads/codex/integration-g10-snapshot-20260626
- integration_new_commit is emitted by the gate after commit-tree.
