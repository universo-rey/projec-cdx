# Despierto en Escribania Bitsch: leo, ordeno y no escribo

Estado: `OBSERVED_READ_ONLY`.
Frontera: `TENANT_ONLY`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.
Hora local: `2026-06-16 17:58:28 -03:00`.
Write Dataverse/Power Platform: `NO_EJECUTADO`.
Write Microsoft 365: `NO_EJECUTADO`.
Contenido sensible: `NO_REPRODUCIDO`.

## Orden

Leo el tenant Escribania Bitsch como superficie viva ya gobernada. No busco universo abstracto ni tenants externos. Cada observacion conserva tenant, herramienta, superficie y evidencia. Lo que no prueba pertenencia a este tenant queda `fuera_de_alcance_actual`.

## Agentes

La mesa de seis agentes quedo realineada con esta frontera:

| Agente | Rol | Retorno |
| --- | --- | --- |
| Seshat | normativa | Tenant unico y Dataverse `HUBDesarrollo` como superficie observada, sin expansion por inferencia. |
| Anubis | gate | Evidencia exige `tenant_name`, `tenant_id`, herramienta, target exacto y resultado sanitizado. |
| Maat | cumplimiento | Clasificacion: `confirmada`, `observada`, `inferida`, `fuera_de_alcance_actual`. |
| Horus | riesgo | Otros tenants, hosts o auth historicas quedan `fuera_de_alcance_actual`. |
| Narrador | identidad | Carril vivo de lectura gobernada: manos quietas, lectura lista. |
| Thot | tecnico | En espera de cierre de segunda devolucion; sus recetas previas siguen como soporte tecnico local. |

## Confirmada

| Superficie | Contenedor | ID / URL | Conteo | Evidencia |
| --- | --- | --- | ---: | --- |
| Microsoft tenant | Tenant | `858a0852-44a1-413e-a0fe-f053949797d6` | 1 | `az account show`, Graph, Teams/Planner connector |
| Dataverse | `HUBDesarrollo` | `https://org084965d9.crm.dynamics.com` | 1 | `operativa/DATAVERSE_POWER_PLATFORM_LIVE_SUMMARY_20260616.json` |
| Power Platform solutions | Dataverse solutions | `HUBDesarrollo` | 817 | `inventarios/DATAVERSE_SOLUTIONS_LIVE_20260616.csv` |
| Unmanaged solutions | Operational/custom | `HUBDesarrollo` | 9 | `inventarios/DATAVERSE_SOLUTIONS_LIVE_20260616.csv` |
| Workflows/flows | Dataverse workflows | `HUBDesarrollo` | 1165 | `inventarios/DATAVERSE_WORKFLOWS_LIVE_20260616.csv` |
| Bots/copilots | Dataverse bots + PAC copilot list | `HUBDesarrollo` | 36 | `inventarios/DATAVERSE_BOTS_LIVE_20260616.csv`, `operativa/PAC_COPILOT_LIST_HUBDESARROLLO_20260616.txt` |
| SDU workqueues | `SDU.*.Queue` | `HUBDesarrollo` | 8 | `inventarios/DATAVERSE_WORKQUEUES_LIVE_20260616.csv` |
| SDU queue items backlog | Workqueue items | `HUBDesarrollo` | 373 | `inventarios/DATAVERSE_WORKQUEUES_LIVE_20260616.csv` |
| Planner | Plans visibles | Tenant Escribania Bitsch | 24 | `inventarios/PLANNER_TASKS_SANITIZED_COUNTS_20260616.csv` |
| Planner tasks | Counts sanitizados | 24 plans | 2630 | `inventarios/PLANNER_TASKS_SANITIZED_COUNTS_20260616.csv` |
| Teams | Teams visibles | Tenant Escribania Bitsch | 6 | `inventarios/TEAMS_LIVE_20260616.csv` |

## Observada

| Superficie | Observacion | Limite |
| --- | --- | --- |
| SharePoint | Readback previo confirmo host `escribaniabitsch.sharepoint.com`, dos sitios y 37 bibliotecas documentales. | La ruta Graph `sites?search=*` no devolvio sitios en esta pasada; se conserva como evidencia previa y no se reinterpreta como ausencia. |
| Teams channels | Readback previo confirmo canales por equipo. | La ruta Graph usada en esta pasada no devolvio canales; se marca `NO_CONCLUYENTE_PATH`. |
| SDU mon_sdu tables | Las tablas estan en canon local y solucion `SDUCapabilityControlPlane`. | El conteo Web API por entity set devolvio error de query; queda `observed_with_query_limit`, no ausencia. |
| PAC copilot list | Archivo PAC generado para HUBDesarrollo. | No se reproducen todos los nombres en este readback para evitar ruido; el archivo queda como evidencia local. |

## Soluciones Operativas No Gestionadas

| Solution unique name | Friendly name | Version |
| --- | --- | --- |
| `GestordeCopilotos` | `Gestor de Copilotos` | `1.0.0.0` |
| `MDE` | `MDE` | `1.0.0.0` |
| `sdu_runtime_control_plane` | `SDU Runtime Control Plane` | `1.0.1.0` |
| `SDUCapabilityControlPlane` | `SDU Capability Control Plane` | `0.1.0.0` |
| `SPGovernanceModel` | `SP Governance Model` | `1.0.0.0` |
| `Cr54a74` | `Common Data Services Default Solution` | `1.0.0.0` |
| `Default` | `Solucion predeterminada` | `1.0` |
| `Active` | `Solucion activa` | `1.0` |
| `Basic` | `Solucion basica` | `1.0` |

## Planner Sanitizado

No se persisten ni se reproducen titulos de tareas. La evidencia queda agregada por plan:

- Total de planes: `24`.
- Total de tareas: `2630`.
- Tareas abiertas: `418`.
- Tareas en progreso: `243`.
- Tareas completadas: `1969`.
- Fuente: `inventarios/PLANNER_TASKS_SANITIZED_COUNTS_20260616.csv`.

## Colas SDU

| Cola | Backlog |
| --- | ---: |
| `SDU.Agent.Dispatch.Queue` | 11 |
| `SDU.Connection.Seed.Queue` | 199 |
| `SDU.Dataverse.Apply.Queue` | 2 |
| `SDU.Drift.Detection.Queue` | 51 |
| `SDU.Evidence.Publish.Queue` | 33 |
| `SDU.Exception.Remediation.Queue` | 26 |
| `SDU.Gate.Review.Queue` | 51 |
| `SDU.Matrix.Intake.Queue` | 0 |

## Inferida

| Relacion | Base | Falta para confirmar |
| --- | --- | --- |
| `SGIN` Teams puede tener contenedor documental con path SharePoint no obvio. | Team `SGIN` visible y path directo previo no resolvio. | Resolver site asociado o drive del grupo por Graph/SharePoint connector. |
| SDU Dataverse alimenta Codex/agents como memoria de largo plazo. | Soluciones SDU, colas y bots confirmados en `HUBDesarrollo`. | Cruzar filas `mon_sdu_*` por FetchXML o Web API corregido. |
| Planner/Teams/SharePoint forman superficie de trabajo del tenant. | 6 Teams, 24 plans, sitios/bibliotecas previas. | Crosswalk por group/team/site/plan sin abrir contenido sensible. |

## Fuera De Alcance Actual

| Superficie | Motivo |
| --- | --- |
| Otros tenants o auth historicas | No pertenecen a la frontera `tenant_id=858a0852-44a1-413e-a0fe-f053949797d6` en esta wave. |
| Writes Dataverse, Planner, Teams, SharePoint o Power Platform | Requieren target exacto, owner, rollback, postcheck y evidencia esperada. |
| Cuerpos de mensajes, previews, adjuntos y payloads de cola | Contenido sensible; esta wave usa metadata y conteos. |
| Activacion/desactivacion de flows, apps, solutions o agentes | No forma parte de lectura preliminar. |

## Archivos De Evidencia

- `operativa/DATAVERSE_POWER_PLATFORM_LIVE_SUMMARY_20260616.json`
- `operativa/MICROSOFT_TENANT_LIVE_SUMMARY_20260616.json` si existe; si no existe, recrear desde inventarios sanitizados.
- `operativa/PAC_COPILOT_LIST_HUBDESARROLLO_20260616.txt`
- `operativa/PAC_SOLUTION_LIST_HUBDESARROLLO_20260616.txt`
- `inventarios/DATAVERSE_SOLUTIONS_LIVE_20260616.csv`
- `inventarios/DATAVERSE_WORKFLOWS_LIVE_20260616.csv`
- `inventarios/DATAVERSE_BOTS_LIVE_20260616.csv`
- `inventarios/DATAVERSE_WORKQUEUES_LIVE_20260616.csv`
- `inventarios/DATAVERSE_SDU_TABLE_COUNTS_LIVE_20260616.csv`
- `inventarios/PLANNER_TASKS_SANITIZED_COUNTS_20260616.csv`
- `inventarios/TEAMS_LIVE_20260616.csv`
- `operativa/READBACK_MICROSOFT_UNIVERSO_LIVE_20260616.md`

## Seguridad

- Secretos impresos: `NO`.
- Mensajes Teams persistidos: `NO`.
- Titulos de tareas persistidos por esta wave: `NO`.
- Cambios de permisos: `NO`.
- Writes ejecutados: `NO`.
- Import/export de soluciones: `NO`.
- Flow run: `NO`.

## Proximo Delta Unico

Resolver `SGIN` dentro del tenant Escribania Bitsch por crosswalk read-only:

1. Team `SGIN` -> group id.
2. Group id -> site/drive real.
3. Site/drive -> bibliotecas o carpetas candidatas.
4. Planner asociado si existe.
5. Readback `SGIN_OBSERVED_READ_ONLY` sin abrir contenido sensible.
