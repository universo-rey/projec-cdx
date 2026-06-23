---
artifact_id: docs/cloud-codex-governed.md
categoria: procesos
tipo: plan
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: docs/cloud-codex-governed.md
etiquetas:
  - cloud
  - codex
  - agents
  - github-actions
relacionados:
  - .github/workflows/codex-governed.yml
  - operativa/CLOUD_CODEX_GOVERNED_READBACK_20260622.md
descripcion: Flujo Codex Cloud gobernado para validacion analitica read-only con agentes y evidencia JSON.
---

# Codex Governed Cloud

## Principio

El cloud no reemplaza el gobierno local: lo extiende bajo control.

## Workflow

`.github/workflows/codex-governed.yml` corre en:

- `pull_request` contra `main`.
- `push` a `main`.
- `workflow_dispatch` controlado.

## Permisos

El workflow usa `contents: read`. No tiene permisos para comentar PRs, crear ramas, pushear, abrir releases ni ejecutar superficies live.

## Pasos

1. Verifica estado runtime con `python main.py runtime status --json`.
2. Valida metadata con `python -m tools.validate`.
3. Regenera indices y exige que no haya diff.
4. Ejecuta Sentinel runtime.
5. Ejecuta agentes gobernados con `python main.py --governed-check`.
6. Ejecuta tests.
7. Sube evidencia JSON como artifact `codex-governed-report`.

## Agentes

- `thot-tecnico`: estructura y consistencia tecnica.
- `maat-cumplimiento`: evidencia, gates y metadata.
- `horus-riesgo`: riesgo tecnico, operativo y de gobierno.
- `anubis-gate`: frontera, secrets y live.
- `seshat-normativa`: evidencia y trazabilidad.

## Frontera

- No live.
- No writes externos.
- No secretos.
- No PR comments automaticos sin gate de escritura.
- No workflow dispatch de superficies live.
