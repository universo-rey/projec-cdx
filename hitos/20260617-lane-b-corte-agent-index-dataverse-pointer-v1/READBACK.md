# Readback Lane B Corte Agent Index Dataverse Pointer v1

Estado: `DELTA_APLICADO`

## Decision

El atomo `INDICE_CORTE_AGENTES_20260617.md` queda preparado para registrarse en Dataverse como puntero de metadata. La finalidad es que Dataverse contenga memoria estructural y que los agentes consuman el indice sin depender de una busqueda visual en SharePoint.

## Fan-In

| Agente | Aporte integrado |
| --- | --- |
| `cdf.project_manager_delegador` | Delta separado: puntero Dataverse ahora; Home binding despues. |
| `cdf.prompt_router` | Ruta a `connection_control_guard` y `evidence_validator`. |
| `cdf.connection_control_guard` | Metadata-only, sin payload documental ni flow run. |
| `cdf.microsoft_graph_guard` | SharePoint ya publicado, sin editar `Home.aspx`. |
| `cdf.evidence_validator` | Hash, URL, item id, rollback y postcheck. |
| `cdf.solution_architect` | Siguiente movimiento unico: cerrar puntero y luego elegir binding UI. |

## Canonical IDs

- Source: `sharepoint:corte-agent-index:20260617:v1`
- Evidence: `evidence:sharepoint:corte-agent-index:20260617:v1`

## Ejecutado

- Dataverse source pointer: `sharepoint:corte-agent-index:20260617:v1`.
- Dataverse evidence pointer: `evidence:sharepoint:corte-agent-index:20260617:v1`.
- Mode: `LIVE_METADATA_POINTER_WRITE`.
- Postcheck: `source_count=1`, `evidence_count=1`.
- Resultado: `operativa/archive/legacy-root/20260617/DATAVERSE_PROMOTION_INDICE_CORTE_AGENTES_20260617.json`.

## No Ejecutado

- No `Home.aspx`.
- No permisos.
- No flow run.
- No contenido documental en Dataverse.

## Siguiente Delta

Elegir binding UI/surface posterior para que `Home.aspx` u otra superficie visible enlace el indice ya publicado y registrado.
