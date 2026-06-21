---
artifact_id: docs/referencia/README.reference.md
categoria: playbooks
tipo: reporte
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/referencia/README.reference.md
etiquetas:
  - docs
  - readme
  - referencia
relacionados: []
descripcion: Referencia historica extendida de la superficie documental.
---
# README.reference.md - PROJEC CDX

Inventario de referencia de la carpeta `C:\Users\enzo1\PROJEC CDX`.
Se deja como soporte mientras organizamos el espacio y consolidamos los artefactos.

La wave visible mas reciente es [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

## Objetivo de la carpeta

Esta carpeta concentra workbooks, paquetes y salidas generadas alrededor de:

- workbook base
- tracker general
- inicio de workbook
- paquetes evolucionarios de Codex
- el origen del chat actual, que sirve como canon de referencia para este ordenamiento

La cartografia completa del universo compartido vive en [CARTOGRAFIA_COMPLETA.md](C:/Users/enzo1/.codex/CARTOGRAFIA_COMPLETA.md).
La tabla de relaciones ejecutiva para auditoria rapida vive en [outputs/cabina_relationship_audit_20260614/CABINA_RELATIONSHIP_AUDIT_EXECUTIVE.xlsx](C:/Users/enzo1/PROJEC%20CDX/outputs/cabina_relationship_audit_20260614/CABINA_RELATIONSHIP_AUDIT_EXECUTIVE.xlsx).
La nota operativa sobre duplicados vivos, `models_cache.json` y los sensibles `auth.json` / `cap_sid` tambien queda reflejada en [inventarios/CODEX_ROOT_INVENTORY.xlsx](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEX_ROOT_INVENTORY.xlsx) y en [inventarios/CODEX_ROOT_MOVE_PLAN.json](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEX_ROOT_MOVE_PLAN.json).
Las superficies sensibles `secrets/`, `.sandbox-secrets/` y `private/` se inventarian como puertas dedicadas, no como candidatos de limpieza.

## Superficies visibles

| Archivo | Uso |
|---|---|
| [workbooks/inicio.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/inicio.xlsx) | Workbook de inicio |
| [workbooks/tracker.xlsx](C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx) | Workbook de seguimiento |
| [packages/codex_evolutionary_blueprint_package.zip](C:/Users/enzo1/PROJEC%20CDX/packages/codex_evolutionary_blueprint_package.zip) | Paquete comprimido de blueprint |
| [packages/codex_evolutionary_runtime_activation_v2.zip](C:/Users/enzo1/PROJEC%20CDX/packages/codex_evolutionary_runtime_activation_v2.zip) | Paquete comprimido de activacion |
| [AGENTS.md](C:/Users/enzo1/PROJEC%20CDX/AGENTS.md) | Guia minima local |
| [docs/referencia/AGENTS.reference.md](C:/Users/enzo1/PROJEC%20CDX/docs/referencia/AGENTS.reference.md) | Guia completa temporal |
| [Origen del chat actual](C:/Users/enzo1/.codex/attachments/296335cf-ca6e-4cf2-b2c5-a46b23c27ff4/pasted-text.txt) | Canon de origen usado para esta organización |
| [CARTOGRAFIA_COMPLETA.md](C:/Users/enzo1/.codex/CARTOGRAFIA_COMPLETA.md) | Mapa maestro del universo compartido |

## Estructura de salidas

La carpeta `outputs/` contiene resultados generados por fecha y tema.

### `outputs/workbook_base_20260613`

- `workbook_base.xlsx`
- `build_workbook.mjs`
- `resumen.png`
- `registro.png`
- `listas.png`
- `inspect_resumen.ndjson`
- `inspect_registro.ndjson`
- `inspect_listas.ndjson`
- `formula_errors.ndjson`

### `outputs/tracker_general_20260613`

- `tracker.xlsx`
- `build_tracker_general.mjs`
- `inicio.png`
- `registro.png`
- `listas.png`
- `inspect_inicio.ndjson`
- `inspect_registro.ndjson`
- `inspect_listas.ndjson`
- `formula_errors.ndjson`

### `outputs/tracker_workbook_20260613`

- `tracker_workbook.xlsx`
- `build_tracker.mjs`
- `resumen.png`
- `registro.png`
- `listas.png`
- `inspect_resumen.ndjson`
- `inspect_registro.ndjson`
- `inspect_listas.ndjson`
- `formula_errors.ndjson`

### `outputs/inicio_workbook_20260613`

- `excel_inicio.xlsx`
- `build_inicio.mjs`
- `inicio.png`
- `registro.png`
- `listas.png`
- `inspect_inicio.ndjson`
- `inspect_registro.ndjson`
- `inspect_listas.ndjson`
- `formula_errors.ndjson`

## Inventarios

- [inventarios/CODEX_ROOT_INVENTORY.xlsx](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEX_ROOT_INVENTORY.xlsx)
- [inventarios/CODEX_ROOT_INVENTORY.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEX_ROOT_INVENTORY.csv)
- [inventarios/CODEX_ROOT_MOVE_PLAN.json](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEX_ROOT_MOVE_PLAN.json)
- [inventarios/CODEX_ROOT_MOVE_RESULTS.json](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEX_ROOT_MOVE_RESULTS.json)
- [inventarios/SKILLS_UNIFIED_TABLE.xlsx](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.xlsx)
- [inventarios/SKILLS_UNIFIED_TABLE.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.csv)
- [inventarios/SKILLS_UNIFIED_TABLE.md](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.md)

### `outputs/dataverse_blocker_frontier_20260614`

- `dataverse_blocker_frontier.xlsx`
- `build_dataverse_blocker_frontier.py`
- `README.md`
- `MAPA.md`
- `READBACK.md`

## Dependencias locales

- `node_modules/`: arbol de dependencias local. No editar manualmente.

## Piezas clave

- `inicio.xlsx` y `tracker.xlsx` parecen ser los puntos de trabajo visibles.
- Los `.zip` parecen contener paquetes de evolucion o activacion.
- Los `.mjs` dentro de `outputs/` son scripts de generacion usados para producir los artefactos.
- Los `.ndjson` son inspecciones o trazas por corrida.
- Las `.png` son capturas de validacion o vista previa.

## Regla de orden

Cuando se siga organizando la carpeta:

1. Identificar primero el artefacto fuente.
2. Separar salidas generadas de archivos de trabajo.
3. Dejar un unico punto de entrada visible.
4. Mantener las referencias historicas hasta confirmar que ya no se usan.
5. Si hay que simplificar sin romper enlaces, usar `codex-surface-map`.
