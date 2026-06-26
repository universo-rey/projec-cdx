# SDU G8.5 - Final Normalization and Legacy Deprecation

Fecha: 2026-06-25 18:26 ART
Modo: HARDENING + READ/WRITE CONTROLADO
Entorno: HUBDesarrollo

## Estado

HECHO_VERIFICADO: PASS.

Se cerro la dependencia activa de ADX sin modificar registros `adx_portalcomment` en Dataverse. La deprecacion quedo registrada como metadata local y evidencia auditable.

## Sistemas tocados

- Dataverse HUBDesarrollo: solo GET.
- `C:\CEO\watchdog\state\adx_legacy_deprecation.json`: metadata local legacy.
- `C:\CEO\watchdog\config.sharepoint-link.json`: normalizado `sharePointLink.top = 25`.
- `C:\CEO\watchdog\evidence\`: evidencia G8.5 y watchdog.

## Sistemas no tocados

- No se modificaron registros `adx_portalcomment`.
- No DELETE.
- No PATCH/PUT.
- No carpetas SharePoint.
- No flows.
- No scheduler.
- No push.
- No PR.

## Cambios

Metadata local creada para todos los ADX:

```json
{
  "status": "LEGACY",
  "migrationStatus": "COMPLETED",
  "noFurtherUse": true
}
```

Configuracion watchdog:

- Antes: `sharePointLink.top = 10`
- Despues: `sharePointLink.top = 25`
- Backup: `C:\CEO\watchdog\config.sharepoint-link.pre-g8_5_20260625_182545.json`

## Validacion

- Total `adx_portalcomment`: 5
- Legacy completados: 5
- Incompletos: 0
- Todos tienen expediente equivalente: si
- Todos tienen DocumentLocation equivalente: si
- `adx creation = DISABLED`: si
- fallback automatico ADX: disabled
- via manual equivalente: `AnchorMode adx + AllowAdxCreate`
- Watchdog: YELLOW
- `locationsReviewed`: 15 / 15
- Graph failures: 0
- Non-info failed checks: 0

El estado YELLOW no degrada: solo quedan checks informativos de estructura de carpetas.

## Residual

```json
{
  "type": "PRE_FIX_DUPLICATE",
  "status": "ACCEPTED",
  "action": "NO_AUTO_DELETE",
  "reason": "historical traceability preservation"
}
```

Residual preservado:

- `regardingObjectId`: `d4f4dbac-5370-f111-ab0e-000d3a340b69`
- Tipo: `adx_portalcomment`
- DocumentLocations: 2
- Accion: no auto delete

## Evidencia

- G8.5: `C:\CEO\watchdog\evidence\g8_5_final_normalization_20260625_182545.json`
- Metadata local: `C:\CEO\watchdog\state\adx_legacy_deprecation.json`
- Watchdog: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_182549.json`
- Config backup: `C:\CEO\watchdog\config.sharepoint-link.pre-g8_5_20260625_182545.json`

## Riesgos

- ADX queda disponible solo como compatibilidad historica y trazabilidad.
- La via manual ADX existe para contingencia controlada; no hay fallback automatico.
- El residual historico no se limpia automaticamente por preservacion de trazabilidad.

## Rollback

- Restaurar config desde `C:\CEO\watchdog\config.sharepoint-link.pre-g8_5_20260625_182545.json`.
- Remover/archivar solo metadata local `adx_legacy_deprecation.json` si se revierte la decision de deprecacion.
- No hay rollback Dataverse porque no hubo writes Dataverse en G8.5.

## Proximos carriles

G9 recomendado: operar carril documental domain-only con `cr3c_expediente`, mantener ADX en observacion read-only y preparar limpieza manual del residual solo bajo orden explicita, con rollback y aprobacion formal.

## Output Contract

- agente: Codex SDU/Cabina
- orden: SDU_G8_5_FINAL_NORMALIZATION_AND_LEGACY_DEPRECATION
- superficie: Dataverse read-only + C:\CEO\watchdog local
- skill: sdu-ejecutor-gates / no-inference-runtime-write-guard / governed-readback-closeout
- receta: legacy local metadata + watchdog coverage normalization + consistency validation
- tool: PowerShell + Azure CLI token + watchdog
- estado: PASS
- evidencia: `C:\CEO\watchdog\evidence\g8_5_final_normalization_20260625_182545.json`
- validador: watchdog `locationsReviewed=15`, Graph failures `0`
- riesgo: residual ADX historico aceptado
- rollback: config backup + no Dataverse rollback required
- stop_condition: none
- proximos_carriles: G9 domain-only operations
