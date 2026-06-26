# READBACK_SDU_NOC_INTELLIGENCE_20260625

## Estado
HECHO_VERIFICADO: NOC web elevado a inteligencia predictiva, multi-sistema y outbox externo seguro sin envio automatico.

## Sistemas tocados
- Local files: C:\CEO\watchdog\intelligence.ps1
- Local files: C:\CEO\watchdog\config\systems.json
- Local files: C:\CEO\watchdog\noc-web\index.html
- Local files: C:\CEO\watchdog\noc-web\app.js
- Local files: C:\CEO\watchdog\noc-web\styles.css
- Local outputs: C:\CEO\watchdog\state\predictive_score.json
- Local outputs: C:\CEO\watchdog\logs\anomalies.jsonl
- Local outputs: C:\CEO\watchdog\outbox\alerts_out.jsonl

## Sistemas no tocados
- Dataverse: no tocado
- SharePoint: no tocado
- watchdog core: no modificado
- run-documentlocation-loop.ps1: no modificado
- scheduler: no creado ni activado
- integraciones externas: no enviadas

## Cambios
- Agregado motor local intelligence.ps1 con score 0-100 ponderado por health, alertas, loop, variacion locationsReviewed y Graph.
- Agregado systems.json con carriles DOCUMENTAL y RUNTIME en modo configuracion/read-only.
- Agregado predictive_score.json como salida consolidada para UI.
- Agregado anomalies.jsonl append-only con deteccion temprana.
- Agregado alerts_out.jsonl webhook-ready con sendMode=NOT_SENT.
- NOC web muestra score gauge, tendencia, top alert, sistema critico, grid multi-sistema y clasificacion avanzada.
- Refresh mantiene setInterval con debounce y diff rendering.

## Validacion
- Score: 70
- Trend: STABLE
- Risk: HIGH
- Health: YELLOW
- locationsReviewed: 15
- Graph OK: True
- HTTP dashboard OK: True
- HTTP predictive_score OK: True
- Node REPL app render: OK WATCHDOG/YELLOW/15/70/HIGH
- Evidence: C:\CEO\watchdog\evidence\noc_intelligence_upgrade.json

## Riesgos
- RUNTIME queda como carril configurado/read-only hasta que exista fuente formal de estado.
- Alertas historicas recientes elevan risk=HIGH aunque health permanezca YELLOW y Graph OK.
- Outbox es preparacion local; no implica entrega real a Teams, Webhook o Email.

## Rollback
- Restaurar app.js/index.html/styles.css desde version anterior si la UI no carga.
- Remover lectura de predictive_score.json en app.js para volver a source-of-truth WATCHDOG directo.
- Mantener logs generados como evidencia; no requieren cleanup automatico.

## Proximos carriles
- G7/NOC: definir fuente runtime formal para carriles adicionales.
- G7/NOC: gate separado para envio real Teams/Webhook.
- G7/NOC: calibrar umbrales de score con mas ventana historica.

## Contrato
- agente: Codex
- orden: SDU_NOC_INTELLIGENCE_MULTI_SYSTEM_AND_EXTERNAL_INTEGRATION
- superficie: local NOC dashboard
- skill: sdu-ejecutor-gates, governed-readback-closeout
- receta: read-only analytics + optional local output
- tool: powershell local + node_repl validation
- estado: DELTA_APLICADO
- evidencia: C:\CEO\watchdog\evidence\noc_intelligence_upgrade.json
- validador: intelligence.ps1 + HTTP localhost + node_repl render
- riesgo: bajo/medio por output local nuevo
- rollback: revertir NOC web a lectura WATCHDOG directa
- stop_condition: ninguna activa
- proximos_carriles: runtime source + external send gate