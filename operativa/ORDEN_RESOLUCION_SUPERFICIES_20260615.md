# Orden de Resolucion de Superficies 20260615

## Objetivo

Resolver el resto de superficies de `PROJEC CDX` en un orden estable, tomando primero lo canonico y dejando lo historico para el final.

## Orden

### 1. `inventarios`

- Tomar:
  - `PROJEC_CDX_ROOT_INVENTORY.*`
  - `CODEX_ROOT_INVENTORY.*`
  - `CODEX_ROOT_MOVE_PLAN.json`
  - `CODEX_ROOT_MOVE_RESULTS.json`
  - `SKILLS_UNIFIED_TABLE.*`
- Resolver:
  - que inventario describe cada raiz
  - que tabla manda para clasificacion de superficie
  - que queda como historico y que queda como vivo

### 2. `workbooks`

- Tomar:
  - `control_operativo.xlsx`
  - `inicio.xlsx`
  - `tracker.xlsx`
- Resolver:
  - que workbook es el maestro de control
  - que workbook queda como entrada de inicio
  - que workbook sigue como tracker derivado

### 3. `outputs`

- Tomar:
  - `control_operativo_20260615`
  - `dataverse_blocker_frontier_20260614`
  - `universe_relationship_audit_20260614`
  - `cabina_relationship_audit_20260614`
  - `tracker_general_20260613`
  - `tracker_workbook_20260613`
  - `workbook_base_20260613`
  - `inicio_workbook_20260613`
  - `handoffs`
- Resolver:
  - que corridas siguen vigentes
  - que evidencia se reutiliza
  - que corridas quedan solo como historico

### 4. `tools`

- Tomar:
  - `build_codex_root_inventory.py`
  - `codex-control-total.ps1`
  - `build_control_workbook.mjs`
  - `build_skills_unified_table.ps1`
  - `build_skills_workbook.py`
  - `build_universe_relationship_audit.py`
  - `validate_proj_cdx_workbench.ps1`
  - `validate_proj_cdx_sync.ps1`
- Resolver:
  - cual genera cada superficie
  - cual valida cada superficie
  - cual cuenta `.codex`

## Regla

- Se resuelve una superficie por vez.
- Lo que no se usa para el delta actual queda como historico.
- Si la superficie ya tiene tabla maestra o mapa corto, se toma eso primero.
