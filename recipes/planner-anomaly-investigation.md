# Planner Anomaly Investigation

Recipe G50/G8-ready para investigar anomalías cruzadas entre Planner, watchdog,
VSI/extensiones y runtime SDU sin ejecutar acciones live por inferencia.

## Cuándo Usarla

Cuando una anomalía pueda venir de datos Planner, eventos watchdog, extensiones
VSI o reproduccion de runtime y requiera fan-in multi-agente.

## Mesa Paralela

| thread | agente | skill | tool | salida |
| --- | --- | --- | --- | --- |
| thread_1 | sdu-agent-comms | analyze-planner-data | planner-read-only o local-file-read | planner_signal |
| thread_2 | sdu-agent-runtime | inspect-watchdog-events | local-event-log-read | watchdog_signal |
| thread_3 | sdu-agent-runtime | inspect-vsi-extensions | local-extension-inventory | vsi_signal |
| thread_4 | sdu-orchestrator | reproduce-anomaly | dry-run-reproduction | reproduction_signal |

## Skills Requeridas

| skill | estado actual | implementacion propuesta | stop_condition |
| --- | --- | --- | --- |
| analyze-planner-data | NO_DISPONIBLE | skill read-only que resume planes/tareas saneadas, sin payload sensible ni update | planner_skill_missing |
| inspect-watchdog-events | NO_DISPONIBLE | skill local-only que clasifica eventos watchdog por severidad, dominio y guard | watchdog_skill_missing |
| inspect-vsi-extensions | NO_DISPONIBLE | skill local-only que inventaria extensiones VSI/MCP/plugin y sus gates | vsi_skill_missing |
| reproduce-anomaly | NO_DISPONIBLE | skill dry-run que reconstruye pasos, entradas y esperado sin tocar live | anomaly_reproduction_skill_missing |

## Derivación

1. Emitir `SDU_PLAN_CREATED`.
2. Abrir cuatro threads en paralelo y emitir `SDU_THREAD_STARTED` por thread.
3. Mantener scopes disjuntos y read-only salvo orden gobernada.
4. Validar cada thread con evidencia local y stop condition.
5. Emitir `SDU_THREAD_COMPLETED` por thread.
6. Hacer fan-in: patron comun, causa raiz probable, riesgo y proximo gate.
7. Emitir `SDU_PARALLEL_ANALYSIS_DONE`.

## Validación

- Cada thread tiene agente, skill, tool, evidencia, validador y stop condition.
- Las skills faltantes quedan declaradas como `NO_DISPONIBLE`.
- No hay live write, delete, move, push, PR, secretos ni cambios de permisos.
- La causa raiz se marca `probable` si falta evidencia de una rama.

## Eventos

- `SDU_THREAD_STARTED`
- `SDU_THREAD_COMPLETED`
- `SDU_PARALLEL_ANALYSIS_DONE`

## Stop Condition

- Falta una skill y no hay implementacion propuesta.
- Un thread intenta operar fuera de su scope.
- La investigacion requiere Microsoft live write, secretos, permisos, red o produccion.
- No hay evidencia suficiente para fan-in.
