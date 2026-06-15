# Orden Atomica PR 43

## Estado de orden

`PENDIENTE_GOBERNADO`

## Objetivo

Cerrar el PR `43` solo despues de salir de draft y mantener checks verdes.

## Target Exacto

- repo: `universo-rey/organizacion`
- PR: `#43`
- base: `main`
- head: `codex/service-design-documental-20260605`
- head_oid: `fa5e5f6979e3d9dee2c69caa7ef4b8fd2e0bc300`
- url: `https://github.com/universo-rey/organizacion/pull/43`

## Owner

- `rey.repo_cartographer`

## Precheck

- `mergeable=MERGEABLE`
- `mergeStateStatus=CLEAN`
- `draft=true`
- checks en verde

## Rollback

- No mergear mientras siga draft.
- Si se confundiera la ruta y se cerrara por error, reabrir el PR y restaurar la rama `codex/service-design-documental-20260605`.

## Postcheck

- `gh pr view 43 --json isDraft,mergeable,mergeStateStatus,statusCheckRollup,headRefOid`
- `isDraft=false`
- `mergeStateStatus=CLEAN`
- checks sin regresion

## Evidencia

- `outputs/live_repo_review_20260615/READBACK.md`
- `outputs/live_repo_review_20260615/LIVE_REPO_REVIEW_20260615.csv`
- `gh pr view 43 --json headRefOid,baseRefOid,mergeable,mergeStateStatus,isDraft,statusCheckRollup`

## Stop Condition

`draft_not_cleared` o `checks_regressed`
