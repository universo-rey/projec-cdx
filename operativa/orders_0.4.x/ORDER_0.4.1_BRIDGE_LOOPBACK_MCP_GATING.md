# ORDER 0.4.1 - Bridge loopback MCP gating

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.15

## Fuente
Correo indica que `SDU_BRIDGE_BIND_HOST=0.0.0.0` podria exponer el bridge en interfaz publica, y que conexiones con `requires_approval=yes` deben quedar gated aunque `write_scope=none`.

## Target repo
universo-rey/cabina-universal-d

## Target files probables
- local-agent-bridge/src/server.mjs
- local-agent-bridge/src/mcpRegistry.mjs

## Objetivo
Preparar patch remoto para proteger el bind host del bridge y asegurar que MCP respete aprobacion obligatoria.

## Cambios esperados
- Rechazar bind host no-loopback salvo gate explicito.
- Ignorar override peligroso sin gate.
- `requires_approval === "yes"` implica `gated=true`.
- Test de `0.0.0.0` bloqueado.
- Test MCP approval-required gated.

## Prohibido
- Ejecutar bridge.
- Abrir puerto.
- Teams live.
- MCP live.
- Codex Cloud.
- Hacer push.
- Abrir PR.
- Ejecutar workflow dispatch.

## Owner required
true

## Rollback
Revertir patch remoto en configuracion bridge/MCP y tests asociados.

## Postcheck
- Host no-loopback falla sin gate explicito.
- Override peligroso no abre bridge sin gate.
- `requires_approval=yes` queda gated aunque `write_scope=none`.
- No hay bridge execution, Teams live, MCP live ni Codex Cloud.

## Evidencia local
- operativa/archive/legacy-root/20260622/GATE_0.3.15_BRIDGE_LOOPBACK_MCP_GATING_PACKET_20260622.md
- operativa/archive/legacy-root/20260622/GATE_0.3.15_BRIDGE_LOOPBACK_MCP_GATING_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.1_READY_FOR_REMOTE_PATCH_AUTHORIZATION
