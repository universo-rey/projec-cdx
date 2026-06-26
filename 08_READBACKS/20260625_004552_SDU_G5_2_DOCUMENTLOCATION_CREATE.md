# SDU G5.2 DocumentLocation Create

Mode: CONTROLLED_WRITE_G5_2
Dictamen: FAIL_DOCUMENTLOCATION_POST_REJECTED
Environment: HUBDesarrollo / https://org084965d9.crm.dynamics.com
Owner gates: ALLOW_POC_CREATE / ALLOW_DOCUMENTLOCATION_POC_WRITE

## IDs

- activityid: f22fbb06-77bc-42ff-8b97-0efc0cfb31d2
- sharepointdocumentlocationid:
- parent sharepointsiteid: 52bda16d-2777-4304-9f5f-2cfdcb3ce4b0

## Payload POC

```json
{
  "activityid": "f22fbb06-77bc-42ff-8b97-0efc0cfb31d2",
  "subject": "SDU_POC_DOCUMENT_LINK",
  "description": "POC Document Location anchor. No sensitive data.",
  "actualdurationminutes": 0
}
```

## Payload DocumentLocation

Attempted payload rejected by Dataverse:

```json
{
  "sharepointdocumentlocationid": "ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d",
  "name": "SDU_POC_DOCUMENT_LOCATION",
  "servicetype": 0,
  "locationtype": 0,
  "relativeurl": "BIB_DOC_Expediente",
  "absoluteurl": "https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente",
  "description": "SDU G5.2 POC DocumentLocation for existing SGIN/BIB_DOC_Expediente library root. No sensitive data.",
  "parentsiteorlocation_sharepointsite@odata.bind": "/sharepointsites(52bda16d-2777-4304-9f5f-2cfdcb3ce4b0)",
  "regardingobjectid_adx_portalcomment@odata.bind": "/adx_portalcomments(f22fbb06-77bc-42ff-8b97-0efc0cfb31d2)"
}
```

Dataverse error:

```json
{
  "code": "0x80040203",
  "message": "SharePointDocumentLocation cannot have both absoluteurl and relative url."
}
```

Corrected payload prepared for a new gate, not executed:

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

## RetrieveAbsoluteAndSiteCollectionUrl

Not executed because no `sharepointdocumentlocation` was created.

Evidence placeholder: `C:\CEO\watchdog\evidence\documentlocation_retrieve_absolute_20260625_004552.json`

## Health

- Before: YELLOW / locationsReviewed=0
- After: YELLOW / locationsReviewed=0
- Watchdog evidence: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_004852.json

## Graph Evidence

- Site: https://escribaniabitsch.sharepoint.com/sites/sistema
- Library: BIB_DOC_Expediente
- Library URL: https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente
- Root folder facet: True

## Evidence

- POC create: C:\CEO\watchdog\evidence\poc_adx_portalcomment_created_20260625_004552.json
- DocumentLocation create: C:\CEO\watchdog\evidence\documentlocation_created_20260625_004552.json
- RetrieveAbsolute: C:\CEO\watchdog\evidence\documentlocation_retrieve_absolute_20260625_004552.json
- Combined: C:\CEO\watchdog\evidence\sdu_g5_2_documentlocation_create_20260625_004552.json
- Watchdog after failure: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_004852.json

## Limits

- POC records created: 1
- DocumentLocations created: 0
- DELETE: 0
- PATCH: 0
- Flow runs: 0
- Scheduler changes: 0
- Push: False
- PR: False
- Retry POST: False

## Next Step

STOP_REVIEW_PARTIAL_POC_CREATED.

Next safe gate: G5.2B, create only `sharepointdocumentlocation` using the existing POC and `relativeurl` only.

Required owner phrase: `ALLOW_DOCUMENTLOCATION_RELATIVEURL_ONLY_WRITE`
