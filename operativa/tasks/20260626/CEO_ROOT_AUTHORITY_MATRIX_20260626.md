# Matriz de autoridad - C:\CEO

Fecha UTC: 2026-06-26
Modo: READ_ONLY_AUTHORITY_MATRIX_G1

## Resultado

La autoridad viva queda separada por capas:

| Capacidad | Autoridad actual | Evidencia | Estado |
|---|---|---|---|
| Cabina raiz | `C:\CEO` | `C:\CEO\README.md`, `C:\CEO\AGENTS.md`, `C:\CEO\policy.json` | ACTIVA |
| Repo activo | `C:\CEO\project-cdx` junction a `C:\Users\enzo1\PROJEC CDX` | `policy.json.canonical.projectRoot`, AGENTS local | ACTIVA |
| Bootstrap | `C:\CEO\Start-CEO.ps1` | Carga `core\00..99` por dot-source y marca `CEO_BOOT_OK` | ACTIVO, NO EJECUTADO |
| Politica runtime | `C:\CEO\policy.json` | `mode=STRICT`, `owner=PROJEC CDX / CEO`, `writeEvidenceOnBoot=true`, `watch.enabled=true` | ACTIVA |
| Guard bootstrap | `C:\CEO\watch` | `policy.json.watch`, `core\70-Watch.ps1` | FORMAL_BOOTSTRAP_GUARD |
| Observabilidad primaria | `C:\CEO\watchdog` | `.cabina\SDU_RUNTIME_ROOT\05_CONFIG\WATCHDOG_BINDINGS.yaml` | PRIMARY_ACTIVE |
| Watch legacy | `C:\CEO\watch` | `WATCHDOG_BINDINGS.yaml` declara `CEO_WATCH_LEGACY`, `LEGACY_READONLY_STALE`, `do_not_start=true` | PRESERVAR_NO_INICIAR |
| Scheduler watchdog | `C:\CEO\watchdog\scheduler` | JSON de registro declara `CEO_WATCHDOG_PRIMARY` y `CEO_WATCHDOG_TELEMETRY` | REGISTRADO_EN_ARCHIVO, NO_VALIDADO_SO |
| NOC web | `C:\CEO\watchdog\noc-web` | `app.js`, `owner_actions_server.py`, HTML/CSS | ACTIVO_POR_ARCHIVOS, NO_EJECUTADO |
| Bus/eventos | `C:\CEO\watchdog\scripts\g8-event-bus-router.ps1` | Router por alerts/score/recommendations | CAPACIDAD_PRESENTE, NO_EJECUTADA |
| Telemetria | `C:\CEO\watchdog\telemetry.json`, `logs\alerts.jsonl` | Ultimo timestamp observado 2026-06-26 06:19 local | VIVA_POR_ARCHIVOS |
| DocumentLocation | `C:\CEO\watchdog\state`, `logs`, `evidence` | dual anchor `adx_portalcomment` + `cr3c_expediente` | FUERTE, CON_CAPACIDAD_REMOTA_LATENTE |
| Metadata local | `C:\CEO\.metadata` | audit/local-cleanup/tooling/local-config/devcontainers/devdrive/incoming | EVIDENCIA_GOBERNADA |

## Resolucion Operativa

`watchdog` es la superficie operativa primaria para observabilidad/NOC/telemetria. `watch` sigue existiendo como guard de bootstrap heredado por `policy.json` y `core\70-Watch.ps1`, pero el binding canon del repo lo declara legacy read-only stale.

No se debe borrar `watch`, no se debe iniciar `watch`, y no se debe asumir que `watchdog` reemplaza todas las responsabilidades de bootstrap sin una reconciliacion explicita de `policy.json` y `core\70-Watch.ps1`.

## Estado Vivo Observado

- `predictive_score.json`: `score=68`, `health=YELLOW`, `risk=HIGH`, `graphOk=true`.
- `systems_status.json`: `DOCUMENTAL` activo; `EXPEDIENTES`, `FIRMAS`, `COMUNICACIONES`, `RUNTIME` en stub/config.
- `telemetry.json`: actualizado al 2026-06-26 06:19 local.
- `logs\alerts.jsonl`: alertas `HIGH` `LOG_ONLY` hasta 2026-06-26 06:19 local.
- `logs\action_execution.jsonl`: `SYSTEM_AUTO` ejecuto `CHECK_ALERT_SOURCE` el 2026-06-26 01:55 local con impacto declarado `READ_ONLY`.

## Riesgos

- `policy.json.watch.action=Kill` y `CEO-Watchdog.ps1` puede usar `Stop-Process -Force`.
- `watchdog.ps1` puede reiniciar servicios ante eventos de OpenSSH/sshd.
- `run-documentlocation-loop.ps1` contiene capacidad Dataverse `POST`; no ejecutar sin gate live.
- `run-telemetry.ps1` requiere revision sintactica antes de uso; el carril Anubis reporto posible corrupcion alrededor de `ConvertTo-Json | Out-File`.
- NOC/G9 contiene autoacciones locales de bajo riesgo; hoy se observo `SYSTEM_AUTO`.
- `owner_actions_server.py` expone endpoints de ejecucion/autoejecucion/kill-switch; no levantar sin gate.

## Cruces Requeridos

1. Reconciliar `policy.json.watch` y `core\70-Watch.ps1` contra `WATCHDOG_BINDINGS.yaml`.
2. Validar scheduler real del SO solo con gate: no se consulto estado vivo de tareas.
3. Revisar sintaxis de `run-telemetry.ps1` en read-only antes de cualquier arranque.
4. Confirmar si `Start-CEO.ps1` debe seguir exponiendo watch legacy o migrar a wrapper controlado de watchdog.
5. Mantener `C:\CEO\project-cdx` como entrada canonica y no confundir con raiz fisica heredada.
