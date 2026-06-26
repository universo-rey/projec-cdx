---
artifact_id: operativa/archive/legacy-root/20260622/READBACK_G4_REMOTE_CHECKS_STABILIZATION_v0.6.0-rc1_20260622.md
categoria: operativa
tipo: readback
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/READBACK_G4_REMOTE_CHECKS_STABILIZATION_v0.6.0-rc1_20260622.md
etiquetas:
- cabina
- release
- github
- checks
- readback
relacionados:
- operativa/archive/legacy-root/20260622/G4_REMOTE_CHECKS_STABILIZATION_v0.6.0-rc1_20260622.md
- operativa/archive/legacy-root/20260622/G4_REMOTE_CHECKS_MATRIX_v0.6.0-rc1_20260622.csv
descripcion: Readback de estabilizacion G4 de checks remotos para PR gobernado v0.6.0-rc1.
fecha_evento: '2026-06-22'
---

# READBACK G4 REMOTE CHECKS STABILIZATION v0.6.0-rc1

## Estado

`G4_REMOTE_CHECKS_STABILIZATION_IN_PROGRESS`

## Fallas remotas tratadas

- `metadata`: indices desactualizados.
- `lint-test`: orden de imports Ruff y formato Black.
- `pytest`: resolucion local de `tools` faltante bajo entrypoint de CI.
- `chain-resolver`: paths relativos con separador Windows rompian fixture en Linux.

## Acciones ejecutadas

- Regeneracion de `index.json`.
- Regeneracion de `operativa/archive/legacy-root/undated/index.json`.
- Correccion Ruff en:
  - `src/launch_desk/service.py`
  - `src/metadata/cli.py`
  - `tools/sdu_auto_remediation.py`
  - `tools/sdu_sentinel.py`
- Formato Black aplicado sobre `src`, `tests` y `tools`.
- Ajuste de `pyproject.toml` para incluir la raiz del repo en `pythonpath`.
- Ajuste portable de `_path` en `tools/sdu_chain_resolver.py`.

## Validacion esperada

- `metadata`: success.
- `lint-test`: success.
- `graph`: success.
- `analyze`: success.
- `CodeQL`: success.

## Frontera

- No merge.
- No tag push.
- No workflow dispatch.
- No live.
- No secretos.
- No PR nuevo.

## Resultado

`READY_FOR_REMOTE_RECHECK`
