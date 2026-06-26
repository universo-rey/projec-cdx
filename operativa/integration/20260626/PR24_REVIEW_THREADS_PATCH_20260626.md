# PR24 review threads patch - 2026-06-26

## Estado

- PR: #24
- Head inicial: `codex/integration-g10-snapshot-20260626` @ `46ca76cb00029718e64bfc3b8f3d55cad4e26bb9`
- Base: `main` @ `56a4eda1dd36c545c12546bb37fc2046dbb7fb05`
- Rama viva preservada: `codex/live-state-g10-governed-20260626` @ `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- Modo: parche sobre arbol temporal, commit por `GIT_INDEX_FILE` + `commit-tree`
- Merge: no ejecutado
- Live/G11/Graph/SharePoint/Dataverse/Power Platform: no tocados

## Threads atendidos

| Thread | Archivo | Resolucion |
| --- | --- | --- |
| P1 sentinel dirty workspace | `.github/workflows/codex-governed.yml` | El comando `runtime sentinel` ahora escribe con `--output` en el directorio de reportes, evitando el archivo por defecto en `operativa/sentinel/`. |
| P2 meta legacy index | `.github/workflows/meta-validate.yml` | La validacion de metadata pasa a verificar `operativa/index.json` junto con `index.json`. |
| P2 promote legacy index | `.github/workflows/promote.yml` | La lista de paths versionables usa `operativa/index.json` en lugar del path legacy archivado. |
| P2 duplicate snapshot id | `src/runtime_versioning/cli.py`, `tests/test_ceo_runtime.py` | `save_snapshot` sincroniza `snapshot_id` con el path final desambiguado y recalcula `global_hash`; se agrega prueba de dos snapshots en el mismo minuto. |

## Validadores locales

- `python -m tools.build_index` ejecutado dos veces: PASS, idempotente
- `python -m tools.validate`: PASS
- `python -m py_compile src\runtime_versioning\cli.py`: PASS
- `python -m pytest tests\test_ceo_runtime.py -q --basetemp <external-temp>`: PASS, `11 passed`
- `tools\validate_proj_cdx_sync.ps1 -Root <patch> -Json`: PASS
- `tools\validate_proj_cdx_workbench.ps1 -Root <patch> -Json`: OBSERVED, sin FAIL; observaciones historicas/no versionadas
- `tools\validate_proj_cdx_operational_chain.ps1 -Root <patch> -ResolverPy <patch>\tools\sdu_chain_resolver.py -Json`: PASS
- `tools\sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json`: PASS
- `tools\validate_sdu_dataverse_metadata_wave.ps1 -Root <patch>`: PASS
- Scan sensible de los 7 archivos candidatos: PASS, 0 hits de contenido, 0 hits de path

## Retry remoto

- Primer push: `eaed9c0f6a322de0207e1639b5210a85d106b028`.
- Resultado remoto parcial: `build-graph`, `quality` y `meta-validate` PASS; `codeql` en progreso; `codex-governed` FAIL en `Runtime sentinel`.
- Causa: `build_sentinel_report` intentaba convertir un output externo a ruta relativa del repo.
- Reparacion minima: `report["path"]` usa fallback para rutas externas y se cubre con test.

## Pendientes

- Checks remotos de PR #24 pendientes hasta publicar el nuevo commit en `codex/integration-g10-snapshot-20260626`.
- No resolver threads, aprobar ni mergear en esta orden.

## Rollback

- Volver `refs/heads/codex/integration-g10-snapshot-20260626` a `46ca76cb00029718e64bfc3b8f3d55cad4e26bb9`.
- La rama viva no requiere rollback: no fue modificada.
