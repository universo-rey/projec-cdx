# SGIN cruza con Dataverse: matches de metadata, no ejecucion

Estado: `OBSERVED_READ_ONLY`.
Frontera: `TENANT_ONLY`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.
Hora local: `2026-06-16 18:05 -03:00`.
Write Dataverse/Power Platform: `NO_EJECUTADO`.
Write SharePoint/Teams/Planner: `NO_EJECUTADO`.
Contenido sensible: `NO_REPRODUCIDO`.

## Fuente

Parto de `SGIN` ya resuelto:

- Group/team: `2c52551d-e68a-4496-bf65-eadc3b976ebe`.
- Site real: `https://escribaniabitsch.sharepoint.com/sites/sistema`.
- Drive: `Documentos compartidos`.
- Site metadata: 41 listas/bibliotecas.
- Drive root: 10 items contados sin nombres.

## Cruce Ejecutado

Se cruzaron patrones `SGIN`, `sistema`, `sdu`, `sharepoint`, `SPGovernance`, `GestordeCopilotos` y `MDE` contra inventarios vivos locales:

- `inventarios/DATAVERSE_SOLUTIONS_LIVE_20260616.csv`
- `inventarios/DATAVERSE_WORKFLOWS_LIVE_20260616.csv`
- `inventarios/DATAVERSE_BOTS_LIVE_20260616.csv`
- `inventarios/DATAVERSE_WORKQUEUES_LIVE_20260616.csv`

No se consulto contenido documental. No se ejecuto flow. No se abrieron payloads de cola.

## Confirmada

| Fuente | Matches |
| --- | ---: |
| Dataverse solutions | 12 |
| Dataverse workflows | 17 |
| Dataverse workqueues | 8 |
| Dataverse bots | 0 |

Evidencia: `inventarios/SGIN_DATAVERSE_POWER_PLATFORM_METADATA_CROSSWALK_20260616.csv`.

## Matches Relevantes

| Familia | Superficie | Lectura |
| --- | --- | --- |
| SharePoint | `msdyn_SharePointIntegration`, `msdyn_SharePointAuthInfraComponents`, anchors Power Apps SharePoint | Confirma capacidades SharePoint/Power Platform presentes en el ambiente. |
| Sistema | `msdyn_SystemAppActions`, `System` | Match lexical con `sistema`; no prueba relacion especifica con site `/sites/sistema`. |
| SDU | `sdu_runtime_control_plane`, `SDUCapabilityControlPlane` | Control plane SDU presente. |
| SP governance | `SPGovernanceModel` | Modelo de gobierno SharePoint presente. |
| Copilots | `GestordeCopilotos` | Solucion de gestion de copilots presente. |
| Flows SDU | `SDU_Process_*`, `SDU_Work_Queue_*`, `SDU_OpenAI_Assisted_Metadata_Classifier` | Runtime SDU visible por metadata de workflows. |
| Colas SDU | 8 colas `SDU.*.Queue` | Backlog total conocido: 373 items. |

## Observada

| Punto | Estado |
| --- | --- |
| Relacion directa SGIN -> flow | `NO_CONFIRMADA` por este cruce. |
| Relacion directa SGIN -> cola SDU | `NO_CONFIRMADA` por este cruce. |
| Relacion directa SGIN -> bot/copilot | `NO_CONFIRMADA` por este cruce. |
| Relacion directa SGIN -> SPGovernanceModel | `PROBABLE_POR_DOMINIO`, requiere probe exacto. |

## Fuera De Alcance Actual

- Abrir documentos del drive SGIN.
- Ejecutar, activar o desactivar workflows.
- Leer payloads de workqueue items.
- Crear mappings, tareas o registros.
- Cambiar permisos o conectores.

## Proximo Delta Unico

Resolver el vinculo exacto `SGIN site/drive -> SPGovernanceModel/SDU` por metadata estructurada:

1. Buscar componentes de solucion que referencien SharePoint/site/list sin ejecutar nada.
2. Buscar workflows con nombres SDU/SharePoint y revisar solo metadata de definicion si el conector lo permite sin secretos.
3. Si aparece payload o conexion sensible, detener en `en_espera_de_cierre`.
