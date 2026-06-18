# Tools

Scripts locales para generar y normalizar artefactos de este workspace.

La consolidacion operativa mas reciente queda absorbida en [CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md).

- [MAPA.md](C:/Users/enzo1/PROJEC%20CDX/tools/MAPA.md)

## Incluye

- [RESOLUCION_TOOLS_20260615.md](C:/Users/enzo1/PROJEC%20CDX/tools/RESOLUCION_TOOLS_20260615.md)
- `build_codex_root_inventory.py`
- `build_skills_unified_table.ps1`
- `build_skills_workbook.py`
- `build_control_workbook.mjs`
- `build_universe_relationship_audit.py`
- `codex-control-total.ps1`
- `codex-cloud-bootstrap.ps1`
- `codex-cloud-setup.sh`
- `codex-cloud-bootstrap.sh`
- `codex-cloud-maintenance.ps1`
- `codex-cloud-maintenance.sh`
- `codex-cloud-live.ps1`
- `normalize_codex_surfaces.ps1`
- `rehome_codex_root_safe.ps1`
- `test_codex_powershell_layout.ps1`
- `validate_proj_cdx_operational_chain.ps1`
- `validate_proj_cdx_workbench.ps1`
- `validate_proj_cdx_sync.ps1`

## Uso

- Ejecutar `build_codex_root_inventory.py` para regenerar el inventario estructural de la raiz `.codex`.
- Ejecutar `codex-control-total.ps1` para una pasada rapida de estado sobre Codex, PowerShell, `.codex`, herramientas y repos principales.
- Ejecutar `codex-control-total.ps1 -ScanCodexRoot` para contar carpetas, archivos y versiones de `.codex` con una lectura viva.
- Ejecutar `codex-control-total.ps1 -ScanGitHubRoot` para barrer toda `C:\Users\enzo1\Documents\GitHub` y clasificar tambien carpetas no Git.
- Ejecutar los otros scripts cuando haya que regenerar la tabla unificada, el workbook o la normalización de superficies.
- Ejecutar `validate_proj_cdx_workbench.ps1` antes de cerrar un delta.
- Ejecutar `validate_proj_cdx_sync.ps1` cuando el cambio toque fuentes vivas, outputs, hitos o Dataverse.
- Ejecutar `validate_proj_cdx_operational_chain.ps1` cuando cambie el indice puente repo-agente-skill-receta-tool-evidencia.
- Ejecutar `codex-cloud-bootstrap.ps1` para dejar declarado el contrato local de Codex Cloud y el registro metadata-only.
- Ejecutar `codex-cloud-setup.sh` como wrapper minimo y portable para Codex Cloud.
- Ejecutar `codex-cloud-bootstrap.sh` si queres invocarlo directo sin el wrapper.
- Ejecutar `codex-cloud-maintenance.ps1` para validar la superficie declarada, refrescar el registro y escribir la bitacora local.
- Ejecutar `codex-cloud-maintenance.sh` si el entorno no tiene `pwsh`.
- Ejecutar `codex-cloud-live.ps1` para lanzar el carril vivo con un solo comando sobre la `.venv` local.
- Mantener esta carpeta como zona de herramientas, no como salida final.

## Control total rapido

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1"
```

Salida auditable:

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1" -Format Json
```

Pasada extendida de repos:

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1" -Full
```

Barrido completo de la raiz GitHub:

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1" -ScanGitHubRoot
```

Arranque vivo unico:

```powershell
pwsh -NoProfile -File ".\tools\codex-cloud-live.ps1"
```
