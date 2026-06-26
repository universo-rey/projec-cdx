# Heavy Branches Audit Notes

## Duplicate Alias Group

These branches point to the same tip and must be reviewed once:

- `backup/main-ahead-34-20260620-040104`
- `codex/windows-boot-origin-normalization-v1`
- `control-plane/verde-gobernado-20260620`

Decision: `DUPLICATE_ALIAS_HOLD`.

No delete, rename, move, merge, reset or branch cleanup is authorized by this plan.

## Heavy Branch Rule

Every `AUDIT_ONLY` branch requires a future owner decision with:

- target branch,
- expected files,
- rollback,
- postcheck,
- evidence file,
- validator,
- explicit stop condition.

## Branch Notes

- `codex/multirepo-alignment-16`: very large release and multirepo alignment history; do not merge directly.
- `codex/dataverse-corte-ejecutora-v1`: Dataverse-heavy history; keep metadata-only unless owner opens a live gate.
- `codex/cabina-canon-agents-runtime-audit`: runtime audit branch; review as historical control evidence.
- `feature/docs-refactor`: documentation restructure; review as canon-documental candidate only.
- `copilot/featureschema-validation`: diverged upstream; requires separate remote/current-state decision before action.
- `codex/mesa-archivo-20260620`: archive/control history; keep as audit source.
- `codex/cloud-setup-ui-v1`: cloud UI setup; do not activate Codex Cloud or OpenAI API from this review.
- `codex/wave-mapas-uniformes-v1`: map wave historical; extract navigational ideas only.
- `codex/revisar-procesos-del-equipo`: Dataverse startup cache evidence; no live Dataverse action.

## Stop Conditions

- Any direct merge proposal.
- Any branch deletion, rename or cleanup.
- Any checkout into the dirty worktree.
- Any fetch, pull, push, PR or workflow dispatch.
- Any Microsoft, Dataverse, SharePoint, Power Platform, OpenAI API or Codex Cloud action without a literal gate.
