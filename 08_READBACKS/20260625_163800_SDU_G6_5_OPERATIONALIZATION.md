# SDU G6.5 Operationalization Controlled Runtime

Mode: CONTROLLED_RUNTIME_NO_SCHEDULER
Dictamen: PASS
Environment: HUBDesarrollo
Dataverse URL: https://org084965d9.crm.dynamics.com

## Estado Previo

- Runtime base: `C:\CEO\watchdog\run-documentlocation-loop.ps1`
- Loop G6.4 validado: 3 iteraciones idempotentes.
- Health previo: `YELLOW`
- `locationsReviewed` previo: `5`
- Residual duplicado conocido: no tocado en esta fase.

## Cambios Aplicados

Runtime actualizado:

- Source: `tools/run-documentlocation-loop.ps1`
- Runtime desplegado: `C:\CEO\watchdog\run-documentlocation-loop.ps1`

Se agrego cabecera por ejecucion:

```json
{
  "runId": "GUID",
  "eventKey": "<string>",
  "timestamp": "now",
  "mode": "CONTROLLED_LOOP",
  "domain": "SDU_DOCUMENTLOCATION"
}
```

Se agrego:

- `runId` unico por ejecucion.
- Persistencia de `eventKey`.
- Reuso de `activityid` y `sharepointdocumentlocationid` si existen.
- Telemetria append-only.
- Estado `last`.
- Salida ejecutiva para uso manual.
- `-JsonOnly` para validadores automaticos.

## Archivos Generados

- Runtime: `C:\CEO\watchdog\run-documentlocation-loop.ps1`
- Telemetria append-only: `C:\CEO\watchdog\logs\g6_loop_events.jsonl`
- Ultimo estado: `C:\CEO\watchdog\state\g6_loop_last.json`
- Scheduler preparado no activo: `C:\CEO\watchdog\scripts\scheduler_g6_loop.txt`
- Evidencia G6.5: `C:\CEO\watchdog\evidence\g6_operationalization_20260625_163629.json`

## Validacion 3 Runs

EventKey:

- `G6_5_OPERATIONAL_20260625_163629`

IDs:

- `activityid`: `5a35472d-cd70-f111-ab0e-000d3a340b69`
- `sharepointdocumentlocationid`: `a1132bcd-a0c1-42d1-8595-2505d37d0629`

| Iteration | runId | POC | DocumentLocation | Health | locationsReviewed | Graph |
| --- | --- | --- | --- | --- | ---: | --- |
| 1 | `116345b4-84d4-4f6f-84a9-b7179a3b729b` | created | created | YELLOW | 6 | OK |
| 2 | `7d6ab0ac-c7fa-4c44-a4f0-8afdd272c3cc` | reused | reused | YELLOW | 6 | OK |
| 3 | `d315d5da-09cc-4f32-8f0b-d2681c32e1a0` | reused | reused | YELLOW | 6 | OK |

Criteria:

- uniqueRunIds: 3
- uniqueActivityIds: 1
- uniqueDocumentLocationIds: 1
- firstRunCreatedDocumentLocation: true
- subsequentRunsReusedDocumentLocation: true
- stableOrIncrementingLocationsReviewed: true
- watchdogNeverZero: true
- graphAlwaysOk: true
- noFolderCreated: true
- noDuplicateDocumentLocationsForRegarding: true
- telemetryAppended: true
- lastStateOk: true

## Estado Posterior

- Health final: `YELLOW`
- `locationsReviewed` final: `6`
- Watchdog evidence final: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_163728.json`
- Last state apunta al tercer run y al mismo DocumentLocation.

## Scheduler

Preparado como texto, no ejecutado:

- `C:\CEO\watchdog\scripts\scheduler_g6_loop.txt`

Estado:

- Scheduler: no creado.
- Scheduled task: no registrada.
- Power Automate: no creado ni ejecutado.

## Confirmaciones

- No scheduler.
- No Power Automate.
- No SharePoint writes.
- No DELETE.
- No PATCH.
- No PUT.
- No push.
- No PR.

## Residual

Residual G6.4 pre-parche no tocado:

- `activityid`: `d4f4dbac-5370-f111-ab0e-000d3a340b69`
- DocumentLocations residuales:
  - `d462a131-42d7-4006-8e0a-8e04d8fa19d9`
  - `5be74ed6-068e-49b9-9fd6-b030d254effc`

Cleanup requiere gate separado con IDs exactos.

## Proximos Pasos

G6.6 readiness:

- Runtime local operativo.
- Telemetria estructurada activa.
- Estado last persistido.
- Scheduler template preparado pero inactivo.

Antes de activar scheduler:

- Resolver o aceptar formalmente el residual G6.4.
- Definir `EventKey` real por expediente/proceso.
- Gate formal G6.6 con owner, rollback, postcheck y evidencia.
