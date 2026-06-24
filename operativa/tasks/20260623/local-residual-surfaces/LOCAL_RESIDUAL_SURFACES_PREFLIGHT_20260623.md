---
artifact_id: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_PREFLIGHT_20260623.md
categoria: operativa
tipo: reporte
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_PREFLIGHT_20260623.md
etiquetas:
  - runtime
  - residual
  - preflight
relacionados:
  - operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_PREFLIGHT_20260623.json
  - operativa/runtime-events/FINAL_READBACK_RUNTIME_STATE_AND_SNAPSHOT_ALIGNMENT_G1.md
descripcion: Preflight del carril local residual surfaces owner decision.
---
# LOCAL RESIDUAL SURFACES PREFLIGHT 20260623

## Estado

- Operation: LOCAL_RESIDUAL_SURFACES_OWNER_DECISION_G1
- HEAD: e019422734f40419fbbc2f28585c0e408b01537d
- Branch: codex/runtime-versioning-snapshots
- Snapshot: CEORUNTIME_20260623_1246
- Runtime status: WARN
- Status entries captured: 87
- Tracked modified entries: 1
- Untracked entries: 86
- Stage/commit/delete/move/push/PR/live: false

## Validaciones

- git diff --check: PASS_WITH_CRLF_WARNING
- python -m tools.validate: PASS - OK: 135 metadatos validos.
- python tools/sdu_sentinel.py check: PASS
- ceo-runtime-status --json: WARN por dirty residual local.

## Diagnostico script tracked

- Path: tools/promote_sdu_manifesto_dataverse.ps1
- Diff summary: warning: in the working copy of 'tools/promote_sdu_manifesto_dataverse.ps1', LF will be replaced by CRLF the next time Git touches it  1 file changed, 1 insertion(+), 1 deletion(-)
- git diff -w: EMPTY
- git diff --ignore-space-at-eol: PRESENT
- git diff --ignore-cr-at-eol: PRESENT
- Dictamen preliminar: UNKNOWN_NEEDS_OWNER, porque el cambio visible es whitespace-only y no estrictamente solo CRLF.

## Nota de no exposicion

El diff bruto del script se ejecuto para diagnostico, pero no se vuelca completo a esta evidencia para evitar exposicion innecesaria de valores operativos.
