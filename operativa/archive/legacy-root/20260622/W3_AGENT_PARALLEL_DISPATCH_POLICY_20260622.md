---
artifact_id: operativa/archive/legacy-root/20260622/W3_AGENT_PARALLEL_DISPATCH_POLICY_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/W3_AGENT_PARALLEL_DISPATCH_POLICY_20260622.md
etiquetas:
- cabina
- agentes
- dispatch
- w3
relacionados:
- operativa/archive/legacy-root/20260622/W3_AGENT_CHAIN_CARRIL_ASSIGNMENT_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/W3_AGENT_TOOL_GATE_BOUNDARY_MATRIX_20260622.csv
descripcion: Politica W3 para despacho paralelo seguro de agentes por carril.
fecha_evento: '2026-06-22'
---

# W3 AGENT PARALLEL DISPATCH POLICY

## Politica

Despachar en paralelo solo carriles independientes y read-only. Serializar cualquier write por bloque.

## Permitido

- Lectura/clasificacion independiente.
- Fan-in con matriz y readback.
- Validacion comun por runner IDE.

## Bloqueado

- Dos agentes editando el mismo archivo.
- Live/MCP/secretos.
- Agente sin return shape o stop condition.
