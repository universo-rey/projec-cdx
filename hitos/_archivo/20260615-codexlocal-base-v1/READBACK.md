# READBACK_CODEXLOCAL_BASE_20260615

## Estado

HECHO_VERIFICADO: `C:\Users\enzo1\CodexLocal` queda registrado como base local previa para leer frentes y workspaces derivados.

## Sistemas tocados

- `PROJEC CDX/inventarios/CODEXLOCAL_SURFACE_MAP_20260615.csv`
- `PROJEC CDX/inventarios/CODEXLOCAL_SPLIT_CABINA_20260615.csv`
- `PROJEC CDX/hitos/20260615-codexlocal-base-v1`

## Sistemas no tocados

- secretos
- `auth.json`
- `cap_sid`
- `global-state`
- SQLite
- writes live Microsoft/OpenAI/GitHub
- worktrees de `CodexLocal`

## Cambios

- Se tomo `CodexLocal` como base, no solo el split.
- Se inventariaron 10 superficies raiz.
- Se separo el split Cabina en 5 paquetes.
- Se marco `work-dispatch-sdk-gates` como paquete principal.
- Se registro que los worktrees de cabina estan atrasados y sucios.
- Se cruzaron las 4 filas `INDEX_ONLY` contra CodexLocal.
- Se creo `CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv`.
- Se promovieron `remote`, `runtime_parallel`, `sdk` y `sdu_cn` a cadena visible gobernada sin autorizar live.

## Validacion

- Lectura local de indices CodexLocal.
- Lectura local de documentos clave del split.
- `validate_proj_cdx_workbench.ps1`: `PASS`.
- `validate_proj_cdx_sync.ps1`: `PASS`.
- `validate_proj_cdx_operational_chain.ps1`: `PASS`.
- Filas `INDEX_ONLY`: `0`.

## Riesgos

- `CodexLocal` puede contener espejos o splits historicos.
- Si existe repo equivalente en `C:\Users\enzo1\Documents\GitHub`, manda `Documents\GitHub` para operaciones de repo.

## Rollback

Eliminar este hito y retirar las dos matrices de inventario nuevas.

## Proximos carriles

1. Usar `C:\Users\enzo1\Documents\GitHub` como raiz canonica para repos.
2. Mantener `CodexLocal` como evidencia/espejo/split/soporte local.
3. Si se ordena live, abrir orden atomica con target, owner, rollback, postcheck y evidencia.
