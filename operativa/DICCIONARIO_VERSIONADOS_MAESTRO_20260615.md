# Diccionario de Versionados - Maestro 20260615

## Estado

`CANON_OPERATIVO`

## Proposito

Definir, en una sola tabla, que superficie versionada se consulta, que se toma de ella y para que se usa.

## Tabla Maestra

| Superficie | Rol | Leer primero | Tomar de aqui | Usar cuando | Version vigente |
| --- | --- | --- | --- | --- | --- |
| `inventarios` | Inventarios y tablas de referencia del workspace | `README.md`, `MAPA.md` | `PROJEC_CDX_ROOT_INVENTORY.*`, `CODEX_ROOT_INVENTORY.*`, `CODEX_ROOT_MOVE_PLAN.json`, `CODEX_ROOT_MOVE_RESULTS.json`, `SKILLS_UNIFIED_TABLE.*` | clasificar superficies, comparar raiz actual contra `.codex`, revisar gaps de skills | vivo |
| `workbooks` | Libros de trabajo visibles y sus resúmenes | `README.md`, `MAPA.md`, `EXCEL_AL_FRENTE.md` | `control_operativo.xlsx`, `inicio.xlsx`, `tracker.xlsx` | alinear seguimiento, trazabilidad, formularios y control operativo en Excel | vivo |
| `outputs` | Corridas generadas, evidencia fechada y salidas consumibles | `README.md`, `MAPA.md`, `RETENCION.md` | corrida vigente del frente activo, `xlsx/md/csv/png/ndjson`, readbacks durables | recuperar evidencia, comparar versiones de corrida o cerrar un delta con artefactos | vivo |
| `tools` | Scripts de generacion, normalizacion y validacion | `README.md`, `MAPA.md` | `build_codex_root_inventory.py`, `codex-control-total.ps1`, `validate_proj_cdx_workbench.ps1`, `validate_proj_cdx_sync.ps1` | regenerar inventarios, contar `.codex`, validar superficies o cerrar un cambio | vivo |
| `hitos` | Cierres, readbacks y hitos operativos durables | `README.md`, `MAPA.md`, `INDICE_MAESTRO.md` | hito vigente y su evidencia; usar `INDICE_MAESTRO.md` para la seleccion de version | cerrar, versionar o recuperar continuidad | versionado |
| `catalogo-local` | Snapshot versionado del catalogo local de skills, roots y config | `README.md`, `20260614-v6/README.md` | `skills_inventory.csv`, `roots_summary.csv`, `duplicate_skill_names.csv`, `config_catalog_sections.txt`, `index_consistency_gap.csv` | alinear config, plugins, skills y roots | versionado |

## Regla Operativa

- De cada superficie se toma solo lo necesario para el delta actual.
- Lo historico queda como respaldo y no se reabre sin motivo.
- Si hay duda entre capa viva y capa versionada, manda la versionada para continuidad y la viva para ejecucion.
