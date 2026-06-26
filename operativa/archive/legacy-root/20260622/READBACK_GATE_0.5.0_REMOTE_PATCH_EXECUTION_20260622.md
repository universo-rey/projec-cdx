# READBACK GATE 0.5.0 - REMOTE PATCH EXECUTION

## Estado
GATE_0.5.0_REMOTE_PATCH_PREPARED_FOR_PR_OR_BRANCH_READY

## Gate
0.5.0 - Cabina bridge auth token fail-closed

## Target repo
universo-rey/cabina-universal-d

## Target branch
codex/sdu-0.5.0-bridge-auth-fail-closed

## Target commit
d676dcb - fix(bridge): fail closed dev auth placeholder

## Worktree
C:/CEO/worktrees/cabina-universal-d/sdu-0.5.0-bridge-auth-fail-closed

## Problema
El bridge no debe aceptar DEV_AUTH_PLACEHOLDER_ONLY como token valido.

## Cambio realizado
- Se agrego `local-agent-bridge/src/devAuth.mjs`.
- `SDU_BRIDGE_DEV_AUTH` ausente queda como auth no configurada.
- `DEV_AUTH_PLACEHOLDER_ONLY` queda bloqueado como valor no valido.
- Las rutas protegidas rechazan token ausente o placeholder.
- El test local cubre token ausente, placeholder y token sintetico no-placeholder.
- El validador local impide regresar al fallback placeholder.

## Validacion target
- root `npm test`: VALIDATOR_NOT_AVAILABLE_REPO_LOCAL, no existe package.json en raiz target.
- `local-agent-bridge` `npm test`: PASS.
- `scripts/validators/local_agent_bridge_validator.py`: PASS.
- `scripts/validators/sdu_local_bridge_dev_activation_validator.py`: PASS.
- `git diff --check`: PASS.

## Resultado PR
No se abrio PR.

## Rollback
Revertir commit `d676dcb` en la branch `codex/sdu-0.5.0-bridge-auth-fail-closed`.

## Frontera confirmada
- No push.
- No PR.
- No merge.
- No workflow dispatch.
- No live surface.
- No secretos.
- No token print.
- No bridge publico.
- No Dataverse.
- No Power Platform.
- No Teams.
- No Codex Cloud.

## Resultado
SDU_0.5.0_CONTROLLED_REMOTE_PATCH_REALIZED_NO_LIVE
