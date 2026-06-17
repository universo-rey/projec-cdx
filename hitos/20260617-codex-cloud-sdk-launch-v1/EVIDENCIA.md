# Evidencia Codex Cloud SDK Launch

## Comandos

- `python -m projec_cdx_cloud --smoke --json`
- `python -m projec_cdx_cloud --cloud-bridge --json`
- `python -m projec_cdx_cloud --cloud-bridge --write-readback --json`
- `python -m projec_cdx_cloud --agentic-cloud-bridge --prompt "<prompt gobernado>" --json`

## Observaciones

- `smoke`: `status=prepared`, `context_ok=True`, `context_drift=[]`.
- `cloud_bridge`: `PASS`.
- `remote_head`: `93dd19aa503ac7135552a8f28be2ef80b5e29f6d`.
- `agents_sdk_version`: `0.17.0`.
- `sdu_sdk_agents_defined`: `6`.
- `agentic_cloud_bridge`: `status=ok`, `final_output=OBSERVED`.
- `inspect_cloud_bridge`: `PASS`.

## Sistemas No Tocados

- Codex Cloud task create API.
- Microsoft write.
- SharePoint write.
- Dataverse write.
- Power Automate run.
- Secret output.
