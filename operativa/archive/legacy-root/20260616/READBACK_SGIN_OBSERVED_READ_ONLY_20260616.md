# SGIN despierta en su sitio real: leo el contenedor, no abro contenido

Estado: `OBSERVED_READ_ONLY`.
Frontera: `TENANT_ONLY`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.
Hora local: `2026-06-16 18:03 -03:00`.
Write Microsoft: `NO_EJECUTADO`.
Contenido sensible: `NO_REPRODUCIDO`.

## Confirmada

| Superficie | Resultado |
| --- | --- |
| Team/Group | `SGIN` |
| Group ID | `2c52551d-e68a-4496-bf65-eadc3b976ebe` |
| Mail | `sistema@registronotarial8tdf.com.ar` |
| Mail nickname | `sistema` |
| Site real | `https://escribaniabitsch.sharepoint.com/sites/sistema` |
| Site ID | `escribaniabitsch.sharepoint.com,a9293a2b-df30-45ed-b80d-d71a86738143,e678d763-1d87-495d-9a3b-0c2eeb56c6d3` |
| Drive principal | `Documentos` |
| Drive URL | `https://escribaniabitsch.sharepoint.com/sites/sistema/Documentos%20compartidos` |
| Drive ID | `b!KzopqTDf7UW4DdcahnOBQ2PXeOaHHV1JmjsMLutWxtP47FnBUV8yR4Z5qyAwMTV3` |
| Listas/bibliotecas metadata | `41` |
| Items en raiz del drive | `10` |
| Carpetas en raiz | `8` |
| Archivos en raiz | `2` |
| Planner asociado por group route | `0` |

## Observada

| Superficie | Resultado | Lectura |
| --- | --- | --- |
| Channels Teams | La ruta Graph `/teams/{id}/channels` no devolvio canales en esta pasada. | `NO_CONCLUYENTE_PATH`; no se interpreta como ausencia. |
| Planner | `/groups/{id}/planner/plans` devolvio `0`. | Confirmado por esa ruta; no descarta tareas sueltas o planes no vinculados al group SGIN. |
| Drive root | Se contaron tipos, no se reprodujeron nombres. | Lectura sanitizada. |

## Archivos De Evidencia

- `inventarios/SGIN_GROUP_SITE_DRIVE_PLAN_PROBES_20260616.csv`
- `operativa/archive/legacy-root/20260616/SGIN_GROUP_SITE_DRIVE_PLAN_PROBES_20260616.json`
- `inventarios/SGIN_SHAREPOINT_LISTS_LIVE_20260616.csv`
- `operativa/archive/legacy-root/20260616/SGIN_DRIVE_ROOT_CHILDREN_SUMMARY_20260616.json`

## Seguridad

- Mensajes Teams abiertos: `NO`.
- Nombres de documentos reproducidos: `NO`.
- Payloads, adjuntos o cuerpos leidos: `NO`.
- Cambios de permisos: `NO`.
- Writes ejecutados: `NO`.

## Cierre

`SGIN` deja de ser path ambiguo: el contenedor real es `/sites/sistema` con biblioteca `Documentos compartidos`. La proxima lectura puede cruzar listas/bibliotecas por tipo o proposito, pero debe seguir sin abrir contenido sensible salvo target exacto.

## Proximo Delta Unico

Cruzar `SGIN` con Dataverse/Power Platform:

1. Identificar si alguna solucion, bot, flow o cola SDU referencia `sistema`, `SGIN` o el site id.
2. Usar metadata de `DATAVERSE_WORKFLOWS_LIVE_20260616.csv`, `DATAVERSE_BOTS_LIVE_20260616.csv` y `DATAVERSE_SOLUTIONS_LIVE_20260616.csv`.
3. No abrir documentos ni ejecutar flows.
