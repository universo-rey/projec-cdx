---
artifact_id: operativa/archive/legacy-root/20260622/ACTA_RUNTIME_VERSIONING_SNAPSHOTS_20260622.md
categoria: operativa
tipo: acta
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/archive/legacy-root/20260622/ACTA_RUNTIME_VERSIONING_SNAPSHOTS_20260622.md
etiquetas:
  - runtime-save
  - runtime-restore
  - sentinel
  - versionado
relacionados:
  - VERSION_POLICY.md
descripcion: Acta base del sistema gobernado de versionado continuo, snapshots y recuperacion.
---

# ACTA RUNTIME VERSIONING SNAPSHOTS

## Estado

`RUNTIME_VERSIONING_AND_SNAPSHOTS_ACTIVE`

## Alcance

- Versionado continuo con semantica `vX.Y.Z`, `vX.Y.Z-rcN` y `vX.Y.Z-hotfixN`.
- Snapshots reproducibles en `operativa/snapshots/`.
- Restore bloqueado ante workspace dirty y sin confirmacion explicita.
- Watchdog runtime en `operativa/sentinel/SENTINEL_REPORT.json`.

## Comandos

- `tools/ceo-runtime-save.ps1`
- `tools/ceo-runtime-list.ps1`
- `tools/ceo-runtime-restore.ps1`
- `tools/ceo-runtime-sentinel.ps1`

## Frontera

- No live.
- No MCP.
- No workflow dispatch.
- No secretos.
- No restore destructivo sin `--apply --yes`.

## Resultado

`READY_FOR_GOVERNED_RUNTIME_SAVE`
