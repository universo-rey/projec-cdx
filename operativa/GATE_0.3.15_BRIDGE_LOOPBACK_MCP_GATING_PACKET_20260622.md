# GATE 0.3.15 BRIDGE LOOPBACK AND MCP REGISTRY GATING

## Estado
GATE_0.3.15_READY_FOR_REMOTE_REPO_PATCH_GATE

## Objetivo
Preparar patch packet para rechazar bind hosts no loopback sin gate y gatear conexiones con `requires_approval=yes` aunque `write_scope=none`.

## Frontera
No bridge execution, no Teams, no MCP live, no Codex Cloud, no push, no PR.

## Postcheck
- Host no loopback falla sin gate.
- `requires_approval=yes` exige gate aunque `write_scope=none`.
