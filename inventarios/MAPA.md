# Mapa De Inventarios

Vista unica de los inventarios y tablas de referencia de `PROJEC CDX`.

La wave visible mas reciente es [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

El inventario debe mostrar fase, impulso y estado terminal de la superficie que describe.

## Contenido

- `RESOLUCION_INVENTARIOS_20260615.md`
- `PROJEC_CDX_ROOT_INVENTORY.md`
- `PROJEC_CDX_ROOT_INVENTORY.csv`
- `CODEXLOCAL_SURFACE_MAP_20260615.csv`
- `CODEXLOCAL_SPLIT_CABINA_20260615.csv`
- `CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv`
- `GITHUB_REPOS_CANONICAL_20260615.csv`
- `AUDITAR_SURFACE_INDEX_20260615.csv`
- `CODEX_ROOT_INVENTORY.xlsx`
- `CODEX_ROOT_INVENTORY.csv`
- `CODEX_ROOT_MOVE_PLAN.json`
- `CODEX_ROOT_MOVE_RESULTS.json`
- `SKILLS_UNIFIED_TABLE.xlsx`
- `SKILLS_UNIFIED_TABLE.csv`
- `SKILLS_UNIFIED_TABLE.md`

## Lectura

- `PROJEC_CDX_ROOT_INVENTORY.*` resume la raiz actual de `PROJEC CDX`.
- `CODEXLOCAL_SURFACE_MAP_20260615.csv` resume la raiz local `C:\Users\enzo1\CodexLocal`.
- `CODEXLOCAL_SPLIT_CABINA_20260615.csv` resume los paquetes del split Cabina.
- `CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv` cruza los antiguos huecos `INDEX_ONLY` contra CodexLocal.
- `GITHUB_REPOS_CANONICAL_20260615.csv` resume la raiz canonica local de repos en `C:\Users\enzo1\Documents\GitHub`.
- `AUDITAR_SURFACE_INDEX_20260615.csv` resume la carpeta agregadora no Git `Auditar`.
- `CODEX_ROOT_INVENTORY.*` resume principalmente la raiz global `.codex`, fuera del workspace `PROJEC CDX`.
- La tabla unificada de skills consolida el catalogo local.
- Los JSON de movimiento registran el plan y el resultado del rehome.

## Regla

- Si cambia la raiz o el catalogo local, se actualizan estos inventarios.
- Si hay duda de fuente, `PROJEC_CDX_ROOT_INVENTORY.*` manda para el workspace y `CODEX_ROOT_INVENTORY.*` para `.codex`.
