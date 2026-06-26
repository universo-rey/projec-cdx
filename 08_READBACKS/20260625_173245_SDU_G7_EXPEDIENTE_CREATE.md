# SDU_G7_EXPEDIENTE_CREATE

## Estado

DICTAMEN: PASS

Entidad real de dominio creada y validada para DocumentLocation.

readiness: G8_READY_FOR_MIGRATION_DESIGN

## Entidad Creada

- logicalName: cr3c_expediente
- schemaName: cr3c_Expediente
- entitySetName: cr3c_expedientes
- solution: SPGovernanceModel
- publisherPrefix: cr3c
- primaryNameAttribute: cr3c_titulo
- primaryIdAttribute: cr3c_expedienteid
- entityMetadataId: 97c3dab2-d370-f111-ab0e-000d3a340906

## Campos Minimos

- cr3c_titulo
- cr3c_fechacontrol
- cr3c_estadooperativo

## Capabilities Confirmadas

- DocumentManagementEnabled: true
- IsRegardingTarget: true
- sharepointdocumentlocation.regardingobjectid target: cr3c_expediente

## Registro POC

- expedienteId: 199f43e4-d370-f111-ab0e-000d3a340b69
- titulo: SDU_G7_EXPEDIENTE_POC
- estadoOperativo: POC

## DocumentLocation POC

- documentLocationId: 741d8199-d470-f111-ab0e-000d3a340906
- name: SDU_G7_EXPEDIENTE_DOCUMENT_LOCATION
- relativeurl: BIB_DOC_Expediente
- parentNavigation: parentsiteorlocation_sharepointsite
- regardingNavigation: regardingobjectid_cr3c_expediente
- sharePointSiteId: 52bda16d-2777-4304-9f5f-2cfdcb3ce4b0

## Watchdog

- health: YELLOW
- locationsReviewed: 7
- Graph OK: true
- newLocationReviewed: true
- absoluteUrl: https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente
- classification: SITE_COLLECTION_URL_OPTIONAL

## Evidencia

- finalEvidence: C:\CEO\watchdog\evidence\g7_expediente_final_20260625_173242.json
- watchdogFinal: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_173206.json
- metadataAndRecordCreated: C:\CEO\watchdog\evidence\g7_expediente_creation_20260625_172305.json
- documentLocationCreatedBootstrapWatchdogFailed: C:\CEO\watchdog\evidence\g7_documentlocation_completion_20260625_172933.json
- firstRejectedPayload: C:\CEO\watchdog\evidence\g7_expediente_creation_20260625_171751.json

## Incidencias Controladas

Primer POST de metadata:

- resultado: rejected 400
- efecto visible: ninguno
- verificacion: cr3c_expediente no existia y DocumentLocations seguia en 6

Payload corregido:

- se agregaron IsPrimaryName, HasActivities, HasNotes, AttributeType, AttributeTypeName y tipos OData de Label
- resultado: entidad creada, publicada y validada

Primer POST de DocumentLocation:

- resultado: rejected 400
- causa: parent navigation property incorrecta
- correccion: usar parentsiteorlocation_sharepointsite
- resultado final: DocumentLocation creado

Primer watchdog post-DocumentLocation:

- resultado: DEGRADED / 0
- causa: powershell.exe no veia az en PATH
- correccion: re-ejecucion read-only con Azure CLI path inyectado
- resultado final: YELLOW / locationsReviewed 7 / Graph OK

## Sistemas Tocados

- Dataverse metadata: 1 entidad cr3c_expediente
- Dataverse rows: 1 cr3c_expediente POC
- Dataverse rows: 1 sharepointdocumentlocation POC
- Evidencia local: C:\CEO\watchdog\evidence
- Readback local repo: 08_READBACKS

## Sistemas No Tocados

- SharePoint: sin writes, sin carpetas nuevas
- Loop G6: no ejecutado, no modificado
- Power Automate: sin flows
- Scheduler: sin activacion
- DELETE: no ejecutado
- PATCH/PUT: no ejecutado
- Git remoto: sin push, sin PR

## Riesgos

El health queda YELLOW por warnings informativos ya esperados del watchdog, no por falla de Graph ni por ausencia de vinculo.

El residual G6 PRE_FIX sigue declarado; no fue limpiado ni modificado en G7.

## Rollback

No se ejecuto rollback automatico.

Rollback requiere gate separado porque implicaria eliminar o desactivar metadata/filas Dataverse creadas:

- sharepointdocumentlocation: 741d8199-d470-f111-ab0e-000d3a340906
- expediente: 199f43e4-d370-f111-ab0e-000d3a340b69
- entidad: cr3c_expediente

## Proximos Carriles

G8: migrar automatizacion desde ancla tecnica adx_portalcomment hacia entidad real cr3c_expediente.

Condicion de entrada G8:

- no crear nuevas carpetas por defecto
- no tocar scheduler
- no activar flows sin gate
- mantener GET before POST para DocumentLocation
- mantener watchdog postcheck obligatorio
