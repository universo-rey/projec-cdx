# SDU G6 DocumentLocation Automation Blueprint

Mode: READ_ONLY_DESIGN
Dictamen: BLUEPRINT_READY_NO_WRITES
Environment: HUBDesarrollo
Dataverse URL: https://org084965d9.crm.dynamics.com

## Alcance

Disenar el flujo automatico para:

registro -> carpeta SharePoint -> sharepointdocumentlocation -> validacion watchdog

Este documento no implementa el flow, no ejecuta operaciones remotas y no habilita scheduler. Es un plano para G6.2 bajo owner gate formal.

## Estado Base Confirmado

- SharePointSite root creado: `52bda16d-2777-4304-9f5f-2cfdcb3ce4b0`
- SharePoint site real: `https://escribaniabitsch.sharepoint.com/sites/sistema`
- Sitio: `SGIN`
- Biblioteca: `BIB_DOC_Expediente`
- DocumentLocation POC creado: `ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d`
- POC regarding probado: `adx_portalcomment/f22fbb06-77bc-42ff-8b97-0efc0cfb31d2`
- Watchdog validado: `YELLOW`, `locationsReviewed=1`
- Clasificacion aceptada: `SITE_COLLECTION_URL_OPTIONAL`

## Resolucion De Entidad Origen

La entidad de negocio deseada para el flow es el registro documental operativo, por ejemplo un expediente. En el sistema real ya observado, `sharepointdocumentlocation.regardingobjectid` no acepto tablas `cr3c_*` durante G5. Los targets validos detectados incluyeron `adx_portalcomment`, que fue usado como POC y quedo probado end-to-end.

Decision para G6.2:

- Opcion A, preferida si existe metadata valida: usar la tabla real de expediente solo si aparece como target valido de `sharepointdocumentlocation.regardingobjectid`.
- Opcion B, compatible con el estado probado: crear o reutilizar un registro tecnico `adx_portalcomment` como ancla documental por expediente, y registrar el backreference al expediente en la bitacora/tabla de control que se defina bajo gate separado.

Stop condition:

- Si la entidad de expediente no aparece en los targets de `regardingobjectid` y no se aprueba ancla tecnica, el flow no debe crear carpeta ni DocumentLocation.

## Trigger Candidate

Trigger recomendado:

- Dataverse: row added or modified.
- Tabla: entidad documental origen aprobada por el gate de metadata.
- Condicion: solo cuando el registro tenga identidad estable y solicite carpeta documental.

Filtro operativo sugerido:

- `document_link_requested = true`
- `document_location_status` en `Pending` o vacio
- `expediente_key` no vacio
- registro activo

No se recomienda disparar por cualquier update de la fila. El trigger debe depender de atributos acotados para evitar duplicados y ruido.

## Mapping Hacia SharePoint

Fuente minima esperada:

- `source_entity_logical_name`
- `source_entity_set_name`
- `source_row_id`
- `expediente_key` o clave documental estable
- `display_name` opcional, sanitizado
- `createdon` o fecha documental para particion anual

Destino:

- Parent `sharepointsite`: `52bda16d-2777-4304-9f5f-2cfdcb3ce4b0`
- Library: `BIB_DOC_Expediente`
- RelativeUrl base: `BIB_DOC_Expediente`

Estructura de ruta recomendada:

```text
BIB_DOC_Expediente/<yyyy>/<expediente_key>
```

Reglas de path:

- Usar una clave estable, no nombres personales.
- Sanitizar caracteres no validos para SharePoint.
- Mantener longitud total por debajo del limite de SharePoint.
- No cambiar el path luego de crear el DocumentLocation salvo gate explicito.
- Si hay colision, bloquear y enviar a revision; no agregar sufijos automaticos sin politica.

## Preflight Obligatorio

Antes de cualquier write remoto en G6.2:

1. Validar que el flow corre en HUBDesarrollo.
2. Validar que el parent `sharepointsite` existe y apunta a SGIN.
3. Resolver metadata de la entidad origen y su `EntitySetName`.
4. Confirmar que la entidad origen es target valido de `sharepointdocumentlocation.regardingobjectid`.
5. Leer el registro origen y confirmar que esta activo.
6. Construir el `relativeurl` y guardarlo en preview.
7. GET Graph para confirmar sitio, drive y carpeta base.
8. GET Dataverse para confirmar que no existe DocumentLocation equivalente.
9. Owner gate G6.2 antes de crear carpeta o DocumentLocation.

## GET Before POST

Carpeta SharePoint:

```text
GET /sites/{site-id}/drives
GET /drives/{drive-id}/root:/BIB_DOC_Expediente/<yyyy>/<expediente_key>
```

Si existe, reutilizar. Si no existe, crear solo bajo gate G6.2.

DocumentLocation:

```text
GET /api/data/v9.2/sharepointdocumentlocations?
  $select=sharepointdocumentlocationid,name,relativeurl,_parentsiteorlocation_value,_regardingobjectid_value&
  $filter=_parentsiteorlocation_value eq 52bda16d-2777-4304-9f5f-2cfdcb3ce4b0
    and relativeurl eq 'BIB_DOC_Expediente/<yyyy>/<expediente_key>'
```

Luego filtrar por `_regardingobjectid_value == <source_row_id>` si la consulta devuelve candidatos.

Resultado:

- Si existe una ubicacion equivalente: no crear otra; registrar `REUSED_EXISTING_DOCUMENTLOCATION`.
- Si no existe: permitir un unico POST bajo gate.

## Payload DocumentLocation

Payload logico para G6.2, sin `absoluteurl`:

```json
{
  "name": "<expediente_key>_DOCUMENT_LOCATION",
  "servicetype": 0,
  "locationtype": 0,
  "relativeurl": "BIB_DOC_Expediente/<yyyy>/<expediente_key>",
  "parentsiteorlocation_sharepointsite@odata.bind": "/sharepointsites(52bda16d-2777-4304-9f5f-2cfdcb3ce4b0)",
  "regardingobjectid_<source_entity>@odata.bind": "/<source_entity_set>(<source_row_id>)"
}
```

Reglas:

- No enviar `absoluteurl`.
- No enviar `sitecollectionurl`.
- No hardcodear el navigation property de `regardingobjectid`; resolverlo por metadata.
- No hacer segundo POST si el primero queda en estado ambiguo. Primero hacer readback.

## Flujo Textual

```text
Dataverse trigger
  -> crear correlation_id
  -> leer registro origen
  -> validar metadata regardingobjectid
  -> construir path canonico
  -> GET SharePoint folder
      -> si existe: reuse
      -> si falta: create folder bajo gate G6.2
  -> GET existing DocumentLocation
      -> si existe: reuse
      -> si falta: POST unico relativeurl-only
  -> RetrieveAbsoluteAndSiteCollectionUrl()
  -> registrar evidencia
  -> ejecutar watchdog gobernado
  -> clasificar HEALTHY/YELLOW/DEGRADED
  -> cerrar con audit log
```

## Manejo De Errores

| Caso | Accion |
| --- | --- |
| Entidad origen no valida para `regardingobjectid` | Bloquear antes de SharePoint y Dataverse writes |
| Registro origen no existe o esta inactivo | Bloquear y registrar `SOURCE_NOT_AVAILABLE` |
| Carpeta ya existe | Reutilizar, no crear duplicado |
| DocumentLocation ya existe | Reutilizar, no crear duplicado |
| Graph no resuelve sitio o drive | Bloquear antes de DocumentLocation |
| Dataverse rechaza POST | No reintentar automaticamente; guardar respuesta y readback |
| Timeout despues de POST | Hacer GET de duplicado por path/correlation antes de cualquier retry |
| Watchdog devuelve YELLOW | No bloquear la operacion si Graph y DocumentLocation estan OK; abrir revision |
| Watchdog devuelve DEGRADED | Marcar operacion como `NEEDS_REVIEW` y no activar scheduler |

Rollback:

- No borrar automaticamente carpetas ni DocumentLocations.
- Si se requiere rollback, debe ser un gate separado con ID exacto, evidencia y owner approval.

## Retry Policy Controlada

- GET Graph/Dataverse: hasta 3 intentos con backoff corto para 429/5xx.
- Create folder: un intento despues de GET. Si devuelve conflict, hacer GET y reutilizar.
- POST DocumentLocation: un intento.
- Si POST DocumentLocation falla por 429/5xx o timeout, no repetir sin readback de duplicado.
- No hay retry para 4xx funcionales como metadata invalida, bind invalido o payload rechazado.

## Logging Requerido

Cada ejecucion debe emitir una fila/evento con:

- `correlation_id`
- `flow_run_id`
- `environment_url`
- `source_entity`
- `source_entity_set`
- `source_row_id`
- `sharepointsiteid`
- `library`
- `relativeurl`
- `folder_exists_before`
- `folder_created`
- `documentlocation_exists_before`
- `documentlocation_created`
- `sharepointdocumentlocationid`
- `retrieve_absolute_url`
- `sitecollectionurl_empty`
- `watchdog_health`
- `watchdog_evidence`
- `classification`
- `attempt_count`
- `error_code`
- `error_message_sanitized`
- `createdon_utc`

Destino de logging recomendado para G6.2:

- Power Automate run history.
- JSONL local o Dataverse log tecnico bajo gate separado.
- Evidencia watchdog en `C:\CEO\watchdog\evidence`.

## Integracion Con Watchdog

El flow cloud no debe asumir que puede ejecutar directamente `C:\CEO\watchdog\watchdog-sharepoint-link.ps1`. La integracion segura es:

1. El flow registra `correlation_id`, `relativeurl` y `sharepointdocumentlocationid`.
2. Un runner local gobernado ejecuta el watchdog despues del write.
3. El resultado se une por `sharepointdocumentlocationid` o `relativeurl`.
4. El cierre acepta:
   - `HEALTHY`
   - `YELLOW` con Graph OK y `SITE_COLLECTION_URL_OPTIONAL`
5. El cierre bloquea promocion si:
   - `locationsReviewed` no aumenta o no incluye el target.
   - Graph no encuentra carpeta.
   - `AbsoluteUrl` esta vacio.

Comando de validacion local:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\CEO\watchdog\watchdog-sharepoint-link.ps1" `
  -DataverseUrl "https://org084965d9.crm.dynamics.com" `
  -UseAzureCliToken
```

## Queries Necesarias

Metadata `sharepointdocumentlocation`:

```text
GET /api/data/v9.2/EntityDefinitions(LogicalName='sharepointdocumentlocation')
GET /api/data/v9.2/EntityDefinitions(LogicalName='sharepointdocumentlocation')/Attributes/Microsoft.Dynamics.CRM.LookupAttributeMetadata
```

Metadata entidad origen:

```text
GET /api/data/v9.2/EntityDefinitions(LogicalName='<source_entity>')
```

Parent site:

```text
GET /api/data/v9.2/sharepointsites(52bda16d-2777-4304-9f5f-2cfdcb3ce4b0)
```

Registro origen:

```text
GET /api/data/v9.2/<source_entity_set>(<source_row_id>)
```

DocumentLocation existente:

```text
GET /api/data/v9.2/sharepointdocumentlocations?$select=sharepointdocumentlocationid,name,relativeurl,_parentsiteorlocation_value,_regardingobjectid_value&$filter=relativeurl eq '<relativeurl>'
```

RetrieveAbsolute:

```text
GET /api/data/v9.2/sharepointdocumentlocations(<sharepointdocumentlocationid>)/Microsoft.Dynamics.CRM.RetrieveAbsoluteAndSiteCollectionUrl()
```

Graph:

```text
GET /sites/escribaniabitsch.sharepoint.com:/sites/sistema
GET /sites/{site-id}/drives
GET /drives/{drive-id}/root:/BIB_DOC_Expediente/<yyyy>/<expediente_key>
```

## Puntos De Control SDU

- `POLICY_STRICT`: default deny.
- `OWNER_GATE_G6_2`: requerido antes de crear flow o writes reales.
- `MULTI_ACTOR`: requerido para pasar a live real.
- `PREFLIGHT`: metadata, target, path, duplicate check.
- `SINGLE_POST`: un DocumentLocation por registro y path.
- `EVIDENCE`: preview, payload, response, readback y watchdog evidence.
- `POSTCHECK`: RetrieveAbsolute + Graph + watchdog.
- `NO_SCHEDULER`: no activar recurrencia hasta gate final.
- `NO_PUSH_PR`: no publicar sin cierre separado.

## Riesgos Identificados

- La tabla real de expediente podria no ser target valido de `regardingobjectid`.
- Un flow cloud no puede ejecutar el watchdog local sin un puente gobernado.
- Concurrencia: dos updates del mismo registro pueden intentar crear la misma carpeta.
- Path con datos sensibles o nombres cambiantes puede generar deuda documental.
- Permisos Graph/Dataverse pueden estar correctos para el owner pero no para la connection del flow.
- `SiteCollectionUrl` puede venir vacio; esto es aceptable solo si `AbsoluteUrl` y Graph validan.
- `folder_structure_hints` puede quedar como INFO/YELLOW si la biblioteca no sigue la taxonomia esperada.

## Readiness Para G6.2

Estado: READY_FOR_IMPLEMENTATION_DESIGN_ONLY

G6.2 puede avanzar cuando existan:

- Entidad origen final aprobada.
- Metadata confirmando target valido de `regardingobjectid` o patron de ancla tecnica aprobado.
- Esquema de path aprobado.
- Owner gate formal para crear el flow en modo deshabilitado o simulado.
- Plan de prueba con un solo registro.
- Rollback documentado.
- Postcheck watchdog definido.

No esta autorizado todavia:

- Crear flow.
- Ejecutar flow.
- Crear carpetas por automatizacion.
- Crear DocumentLocations adicionales.
- Scheduler.
- Push o PR.
