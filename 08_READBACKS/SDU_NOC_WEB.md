# SDU NOC Web Dashboard

Fecha: 2026-06-25 18:55 ART
Modo: READ-ONLY / WEB / VISUAL / ANALYTICS

## Estado

HECHO_VERIFICADO: DELTA_APLICADO.

Se creo un dashboard web local tipo SOC para visualizar estado SDU en tiempo real usando exclusivamente los logs y estados existentes indicados por la orden.

Actualizacion 2026-06-25 18:59 ART: se alineo el source of truth del panel de estado. El dashboard ahora prioriza la ultima evidencia `sharepoint_link_watchdog_*.json`; si no existe, cae a la ultima evidencia `g8_*.json`; si tampoco existe, usa `g6_loop_last.json`.

## Sistemas tocados

- `C:\CEO\watchdog\noc-web\index.html`
- `C:\CEO\watchdog\noc-web\app.js`
- `C:\CEO\watchdog\noc-web\styles.css`
- `C:\CEO\watchdog\noc-web\serve.ps1`
- `C:\CEO\watchdog\evidence\noc_web_dashboard_20260625.json`
- `C:\CEO\project-cdx\08_READBACKS\SDU_NOC_WEB.md`

## Sistemas no tocados

- No se modifico `watchdog-sharepoint-link.ps1`.
- No se modifico `run-documentlocation-loop.ps1`.
- No Dataverse.
- No SharePoint.
- No Power Automate.
- No scheduler.
- No logica de negocio.

## Configuracion

Carpeta:

```text
C:\CEO\watchdog\noc-web\
```

Archivos:

```text
index.html
app.js
styles.css
serve.ps1
```

Servidor:

```powershell
C:\CEO\watchdog\noc-web\serve.ps1
```

URL:

```text
http://localhost:8080/noc-web/
```

Nota tecnica: `serve.ps1` sirve desde `C:\CEO\watchdog` para que el dashboard pueda leer por HTTP `/state/...` y `/logs/...` sin copiar ni modificar fuentes.

## Fuentes usadas

Fuentes operativas:

- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_*.json` latest
- `C:\CEO\watchdog\evidence\g8_*.json` latest
- `C:\CEO\watchdog\state\g6_loop_last.json`
- `C:\CEO\watchdog\logs\g6_loop_events.jsonl`
- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\state\system_snapshot.json`

Prioridad de estado:

1. `sharepoint_link_watchdog_*.json` latest
2. `g8_*.json` latest
3. `g6_loop_last.json`

Fuente efectiva validada:

- Label UI: `DATA SOURCE: WATCHDOG`
- Archivo: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_183012.json`
- Health: `YELLOW`
- locationsReviewed: `15`
- Graph failures: `0`

## Metricas leidas

Desde el source of truth alineado:

- Health: `YELLOW`
- locationsReviewed: `15`
- lastRunId: `c19d1710-44d1-4b10-9d1a-bb5db566fa9b`
- EventKey: `G8_3_AUTO_DOMAIN_20260625_1802`
- Event lines: `11`
- Alert lines: `31`

## Comportamiento

- Tema SOC oscuro.
- Layout: Header / Status / Loop / Anchors / Alerts / Timeline / Intelligence.
- Auto-refresh: `setInterval(render, 3000)`.
- Lectura via `fetch`.
- Parse JSONL para eventos y alertas.
- Normalizacion de BOM UTF-8 antes de `JSON.parse`.
- Descubrimiento de evidencia por indice HTTP `/evidence/`.
- Cache-bust activo: `app.js?v=20260625-1905`.
- Sin backend propio.
- Sin llamadas a Azure CLI, Dataverse o SharePoint.

## Semaforo

Reglas:

- `HEALTHY` -> verde.
- `YELLOW` -> amarillo.
- `DEGRADED` -> rojo.

## Loop

Calcula desde `g6_loop_events.jsonl`:

- total runs.
- created.
- reused.
- reuse ratio.

## Anchors

Calcula desde eventos:

- conteo `cr3c_expediente`.
- conteo `adx_portalcomment`.
- porcentaje relativo.

## Alertas inteligentes

Reglas:

- Muchos `HIGH` en ventana corta -> `INCIDENT`.
- `LOW` repetido -> `NOISE`.
- Tipo nuevo -> `NEW_SIGNAL`.
- Health estable con alertas -> `NON_BLOCKING`.

## Timeline

Muestra ultimos eventos:

- runId.
- timestamp.
- created/reused/outcome.
- anchorType.

## Validacion

- Server local en `8080`: listening.
- `index.html`: HTTP 200.
- `app.js`: HTTP 200.
- `styles.css`: HTTP 200.
- `g6_loop_last.json`: HTTP 200.
- `g6_loop_events.jsonl`: HTTP 200.
- `alerts.jsonl`: HTTP 200.
- `system_snapshot.json`: HTTP 200.
- `indexHasTitle`: true.
- `appHasRefresh`: true.
- `appHasBomStrip`: true.
- `appHasAlertClassification`: true.
- `appUsesOnlyAllowedSources`: true.
- `appImportWithRealData`: OK con Node REPL + DOM/fetch simulados.
- `appImportWithRealData`: OK `WATCHDOG/YELLOW/15`.
- `indexHasDataSource`: true.
- Browser abierto: true.

Playwright visual smoke no se pudo completar por restriccion local `EPERM` del runtime de navegador de Codex; se valido por HTTP, import JS con datos reales y apertura del navegador local.

## Evidencia

- `C:\CEO\watchdog\evidence\noc_web_dashboard_20260625.json`
- `C:\CEO\watchdog\evidence\noc_web_alignment.json`

## Riesgos

- La URL efectiva del dashboard es `/noc-web/`; la raiz `http://localhost:8080` queda como raiz del servidor para exponer `state` y `logs`.
- `system_snapshot.json` puede quedar historico si no se regenera; ya no gobierna el estado principal del panel.
- El descubrimiento de evidencia depende de que el servidor local permita listar `/evidence/`, comportamiento disponible con `python -m http.server`.
- Es visual/read-only: no corrige estados ni dispara acciones.

## Rollback

- Eliminar o archivar `C:\CEO\watchdog\noc-web\`.
- Detener el proceso `python -m http.server 8080` si queda corriendo.
- No hay rollback Dataverse/SharePoint porque no hubo writes externos.

## Proximos carriles

- NOC WEB G9.1: si se requiere URL raiz directa, agregar redireccion controlada en `C:\CEO\watchdog\index.html`.
- NOC WEB G9.2: opcional mini-servidor con API read-only para snapshot consolidado, si se quiere evitar exponer directorios por `http.server`.

## Output Contract

- agente: Codex SDU/Cabina
- orden: SDU_NOC_WEB_DASHBOARD_REALTIME_SOC_MODE
- superficie: C:\CEO\watchdog\noc-web local
- skill: sdu-ejecutor-gates / governed-readback-closeout
- receta: static SOC dashboard over existing JSON/JSONL logs
- tool: PowerShell + HTTP static server + Node REPL validation
- estado: DELTA_APLICADO
- evidencia: `C:\CEO\watchdog\evidence\noc_web_dashboard_20260625.json`
- validador: HTTP 200 sources, app import with real data, browser opened
- riesgo: visual-only, snapshot source may be stale until regenerated
- rollback: remove noc-web and stop local server
- stop_condition: none
- proximos_carriles: root redirect or optional read-only API server
