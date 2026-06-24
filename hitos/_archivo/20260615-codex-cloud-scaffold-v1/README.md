# Hito 20260615 - Codex Cloud Scaffold Y UI v1

Versiona el scaffold completo de Codex Cloud para `PROJEC CDX`: entorno seleccionable en la UI, scripts de setup y cleanup, contrato local, runner Python y carril metadata-only gobernado.

## Alcance

- `.codex/environments/environment.toml`
- `.codex/config.toml`
- `tools/codex-environment-setup.ps1`
- `tools/codex-environment-cleanup.ps1`
- `tools/codex-cloud-bootstrap.ps1`
- `tools/codex-cloud-maintenance.ps1`
- `tools/codex-cloud-live.ps1`
- `pyproject.toml`
- `main.py`
- `src/projec_cdx_cloud/cli.py`
- `src/projec_cdx_cloud/agent.py`
- `src/projec_cdx_cloud/__main__.py`
- `operativa/archive/legacy-root/20260615/CODEX_CLOUD_CONTRACT_20260615.md`
- `operativa/archive/legacy-root/undated/SETUP_APERTURA_CODEX_UI.md`
- `recipes/configuracion-entorno-codex-ui.md`
- `operativa/archive/root-loose/20260618/README_ARRANQUE_CODEX_CLOUD.md`

## Evidencia

- [MANIFEST.yaml](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-codex-cloud-scaffold-v1/MANIFEST.yaml)
- [REGISTRO_HITOS.md](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-codex-cloud-scaffold-v1/REGISTRO_HITOS.md)
- [INDICE.csv](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-codex-cloud-scaffold-v1/INDICE.csv)
- [EVIDENCIA.md](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-codex-cloud-scaffold-v1/EVIDENCIA.md)
- [READBACK.md](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-codex-cloud-scaffold-v1/READBACK.md)

## Estado

`GREEN_LOCAL`: la UI ya expone el entorno, el runner parsea el scaffold y el humo local pasa sin live write.
