# SDU BOUNDARY MATRIX RECONCILIATION 20260622

## Estado de entrada

`SDU_BOUNDARY_MATRIX_PRESENT_READY_FOR_SENTINEL`

HEAD de entrada: `1753f420`

Branch: `codex/multirepo-alignment-16`

## Objetivo

Buscar matrices locales existentes antes de tratar `operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json` como canon aislado y reconciliar su relacion con la frontera runtime de `PROJEC CDX`.

## Fuentes buscadas

- `C:/Users/enzo1/PROJEC CDX`
- `C:/Users/enzo1/.codex/matrices`
- `C:/Users/enzo1/.codex/worktrees`
- `C:/Users/enzo1/.agents`
- `C:/Users/enzo1/Documents/GitHub`
- `C:/Users/enzo1/Documents/Codex`
- `C:/CEO`
- unidades locales disponibles

No se leyo `.env.local`.

No se usaron superficies externas.

## Hallazgo

Si existen matrices locales de frontera/gate relacionadas, principalmente:

- `CONNECTION_GATE_MATRIX.csv`
- `CONNECTION_SECRET_BOUNDARY_MATRIX.csv`
- `seed_connection_gates.csv`
- `seed_validation_gates.csv`
- `DEV_RUNTIME_ACTIVATION_TARGET_MATRIX.csv`
- `DEV_RUNTIME_STATE_MATRIX.csv`
- `BACK_REFERENCE_RUNTIME_TRACE_SOURCE_MATRIX.csv`
- `TOOLCHAIN_CAPABILITY_MATRIX.csv`
- `SDU_MASTER_ENVIRONMENT_SOLUTION_MATRIX.csv`
- `PLUGIN_SKILL_BOUNDARY_MATRIX.csv` en worktrees locales

Ninguna de esas matrices es equivalente directo a:

`operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json`

porque operan a otro grano:

- conexion
- secreto
- provider
- entorno Dataverse/Power Platform
- plugin/skill
- worktree historico
- evidence/gate review

## Decision de reconciliacion

`operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json` queda como fuente unica de verdad de frontera ejecutable del repo.

Las matrices locales anteriores quedan reconciliadas como:

- antecedentes
- soporte
- evidencias historicas
- matrices de granularidad menor
- duplicados archivados en worktrees

No se copian filas ni se fusionan automaticamente porque eso mezclaria granos distintos.

## Archivo de reconciliacion

`operativa/archive/legacy-root/20260622/BOUNDARY_MATRIX_RECONCILIATION_20260622.csv`

Ese archivo declara para cada fuente:

- tipo
- alcance
- relacion con la frontera runtime
- si se adopta o no
- razon
- decision

## Resultado

`BOUNDARY_MATRIX_RECONCILED_WITH_LOCAL_MATRICES`

## Siguiente accion

Reintentar `SDU_SENTINEL_LAYER`.

El Sentinel debe consumir:

1. `operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json` como frontera ejecutable.
2. `operativa/archive/legacy-root/20260622/BOUNDARY_MATRIX_RECONCILIATION_20260622.csv` como contexto de reconciliacion local.

## Confirmacion de frontera

- no OpenAI live
- no Microsoft live
- no SharePoint live
- no Dataverse live
- no Power Platform mutation
- no GitHub push
- no PR
- no Codex Cloud execution
- no secretos impresos
