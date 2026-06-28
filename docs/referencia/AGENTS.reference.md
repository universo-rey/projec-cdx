---
artifact_id: docs/referencia/AGENTS.reference.md
categoria: playbooks
tipo: reporte
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/referencia/AGENTS.reference.md
etiquetas:
  - docs
  - agents
  - referencia
relacionados: []
descripcion: Referencia extendida de instrucciones locales de agentes.
---
# AGENTS.reference.md - PROJEC CDX

Version temporal completa de la guia de esta carpeta. Se deja como referencia mientras terminamos de organizar el espacio.

## Prioridades

- Responder en español claro y técnico.
- Inspeccionar primero, luego cambiar.
- Preferir cambios locales, pequeños y verificables.
- No tocar otras carpetas salvo que el usuario lo pida.

## Reglas de trabajo

- Usar `apply_patch` para editar archivos.
- Usar `rg` para buscar y `Get-Content` para leer.
- No borrar ni mover nada sin confirmación.
- Si existe una guia local más específica, seguirla.
- Si algo depende de `.codex`, referenciarlo desde allí y no duplicarlo acá.

## Modelo G50 obligatorio

Toda tarea operativa debe entrar como orquestacion SDU, no como ejecucion directa.
Antes de ejecutar hay que emitir:

- `DIAGNOSTICO`: intencion, alcance y restricciones.
- `PLAN`: objetivo, pasos, agentes requeridos, skills requeridas, riesgo.
- `DELEGATION`: por cada paso, resolver agente, skill y tool.
- `EJECUCION`: declarar la skill/tool invocada; no usar scripts directos fuera de cadena.
- `VALIDACION`: resultado esperado, evidencia y stop condition.
- `EVENTOS`: registrar `SDU_PLAN_CREATED`, `SDU_AGENT_SELECTED`, `SDU_SKILL_INVOKED`, `SDU_ACTION_EXECUTED`, `SDU_VALIDATION_OK`.

Reglas G50:

- Primero planificar, luego delegar, despues ejecutar.
- Usar cadena declarativa `agents -> skills -> tools -> recipes`.
- Para tareas simples usar `DEFAULT_AGENT = sdu-operator`, pero declarar delegacion igualmente.
- Si no existe skill aplicable, no ejecutar directo: proponer plan de nueva skill y marcar el faltante como `NO_DISPONIBLE`.
- Ninguna accion live, destructiva, externa, con secretos, permisos, red, costo o produccion se ejecuta sin target, owner, rollback, postcheck y evidencia.
- El modelo G50 queda subordinado a instrucciones de mayor prioridad y a gates locales mas restrictivos.

### G50 paralelo / G8-ready

Cuando una tarea sea multi-step, anomalica o de investigacion cruzada, el G50 debe abrir una mesa paralela antes de cualquier ejecucion:

- `thread_1`: `sdu-agent-comms`, skill `analyze-planner-data`.
- `thread_2`: `sdu-agent-runtime`, skill `inspect-watchdog-events`.
- `thread_3`: `sdu-agent-runtime`, skill `inspect-vsi-extensions`.
- `thread_4`: `sdu-orchestrator`, skill `reproduce-anomaly`.

Reglas:

- Usar al menos `sdu-agent-comms`, `sdu-agent-expediente`, `sdu-agent-governance` y `sdu-agent-runtime`; no cerrar solo con orchestrator.
- Buscar recipe existente antes de ejecutar; si no existe, definirla como propuesta y no ejecutar directo.
- Para anomalías Planner/watchdog/VSI usar `recipe: planner-anomaly-investigation`.
- Cada thread debe emitir `SDU_THREAD_STARTED`, validar su salida y cerrar con `SDU_THREAD_COMPLETED`.
- El fan-in debe unir resultados, detectar patron comun, inferir causa raiz y emitir `SDU_PARALLEL_ANALYSIS_DONE`.
- Si una skill requerida no existe, declararla `NO_DISPONIBLE`, proponer implementacion y detener la accion que dependia de ella.
- El cierre debe incluir matriz `thread -> agente -> skill -> recipe -> tool -> evidencia -> validador -> stop_condition`.

## En esta carpeta

- `README.md` y documentación: leer antes de cambiar.
- `node_modules`: no editar manualmente.
- `outputs`: tratarlo como salida generada.
- Si el usuario pide ordenar, limpiar o comparar, primero listar qué hay.

## Cierre

- Cuando termine una tarea, dejar claro qué cambió y en qué ruta.
