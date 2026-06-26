# M365 Escribania / Registro / Dataverse Restore Readback

Mode: READ_ONLY_RESTORE
Wave: Escribania / Registro / Dataverse
Out of wave: modoe.com.ar, Modo E, broad Teams/Planner testing

## Identity

- SharePoint profile: Enzo Figueroa <efigueroa@registronotarial8tdf.com.ar>
- Outlook Calendar profile: Enzo Figueroa <efigueroa@registronotarial8tdf.com.ar>
- Outlook Email profile: Enzo Figueroa <efigueroa@registronotarial8tdf.com.ar>
- Dataverse PAC profile: efigueroa@registronotarial8tdf.com.ar

## SharePoint Sites Confirmed

- https://escribaniabitsch.sharepoint.com/sites/escrituracion
  - Display name: Escrituracion y Protocolo
  - Document libraries visible: 30
- https://escribaniabitsch.sharepoint.com/sites/ESCRIBANIABITSCH
  - Display name: Escribania Bitsch
  - Document libraries visible: 7
- https://escribaniabitsch.sharepoint.com/sites/sistema
  - Display name: SGIN
  - Document libraries visible: 7

## Dataverse Confirmed

- Environment: HUBDesarrollo
- Org URL: https://org084965d9.crm.dynamics.com/
- Environment ID: 7f65fc04-c27a-ea0d-bd2d-266aa9203c1e
- Org ID: f982db28-49e3-f011-aa23-000d3a5ca83f
- User ID: 9e347a71-cbcb-f011-8543-002248028cf4

## Power Platform Connections

PAC `connection list --environment https://org084965d9.crm.dynamics.com` returned 15 connections, all `Connected`.

Connected surfaces include:
- Office 365
- Dataverse
- Power Platform Admin
- Power Platform for Admins
- SharePoint Online
- WorkIQ SharePoint
- WorkIQ OneDrive
- Planner
- Planner MCP server
- A365 MCP server
- A365 Teams MCP
- A365 Copilot Chat MCP
- A365 ME MCP
- Microsoft Copilot Studio
- GitHub / SeshatSgin

## Outlook Calendar Metadata

Outlook Calendar profile is available for `efigueroa@registronotarial8tdf.com.ar`.

Calendar metadata returned 5 calendars:
- Calendario
- Dias festivos de Espana
- Cumpleanos
- Tareas SHB
- Escrituraciones Escribania Btisch

Mailbox settings returned `403 AccessDenied`, so calendar mailbox settings remain blocked even though calendar metadata is readable.

## OneDrive Metadata

User drive metadata returned 3 business drives under `escribaniabitsch-my.sharepoint.com`:
- Documentos
- PersonalCacheLibrary
- KARuntime

No OneDrive file contents were listed or fetched.

## Dataverse Solutions

PAC `solution list --environment https://org084965d9.crm.dynamics.com` confirmed these unmanaged solutions:
- Common Data Services Default Solution
- Gestor de Copilotos
- MDE
- SDU Capability Control Plane
- SDU Runtime Control Plane
- Solucion predeterminada
- SP Governance Model

PAC `connector list --environment https://org084965d9.crm.dynamics.com` returned no custom connectors in the environment.

## Guardrails

- No Dataverse write/import/update/delete executed.
- No Power Automate flow executed.
- No SharePoint upload/delete/create/move/permission change executed.
- No Outlook mail/event content read.
- No email sent.
- No calendar event created or changed.
- No Teams/Planner action executed in this wave.
- No secrets or `.env.local` read.

## Remaining Blocks

- Outlook mailbox settings returned 403 AccessDenied.
- Teams remains outside this wave because it is authenticated as `efigueroa@modoe.com.ar`.
- Native SharePoint list rows were not read.
- Power Automate flows were not enumerated or run; PAC did not expose a direct `flow list` command in this runtime.
- Full content-level SharePoint validation remains gated by exact target.

## Status

RESTORED_READ_ONLY_OK

## DocumentLocation POC Preflight - 2026-06-25

Mode: READ_ONLY_METADATA_PREFLIGHT
Outcome: BLOQUEADO_CON_CAUSA_REAL before write gate
Environment: HUBDesarrollo / https://org084965d9.crm.dynamics.com

### Step 1 - Metadata Preflight

- `sharepointdocumentlocation` entity set: `sharepointdocumentlocations`.
- `sharepointsite` entity set: `sharepointsites`.
- Creatable fields confirmed by metadata: `name`, `servicetype`, `locationtype`, `absoluteurl`, `relativeurl`, `parentsiteorlocation`, `regardingobjectid`.
- Required fields confirmed by metadata: `name`, `servicetype`.
- `servicetype=0` means `SharePoint`.
- `locationtype=0` means `General`.
- `parentsiteorlocation` targets: `sharepointdocumentlocation`, `sharepointsite`.
- `regardingobjectid` targets: `account`, `adx_portalcomment`, `kbarticle`, `knowledgearticle`, `lead`, `msdyn_knowledgearticletemplate`, `msdyn_playbookactivity`, `mspp_website`, `opportunity`, `product`, `quote`, `salesliterature`.
- Current standard `sharepointsites` rows: `0`.
- Current standard `sharepointdocumentlocations` rows: `0`.

### Step 2 - POC Record

No POC record was selected.

Reason: read-only scan over all 12 `regardingobjectid` target tables found `0` rows available for a supported record link. Creating a POC business record would be a separate Dataverse write and is outside this gate.

### Step 3 - SharePoint POC Folder/Library

Confirmed by Microsoft Graph GET:

- Site: `SGIN`
- Site URL: `https://escribaniabitsch.sharepoint.com/sites/sistema`
- Library: `BIB_DOC_Expediente`
- Library URL: `https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente`
- Drive type: `documentLibrary`
- Root folder facet: `true`

### Step 4 - DocumentLocation Payload Preview

This is a blocked preview wrapper, not an executable POST body.

```json
{
  "control": {
    "preview_state": "NO_EXECUTE",
    "reason": "No supported regardingobjectid record and no parent sharepointsite row exist in Dataverse.",
    "write_allowed": false
  },
  "candidate_create_body": {
    "name": "POC_SGIN_BIB_DOC_Expediente_ROOT",
    "servicetype": 0,
    "locationtype": 0,
    "absoluteurl": "https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente",
    "relativeurl": "BIB_DOC_Expediente"
  },
  "blocked_bindings": {
    "parentsiteorlocation_sharepointsite@odata.bind": null,
    "regardingobjectid_<target>@odata.bind": null
  }
}
```

### Gate Status

Stop condition: `rows_absent` plus `parent_sharepointsite_absent`.

No Dataverse POST/PATCH/PUT/DELETE was executed.
No SharePoint write was executed.
No scheduler was created or modified.

## Anchor Setup And DocumentLocation POC G5 - 2026-06-25

Mode: G5_PREVIEW_NO_EXECUTE
Preview: `operativa/evidence-curated/document_location_apply_preview.json`

### Decision

Prepared but not executed.

`document-location-preflight.ps1` was not found under `C:\CEO\watchdog`, `.codex`, `.agents`, or this repo, so the preview was generated from live read-only Dataverse/Graph metadata and stored as local evidence.

### Dynamic Metadata Results

- `sharepointsite` endpoint: `/api/data/v9.2/sharepointsites`
- `sharepointsite` selected URL field: `absoluteurl`
- `sharepointdocumentlocation` endpoint: `/api/data/v9.2/sharepointdocumentlocations`
- Parent navigation property: `parentsiteorlocation_sharepointsite`
- Regarding navigation property selected: `regardingobjectid_adx_portalcomment`
- Requested `cr3c_*` POC priority was rejected for the DocumentLocation link because those entities are not allowed `regardingobjectid` targets in live metadata.
- Selected fallback POC target: `adx_portalcomment`

### Planned IDs

- `sharepointsiteid`: `52bda16d-2777-4304-9f5f-2cfdcb3ce4b0`
- `poc_activityid`: `f22fbb06-77bc-42ff-8b97-0efc0cfb31d2`
- `sharepointdocumentlocationid`: `ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d`

### Gate Split

1. `ALLOW_SHAREPOINTSITE_CREATE`
   - Creates exactly one `sharepointsite`.
   - Then GET postcheck only.
2. `ALLOW_DOCUMENTLOCATION_POC_WRITE`
   - Creates exactly one `adx_portalcomment` POC record.
   - Creates exactly one `sharepointdocumentlocation`.
   - Then watchdog read-only verification.

### Stop

Current execution state: `WAITING_FOR_ALLOW_SHAREPOINTSITE_CREATE`.

No Dataverse POST/PATCH/PUT/DELETE was executed.
No SharePoint write was executed.
No flow or scheduler was executed.

## SharePointSite Anchor Create G5.1 - 2026-06-25

Mode: CONTROLLED_WRITE_G5
Dictamen: PASS
Owner gate: `ALLOW_SHAREPOINTSITE_CREATE`

### Result

- Created exactly one `sharepointsite`.
- Created ID: `52bda16d-2777-4304-9f5f-2cfdcb3ce4b0`
- Entity set: `sharepointsites`
- URL field used: `absoluteurl`
- Preview: `C:\CEO\watchdog\logs\sharepointsite_create_preview.json`
- Evidence: `C:\CEO\watchdog\evidence\sharepointsite_created_20260625_004013.json`
- Readback: `C:\CEO\project-cdx\08_READBACKS\20260625_004013_SDU_G5_SHAREPOINTSITE_CREATE.md`

### Payload Used

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

### Limits Preserved

- No `sharepointdocumentlocation` created.
- No POC entity created.
- No SharePoint folder created.
- No DELETE.
- No PATCH.
- No flow run.
- No scheduler change.
- No push.
- No PR.

### Next Gate

Current execution state: `SHAREPOINTSITE_CREATED_WAITING_FOR_G5_2_POC`.

Next step: G5.2, create exactly one POC record after explicit gate.

## POC And DocumentLocation Create G5.2 - 2026-06-25

Mode: CONTROLLED_WRITE_G5_2
Dictamen: FAIL_DOCUMENTLOCATION_POST_REJECTED
Owner gates: `ALLOW_POC_CREATE` / `ALLOW_DOCUMENTLOCATION_POC_WRITE`

### Result

- Created exactly one `adx_portalcomment` POC record.
- POC `activityid`: `f22fbb06-77bc-42ff-8b97-0efc0cfb31d2`
- Created `sharepointdocumentlocation`: no.
- `sharepointdocumentlocationid` planned but not created: `ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d`
- Graph library check: OK for `https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente`
- Watchdog after failure: `YELLOW`, `locationsReviewed=0`

### Dataverse Rejection

```json
{
  "code": "0x80040203",
  "message": "SharePointDocumentLocation cannot have both absoluteurl and relative url."
}
```

### Evidence

- POC create: `C:\CEO\watchdog\evidence\poc_adx_portalcomment_created_20260625_004552.json`
- DocumentLocation rejected create: `C:\CEO\watchdog\evidence\documentlocation_created_20260625_004552.json`
- RetrieveAbsolute placeholder: `C:\CEO\watchdog\evidence\documentlocation_retrieve_absolute_20260625_004552.json`
- Watchdog after failure: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_004852.json`
- Combined: `C:\CEO\watchdog\evidence\sdu_g5_2_documentlocation_create_20260625_004552.json`
- Readback: `C:\CEO\project-cdx\08_READBACKS\20260625_004552_SDU_G5_2_DOCUMENTLOCATION_CREATE.md`

### Limits Preserved

- POC records created: `1`
- DocumentLocations created: `0`
- No retry POST.
- No DELETE.
- No PATCH.
- No flow run.
- No scheduler change.
- No push.
- No PR.

### Next Gate

Current execution state: `POC_CREATED_DOCUMENTLOCATION_REJECTED_WAITING_FOR_G5_2B_DOCUMENTLOCATION_ONLY`.

Next safe gate: `ALLOW_DOCUMENTLOCATION_RELATIVEURL_ONLY_WRITE`, one POST only, using existing POC and corrected payload with `relativeurl` only.

## DocumentLocation RelativeUrl Only G5.2B - 2026-06-25

Mode: CONTROLLED_WRITE_SINGLE_POST
Dictamen: FAIL_POSTVERIFY_G5_2B
Owner gate: `ALLOW_DOCUMENTLOCATION_RELATIVEURL_ONLY_WRITE`

### Result

- Created exactly one `sharepointdocumentlocation`.
- `sharepointdocumentlocationid`: `ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d`
- Parent `sharepointsiteid`: `52bda16d-2777-4304-9f5f-2cfdcb3ce4b0`
- Regarding `activityid`: `f22fbb06-77bc-42ff-8b97-0efc0cfb31d2`
- POST count: `1`
- Retry: `false`
- PATCH/PUT/DELETE: `0`
- SharePoint writes: `0`
- Flows/scheduler: `0`
- Push/PR: `false`

### Payload Correction Applied

The previous rejected payload sent both `absoluteurl` and `relativeurl`.

G5.2B sent only `relativeurl`:

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

### Post Verify

- Dataverse GET: record visible, active.
- `absoluteurl` field on row: `null`, as expected for relativeurl-only payload.
- `RetrieveAbsoluteAndSiteCollectionUrl.AbsoluteUrl`: `https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente`
- `RetrieveAbsoluteAndSiteCollectionUrl.SiteCollectionUrl`: empty string.
- Watchdog health after: `DEGRADED`
- Watchdog `locationsReviewed`: `1`
- Graph library root: OK.

### Evidence

- G5.2B evidence: `C:\CEO\watchdog\evidence\documentlocation_relativeurl_only_20260625_005722.json`
- Watchdog after: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_005735.json`
- Result log: `C:\CEO\watchdog\logs\document_location_apply_result_g5_2b.json`
- Readback: `C:\CEO\project-cdx\08_READBACKS\20260625_005722_SDU_G5_2B_DOCUMENTLOCATION_RELATIVEURL_ONLY.md`

### Next Boundary

Current execution state: `DOCUMENTLOCATION_CREATED_POSTVERIFY_DEGRADED`.

Next step: read-only diagnosis of why `RetrieveAbsoluteAndSiteCollectionUrl()` returns empty `SiteCollectionUrl` while `AbsoluteUrl` is present and watchdog sees `locationsReviewed=1`.

## DocumentLocation Postverify Diagnostic G5.2C - 2026-06-25

Mode: READ_ONLY_DIAGNOSTIC
Dictamen: PASS_DIAGNOSTIC
Classification: `A+E_SITE_COLLECTION_URL_EMPTY_BUT_ABSOLUTE_GRAPH_OK_AND_WATCHDOG_RULE_TOO_STRICT`

### Literal Findings

- `RetrieveAbsoluteAndSiteCollectionUrl.AbsoluteUrl`: `https://escribaniabitsch.sharepoint.com/sites/sistema/BIB_DOC_Expediente`
- `RetrieveAbsoluteAndSiteCollectionUrl.SiteCollectionUrl`: empty string.
- Graph site/library resolution: OK.
- Graph children listed: `50`.
- Parent lookup: OK, points to `52bda16d-2777-4304-9f5f-2cfdcb3ce4b0`.
- Regarding lookup: OK, points to `f22fbb06-77bc-42ff-8b97-0efc0cfb31d2`.
- RelativeUrl: OK, `BIB_DOC_Expediente`.
- Remote reads: true.
- Remote writes: false.
- POST/PATCH/PUT/DELETE: false.
- Flows/scheduler: false.
- Push/PR: false.

### Evidence

- Diagnostic log: `C:\CEO\watchdog\logs\documentlocation_postverify_diagnostic.json`
- Evidence: `C:\CEO\watchdog\evidence\documentlocation_postverify_diagnostic_20260625_010242.json`
- Readback: `C:\CEO\project-cdx\08_READBACKS\20260625_010242_SDU_G5_2C_DOCUMENTLOCATION_POSTVERIFY_DIAGNOSTIC.md`

### Next Boundary

Recommended next action: `G5.2D_PATCH_WATCHDOG_RULE`.

Proposed local-only change, not applied in G5.2C: adjust watchdog so empty `SiteCollectionUrl` is WARN, not DEGRADED, when `AbsoluteUrl` is present and Graph confirms the target. Keep DEGRADED for empty `AbsoluteUrl`, Graph failure, invalid parent/relativeurl, or unreadable DocumentLocation.

## Watchdog SiteCollection Rule Patch G5.2D - 2026-06-25

Mode: LOCAL_PATCH_AND_READ_ONLY_VALIDATE
Dictamen: PASS
Classification: `SITE_COLLECTION_URL_OPTIONAL`

### Change

The watchdog now treats empty `SiteCollectionUrl` as optional when:

- `AbsoluteUrl` is present.
- Graph validates the target driveItem.
- The driveItem exists.

In that case the location output includes:

```json
{
  "classification": "SITE_COLLECTION_URL_OPTIONAL",
  "note": "SiteCollectionUrl empty but AbsoluteUrl + Graph validated"
}
```

### Health

- Before: `DEGRADED`, `locationsReviewed=1`
- After: `YELLOW`, `locationsReviewed=1`
- Graph OK: `true`
- Children count: `50`
- Remaining failed check: `folder_structure_hints:ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d`
- Remaining failed check severity: `INFO`

### Evidence

- Patch evidence: `C:\CEO\watchdog\evidence\watchdog_patch_sitecollection_20260625_011725.json`
- Watchdog evidence after patch: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_010922.json`
- Readback: `C:\CEO\project-cdx\08_READBACKS\20260625_011725_SDU_G5_2D_WATCHDOG_PATCH.md`
- Script hash after: `3E50516AFB81C522D473BD79C2E528CE7A89F2F5B6AD8214BD3F11523FBB4D53`
- Backup: `C:\CEO\watchdog\evidence\watchdog-sharepoint-link_before_sitecollection_patch_20260625_010648.ps1`

### Limits Preserved

- No Dataverse write.
- No SharePoint write.
- No POST/PATCH/PUT/DELETE remote.
- No flows.
- No scheduler.
- No push.
- No PR.

### Next Boundary

G6 can be prepared under formal owner gate. Optional local refinement: review whether `folder_structure_hints` should remain an INFO failed check for this library.
