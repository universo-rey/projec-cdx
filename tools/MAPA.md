# Mapa de Tools

Vista unica de las herramientas locales de `PROJEC CDX`.

La consolidacion operativa mas reciente queda absorbida en [CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md](C:/CEO/project-cdx/operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md).

## Incluye

- [RESOLUCION_TOOLS_20260615.md](C:/CEO/project-cdx/tools/RESOLUCION_TOOLS_20260615.md)
- `build_codex_root_inventory.py`
- `build_skills_unified_table.ps1`
- `build_skills_workbook.py`
- `build_control_workbook.mjs`
- `build_universe_relationship_audit.py`
- `compare_sdu_environment_audits.py`
- `codex-control-total.ps1`
- `codex-cloud-bootstrap.ps1`
- `codex-cloud-maintenance.ps1`
- `codex-cloud-live.ps1`
- `normalize_codex_surfaces.ps1`
- `rehome_codex_root_safe.ps1`
- `test_codex_powershell_layout.ps1`
- `validate_proj_cdx_operational_chain.ps1`
- `validate_proj_cdx_workbench.ps1`
- `validate_proj_cdx_sync.ps1`
- `validate_sdu_dataverse_metadata_wave.ps1`

## Uso

- `build_codex_root_inventory.py` para regenerar el inventario estructural de `.codex`.
- `compare_sdu_environment_audits.py` para comparar dos snapshots de auditoria SDU.
- `codex-control-total.ps1` para una pasada rapida de estado.
- `codex-control-total.ps1 -ScanCodexRoot` para un conteo vivo de carpetas, archivos y versiones en `.codex`.
- `codex-control-total.ps1 -ScanGitHubRoot` para un barrido completo de `C:\Users\enzo1\Documents\GitHub`.
- `validate_proj_cdx_workbench.ps1` para validar mapas, archivos requeridos, links, workbooks y formulas.
- `validate_proj_cdx_sync.ps1` para comprobar fuentes vivas, outputs, hitos y Dataverse local.
- `validate_sdu_dataverse_metadata_wave.ps1` para validar hito, matriz metadata_only y saneamiento Planner de la wave SDU Dataverse.
- `validate_proj_cdx_operational_chain.ps1` para validar schema, estados y fronteras del indice puente.
- `codex-cloud-bootstrap.ps1` para declarar el contrato y el registro local de Codex Cloud.
- `codex-cloud-maintenance.ps1` para refrescar la bitacora y verificar la superficie metadata-only.
- `codex-cloud-live.ps1` para abrir el carril vivo en un solo paso.
- Los demas scripts para inventario, normalizacion o validacion puntual.

## Regla

- Mantener esta carpeta como caja de herramientas, no como salida final.

Arranque vivo unico:

```powershell
pwsh -NoProfile -File "./tools/codex-cloud-live.ps1"
```
