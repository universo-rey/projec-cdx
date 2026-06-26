# SDU_AGENT_CANVAS

Estado: PASS

## Resultado

Se preparo `C:\CEO\watchdog\noc-web\canvas.html` como Canvas unificado local.

Integra:

- Estado NOC desde `predictive_score.json`, `g6_loop_last.json` y `anomalies.jsonl`.
- Inteligencia desde score y recomendaciones.
- Acciones desde `actions_catalog.json` reutilizando `POST /execute`.
- Confirmacion avanzada con modal propio, sin `confirm()`.
- Estructura Graphify desde vistas preprocesadas en `graphify-out/views/*.json`.
- Historial unificado desde `action_execution.jsonl`, `alerts.jsonl` y `anomalies.jsonl`.

## Vistas Graphify

El Canvas no carga `graph.json` completo.

Vistas creadas:

- `C:\CEO\watchdog\graphify-out\views\watchdog.json`
- `C:\CEO\watchdog\graphify-out\views\noc.json`
- `C:\CEO\watchdog\graphify-out\views\commands.json`
- `C:\CEO\watchdog\graphify-out\views\runtime.json`
- `C:\CEO\watchdog\graphify-out\views\index.json`

## Controles

- Estado refresca cada 3 segundos.
- Graph carga on demand.
- Historial refresca incrementalmente cada 5 segundos.
- Click en alerta/anomalia abre grafo filtrado.
- Ejecucion de accion muestra nodo relacionado y foco en `Commands`.
- No se creo endpoint nuevo.

## Superficies No Tocadas

- Dataverse: no tocado.
- SharePoint: no tocado.
- Watchdog core: no modificado.
- Loop base: no modificado.

## Evidencia

- `C:\CEO\watchdog\evidence\canvas_unified_layer.json`

## Validacion Local

- URL operativa con endpoint `/execute`: `http://127.0.0.1:8081/noc-web/canvas.html`
- `GET /noc-web/canvas.html`: `200`
- `GET /graphify-out/views/index.json`: `200`
- `POST /execute` con actionId inexistente: `404 action not found`
- `action_execution.jsonl` permanecio sin escrituras durante la validacion.
- `http://127.0.0.1:8080` sigue sirviendo el panel estatico existente, pero ese proceso devuelve `501` para `POST /execute`.

## Cierre

Agile Agent Canvas operativo completo.
