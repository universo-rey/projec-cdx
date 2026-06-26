# SDU G5 SharePointSite Create

Mode: CONTROLLED_WRITE_G5
Dictamen: PASS
Environment: HUBDesarrollo / https://org084965d9.crm.dynamics.com
Owner gate: ALLOW_SHAREPOINTSITE_CREATE

## Scope

Created exactly one sharepointsite record if and only if POST succeeded.

Not executed:

- No sharepointdocumentlocation create.
- No POC entity create.
- No SharePoint folder create.
- No flow run.
- No scheduler change.
- No push.
- No PR.
- No DELETE.
- No PATCH.

## Metadata Used

- Entity set: sharepointsites
- Primary id attribute: sharepointsiteid
- Primary name attribute: name
- URL field: absoluteurl

## Payload Used

```json
{
  "sharepointsiteid": "52bda16d-2777-4304-9f5f-2cfdcb3ce4b0",
  "name": "SGIN",
  "absoluteurl": "https://escribaniabitsch.sharepoint.com/sites/sistema",
  "servicetype": 0,
  "ispowerbisite": false,
  "description": "SDU G5 SharePointSite root anchor for SGIN/BIB_DOC_Expediente. Created under explicit owner gate."
}
```

## Result

- POST attempted: True
- POST succeeded: True
- Created ID: 52bda16d-2777-4304-9f5f-2cfdcb3ce4b0
- Evidence: C:\CEO\watchdog\evidence\sharepointsite_created_20260625_004013.json
- Preview: C:\CEO\watchdog\logs\sharepointsite_create_preview.json

## Post Verify

```json
{
  "@odata.context": "https://org084965d9.crm.dynamics.com/api/data/v9.2/$metadata#sharepointsites(sharepointsiteid,name,absoluteurl,servicetype,statecode,statuscode)/$entity",
  "@odata.etag": "W/\"30595670\"",
  "statecode": 0,
  "absoluteurl": "https://escribaniabitsch.sharepoint.com/sites/sistema",
  "statuscode": 1,
  "servicetype": 0,
  "sharepointsiteid": "52bda16d-2777-4304-9f5f-2cfdcb3ce4b0",
  "name": "SGIN"
}
```

## Error

```json
null
```

## Health

- Before: YELLOW, locationsReviewed=0
- After: not run by scope. It is expected to remain unchanged until G5.2/G5.3 create the POC and DocumentLocation.

## Next Step

G5.2: create exactly one POC record after explicit gate.
