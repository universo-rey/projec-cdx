# SDU NOC Screen Mode

Fecha: 2026-06-25 18:42 ART
Modo: READ-ONLY + VISUAL + ANALYTICS

## Estado

HECHO_VERIFICADO: DELTA_APLICADO.

Se implemento un dashboard NOC local en modo pantalla con auto-refresh, semaforo ejecutivo, metricas operativas, clasificacion de alertas y snapshot append-only de sesion.

## Sistemas tocados

- `C:\CEO\watchdog\noc-screen.ps1`
- `C:\CEO\watchdog\noclive.ps1`
- `C:\CEO\watchdog\scripts\noclive-alias.ps1`
- `C:\CEO\watchdog\logs\noc_session.jsonl`
- `C:\CEO\watchdog\evidence\noc_screen_deploy_20260625.json`
- `C:\CEO\project-cdx\08_READBACKS\SDU_NOC_SCREEN_MODE.md`

## Sistemas no tocados

- No se modifico `watchdog-sharepoint-link.ps1`.
- No se modifico `run-documentlocation-loop.ps1`.
- No Dataverse.
- No SharePoint.
- No Power Automate.
- No scheduler.
- No logica de negocio.

## Configuracion

- Dashboard: `C:\CEO\watchdog\noc-screen.ps1`
- Wrapper: `C:\CEO\watchdog\noclive.ps1`
- Alias helper: `C:\CEO\watchdog\scripts\noclive-alias.ps1`
- Refresh default: 3 segundos
- Session log: `C:\CEO\watchdog\logs\noc_session.jsonl`
- Evidencia: `C:\CEO\watchdog\evidence\noc_screen_deploy_20260625.json`

Uso:

```powershell
C:\CEO\watchdog\noc-screen.ps1
```

Prueba de una sola renderizacion:

```powershell
C:\CEO\watchdog\noc-screen.ps1 -Once
```

Activar alias en la sesion actual:

```powershell
. C:\CEO\watchdog\scripts\noclive-alias.ps1
noclive
```

## Metricas leidas

Fuentes:

- `C:\CEO\watchdog\logs\sharepoint_link_health.json`
- `C:\CEO\watchdog\state\g6_loop_last.json`
- `C:\CEO\watchdog\logs\g6_loop_events.jsonl`
- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\state\adx_legacy_deprecation.json`

Snapshot de validacion:

- Health: `YELLOW`
- locationsReviewed: `15`
- Checks: `15/63`
- Graph failures: `0`
- Loop runs: `11`
- Created/Reused: `3/7`
- Reuse ratio: `70%`
- Expediente count: `9`
- ADX legacy count: `6`
- Uso dominio real: `60%`
- Stability Score: `82`
- Risk Level: `MEDIUM`

## Comportamiento

- Auto-refresh cada 3 segundos.
- `Q`: salir.
- `R`: refresh manual.
- `F`: freeze/unfreeze.
- Cada render escribe snapshot compacto en `noc_session.jsonl`, salvo que se use `-NoSessionLog`.
- No invoca red, Azure CLI, Dataverse, SharePoint ni scripts de negocio.

## Clasificacion inteligente

Reglas implementadas:

- `HIGH` con mas de 3 eventos en ventana corta: `INCIDENT`.
- `LOW` repetido: `NOISE`.
- Tipo nuevo: `NEW_SIGNAL`.
- Health estable con alertas presentes: `NON_BLOCKING`.

## Deteccion de anomalias

Reglas implementadas:

- Subida abrupta de alertas.
- Caida de `locationsReviewed`.
- Duplicados presentes.
- Senales repetidas.

El residual actual se muestra como:

```text
ANOMALY DETECTED: DUPLICATE_RESIDUAL_ACCEPTED count=1
```

No es bloqueo operativo porque esta aceptado como residual historico.

## Ejemplo visual validado

```text
====================================
SDU NOC DASHBOARD (LIVE MODE)
====================================
SECCION 1 - ESTADO GENERAL
Semaforo Ejecutivo          : YELLOW
Health                      : YELLOW
locationsReviewed           : 15
Graph failures              : 0

SECCION 2 - LOOP
total runs                  : 11
created vs reused           : 3 / 7
reuse ratio                 : 70%

SECCION 3 - ANCHOR MIX
expediente count            : 9
adx count (legacy)          : 6
uso dominio real            : 60%

SECCION 4 - ALERTAS (ultimas 10)
[18:30:37] WARN  NON_BLOCKING  sharepoint_link_watchdog_alert
[18:30:38] HIGH  NON_BLOCKING  LOG_ONLY

EXECUTIVE SUMMARY
System Status               : YELLOW
Risk Level                  : MEDIUM
Stability Score             : 82
Recommendation              : Monitor: watchdog stable with non-blocking warnings.
```

Nota: en algunas capturas no interactivas el simbolo visual de warning puede verse con encoding degradado; el script fuerza UTF-8 para consola interactiva.

## Validacion

- Parse `noc-screen.ps1`: OK.
- Parse `noclive.ps1`: OK.
- Parse `noclive-alias.ps1`: OK.
- Render `-Once`: OK.
- Titulo detectado: OK.
- Executive Summary detectado: OK.
- Anchor Mix detectado: OK.
- Session snapshot append: OK.
- Alias `noclive` validado en sesion: OK.
- Barrido del dashboard: sin `Invoke-RestMethod`, sin Azure CLI, sin Dataverse live.

## Riesgos

- El alias es de sesion PowerShell; para activarlo en una nueva sesion se debe dot-sourcear el helper.
- El dashboard es read-only analitico; no corrige estados ni dispara acciones.
- El residual ADX se muestra como anomalia aceptada para mantener visibilidad.

## Rollback

- Eliminar o archivar `C:\CEO\watchdog\noc-screen.ps1`.
- Eliminar o archivar `C:\CEO\watchdog\noclive.ps1`.
- Eliminar o archivar `C:\CEO\watchdog\scripts\noclive-alias.ps1`.
- No hay rollback Dataverse/SharePoint porque no hubo writes externos.

## Proximos carriles

- NOC G9: definir canal externo gobernado para notificaciones.
- NOC G9.1: dashboard HTML/local si se requiere pantalla compartida no terminal.

## Output Contract

- agente: Codex SDU/Cabina
- orden: SDU_NOC_SCREEN_MODE_AND_INTELLIGENT_ALERTING
- superficie: C:\CEO\watchdog local
- skill: sdu-ejecutor-gates / governed-readback-closeout
- receta: local NOC dashboard from existing JSON/JSONL logs
- tool: PowerShell
- estado: DELTA_APLICADO
- evidencia: `C:\CEO\watchdog\evidence\noc_screen_deploy_20260625.json`
- validador: parse OK, render -Once OK, session snapshot OK
- riesgo: visual-only, residual shown as accepted anomaly
- rollback: remove local dashboard/helper files
- stop_condition: none
- proximos_carriles: NOC external notification channel / optional HTML screen
