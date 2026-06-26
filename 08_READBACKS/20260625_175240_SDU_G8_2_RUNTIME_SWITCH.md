# SDU_G8_2_RUNTIME_SWITCH

## Estado

DICTAMEN: PASS

Runtime cambiado a prioridad de dominio sin romper compatibilidad `adx`.

readiness: G8_3_READY

## Cambio Aplicado

Script actualizado:

- repo: tools/run-documentlocation-loop.ps1
- runtime: C:\CEO\watchdog\run-documentlocation-loop.ps1
- backup: C:\CEO\watchdog\run-documentlocation-loop.pre-g8_2_20260625_174706.ps1

Logica nueva:

```text
IF existing eventKey:
    reuse existing anchor (adx or expediente)
ELSE IF cr3c_expediente available:
    create/use cr3c_expediente
ELSE:
    fallback to adx_portalcomment
```

Parametro agregado:

- AnchorMode: auto | expediente | adx
- default: auto

## Contrato

Contrato vigente:

- adx_portalcomment
- cr3c_expediente

Modo: EXTEND_NOT_REPLACE

## Validacion Domain-First

EventKey:

- G8_2_RUNTIME_DOMAIN_20260625_1748

Resultado:

- outcome: PASS
- anchor: cr3c_expediente
- expedienteId: 2e1c2e1e-d770-f111-ab0e-000d3a340906
- documentLocationId: e02dcf09-03d1-4438-9e7b-4a8b4424d41a
- expedienteCreated: true
- documentLocationCreated: true
- duplicate: false
- health: YELLOW
- locationsReviewed: 9

## Validacion Idempotencia

Re-ejecucion mismo EventKey:

- outcome: PASS
- anchor: cr3c_expediente
- anchorReused: true
- documentLocationReused: true
- duplicate: false
- locationsReviewed: 9

## Validacion Compatibilidad ADX

EventKey existente:

- G6_5_OPERATIONAL_20260625_163629

Resultado:

- outcome: PASS
- anchor: adx_portalcomment
- activityId: 5a35472d-cd70-f111-ab0e-000d3a340b69
- documentLocationId: a1132bcd-a0c1-42d1-8595-2505d37d0629
- anchorReused: true
- pocReused: true
- documentLocationReused: true
- duplicate: false
- locationsReviewed: 9

## Health

Estado final watchdog:

- health: YELLOW
- locationsReviewed: 9
- checksTotal: 39
- checksFailed: 9
- watchdog evidence: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_175026.json

## Duplicacion

Total DocumentLocations Dataverse:

- totalDocumentLocations: 9

Nuevo anchor G8.2:

- DocumentLocations para 2e1c2e1e-d770-f111-ab0e-000d3a340906: 1

Duplicado residual:

- sigue existiendo 1 grupo historico PRE_FIX
- no fue limpiado
- no fue modificado

## Evidencia

- evidencia consolidada: C:\CEO\watchdog\evidence\g8_2_runtime_switch_20260625_175238.json
- domain run: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_174732.json
- idempotency run: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_174831.json
- adx compatibility run: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_175020.json
- contract: C:\CEO\watchdog\state\documentlocation_anchor_contract.json

## Sistemas Tocados

- Runtime local: C:\CEO\watchdog\run-documentlocation-loop.ps1
- Repo local: tools/run-documentlocation-loop.ps1
- Dataverse: 1 cr3c_expediente nuevo por test domain-first
- Dataverse: 1 sharepointdocumentlocation nuevo por test domain-first
- Estado local: documentlocation-loop-state.json, g6_loop_last.json
- Telemetria local: g6_loop_events.jsonl
- Evidencia local: C:\CEO\watchdog\evidence

## Sistemas No Tocados

- adx_portalcomment existente: no reemplazado
- SharePoint: sin writes, sin carpetas nuevas
- Scheduler: sin cambios
- Power Automate: sin flows
- DELETE: no ejecutado
- PATCH/PUT: no ejecutado
- cleanup duplicados: no ejecutado
- migracion masiva: no ejecutada
- Git remoto: sin push, sin PR

## Riesgos

El nombre del archivo de telemetria sigue siendo g6_loop_events.jsonl por compatibilidad historica, aunque ahora registra anchorLogicalName y anchorId.

Health permanece YELLOW por warnings informativos ya esperados del watchdog.

## Rollback

Rollback local disponible:

- restaurar C:\CEO\watchdog\run-documentlocation-loop.pre-g8_2_20260625_174706.ps1 sobre C:\CEO\watchdog\run-documentlocation-loop.ps1
- revertir tools/run-documentlocation-loop.ps1 en repo

Rollback remoto no ejecutado y requiere gate separado:

- sharepointdocumentlocation: e02dcf09-03d1-4438-9e7b-4a8b4424d41a
- expediente: 2e1c2e1e-d770-f111-ab0e-000d3a340906

## Stop Condition

Detener siguientes fases si:

- AnchorMode auto deja de crear cr3c_expediente cuando esta disponible
- AnchorMode adx deja de reusar eventKeys historicos
- locationsReviewed baja de 9 sin causa explicita
- aparece duplicado para un expediente nuevo
- Graph deja de validar BIB_DOC_Expediente

## Proximos Carriles

G8.3: separar telemetria nominal de G6/G8 o documentar el alias historico.

G8.4: disenar migracion controlada de consumidores hacia `anchorLogicalName/anchorId`, manteniendo `activityId` solo como compatibilidad adx.
