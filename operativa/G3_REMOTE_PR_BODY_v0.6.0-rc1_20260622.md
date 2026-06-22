---
artifact_id: operativa/G3_REMOTE_PR_BODY_v0.6.0-rc1_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/G3_REMOTE_PR_BODY_v0.6.0-rc1_20260622.md
etiquetas:
- cabina
- release
- github
- pr-body
- v0-6-0-rc1
relacionados:
- operativa/G3_TECHNICAL_HARDENING_ACTA_v0.6.0-rc1_20260622.md
- operativa/G3_FRONTIER_CERTIFICATION_v0.6.0-rc1_20260622.md
descripcion: Cuerpo estructurado para PR draft gobernado v0.6.0-rc1.
fecha_evento: '2026-06-22'
---

# G3 REMOTE PR BODY v0.6.0-rc1

## Estado

Publicacion remota gobernada de `v0.6.0-rc1`.

## Alcance

- Gobierno total local de cabina.
- IDE control-plane.
- Sistema nervioso inventariado.
- Skills, recipes y plugins reconciliados.
- Runner PowerShell fijado.
- W1-W7 cerradas localmente.
- Metadata PASS.
- Sentinel NO_DRIFT.
- Pytest PASS.
- Tag local existente `v0.6.0-rc1`, no publicado.
- G1 labels de gobierno creadas.
- G2 rama candidate publicada.

## Evidencia

- `operativa/VERSION_v0.6.0_RC1_CLOSEOUT_20260622.md`
- `operativa/READBACK_TAG_v0.6.0-rc1_LOCAL_ONLY_20260622.md`
- `operativa/REMOTE_PUBLICATION_PLAN_v0.6.0-rc1_20260622.md`
- `operativa/READBACK_REMOTE_REPO_PREFLIGHT_v0.6.0-rc1_20260622.md`
- `operativa/READBACK_G1_LABEL_TAXONOMY_GATE_v0.6.0-rc1_20260622.md`
- `operativa/READBACK_G2_REMOTE_BRANCH_PUSH_CANDIDATE_v0.6.0-rc1_20260622.md`
- `operativa/G3_TECHNICAL_HARDENING_ACTA_v0.6.0-rc1_20260622.md`
- `operativa/G3_FRONTIER_CERTIFICATION_v0.6.0-rc1_20260622.md`
- `operativa/G3_OPERATIONAL_SYNC_MATRIX_v0.6.0-rc1_20260622.csv`
- `operativa/G3_RISK_MATRIX_v0.6.0-rc1_20260622.csv`

## Fuera de alcance

- No live.
- No MCP execution.
- No Dataverse write.
- No Microsoft write.
- No OpenAI write.
- No workflow dispatch.
- No secretos.
- No force push.
- No tag push.
- No merge.

## Validacion local

- `tools.validate`: PASS.
- `sdu_sentinel.py scan`: PASS / NO_DRIFT.
- `sdu_auto_remediation.py analyze`: PASS / NO_DRIFT.
- `sdu_sentinel.py check`: PASS.
- `pytest`: PASS.
- `git diff --check`: PASS.
- `git status`: limpio.

## Gates

- G0 remote publication plan: cerrado.
- G1 remote repo preflight: cerrado.
- G1 label taxonomy gate: cerrado.
- G2 remote branch push: cerrado.
- G3 PR draft: este PR.
- G4 checks/review/stabilization: pendiente.
- G5 tag push: pendiente, no autorizado por este PR.

## Stop conditions

- HEAD remoto cambia sin control.
- Checks fallan.
- REQUEST_CHANGES.
- Se detectan secretos.
- Se detecta live, produccion o permisos peligrosos.
- Se intenta workflow dispatch.
- Se intenta tag push.
- Se intenta merge.

## Decision recomendada

Revisar y aprobar el PR si los checks quedan verdes y no hay comentarios bloqueantes. No mergear dentro de este gate.
