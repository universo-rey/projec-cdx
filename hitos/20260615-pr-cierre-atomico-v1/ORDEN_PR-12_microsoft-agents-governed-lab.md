# Orden Atomica PR 12

## Estado de orden

`PREPARADO`

## Objetivo

Cerrar el PR `12` con merge gobernado una vez que se emita la orden de write correspondiente.

## Target Exacto

- repo: `universo-rey/microsoft-agents-governed-lab`
- PR: `#12`
- base: `main`
- head: `dependabot/nuget/samples/dotnet/Agent-Framework/nuget-all-659385cc98`
- head_oid: `25fff81a754286d72af41a92f6c084aa7e30890d`
- url: `https://github.com/universo-rey/microsoft-agents-governed-lab/pull/12`

## Owner

- `rey.repo_cartographer`

## Precheck

- `mergeable=MERGEABLE`
- `mergeStateStatus=CLEAN`
- checks en verde
- PR no draft

## Rollback

- Si se ejecuta merge, el rollback es revertir el merge commit o restaurar el head `25fff81a754286d72af41a92f6c084aa7e30890d`.
- Mientras no haya write, no se toca el branch.

## Postcheck

- `gh pr view 12 --json mergeable,mergeStateStatus,statusCheckRollup,headRefOid`
- `mergeStateStatus=CLEAN`
- checks sin regresion
- PR cerrado solo si merge remoto fue confirmado

## Evidencia

- `outputs/live_repo_review_20260615/READBACK.md`
- `outputs/live_repo_review_20260615/LIVE_REPO_REVIEW_20260615.csv`
- `gh pr view 12 --json headRefOid,baseRefOid,mergeable,mergeStateStatus,statusCheckRollup`

## Stop Condition

`write_order_missing` o `checks_regressed`
