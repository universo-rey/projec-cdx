# SDU G5.2C DocumentLocation Postverify Diagnostic

Mode: READ_ONLY_DIAGNOSTIC
Dictamen: PASS_DIAGNOSTIC
Classification: A+E_SITE_COLLECTION_URL_EMPTY_BUT_ABSOLUTE_GRAPH_OK_AND_WATCHDOG_RULE_TOO_STRICT
Recommended next action: G5.2D_PATCH_WATCHDOG_RULE

## IDs

- sharepointsiteid: 52bda16d-2777-4304-9f5f-2cfdcb3ce4b0
- activityid: f22fbb06-77bc-42ff-8b97-0efc0cfb31d2
- sharepointdocumentlocationid: ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d

## Literal Findings

- Health before diagnostic: DEGRADED / locationsReviewed=1
- Remote reads: true
- Remote writes: false
- POST/PATCH/PUT/DELETE: false
- Flows: false
- Scheduler: false
- Push/PR: false

## SharePointSite Row

`json
{
  "sharepointsiteid": "52bda16d-2777-4304-9f5f-2cfdcb3ce4b0",
  "name": "SGIN",
  "absoluteurl": "https://escribaniabitsch.sharepoint.com/sites/sistema",
  "relativeurl": null,
  "servicetype": 0,
  "ispowerbisite": false,
  "statecode": 0,
  "statuscode": 1
}
`

## DocumentLocation Row

`json
{
  "@odata.context": "https://org084965d9.crm.dynamics.com/api/data/v9.2/$metadata#sharepointdocumentlocations(sharepointdocumentlocationid,name,relativeurl,absoluteurl,_parentsiteorlocation_value,_regardingobjectid_value,statecode,statuscode)/$entity",
  "@odata.etag": "W/\"30602051\"",
  "absoluteurl": null,
  "name": "SDU_POC_DOCUMENT_LOCATION",
  "_regardingobjectid_value@OData.Community.Display.V1.FormattedValue": "SDU_POC_DOCUMENT_LINK",
  "_regardingobjectid_value@Microsoft.Dynamics.CRM.associatednavigationproperty": "regardingobjectid_adx_portalcomment",
  "_regardingobjectid_value@Microsoft.Dynamics.CRM.lookuplogicalname": "adx_portalcomment",
  "_regardingobjectid_value": "f22fbb06-77bc-42ff-8b97-0efc0cfb31d2",
  "_parentsiteorlocation_value@OData.Community.Display.V1.FormattedValue": "SGIN",
  "_parentsiteorlocation_value@Microsoft.Dynamics.CRM.associatednavigationproperty": "parentsiteorlocation_sharepointsite",
  "_parentsiteorlocation_value@Microsoft.Dynamics.CRM.lookuplogicalname": "sharepointsite",
  "_parentsiteorlocation_value": "52bda16d-2777-4304-9f5f-2cfdcb3ce4b0",
  "statecode@OData.Community.Display.V1.FormattedValue": "Activo",
  "statecode": 0,
  "relativeurl": "BIB_DOC_Expediente",
  "sharepointdocumentlocationid": "ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d",
  "statuscode@OData.Community.Display.V1.FormattedValue": "Activo",
  "statuscode": 1
}
`

## RetrieveAbsoluteAndSiteCollectionUrl

`json
{
  "@odata.context": "https://org084965d9.crm.dynamics.com/api/data/v9.2/$metadata#Microsoft.Dynamics.CRM.RetrieveAbsoluteAndSiteCollectionUrlResponse",
  "AbsoluteUrl": "https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente",
  "SiteCollectionUrl": ""
}
`

## Graph Result

`json
{
  "attempted": true,
  "ok": true,
  "siteId": "escribaniabitsch.sharepoint.com,a9293a2b-df30-45ed-b80d-d71a86738143,e678d763-1d87-495d-9a3b-0c2eeb56c6d3",
  "siteWebUrl": "https://escribaniabitsch.sharepoint.com/sites/sistema",
  "driveId": "b!KzopqTDf7UW4DdcahnOBQ2PXeOaHHV1JmjsMLutWxtOippwQVuCZSJHhyk0zO81J",
  "driveName": "BIB_DOC_Expediente",
  "driveWebUrl": "https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente",
  "relativePathInsideDrive": "",
  "driveItemId": "01QEPBDI56Y2GOVW7725BZO354PWSELRRZ",
  "driveItemName": "root",
  "webUrl": "https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente",
  "isFolder": true,
  "childrenCount": 50,
  "childrenNames": [
    "1098-23 -Pawlizki Ramon Anibal  Lara Liliana Rosana - Carpeta17",
    "1501-05 -Aguila Fuentealba Gloria del Carmen-",
    "174-16 -Ruiz Diaz Roberto  - Cancelación de Hipoteca",
    "1844-23 -Navarro Marcelo  Villaroel Maria Alejandra - Carpeta30 - Cancelacion de Hipoteca",
    "2530-05 -Jorge Mitre Claudio Ariel  Lucas Nancy Elcira -",
    "3491-03 -Ruben Adrian Yañez  Godoy Fanny Noemi -",
    "4094-07 -Gariglio Maria Laura   - Carpeta - Cancelacion de Hipoteca",
    "873-14 -Castaño Ramon Ruben  - Cancelacion de Hipoteca",
    "A101 – Cancelación de Hipoteca – BNA – SALDIVIA Fernando",
    "AFECTACIÓN A PH - ADJUDICACIÓN DE UF - VELAZQUEZ",
    "BBVA - PASTORIZA - FLORES - Carpeta N° A103",
    "BBVA-ROGERS-DUARTE-CarpetaA112",
    "BENETUCCI Ariana y GUILLERMO GARONE - A121 - AFECTACION A REG. PROT VIVIENDA",
    "Boleto de Permuta - GONZALEZ a SOTO OJEDA, Aida",
    "Cancelación - Velazquez993-23 Carpeta 13",
    "Cancelación de Hipoteca - CROUNAL SA y POSITIVO ARGENTINA SRL a favor de LEANVAL SA",
    "Cesión de Boleto - BARRIA BAHAMONDE a ANTILEF",
    "Cesión de Derechos de Adjudicación IPVH - CANCHE a GIMENEZ",
    "Cesion de Derechos de Adjudicación IPVH - DIPS - HERNANDEZ",
    "Cesion de Derechos de Adjudicación IPVH - WAYRICH a ZADO",
    "COLLY JOEL - PROTOCOLIZACIÓN DE DECLARATORIA Y VENTA SIMULTANEA - CARPETA A128",
    "COMPRAVENTA - PALACIOS - DIAZ - CARPETA A119",
    "Consulta - ALGARBE, Stella",
    "ConsultaEscrituraVenta-GILARDI-TAURELLIaMACIEL CEV001",
    "CONSULTA–VENTA–OVIEDOMOREYRA,CARLOSJAVIER",
    "DIAZ Rubén - Cesión de Derechos",
    "DILIGENCIAMIENTO DE INSCRIPCION DE VENTA -  Escribania BAREDES CABA",
    "Donación o Venta c Reserva de Usufructo - ALMIRON, Hilda a ALBERTI, Loreley",
    "ESC.FERNANDEZCABA-CarpetaA96",
    "ESCRITURA AGOSTINO - EXP SEGUNDO TESTIMONIO",
    "Escritura de Expediente de IPVH Nelida Alicia Diaz Dni 17295002",
    "ESCRITURA EDDIE VARGAS - MASCIOTRA -",
    "ESCRITURACIÓN – ADJUDICACIÓN MUNICIPAL   SUBIABRE, MARÍA ESTER – TOLHUIN 6 - Expediente Municipal Nº 1.069-2004",
    "Escrituración Galpon - Emprendimiento Patagonico SRL - Carpeta Nº038",
    "Escrituración MLB 3214,98  MALDONADO Olga Irma  Carpeta 11  Compra-Venta IPVH",
    "Exp 1080-05 Leguizamon -Milovic",
    "Exp 1949-01 Rivero",
    "Exp 3083-05 Diaz - Abrego",
    "Expediente 1345-12 Casco - Avanzzati",
    "Expediente 1814-98 MARIN Ana Maria",
    "Expediente 2228-15 - GOMEZ, Mónica Mabis - Carpeta N° 009",
    "Expediente 2819-18 - PEREYRA, Cristian - Carpeta N° 010",
    "Expediente 2989-06 Acuña Sergio Carlos",
    "Expediente 6-23 Ovejero",
    "Expediente 667-98 Velazquez",
    "EXPEDIENTE CONSULTA – VENTA – GONZÁLEZ, VANESA",
    "Expediente de Escrituración - MAZZARO Vicente Manuel- MLB - Carpeta Nº 16",
    "EXPEDIENTE DONACIÓN – PELLEGRINO, JOSÉ CARPETA A111",
    "EXPEDIENTE ESCRITURACIÓN VILLALOBOS - ALDERETE – VENTA DE VIVIENDA IPVH   EXPTE. IPV N.º 3085,97  - CARPETA 002",
    "Expediente IPVH 1164-19  - RUIZ MIGUEL ANGEL -MORALES CINTHIA PAMELA  - Carpeta N° 21"
  ],
  "error": null
}
`

## Classification Rationale

AbsoluteUrl present: True
SiteCollectionUrl present: False
Graph OK: True
Parent lookup OK: True
Regarding lookup OK: True
RelativeUrl OK: True
SharePointSite absoluteurl present: True
Children count: 50

## Evidence Paths

- Diagnostic log: C:\CEO\watchdog\logs\documentlocation_postverify_diagnostic.json
- Evidence: C:\CEO\watchdog\evidence\documentlocation_postverify_diagnostic_20260625_010242.json
- Readback: C:\CEO\project-cdx\08_READBACKS\20260625_010242_SDU_G5_2C_DOCUMENTLOCATION_POSTVERIFY_DIAGNOSTIC.md

## Git Status Short

`	ext
A  08_READBACKS/20260625_004013_SDU_G5_SHAREPOINTSITE_CREATE.md
A  08_READBACKS/20260625_004552_SDU_G5_2_DOCUMENTLOCATION_CREATE.md
A  08_READBACKS/20260625_005426_SDU_G5_2B_DOCUMENTLOCATION_RELATIVEURL_ONLY.md
A  08_READBACKS/20260625_005722_SDU_G5_2B_DOCUMENTLOCATION_RELATIVEURL_ONLY.md
 M README_SUITE.md
 M SYSTEM_NERVOUS_INDEX.json
 M VERSION_STATE.json
 M contracts/action-registry.json
 M contracts/environment-registry.json
 M contracts/live-action.schema.json
 M contracts/live-operation-state.schema.json
A  operativa/evidence-curated/document_location_apply_preview.json
A  operativa/evidence-curated/m365-escribania-dataverse-restore-readback.md
 M tests/run-authorization-tests.ps1
 M tests/run-live-authorization-tests.ps1
 M tests/run-live-policy-block-tests.ps1
 M tests/run-live-preflight-tests.ps1
 M tools/ceo-active-governance.ps1
 M tools/ceo-live-audit.ps1
 M tools/ceo-live-owner-gate.ps1
 M tools/ceo-live-rollback.ps1
 M tools/ceo-suite-common.ps1
 M tools/ceo-trace-dashboard.ps1
 M tools/ceo-validate-event.ps1
?? .agents/
?? .agileagentcanvas-context/
?? .github/copilot-instructions.md
?? 08_READBACKS/20260625_000033_SDU_SHAREPOINT_LINK_WATCHDOG_L6_READBACK.md
?? 08_READBACKS/20260625_001436_SDU_SHAREPOINT_LINK_WATCHDOG_L6_AUTH_RUN_READBACK.md
?? baseline.extensions.json
?? contracts/live-authorization-formal.schema.json
?? contracts/live-execution-real.schema.json
?? docs/watchdogs/
?? operativa/accountability/
?? operativa/tasks/20260623-221904/
?? operativa/tasks/20260623-224243/
?? tests/live-g6-test-helpers.ps1
?? tests/run-accountability-tests.ps1
?? tests/run-audit-formal-tests.ps1
?? tests/run-formal-authorization-tests.ps1
?? tests/run-live-execution-mocked.ps1
?? tests/run-live-session-tests.ps1
?? tests/run-multi-actor-tests.ps1
?? tests/run-rollback-real-mock.ps1
?? tools/ceo-jsonschema-validate.py
?? tools/ceo-live-authorize-formal.ps1
?? tools/ceo-live-executor-real.ps1
?? tools/ceo-live-guardrails-strict.ps1
?? tools/ceo-live-session.ps1
?? web/

`

## Next Boundary

G5.2D_PATCH_WATCHDOG_RULE
