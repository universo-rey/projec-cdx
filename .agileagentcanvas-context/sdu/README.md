# SDU Native Agile Agent Canvas Context

Este paquete representa SDU como modelo nativo del Agile Agent Canvas.

No usa HTML embebido. Las fuentes SDU se transforman en artefactos, relaciones,
workflows, logs y export institucional.

## Load Existing Project

Usar Agile Agent Canvas: Load Existing Project con:

`./sdu/project.json`

## Contenido

- `project.json`: manifiesto del proyecto SDU en modelo Canvas.
- `artifacts/`: artefactos SDU_SYSTEM, SYSTEM_STATE, WATCHDOG, ACTION_ENGINE, GRAPH_LAYER y COMMAND_LAYER.
- `artifacts/sdu-system.json`: contrato de sistema que apunta a `SYSTEM_NERVOUS_INDEX.json`.
- `tasks/`: acciones SDU convertidas a artefactos TASK.
- `relationships.json`: dependencias nativas entre artefactos.
- `graphify-structure.json`: import Graphify reducido a top nodes, communities y entry points.
- `workflows/start-dev-command-map.json`: mapeo del trigger Start Dev a comandos SDU.
- `logs/action-execution-logs.json`: action_execution.jsonl convertido a LOG artifacts.
- `exports/`: export JSON + Markdown para trazabilidad institucional.
