---
artifact_id: operativa/G4_REMOTE_CHECKS_STABILIZATION_v0.6.0-rc1_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/G4_REMOTE_CHECKS_STABILIZATION_v0.6.0-rc1_20260622.md
etiquetas:
- cabina
- release
- github
- checks
- g4
relacionados:
- operativa/G4_REMOTE_CHECKS_MATRIX_v0.6.0-rc1_20260622.csv
- operativa/READBACK_G4_REMOTE_CHECKS_STABILIZATION_v0.6.0-rc1_20260622.md
descripcion: Acta tecnica de estabilizacion de checks remotos del PR gobernado v0.6.0-rc1.
fecha_evento: '2026-06-22'
---

# G4 REMOTE CHECKS STABILIZATION v0.6.0-rc1

## Estado de entrada

`G3_REMOTE_PR_OPEN_GOVERNED_v0.6.0-rc1_OPEN`

## PR

- PR: `https://github.com/universo-rey/projec-cdx/pull/23`
- Rama: `codex/v0.6.0-rc1-governed-publication`
- Base: `main`
- Modo: draft gobernado

## Checks observados

- `metadata`: failed.
- `lint-test`: failed.
- `graph`: success.
- `analyze`: success.
- `CodeQL`: success.

## Causa raiz

- `metadata` fallo porque `index.json` y `operativa/index.json` no estaban alineados con el paquete documental G3.
- `lint-test` fallo primero por orden de imports detectado por Ruff y hubiera seguido fallando por formato Black.
- La validacion local con el entrypoint `pytest` tambien detecto que `tools` no quedaba visible para tests; se normalizo `pythonpath` para cubrir el comando que usa CI.
- La segunda corrida remota redujo el fallo a `test_sdu_chain_resolver_builds_local_chain`: el resolver usaba separadores Windows para rutas relativas y en Linux eso convertia los paths en nombres literales.

## Resolucion tecnica aplicada

- Se regeneraron los indices con el builder canonico.
- Se aplico correccion automatica de Ruff para ordenar imports y espacios.
- Se aplico Black sobre `src`, `tests` y `tools` para cumplir el workflow `quality`.
- Se agrego la raiz del repo al `pythonpath` de pytest para que los tests de `tools` sean resolubles por el entrypoint usado en CI.
- Se corrigio el resolver de rutas de `tools/sdu_chain_resolver.py` para unir partes relativas con el separador nativo de la plataforma.
- No se modifico runtime live.
- No se ejecuto workflow dispatch.
- No se hizo merge.
- No se publico tag.
- No se imprimieron secretos.

## Archivos de codigo normalizados

- `src/launch_desk/service.py`
- `src/metadata/cli.py`
- `src/metadata/doc_report.py`
- `src/projec_cdx_common/__init__.py`
- `src/projec_cdx_common/safe_errors.py`
- `tools/sdu_auto_remediation.py`
- `tools/sdu_canon_source_guard.py`
- `tools/sdu_chain_resolver.py`
- `tools/sdu_sentinel.py`
- `tests/test_sdu_canon_source_guard.py`
- `tests/test_sdu_chain_resolver.py`
- `tests/test_sdu_sentinel.py`
- `pyproject.toml`

## Frontera preservada

- No merge.
- No tag push.
- No workflow dispatch.
- No live execution.
- No Dataverse write.
- No Microsoft write.
- No MCP.
- No secretos.
- No force push.

## Resultado esperado

`G4_REMOTE_CHECKS_STABILIZED_v0.6.0-rc1`
