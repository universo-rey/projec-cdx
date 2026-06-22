# ORDER 0.4.6 - MCP Codex checkout depth

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.18

## Fuente
Correo indica que workflows Teams/MCP/Codex Cloud usan checkout shallow y luego hacen diff contra base/head SHA que pueden no estar presentes.

## Target repo
universo-rey/cabina-universal-d

## Target workflows
- sdu-mcp-codex-cloud-dev-preflight.yml
- sdu-teams-identity-dev-preflight.yml

## Objetivo
Preparar patch remoto para asegurar que los preflights Teams/MCP/Codex Cloud puedan resolver base/head antes de ejecutar diff o deteccion de cambios.

## Patch esperado
- `fetch-depth` suficiente.
- O fetch explicito de base/head refs.
- Diff check contra refs presentes.

## Prohibido
- Workflow dispatch.
- Teams live.
- Codex Cloud execution.
- MCP live.
- Push.
- PR.
- Lectura de secretos.

## Owner required
true

## Rollback
Revertir cambios de checkout, fetch-depth o refspec en workflows remotos.

## Postcheck
- Diff commands ven base y HEAD reales en preflight.
- Deteccion de cambios no falla por checkout shallow.
- No se ejecuta workflow dispatch desde este gate.

## Evidencia local
- operativa/GATE_0.3.18_MCP_CODEX_CLOUD_PREFLIGHT_CHECKOUT_PACKET_20260622.md
- operativa/GATE_0.3.18_MCP_CODEX_CLOUD_PREFLIGHT_CHECKOUT_MATRIX_20260622.csv
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.6_READY_FOR_REMOTE_PATCH_AUTHORIZATION
