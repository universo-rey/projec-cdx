# SDU G5.2D Watchdog Patch

Mode: LOCAL_PATCH_AND_READ_ONLY_VALIDATE
Dictamen: PASS
Classification: SITE_COLLECTION_URL_OPTIONAL

## Motivo

G5.2C confirmó que el DocumentLocation funciona: AbsoluteUrl existe, Graph resuelve la biblioteca, y hay hijos. El único motivo de DEGRADED era que SiteCollectionUrl venía vacío y el watchdog lo trataba como HIGH antes de validar Graph.

## Lógica Anterior

- SiteCollectionUrl vacío hacía etrieve_absolute_url -> ok=false, severity=HIGH.
- Eso impedía la validación Graph.
- Resultado anterior: DEGRADED, locationsReviewed=1.

## Lógica Nueva

- Si AbsoluteUrl existe, se permite validar Graph aunque SiteCollectionUrl esté vacío.
- Si Graph valida driveItem, se agrega classification=SITE_COLLECTION_URL_OPTIONAL.
- Se agrega nota: SiteCollectionUrl empty but AbsoluteUrl + Graph validated.
- DEGRADED queda reservado para AbsoluteUrl vacío, Graph fallido o ubicación ilegible.

## Health

- Antes: DEGRADED / locationsReviewed=1
- Después: YELLOW / locationsReviewed=1
- Failed checks actuales: folder_structure_hints:ba8a2aec-7caa-4c1c-b728-86c51b2f5b8d
- Watchdog evidence: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_010922.json

## Evidencia G5.2C

- C:\CEO\watchdog\evidence\documentlocation_postverify_diagnostic_20260625_010242.json

## Evidencia G5.2D

- Patch evidence: C:\CEO\watchdog\evidence\watchdog_patch_sitecollection_20260625_011725.json
- Script hash before: 779056FDE2FC6466F9D2B53FDDFDF0324A20031CE88D9F4EB761F5F6211DF89E
- Script hash after: 3E50516AFB81C522D473BD79C2E528CE7A89F2F5B6AD8214BD3F11523FBB4D53
- Backup: C:\CEO\watchdog\evidence\watchdog-sharepoint-link_before_sitecollection_patch_20260625_010648.ps1

## Confirmaciones

- No Dataverse write.
- No SharePoint write.
- No POST/PATCH/PUT/DELETE remoto.
- No flows.
- No scheduler.
- No push.
- No PR.

## Git Status Short

`	ext
A  08_READBACKS/20260625_004013_SDU_G5_SHAREPOINTSITE_CREATE.md
A  08_READBACKS/20260625_004552_SDU_G5_2_DOCUMENTLOCATION_CREATE.md
A  08_READBACKS/20260625_005426_SDU_G5_2B_DOCUMENTLOCATION_RELATIVEURL_ONLY.md
A  08_READBACKS/20260625_005722_SDU_G5_2B_DOCUMENTLOCATION_RELATIVEURL_ONLY.md
A  08_READBACKS/20260625_010242_SDU_G5_2C_DOCUMENTLOCATION_POSTVERIFY_DIAGNOSTIC.md
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

## Próximo Paso

G6 puede prepararse bajo owner gate formal. Queda opcional revisar si older_structure_hints debe seguir como INFO no bloqueante para esta biblioteca.
