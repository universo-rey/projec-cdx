# SDU Native Agile Agent Canvas Export

Estado: READY

## Modelo

SDU fue transformado a artefactos nativos del Agile Agent Canvas, sin HTML
embebido y sin ejecutar acciones.

## Artefactos

- SYSTEM_STATE: Architecture con health, score y risk.
- WATCHDOG: Component con estado y alertas.
- ACTION_ENGINE: Component con acciones disponibles.
- GRAPH_LAYER: Architecture con integracion Graphify reducida.
- COMMAND_LAYER: Component con scripts ejecutables modelados.
- check_alert_source: TASK con impacto, riesgo y script asociado.
- evaluate_cleanup: TASK con impacto, riesgo y script asociado.
- action_execution: LOG artifacts desde `action_execution.jsonl`.

## Relaciones

- SYSTEM_STATE -> WATCHDOG
- WATCHDOG -> ACTION_ENGINE
- ACTION_ENGINE -> COMMAND_LAYER
- COMMAND_LAYER -> GRAPH_LAYER

## Workflows

Start Dev (rocket) se mapea a comandos SDU mediante
`workflows/start-dev-command-map.json`.

## AI Features

- Refine: mejorar diagnostico.
- Elicit: generar hipotesis.
- Ask Agent: interpretar estado y seguridad de accion.

## Navegacion

Focus Mode (F) usa SYSTEM_STATE como raiz y recorre:

SYSTEM_STATE -> WATCHDOG -> ACTION_ENGINE -> COMMAND_LAYER -> GRAPH_LAYER

## Export

Export JSON: `exports/sdu-native-project.json`

Export Markdown: `exports/sdu-native-project.md`
