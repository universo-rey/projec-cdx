# Mapa De Tools

Vista unica de las herramientas locales de `PROJEC CDX`.

La consolidacion operativa mas reciente queda absorbida en [CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md).

## Incluye

- [RESOLUCION_TOOLS_20260615.md](C:/Users/enzo1/PROJEC%20CDX/tools/RESOLUCION_TOOLS_20260615.md)
- `build_codex_root_inventory.py`
- `build_skills_unified_table.ps1`
- `build_skills_workbook.py`
- `build_control_workbook.mjs`
- `build_universe_relationship_audit.py`
- `codex-control-total.ps1`
- `normalize_codex_surfaces.ps1`
- `rehome_codex_root_safe.ps1`
- `test_codex_powershell_layout.ps1`
- `validate_proj_cdx_operational_chain.ps1`
- `validate_proj_cdx_workbench.ps1`
- `validate_proj_cdx_sync.ps1`

## Uso

- `build_codex_root_inventory.py` para regenerar el inventario estructural de `.codex`.
- `codex-control-total.ps1` para una pasada rapida de estado.
- `codex-control-total.ps1 -ScanCodexRoot` para un conteo vivo de carpetas, archivos y versiones en `.codex`.
- `codex-control-total.ps1 -ScanGitHubRoot` para un barrido completo de `C:\Users\enzo1\Documents\GitHub`.
- `validate_proj_cdx_workbench.ps1` para validar mapas, archivos requeridos, links, workbooks y formulas.
- `validate_proj_cdx_sync.ps1` para comprobar fuentes vivas, outputs, hitos y Dataverse local.
- `validate_proj_cdx_operational_chain.ps1` para validar schema, estados y fronteras del indice puente.
- Los demas scripts para inventario, normalizacion o validacion puntual.

## Regla

- Mantener esta carpeta como caja de herramientas, no como salida final.
