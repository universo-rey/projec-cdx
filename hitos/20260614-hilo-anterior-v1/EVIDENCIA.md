# Evidencia

## Fuentes principales

- `HANDOFF_THREAD_HEAVY_20260614.md`
- `outputs\README.md`
- `outputs\MAPA.md`
- `CODEX_ROOT_INVENTORY.csv`
- `CODEX_ROOT_MOVE_PLAN.json`
- `CODEX_ROOT_MOVE_RESULTS.json`
- `tools\codex-control-total.ps1`
- `tools\test_codex_powershell_layout.ps1`

## Corridas visibles

- `outputs\cabina_relationship_audit_20260614`
- `outputs\workbook_base_20260613`
- `outputs\tracker_general_20260613`
- `outputs\tracker_workbook_20260613`
- `outputs\inicio_workbook_20260613`
- `outputs\dataverse_blocker_frontier_20260614`

## Conteos verificados

- Control total rapido: `checks=21`, `green=15`, `yellow=6`, `red=0`.
- Inventario `CODEX_ROOT_INVENTORY.csv`: `74` filas clasificadas.
- Movimientos `CODEX_ROOT_MOVE_RESULTS.json`: `118` entradas con `status=DONE`.
- Destinos de movimientos: `85` a `backups`, `22` a `workpapers`, `9` a `tmp`, `2` a `log`.
- Dataverse blocker frontier: `12` fronteras, `9` bloqueantes, `2` observadas, `1` mitigable.

## Limites

- No se leyo contenido de `auth.json`.
- No se leyo contenido de `cap_sid`.
- No se edito SQLite activo.
- No se edito `global-state` activo.
