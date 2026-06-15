# Plan Segunda Pasada Dataverse

Plan para integrar Dataverse en la estructura punta a punta de `PROJEC CDX`.

## Objetivo

Separar y gobernar Dataverse como carril propio:

`evidencia local -> metadata-only -> gate live -> output -> hito -> cierre`

## Fase DV1 - Inventario Local

Reunir evidencia Dataverse ya existente sin consultar live.

Archivos fuente:

- `outputs/dataverse_blocker_frontier_20260614/`
- `inventarios/SKILLS_UNIFIED_TABLE.*`
- `outputs/cabina_relationship_audit_20260614/`
- `outputs/universe_relationship_audit_20260614/`
- `hitos/20260614-hilo-anterior-v1/`

Criterio de cierre:

- Dataverse queda separado en `local_evidence`, `metadata_only`, `prepared_not_executed`, `live_rows_confirmed` o `blocked`.

## Fase DV2 - Playbook Dataverse

Crear playbook gobernado para Dataverse.

Archivo objetivo:

- `playbooks/06-dataverse-gobernado.md`
- `playbooks/07-dataverse-fronteras.md`
- `dataverse/REGISTRO_BLOQUEOS.md`

Criterio de cierre:

- El playbook impide confundir evidencia local con live rows y permite clasificar fronteras del workbook.
- El registro de bloqueos queda como modelo corto para decisiones humanas y escaladas.

## Fase DV3 - Workbook Y Alertas

Agregar Dataverse al workbook de control.

Cambios objetivo:

- columna `dataverse_estado`
- columna `ambiente`
- columna `target_exacto`
- columna `gate_live`
- alerta para `metadata_only` sin postcheck
- alerta para `prepared_not_executed` sin owner

Criterio de cierre:

- El tablero muestra si Dataverse esta local, metadata-only, preparado, live confirmado o bloqueado.

## Fase DV4 - Validador

Extender el validador del workbench.

Debe verificar:

- `dataverse/README.md`
- `dataverse/MAPA.md`
- `dataverse/GATE.md`
- `dataverse/PLAN_SEGUNDA_PASADA.md`
- existencia del output blocker frontier
- presencia de stop conditions Dataverse

Criterio de cierre:

- PASS si Dataverse esta gobernado sin live; OBSERVED si falta evidencia; FAIL si se intenta escribir sin gate.

## Fase DV5 - Hito Dataverse

Versionar la segunda pasada.

Archivo objetivo:

- `hitos/YYYYMMDD-projec-cdx-dataverse-v1/`

Criterio de cierre:

- Una nueva sesion entiende que Dataverse tiene carril propio, gate propio y no nace mezclado con outputs.
