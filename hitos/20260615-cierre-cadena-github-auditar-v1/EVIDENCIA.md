# EVIDENCIA

## Fuentes

- `inventarios/CODEXLOCAL_SURFACE_MAP_20260615.csv`.
- `inventarios/CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv`.
- `inventarios/GITHUB_REPOS_CANONICAL_20260615.csv`.
- `inventarios/AUDITAR_SURFACE_INDEX_20260615.csv`.

## Actas

- `operativa/archive/legacy-root/20260615/ACTA_CIERRE_CADENA_GITHUB_AUDITAR_20260615.md`.
- `operativa/archive/legacy-root/20260615/ACTA_CORTE_EJECUTORA_20260615.md`.
- `dataverse/ACTA_CORTE_EJECUTORA_20260615.md`.

## Validadores

- `tools/validate_proj_cdx_operational_chain.ps1`.
- `tools/validate_proj_cdx_workbench.ps1`.
- `tools/validate_proj_cdx_sync.ps1`.

## Workbook

- `workbooks/control_operativo.xlsx`.
- `outputs/control_operativo_20260615/control_operativo.xlsx`.
- `outputs/control_operativo_20260615/MANIFEST.json`.

## Resultado

- Cadena operativa: PASS, 43 filas, sin `INDEX_ONLY`.
- Workbench: PASS.
- Sincronizacion: PASS.

## Guardrails

- Sin live writes.
- Sin Git writes.
- Sin lectura de secretos.
