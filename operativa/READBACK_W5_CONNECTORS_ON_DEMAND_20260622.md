---
artifact_id: operativa/READBACK_W5_CONNECTORS_ON_DEMAND_20260622.md
categoria: operativa
tipo: readback
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/READBACK_W5_CONNECTORS_ON_DEMAND_20260622.md
etiquetas:
- cabina
- sdu
- w5
- conectores
relacionados:
- operativa/W5_CONNECTORS_ON_DEMAND_MATRIX_20260622.csv
- operativa/W5_CONNECTOR_GATE_TEST_MATRIX_20260622.csv
- operativa/W5_MCP_CONFIG_NO_EXECUTION_MATRIX_20260622.csv
descripcion: Readback W5 de conectores on-demand y gates sin ejecucion live write.
fecha_evento: '2026-06-22'
---

# READBACK W5 CONNECTORS ON DEMAND

## Estado

W5_CONNECTORS_ON_DEMAND_READY

## Sistemas tocados

- Repo local: operativa/*.

## Sistemas no tocados

- GitHub remoto write.
- Dataverse write/PAC live mutation.
- Microsoft/SharePoint write.
- MCP execution.
- OpenAI live/API call.
- Secretos.

## Cambios

- Conectores clasificados como read-ready, config-only, gated o blocked.
- MCP queda explicitamente config-only/no-execution.
- VS Code Insiders queda como control-plane IDE.

## Rollback

Revertir commit W5.

## Stop condition

Detener si un conector intenta live write, MCP execution o secreto sin gate.
