# Mandato De Revision De Agentes 20260616

## Estado

BORRADOR_LISTO_PARA_EJECUCION

## Mandato

Cada agente debe salir a buscar en su propia superficie, revisar su workpaper, confirmar si su pendiente es real, y devolver un informe corto con historia, evidencia y stop condition.

La coordinacion central se queda aqui, en `PROJEC CDX`, sin salir a inventar la revision por ellos.

## Agentes Convocados

- `codex.workspace_guardian`
- `court.openai_dispatcher`
- `rey.control_plane_orchestrator`
- `rey.repo_cartographer`
- `court.seshat_evidence`
- `court.thot_schema`
- `court.sdu_gate`
- `rey.authority_canonist`
- `rey.frontier_guardian`
- `rey.governance_registrar`
- `rey.migration_planner`
- `tech.reference_librarian`
- `universe.escribania_tower`
- `universe.modo_on_tower`

## Lo Que Tiene Que Revisar Cada Uno

1. Su workpaper principal.
2. Su `CURRENT_STATE.md`.
3. Su `OPEN_ITEMS.csv`.
4. El primer registro util de su propia historia.
5. Si el pendiente es real o solo boundary repetido.

## Formato De Salida

- agente
- pendiente_real
- evidencia
- historia_minima
- riesgo
- rollback
- stop_condition
- siguiente_paso

## Criterio

- Si el pendiente cambia superficie, gate, target, owner o rollback, es real.
- Si el pendiente es una frontera repetida de gobernanza, no se promociona como nuevo delta.
- Si el agente no puede probarlo con su propia evidencia, debe devolver `PENDIENTE_DE_REVISION`.

## Siguiente Paso

Entregar este mandato a la mesa, esperar la vuelta de cada agente con su informe y despues consolidar el acta constitutiva definitiva.
