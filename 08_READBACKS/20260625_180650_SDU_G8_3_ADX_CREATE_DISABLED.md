# SDU_G8_3_ADX_CREATE_DISABLED

## Estado

DICTAMEN: PASS

Creacion nueva de `adx_portalcomment` deshabilitada en el loop.

Compatibilidad historica `adx` mantenida por reuse de state.

readiness: G8_4_READY

## Cambio Aplicado

Script actualizado:

- repo: tools/run-documentlocation-loop.ps1
- runtime: C:\CEO\watchdog\run-documentlocation-loop.ps1
- backup: C:\CEO\watchdog\run-documentlocation-loop.pre-g8_3_20260625_180101.ps1

Regla nueva:

```text
IF existing eventKey:
    reuse existing anchor (adx or expediente)
ELSE IF AnchorMode = auto:
    IF cr3c_expediente available:
        create/use cr3c_expediente
    ELSE:
        FAIL_CONTROLLED: NO_EXPEDIENTE_AVAILABLE
ELSE IF AnchorMode = expediente:
    require cr3c_expediente
ELSE IF AnchorMode = adx:
    reuse historical state only
    new adx creation blocked unless explicit AllowAdxCreate is present
```

## Contrato

Contrato local:

- C:\CEO\watchdog\state\documentlocation_anchor_contract.json

Estado:

- mode: DUAL_ANCHOR_ADX_CREATE_DISABLED
- adxReuseEnabled: true
- adxCreationEnabled: false
- automaticAdxPortalCommentCreate: false
- autoFailureWhenNoExpediente: NO_EXPEDIENTE_AVAILABLE

## Validacion Auto Domain

EventKey:

- G8_3_AUTO_DOMAIN_20260625_1802

Resultado:

- outcome: PASS
- anchor: cr3c_expediente
- expedienteId: 8bb5fb24-d970-f111-ab0e-000d3a340f50
- pocCreated: false
- documentLocationId: 6f917c63-d789-48f2-904d-4d47223c51ca
- documentLocationCreated: true
- locationsReviewed: 10
- health: YELLOW

## Validacion Idempotencia

Re-ejecucion mismo EventKey:

- outcome: PASS
- anchor: cr3c_expediente
- expedienteReused: true
- documentLocationReused: true
- duplicate: false

## Validacion ADX Historico

EventKey:

- G6_5_OPERATIONAL_20260625_163629

Resultado:

- outcome: PASS
- anchor: adx_portalcomment
- activityId: 5a35472d-cd70-f111-ab0e-000d3a340b69
- adxCreationAllowed: false
- pocCreated: false
- pocReused: true
- documentLocationReused: true

## Validacion ADX Nuevo Bloqueado

EventKey:

- G8_3_ADX_BLOCKED_20260625_1805

Resultado:

- outcome: FAIL controlado
- error: FAIL_CONTROLLED: ADX_CREATION_DISABLED
- activityId: null
- pocCreated: false
- documentLocationCreated: false

## Conteos

Antes:

- adxPortalComments: 5
- DocumentLocations: 9
- locationsReviewed: 9

Despues:

- adxPortalComments: 5
- DocumentLocations: 10
- locationsReviewed: 10

Conclusion:

- no se creo ningun `adx_portalcomment` nuevo
- se creo 1 nuevo vinculo por `cr3c_expediente`
- el unico duplicado sigue siendo el residual historico PRE_FIX

## Evidencia

- evidencia consolidada: C:\CEO\watchdog\evidence\g8_3_adx_creation_disabled_20260625_180649.json
- auto domain: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_180207.json
- idempotency: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_180327.json
- adx historical reuse: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_180404.json
- adx blocked: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_180454.json
- final pass: C:\CEO\watchdog\evidence\documentlocation_loop_run_20260625_180512.json
- watchdog final: C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_180518.json

## Sistemas Tocados

- Runtime local: C:\CEO\watchdog\run-documentlocation-loop.ps1
- Repo local: tools/run-documentlocation-loop.ps1
- Contrato local: C:\CEO\watchdog\state\documentlocation_anchor_contract.json
- Dataverse: 1 cr3c_expediente nuevo por test auto domain
- Dataverse: 1 sharepointdocumentlocation nuevo por test auto domain
- Estado local: documentlocation-loop-state.json, g6_loop_last.json
- Telemetria local: g6_loop_events.jsonl
- Evidencia local: C:\CEO\watchdog\evidence

## Sistemas No Tocados

- adx_portalcomment existente: no reemplazado
- adx_portalcomment nuevo: no creado
- SharePoint: sin writes, sin carpetas nuevas
- Scheduler: sin cambios
- Power Automate: sin flows
- DELETE: no ejecutado
- PATCH/PUT: no ejecutado
- cleanup duplicados: no ejecutado
- migracion masiva: no ejecutada
- Git remoto: sin push, sin PR

## Riesgos

Existe un switch `AllowAdxCreate` como escape explicito. No esta activo por default y no fue usado en validacion G8.3.

El health permanece YELLOW por warnings informativos conocidos del watchdog.

## Rollback

Rollback local:

- restaurar C:\CEO\watchdog\run-documentlocation-loop.pre-g8_3_20260625_180101.ps1 sobre C:\CEO\watchdog\run-documentlocation-loop.ps1
- revertir tools/run-documentlocation-loop.ps1 en repo
- restaurar contrato local previo si se requiere

Rollback remoto no ejecutado y requiere gate separado:

- sharepointdocumentlocation: 6f917c63-d789-48f2-904d-4d47223c51ca
- expediente: 8bb5fb24-d970-f111-ab0e-000d3a340f50

## Stop Condition

Detener siguientes fases si:

- adxPortalComments aumenta sin gate explicito
- AnchorMode auto intenta crear adx
- EventKey historico adx deja de reusar
- locationsReviewed baja de 10 sin causa explicita
- aparece duplicado para un expediente nuevo

## Proximos Carriles

G8.4: retirar dependencia operativa del nombre historico `g6_loop_events.jsonl` o declarar alias estable.

G8.5: revisar consumidores para que usen `anchorLogicalName` y `anchorId` como contrato primario.
