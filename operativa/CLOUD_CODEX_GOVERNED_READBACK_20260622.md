---
artifact_id: operativa/CLOUD_CODEX_GOVERNED_READBACK_20260622.md
categoria: operativa
tipo: readback
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/CLOUD_CODEX_GOVERNED_READBACK_20260622.md
etiquetas:
  - cloud
  - codex
  - readback
  - sentinel
relacionados:
  - operativa/ACTA_CLOUD_CODEX_GOVERNED_20260622.md
  - .github/workflows/codex-governed.yml
  - src/projec_cdx_cloud/governed.py
descripcion: Readback de cierre para activacion cloud gobernada sin writes externos.
---

# CLOUD CODEX GOVERNED READBACK

## Estado

`CLOUD_FLOW_ACTIVE`

## Implementado

- Workflow read-only `codex-governed`.
- Runner `--governed-check`.
- Agentes `thot`, `maat`, `horus`, `anubis`, `seshat` y `EATOMIC`.
- `EATOMIC` se toma de `operativa/SETUP_APERTURA_CODEX_UI.md` como agente existente, no como runtime nuevo.
- Evidencia JSON en artifact.
- Snapshot gate y runtime status integrados.

## No habilitado

- Comentarios automaticos en PR.
- OpenAI API live.
- Dataverse/Microsoft live.
- Workflow dispatch hacia superficies live.

## Resultado

`READY_FOR_REMOTE_CI_VALIDATION`
