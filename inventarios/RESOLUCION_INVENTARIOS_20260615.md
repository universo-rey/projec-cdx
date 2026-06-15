# Resolucion de Inventarios 20260615

## Estado

`RESUELTO`

## Criterio

- `PROJEC_CDX_ROOT_INVENTORY.*` es el inventario activo del workspace `PROJEC CDX`.
- `CODEX_ROOT_INVENTORY.*` es el inventario de la raiz global `.codex` y se trata como superficie historica / externa.
- `SKILLS_UNIFIED_TABLE.*` es la tabla consolidada para skills y plugins.
- `CODEX_ROOT_MOVE_PLAN.json` y `CODEX_ROOT_MOVE_RESULTS.json` quedan como evidencia de plan y resultado del rehome, no como inventario activo.

## Que Se Toma De Cada Uno

### `PROJEC_CDX_ROOT_INVENTORY.*`

- Estructura actual del workbench.
- Carpetas gobernadas del workspace.
- Base para decidir superficies vivas dentro de `PROJEC CDX`.

### `CODEX_ROOT_INVENTORY.*`

- Clasificacion de la raiz `.codex`.
- Superficies top-level, runtime, cache, secretos y backups.
- Base para control total de `.codex` y comparacion historica.

### `SKILLS_UNIFIED_TABLE.*`

- Tabla unica de skills y plugins visibles.
- Base para revisar aliases, drift y raiz efectiva de capacidades.

### `CODEX_ROOT_MOVE_PLAN.json`

- Plan de movimiento y clasificacion.
- Sirve para rastrear decisiones de rehome, no para inventario vivo.

### `CODEX_ROOT_MOVE_RESULTS.json`

- Resultado del movimiento o clasificacion.
- Sirve como evidencia posterior, no como fuente canonica de inventario.

## Regla de Uso

- Si la pregunta es sobre el workspace actual, usar `PROJEC_CDX_ROOT_INVENTORY.*`.
- Si la pregunta es sobre `.codex`, usar `CODEX_ROOT_INVENTORY.*` y su control total asociado.
- Si la pregunta es sobre skills o plugins, usar `SKILLS_UNIFIED_TABLE.*` y `catalogo-local/v6`.
- Si la pregunta es sobre movimiento o rehome, usar los JSON de plan y resultado como evidencia.
