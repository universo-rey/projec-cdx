# READBACK GATE 0.5.1 - BRIDGE LOOPBACK MCP GATING

## Estado
SDU_0.5.1_CONTROLLED_REMOTE_PATCH_REALIZED_NO_LIVE

## Gate
0.5.1 - Cabina bridge loopback + MCP gating

## Target repo
universo-rey/cabina-universal-d

## Target branch
codex/sdu-0.5.1-bridge-loopback-mcp-gating

## Target commit
8fe58a7 - fix(bridge): enforce loopback and mcp approval gating

## Worktree
C:/CEO/worktrees/cabina-universal-d/sdu-0.5.1-bridge-loopback-mcp-gating

## Cambio realizado
- `SDU_BRIDGE_BIND_HOST` se valida antes de iniciar el listener.
- Hosts no-loopback como `0.0.0.0` quedan bloqueados.
- `127.0.0.1` y `localhost` quedan permitidos.
- `requires_approval=yes` implica `gated=true` aunque `write_scope=none`.
- El test local cubre host no-loopback, loopback permitido y MCP approval-required gated.
- El validador local impide regresar al gating condicionado por write scope.

## Validacion target
- `local-agent-bridge` `npm test`: PASS.
- `scripts/validators/local_agent_bridge_validator.py`: PASS.
- `scripts/validators/sdu_local_bridge_dev_activation_validator.py`: PASS.
- `scripts/validators/mcp_connection_registry_validator.py`: PASS.
- `git diff --check`: PASS.

## Resultado PR
No se abrio PR.

## Rollback
Revertir commit `8fe58a7` en la branch `codex/sdu-0.5.1-bridge-loopback-mcp-gating`.

## Frontera confirmada
- No push.
- No PR.
- No workflow dispatch.
- No live surface.
- No secretos.
- No bridge publico.
- No inferencia multirepo.

## Resultado
SDU_0.5.1_CONTROLLED_REMOTE_PATCH_REALIZED_NO_LIVE
