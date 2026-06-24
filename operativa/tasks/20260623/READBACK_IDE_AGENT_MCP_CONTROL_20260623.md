---
artifact_id: operativa/tasks/20260623/READBACK_IDE_AGENT_MCP_CONTROL_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: IDE_AGENT_MCP_CONTROL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_AGENT_MCP_CONTROL_20260623.md
etiquetas:
  - vscode-insiders
  - agent-tool-hub
  - mcp
  - local-only
  - productiva
relacionados:
  - operativa/tasks/20260623/IDE_AGENT_MCP_CONTROL_MATRIX_20260623.csv
  - tools/ceo-ide-agent-map.ps1
  - tools/ceo-ide-mcp-status.ps1
descripcion: Readback breve del carril IDE_AGENT_MCP_CONTROL para usar VS Code Insiders como hub de agentes, MCP y herramientas sin ejecucion live.
---

# READBACK IDE AGENT MCP CONTROL

## Estado

IDE_AGENT_MCP_CONTROL_READY

## Capacidad producida

IDE Agent Tool Hub.

## Comandos candidatos

- `tools/ceo-ide-agent-map.ps1 -Json`
- `tools/ceo-ide-mcp-status.ps1 -Json`

## Resultado

- Agentes configurados desde contrato local: 5.
- Tools `ceo-*` mapeadas: 23.
- Runners IDE invocables: 4.
- MCP configs observadas: 1.
- MCP servers configurados: 1.
- MCP servers broken: 0.
- MCP execution: no ejecutado.
- Servidor MCP observado: `agent-pipeline`.
- Comando MCP observado: `node`.
- Valores de entorno MCP: no impresos; solo keys.

## Tasks agregadas

- `CEO IDE: Agent Map`.
- `CEO IDE: MCP Status`.
- `CEO IDE: Agent MCP Hub`.

## Brecha controlada

Las matrices `.agents/codex` pedidas por la skill de gobierno no estan disponibles en este workspace. Quedan como `NO_DISPONIBLE_LOCAL`, sin bloquear el hub IDE porque existe contrato local `.cabina`.

## Frontera

- No MCP execution.
- No agent live dispatch.
- No secretos.
- No push.
- No PR.
- No live.
- No stage.
- No commit.

## Proxima accion ejecutable

Ejecutar task `CEO IDE: Agent MCP Hub` desde VS Code Insiders.
