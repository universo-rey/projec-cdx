# SDU G6.4 Controlled Loop Execution And Validation

Mode: CONTROLLED_WRITES_NO_SCHEDULER
Dictamen: PASS_WITH_RESIDUAL_REQUIRING_SEPARATE_CLEANUP_GATE
Environment: HUBDesarrollo
Dataverse URL: https://org084965d9.crm.dynamics.com

## Entregable

Script creado y desplegado:

- Source repo: `tools/run-documentlocation-loop.ps1`
- Runtime local: `C:\CEO\watchdog\run-documentlocation-loop.ps1`

El script ejecuta:

1. Resolve `EventKey`.
2. Reuse/create one `adx_portalcomment`.
3. Graph read-only check for `SGIN / BIB_DOC_Expediente`.
4. GET before POST for `sharepointdocumentlocation`.
5. Create one DocumentLocation only when missing.
6. Save local state in `C:\CEO\watchdog\state\documentlocation-loop-state.json`.
7. Run watchdog and write JSON evidence.

## Correccion Aplicada

El primer loop marco `REQUIRES_REVIEW` porque el script inicial saved state after POC creation but before persisting the DocumentLocation ID. A delayed lookup by `_regardingobjectid_value` let a second iteration create another DocumentLocation for the same `activityid`.

Fix applied:

- Persist `sharepointdocumentlocationid` immediately after POST returns.
- Reuse state by direct GET on `sharepointdocumentlocationid`.
- Treat delayed lookup as acceptable only when direct readback by ID confirms the row.
- Fail closed if more than one DocumentLocation is found for the same `activityid`.

## Loop PASS Corregido

Validation evidence:

- `C:\CEO\watchdog\evidence\g6_loop_validation_20260625_020904.json`

EventKey:

- `G6_4_LOOP_FIXED_20260625_020904`

IDs:

- `activityid`: `25862f01-5470-f111-ab0e-000d3a340906`
- `sharepointdocumentlocationid`: `14a5c5e7-f46b-4fab-b1a9-ee25d8ffbcbf`

Runs:

| Iteration | POC | DocumentLocation | Health | locationsReviewed | Graph | Folder created |
| --- | --- | --- | --- | ---: | --- | --- |
| 1 | created | created | YELLOW | 5 | OK | false |
| 2 | reused | reused | YELLOW | 5 | OK | false |
| 3 | reused | reused | YELLOW | 5 | OK | false |

Criteria:

- allRunsPass: true
- firstRunCreatedDocumentLocation: true
- subsequentRunsReusedDocumentLocation: true
- stableOrIncrementingLocationsReviewed: true
- watchdogNeverZero: true
- graphAlwaysOk: true
- noFolderCreated: true
- noDuplicateDocumentLocationsForRegarding: true
- uniqueActivityIds: 1
- uniqueDocumentLocationIds: 1

Final watchdog:

- health: `YELLOW`
- locationsReviewed: `5`
- evidence: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_021004.json`

## Residual Del Intento Pre-Parche

Validation evidence:

- `C:\CEO\watchdog\evidence\g6_loop_validation_20260625_020651.json`

EventKey residual:

- `G6_4_LOOP_20260625_020651`

Residual IDs:

- `activityid`: `d4f4dbac-5370-f111-ab0e-000d3a340b69`
- duplicate DocumentLocations observed:
  - `d462a131-42d7-4006-8e0a-8e04d8fa19d9`
  - `5be74ed6-068e-49b9-9fd6-b030d254effc`

Cleanup:

- Not performed.
- Requires separate owner gate.
- No DELETE/PATCH was executed.

## Limits Preserved

Final corrected PASS loop:

- Scheduler: false.
- Power Automate flows: false.
- SharePoint writes: 0.
- Folder create: 0.
- DELETE/PATCH/PUT: 0.
- Iterations: 3.

G6.4 total session caveat:

- The failed pre-patch attempt created 1 technical `adx_portalcomment` and 2 duplicate `sharepointdocumentlocation` rows for its own residual EventKey.
- Those rows remain visible to the watchdog and explain `locationsReviewed=5`.

## Next Delta

G6.4.1 optional cleanup gate:

- Decide whether to delete one or both residual DocumentLocations for `activityid d4f4dbac-5370-f111-ab0e-000d3a340b69`.
- This must be a separate exact-ID gate with rollback, postcheck, and watchdog validation.

G6.5 functional next step:

- Keep scheduler closed.
- Use `run-documentlocation-loop.ps1` only manually until the residual decision is closed and the EventKey source is tied to a real expediente process.
