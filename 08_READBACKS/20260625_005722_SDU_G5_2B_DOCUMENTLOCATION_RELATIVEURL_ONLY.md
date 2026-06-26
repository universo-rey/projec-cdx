# SDU G5.2B DocumentLocation RelativeUrl Only

Mode: CONTROLLED_WRITE_SINGLE_POST
Dictamen: FAIL_POSTVERIFY_G5_2B
Environment: HUBDesarrollo / https://org084965d9.crm.dynamics.com
Gate: ALLOW_DOCUMENTLOCATION_RELATIVEURL_ONLY_WRITE

## Previous Attempt Cause

Dataverse rejected the previous attempt because the payload had both `absoluteurl` and `relativeurl`.

## Correction Applied

Created the DocumentLocation with `relativeurl` only. No `absoluteurl` or `sitecollectionurl` was sent.

## IDs

- sharepointsiteid: 52bda16d-2777-4304-9f5f-2cfdcb3ce4b0
- activityid: f22fbb06-77bc-42ff-8b97-0efc0cfb31d2
- sharepointdocumentlocationid: ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d

## Payload Sanitized

```json
{
  "sharepointdocumentlocationid": "ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d",
  "name": "SDU_POC_DOCUMENT_LOCATION",
  "servicetype": 0,
  "locationtype": 0,
  "relativeurl": "BIB_DOC_Expediente",
  "description": "SDU G5.2B corrected POC DocumentLocation using relativeurl only. No sensitive data.",
  "parentsiteorlocation_sharepointsite@odata.bind": "/sharepointsites(52bda16d-2777-4304-9f5f-2cfdcb3ce4b0)",
  "regardingobjectid_adx_portalcomment@odata.bind": "/adx_portalcomments(f22fbb06-77bc-42ff-8b97-0efc0cfb31d2)"
}
```

## Dataverse Verify

```json
{
  "@odata.context": "https://org084965d9.crm.dynamics.com/api/data/v9.2/$metadata#sharepointdocumentlocations(sharepointdocumentlocationid,name,relativeurl,absoluteurl,_parentsiteorlocation_value,_regardingobjectid_value,statecode,statuscode)/$entity",
  "@odata.etag": "W/\"30602051\"",
  "absoluteurl": null,
  "name": "SDU_POC_DOCUMENT_LOCATION",
  "_regardingobjectid_value": "f22fbb06-77bc-42ff-8b97-0efc0cfb31d2",
  "_parentsiteorlocation_value": "52bda16d-2777-4304-9f5f-2cfdcb3ce4b0",
  "statecode": 0,
  "relativeurl": "BIB_DOC_Expediente",
  "sharepointdocumentlocationid": "ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d",
  "statuscode": 1
}
```

## RetrieveAbsoluteAndSiteCollectionUrl

```json
{
  "@odata.context": "https://org084965d9.crm.dynamics.com/api/data/v9.2/$metadata#Microsoft.Dynamics.CRM.RetrieveAbsoluteAndSiteCollectionUrlResponse",
  "AbsoluteUrl": "https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente",
  "SiteCollectionUrl": ""
}
```

Post-verify note: `AbsoluteUrl` is present, but `SiteCollectionUrl` is empty. This is why the run is not closed as G6-ready.

## Health

- Before: YELLOW / locationsReviewed=0
- After: DEGRADED / locationsReviewed=1
- Watchdog evidence: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_005735.json

## Graph Evidence

- Site: https://escribaniabitsch.sharepoint.com/sites/sistema
- Library: BIB_DOC_Expediente
- Library URL: https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente
- Root folder facet: True

## Evidence Paths

- Preview: C:\CEO\watchdog\logs\document_location_apply_preview_g5_2b.json
- Result: C:\CEO\watchdog\logs\document_location_apply_result_g5_2b.json
- Evidence: C:\CEO\watchdog\evidence\documentlocation_relativeurl_only_20260625_005722.json

## Error

```json
null
```

## Git Status Short

```text
A  08_READBACKS/20260625_004013_SDU_G5_SHAREPOINTSITE_CREATE.md
A  08_READBACKS/20260625_004552_SDU_G5_2_DOCUMENTLOCATION_CREATE.md
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
?? 08_READBACKS/20260625_005426_SDU_G5_2B_DOCUMENTLOCATION_RELATIVEURL_ONLY.md
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

```

## Limits

- POST count: 1
- Retry: False
- PATCH: 0
- PUT: 0
- DELETE: 0
- SharePoint writes: 0
- Flow runs: 0
- Scheduler changes: 0
- Push: False
- PR: False

## Next Step

STOP_REVIEW_POSTVERIFY: diagnose why `RetrieveAbsoluteAndSiteCollectionUrl()` returns an empty `SiteCollectionUrl` while the `DocumentLocation` exists and watchdog sees `locationsReviewed=1`.
