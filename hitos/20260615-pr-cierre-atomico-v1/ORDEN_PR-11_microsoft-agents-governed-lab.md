# Orden Atomica PR 11

## Estado de orden

`PENDIENTE_GOBERNADO`

## Objetivo

Cerrar el PR `11` solo cuando la corrida de validacion deje de estar inestable y el conjunto de checks vuelva a un estado mergeable gobernado.

## Target Exacto

- repo: `universo-rey/microsoft-agents-governed-lab`
- PR: `#11`
- base: `main`
- head: `dependabot/npm_and_yarn/npm-all-e7555ea673`
- head_oid: `c596e0582c2d37a6f2ba314757c22edcd47d2823`
- url: `https://github.com/universo-rey/microsoft-agents-governed-lab/pull/11`

## Owner

- `rey.repo_cartographer`

## Precheck

- `mergeable=MERGEABLE`
- `mergeStateStatus=UNSTABLE`
- check `build-node (20)` con conclusion `FAILURE`
- el resto de checks paso o quedo cancelado por la misma corrida

## Rollback

- No mergear hasta que el pipeline quede estable.
- Si se avanzara por error, revertir el merge commit y volver al head `c596e0582c2d37a6f2ba314757c22edcd47d2823`.

## Postcheck

- `gh pr view 11 --json mergeable,mergeStateStatus,statusCheckRollup,headRefOid`
- todos los checks relevantes en `SUCCESS`
- `mergeStateStatus=CLEAN`

## Evidencia

- `outputs/live_repo_review_20260615/READBACK.md`
- `outputs/live_repo_review_20260615/LIVE_REPO_REVIEW_20260615.csv`
- `gh pr view 11 --json headRefOid,baseRefOid,mergeable,mergeStateStatus,statusCheckRollup`

## Stop Condition

`ci_inestable` o `mergeable_regressed`
