# Resolucion de Tools 20260615

## Estado

`RESUELTO`

## Criterio

- `build_codex_root_inventory.py` genera el inventario estructural de `.codex`.
- `codex-control-total.ps1` hace el control total rapido y el conteo vivo de `.codex`.
- `build_control_workbook.mjs` genera el workbook maestro de control.
- `build_skills_unified_table.ps1` y `build_skills_workbook.py` consolidan skills.
- `build_universe_relationship_audit.py` genera la auditoria de relacion entre superficies.
- `validate_proj_cdx_workbench.ps1` valida la estructura del workbench.
- `validate_proj_cdx_sync.ps1` valida sincronizacion de fuentes vivas, outputs, hitos y Dataverse.

## Que Se Toma De Cada Uno

### Inventario y conteo

- `build_codex_root_inventory.py`
- `codex-control-total.ps1`

### Control operativo

- `build_control_workbook.mjs`
- `validate_proj_cdx_workbench.ps1`
- `validate_proj_cdx_sync.ps1`

### Skills y relacion de superficies

- `build_skills_unified_table.ps1`
- `build_skills_workbook.py`
- `build_universe_relationship_audit.py`

### Soporte

- `normalize_codex_surfaces.ps1`
- `rehome_codex_root_safe.ps1`
- `test_codex_powershell_layout.ps1`

## Regla de Uso

- Si hay que contar `.codex`, manda `codex-control-total.ps1`.
- Si hay que reconstruir inventario, manda `build_codex_root_inventory.py`.
- Si hay que validar cierre, mandan los validadores.
- Si hay que regenerar tablas o workbooks, mandan los builders.
