# SDU NOC Alert Patch

Fecha: 2026-06-25 18:31 ART
Modo: LOCAL CHANGE ONLY

## Estado

HECHO_VERIFICADO: DELTA_APLICADO.

Se elimino la dependencia activa de `Send-MailMessage` del runtime de telemetria del watchdog sin tocar la logica de deteccion, deltas, severidad ni health.

## Sistemas tocados

- `C:\CEO\watchdog\telemetry.ps1`
- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\evidence\noc_alert_patch_20260625_183058.json`

## Sistemas no tocados

- No se modifico `watchdog-sharepoint-link.ps1`.
- No se modifico la logica de checks.
- No Dataverse writes.
- No SharePoint writes.
- No flows.
- No scheduler.
- No push.
- No PR.

## Cambio

Bloque removido:

- SMTP placeholder.
- Credenciales placeholder.
- Invocacion `Send-MailMessage`.

Reemplazo:

- Modo `LOG_ONLY`.
- `Write-Output "ALERT_CAPTURED"`.
- Append centralizado en `C:\CEO\watchdog\logs\alerts.jsonl`.

Formato NOC local:

```json
{
  "timestamp": "...",
  "severity": "...",
  "traceId": "...",
  "delta": {}
}
```

Tambien se incluyen `previousTraceId`, `currentTraceId`, `mode` y `note` para trazabilidad.

## Validacion

- Barrido `Send-MailMessage|smtp.office365|TU_PASSWORD|tu-email`: 0 matches.
- Parse PowerShell de `telemetry.ps1`: OK.
- Watchdog ejecutado: `YELLOW`, `locationsReviewed=15`.
- Alert append observado en `logs\alerts.jsonl`.
- Telemetry ejecuto con `ALERT_CAPTURED`.
- No aparecio warning ni salida asociada al comando obsoleto.

Evidencia:

- `C:\CEO\watchdog\evidence\noc_alert_patch_20260625_183058.json`
- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_183012.json`

## Riesgos

- Las alertas ahora quedan locales hasta implementar un canal NOC externo.
- El estado YELLOW del watchdog permanece por hints informativos de estructura; no esta relacionado con el patch NOC.

## Rollback

Rollback local: revertir el bloque `LOG_ONLY` en `C:\CEO\watchdog\telemetry.ps1` desde backup de sistema o historial operativo. No hay rollback Dataverse ni SharePoint porque no hubo writes externos.

## Opciones futuras no implementadas

- Microsoft Graph Mail API.
- Webhook Teams.
- Dashboard local.

## Proximos carriles

G9/NOC: definir canal externo gobernado para alertas formales, con owner gate, permisos, rollback y postcheck.

## Output Contract

- agente: Codex SDU/Cabina
- orden: SDU_NOC_NOTIFICATION_HARDENING_REPLACE_OBSOLETE_SENDMAIL
- superficie: C:\CEO\watchdog local
- skill: sdu-ejecutor-gates / governed-readback-closeout
- receta: replace obsolete mail send with local append-only NOC capture
- tool: PowerShell + watchdog
- estado: DELTA_APLICADO
- evidencia: `C:\CEO\watchdog\evidence\noc_alert_patch_20260625_183058.json`
- validador: parse OK, no obsolete matches, watchdog run, alert append observed
- riesgo: alertas solo locales hasta canal NOC externo
- rollback: revertir bloque local de `telemetry.ps1`
- stop_condition: none
- proximos_carriles: NOC external channel design
