---
artifact_id: operativa/archive/legacy-root/20260622/G3_FRONTIER_CERTIFICATION_v0.6.0-rc1_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/G3_FRONTIER_CERTIFICATION_v0.6.0-rc1_20260622.md
etiquetas:
- cabina
- release
- frontier
- github
- pr
relacionados:
- operativa/archive/legacy-root/20260622/G3_RISK_MATRIX_v0.6.0-rc1_20260622.csv
- operativa/archive/legacy-root/20260622/G3_OPERATIONAL_SYNC_MATRIX_v0.6.0-rc1_20260622.csv
descripcion: Certificacion de frontera para apertura de PR gobernado v0.6.0-rc1.
fecha_evento: '2026-06-22'
---

# G3 FRONTIER CERTIFICATION v0.6.0-rc1

## Estado

`FRONTIER_PASS_FOR_DRAFT_PR_ONLY`

## Permitido en G3

- Fast-forward de la rama candidate con evidencia G3.
- Apertura de PR draft gobernado.
- Edicion de metadata del PR si es necesaria para reflejar evidencia.

## Bloqueado en G3

- Merge.
- Tag push.
- Workflow dispatch.
- Live execution.
- MCP execution.
- Dataverse write.
- Microsoft write.
- OpenAI write.
- Exposicion de secretos.
- Force push.

## Certificacion

La frontera se preserva si el PR se abre como draft y el tag remoto `v0.6.0-rc1` permanece ausente.

## Resultado

`ANUBIS_GATE_PASS`
