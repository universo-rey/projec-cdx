# Delta watch vs watchdog

Fecha UTC: 2026-06-26
Modo: READ_ONLY_DELTA_G1

## Resumen

`C:\CEO\watchdog` es la superficie primaria actual de observabilidad, NOC, telemetria, bus, acciones y evidencia. `C:\CEO\watch` queda como guard heredado/legacy, preservado por eventos y baseline, pero no debe iniciarse ni borrarse.

## Comparacion

| Dimension | `C:\CEO\watch` | `C:\CEO\watchdog` |
|---|---|---|
| Rol | Guard base de bootstrap | Observabilidad/NOC/runtime ampliado |
| Estado canon | `LEGACY_READONLY_STALE` por binding repo | `PRIMARY_ACTIVE` por binding repo |
| Entradas | `policy.json`, baseline activo, procesos, manifest snapshot | alerts, logs, evidence, state, configs, scheduler, NOC web |
| Salidas | `events\watch-YYYYMMDD.jsonl`, `pid.txt` | `telemetry.json`, `alerts.jsonl`, `action_execution.jsonl`, state, outbox, evidence |
| Riesgo principal | `Kill`/`Stop-Process -Force`, PID stale | Autoacciones, scheduler, NOC execute endpoints, scripts con capacidad remota |
| Ultima senal | `pid.txt` timestamp 2026-06-22; eventos hasta 2026-06-23 | telemetry/alerts hasta 2026-06-26 06:19 local |
| Volumen inventario | 7 archivos escaneados | 287 archivos escaneados en profundidad 4 |
| Accion recomendada | Preservar, no iniciar, no borrar | Auditar y gobernar como primaria |

## Watch

Hallazgos:

- `active-baseline.txt`: `20260622-030444-industrial-ops-integrated`.
- `pid.txt`: `16872`; el carril Horus reporto que ese PID resuelve hoy como `svchost`, por lo que debe tratarse como stale/reutilizado, no prueba de watchdog vivo.
- `CEO-Watchdog.ps1` usa `C:\CEO\watch`, no invoca `C:\CEO\watchdog`.
- Eventos posibles: `WATCHDOG_STARTED`, `FORBIDDEN_PROCESS`, `FILE_DRIFT`, `FILE_MISSING`, `NO_ACTIVE_BASELINE`, `WATCHDOG_STOPPED`.
- `core\70-Watch.ps1` define `ceo-watch-start`, `ceo-watch-stop`, `ceo-watch-status`, `ceo-watch-log`, `ceo-watch-events`.

Riesgos:

- Puede matar procesos por politica.
- Puede loguear `CommandLine` de procesos.
- `pid.txt` stale puede inducir lectura falsa de runtime activo.
- Comparacion de hashes cada 5 segundos puede ser ruidosa.

## Watchdog

Hallazgos:

- `WATCHDOG_BINDINGS.yaml`: `WATCHDOG_L6`, root `C:\CEO\watchdog`, `PRIMARY_ACTIVE`.
- `telemetry.json`: `runs` y `resume`; ultima escritura 2026-06-26 06:19 local.
- `predictive_score.json`: `score=68`, `YELLOW`, `HIGH`, `graphOk=true`.
- `systems_status.json`: documental activo, otros sistemas en stub/config.
- `operational_rhythm_g8_beta.json`: low-risk only, human gate required, blocked impacts Dataverse/SharePoint/externalWrites/runtimeMutation.
- `actions_live_catalog.json`: acciones declaradas con `requiresApproval=true`, `mutatesData=false`, `impactsDataverse=false`, `impactsSharePoint=false`.
- `action_execution.jsonl`: evidencia de `SYSTEM_AUTO` para `CHECK_ALERT_SOURCE`, impacto `READ_ONLY`.
- `scheduler\watchdog-scheduler.status.json`: tareas declaradas `CEO_WATCHDOG_PRIMARY` y `CEO_WATCHDOG_TELEMETRY`, no validadas contra SO vivo.

Riesgos:

- Mezcla observabilidad read-only con ejecucion local y capacidades remotas latentes.
- `run-documentlocation-loop.ps1` puede postear Dataverse si se ejecuta con gates/credenciales.
- `watchdog.ps1` puede reiniciar servicios.
- `owner_actions_server.py` tiene endpoints de ejecucion, autoejecucion y kill-switch.
- `serve.ps1`/NOC web requiere reconciliar puertos antes de levantar.

## Decision

Autoridad de lectura actual:

- Primaria: `C:\CEO\watchdog`.
- Legacy preservado: `C:\CEO\watch`.
- Pendiente gobernado: reconciliar bootstrap `policy/core` con binding `WATCHDOG_L6`.
