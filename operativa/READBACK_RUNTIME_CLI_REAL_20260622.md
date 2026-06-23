---
artifact_id: operativa/READBACK_RUNTIME_CLI_REAL_20260622.md
categoria: operativa
tipo: readback
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/READBACK_RUNTIME_CLI_REAL_20260622.md
etiquetas:
  - runtime
  - cli
  - readback
  - restore
relacionados:
  - operativa/ACTA_RUNTIME_CLI_REAL_20260622.md
  - operativa/RUNTIME_CLI_MATRIX_20260622.csv
  - docs/runtime-cli.md
descripcion: Readback de cierre para CLI runtime real integrado al repo y validado localmente.
---

# READBACK RUNTIME CLI REAL

## Estado

`RUNTIME_CLI_REAL_READY`

## Inventario

- Python layer: `src/runtime_versioning/cli.py`.
- PowerShell layer: `tools/ceo-runtime-*.ps1`.
- Entrypoints: `pyproject.toml`.
- Dispatcher local: `main.py runtime`.
- Documentacion: `docs/runtime-cli.md`.

## Controles

- Restore aplica solo con `--apply --yes` o `--apply --confirm`.
- `status` es lectura pura.
- Sentinel escribe reporte vivo local ignorado.
- Snapshots versionados viven bajo `operativa/snapshots/`.

## Riesgo residual

`Bajo`

## Resultado

`READY_FOR_VALIDATION_CLOSEOUT`
