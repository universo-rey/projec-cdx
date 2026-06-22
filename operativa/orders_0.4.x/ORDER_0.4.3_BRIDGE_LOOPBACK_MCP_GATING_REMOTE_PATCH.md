# ORDER 0.4.3 - Bridge loopback and MCP gating remote patch

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.15

## Repo / superficie
universo-rey/cabina-universal-d / GitHub code

## Objetivo
Patch remoto para rechazar bind hosts no loopback sin gate y gatear conexiones `requires_approval=yes`.

## Owner required
true

## Rollback
Revertir patch de configuracion bridge/MCP.

## Postcheck
- Host no loopback falla sin gate.
- `requires_approval=yes` exige gate aunque `write_scope=none`.
- No se abre bridge, Teams, MCP live ni Codex Cloud.

## Evidencia
- operativa/GATE_0.3.15_BRIDGE_LOOPBACK_MCP_GATING_PACKET_20260622.md
- operativa/GATE_0.3.15_BRIDGE_LOOPBACK_MCP_GATING_MATRIX_20260622.csv

## Estado final
READY_FOR_REMOTE_PATCH_AUTHORIZATION
