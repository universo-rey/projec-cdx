# Readback Local Agent Chain Resolver 20260621

## Estado

`SDU_LOCAL_AGENT_CHAIN_RESOLVED`

## Superficie

- Repo fisico: `C:/Users/enzo1/PROJEC CDX`
- Entrada canonica: `C:/CEO/project-cdx`
- Live externo: cerrado
- `.env.local`: no leido por el resolvedor

## Cadena Viva

`agent -> skill -> recipe -> tool -> validator -> evidence -> stop_condition`

## Agentes

- `seshat-normativa`
- `thot-tecnico`
- `anubis-gate`
- `maat-cumplimiento`
- `horus-riesgo`
- `narrador-normativo`

## Artefactos Del Delta

- `tools/sdu_chain_resolver.py`
- `tools/sdu_boot.ps1`
- `tools/validate_proj_cdx_operational_chain.ps1`
- `src/projec_cdx_cloud/cli.py`
- `tools/README.md`
- `tools/MAPA.md`
- `tests/test_sdu_chain_resolver.py`

## Validaciones

- `pwsh -NoProfile -File ./tools/sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun`: PASS
- `pwsh -NoProfile -File ./tools/validate_proj_cdx_operational_chain.ps1`: PASS
- `.venv/Scripts/python.exe -m pytest -q`: PASS, 20 tests
- `.venv/Scripts/python.exe -m tools.validate`: PASS, 59 metadatos validos
- `.venv/Scripts/python.exe main.py --smoke --no-local-env --json`: PASS
- `pwsh -NoProfile -File ./tools/validate_sdu_dataverse_metadata_wave.ps1`: PASS

## Decision

La activacion local SDU queda resuelta por puerta unica segura.

## Stop Condition

No abrir GitHub, Dataverse, Microsoft, SharePoint, Codex Cloud ni OpenAI live desde esta puerta sin orden gobernada con target, owner, rollback, postcheck y evidencia.
