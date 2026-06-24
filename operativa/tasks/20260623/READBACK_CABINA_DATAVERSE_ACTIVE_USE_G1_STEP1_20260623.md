---
artifact_id: operativa/tasks/20260623/READBACK_CABINA_DATAVERSE_ACTIVE_USE_G1_STEP1_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: CABINA_DATAVERSE_ACTIVE_USE_G1_STEP1
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_CABINA_DATAVERSE_ACTIVE_USE_G1_STEP1_20260623.md
etiquetas:
  - dataverse
  - active-use
  - read-only
  - vscode-insiders
  - canon-delta
relacionados:
  - operativa/tasks/20260623/CABINA_DATAVERSE_ACTIVE_USE_G1_STEP1_LIVE_INVENTORY_20260623.csv
  - .cabina/dataverse/out/dataverse-live-inventory.json
  - .cabina/dataverse/out/dataverse-usable-memory.json
  - .cabina/dataverse/out/dataverse-canon-delta.json
  - tools/ceo-dataverse-active-use.ps1
descripcion: Readback de activacion Dataverse G1 Step1 con lectura viva gobernada y sin mutaciones.
---

# CABINA_DATAVERSE_ACTIVE_USE_G1_STEP1

## Estado

`DATAVERSE_ACTIVE_USE_G1_STEP1_READY_READ_ONLY`

## Resultado vivo

- Entorno: `https://org084965d9.crm.dynamics.com`
- Metodo: Azure CLI con perfil aislado + Dataverse Web API `GET`
- Solucion observada: `SPGovernanceModel`
- Tablas observadas: `8`
- Filas reales confirmadas: `true`

## Tablas utilizables

- `cr3c_cr3c_spsite`
- `cr3c_cr3c_spcontainer`
- `cr3c_contenedorsp`
- `cr3c_cr3c_spfield`
- `cr3c_camposp`
- `cr3c_tipodecontenidosp`
- `cr3c_cr3c_containercontenttype`
- `cr3c_cr3c_spchoiceoption`

## Brecha detectada

El canon corto esperaba:

- `cr3c_spgovernancemodel`
- `cr3c_spsite`
- `cr3c_spcontainer`
- `cr3c_spfield`
- `cr3c_spcontenttype`
- `cr3c_spchoiceoption`

La superficie viva existe, pero con nombres reales distintos:

- solucion real: `SPGovernanceModel`
- tablas reales con doble prefijo `cr3c_cr3c_*` y variantes en espanol (`cr3c_contenedorsp`, `cr3c_camposp`, `cr3c_tipodecontenidosp`)

Decision tecnica: `CANON_NAME_DRIFT_WITH_REAL_TABLE_PRESENT`.

## Comandos producidos

- `tools\ceo-dataverse-active-use.ps1`
- `tools\ceo-dataverse-status.ps1`
- `tools\ceo-dataverse-solutions.ps1`
- `tools\ceo-dataverse-tables.ps1`
- `tools\ceo-dataverse-schema.ps1`
- `tools\ceo-dataverse-records.ps1`
- `tools\ceo-dataverse-memory.ps1`
- `tools\ceo-dataverse-canon-delta.ps1`

## Evidencia producida

- `.cabina\dataverse\out\dataverse-live-inventory.json`
- `.cabina\dataverse\out\dataverse-usable-memory.json`
- `.cabina\dataverse\out\dataverse-canon-delta.json`
- `operativa\tasks\20260623\CABINA_DATAVERSE_ACTIVE_USE_G1_STEP1_LIVE_INVENTORY_20260623.csv`

## Frontera

- No Dataverse write.
- No create table.
- No rename.
- No delete.
- No flow create.
- No token print.
- No push.
- No PR.

## Proxima accion

`DATAVERSE_CANON_NAME_RECONCILIATION_DECISION`

El siguiente paso no es crear tablas. Es decidir si el canon documenta alias vivos o si se corrige la nomenclatura esperada hacia los logical names reales.
