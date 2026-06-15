# Orden Atomica PR 155

## Estado de orden

`PENDIENTE_GOBERNADO`

## Objetivo

Cerrar el PR `155` de `cabina-universal-d` solo cuando deje de estar en conflicto y el postcheck confirme estado gobernado.

## Target Exacto

- repo: `universo-rey/cabina-universal-d`
- PR: `#155`
- base: `main`
- head: `codex/cabina-universal-d-coordination-20260611`
- head_oid: `703de63b2b9cbce057dc0b52ac7aca9fa15c9064`
- url: `https://github.com/universo-rey/cabina-universal-d/pull/155`

## Owner

- `rey.repo_cartographer`

## Precheck

- `mergeable=CONFLICTING`
- `mergeStateStatus=DIRTY`
- checks observados en verde, pero con conflicto de merge vigente

## Rollback

- No mergear hasta resolver conflicto.
- Si un merge llega a ocurrir por error, revertir el merge commit en `main` y restaurar la referencia del head `703de63b2b9cbce057dc0b52ac7aca9fa15c9064`.

## Postcheck

- `gh pr view 155 --json mergeable,mergeStateStatus,baseRefName,headRefName,headRefOid`
- `mergeable=MERGEABLE`
- `mergeStateStatus=CLEAN`
- diff revisado contra `main`
- checks sin regresion

## Evidencia

- `outputs/live_repo_review_20260615/READBACK.md`
- `outputs/live_repo_review_20260615/LIVE_REPO_REVIEW_20260615.csv`
- `gh pr view 155 --json headRefOid,baseRefOid,mergeable,mergeStateStatus,statusCheckRollup`

## Stop Condition

`mergeable_not_resolved` o `checks_regressed`
