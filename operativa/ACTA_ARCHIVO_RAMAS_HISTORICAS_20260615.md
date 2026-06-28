# Acta Archivo Ramas Historicas 20260615

## Estado

- Fecha: 2026-06-15
- Alcance: lista corta de ramas historicas para archivo
- Resultado: `RAMAS_HISTORICAS_REGISTRADAS`
- Regla aplicada: no borrar, no mover, no tocar remotos salvo resolucion ya ejecutada

## Repos

### cabina-universal-d

- `codex/agent-global-dirty-reconciliation-20260605`
- `codex/agent-global-operability-next-lane-execution-20260605`
- `codex/agent-naming-rationalization-20260605`
- `codex/codex-cloud-capability-audit-20260605`
- `codex/full-repo-validation-followups-20260605`
- `codex/process-manuals-framework-20260605`
- `codex/process-rescue-framework-20260605`
- `codex/retrospective/dataverse-atomic-segment-skill-20260608`
- `codex/session-worktree-parking-20260605`

### organizacion

- `codex/service-design-documental-20260605`

## Lectura

- Las ramas listadas arriba no se eliminan.
- Quedan como historial operativo o soporte de worktree.
- La superficie operativa activa sigue siendo `main` en los 13 repos confirmados.

## Validacion

- Repos confirmados: `13`
- Repos en `main`: `13/13`
- Repos limpios: `13/13`
- `organizacion` ya fue publicada en `origin/main`
- Matriz compañera: [MATRIZ_RAMAS_HISTORICAS_20260615.xlsx](C:/Users/enzo1/PROJEC%20CDX/operativa/MATRIZ_RAMAS_HISTORICAS_20260615.xlsx)

## Riesgo

- Riesgo bajo: solo inventario documental, sin write destructivo.

## Rollback

- Retirar esta acta si se decide no conservar el archivo de ramas historicas.

## Stop Condition

- Detener si se pide borrar ramas o limpiar worktrees sin orden explicita.

## Proximos Carriles

- Si hace falta, convertir esta lista en matriz por repo con `branch`, `estado`, `motivo` y `accion`.
