# CABINA_CONTRACT_EXPANSION_REFRAME

Fecha local: 2026-06-23
Baseline: SDU_ORG_TOTAL_G1_V3_BASELINE_CANDIDATE_20260623
Commit baseline: 2ec642ff52712699bbb673b604cf43714615ccee
Ajuste: SDU_CABINA_CONTRACT_EXPANSION_FIRST_REFRAME_G1
Contract mode: ORGANISMO_VIVO_ENABLEMENT

## Dictamen

EXPANSION_FIRST_CONTRACT_REFRAMED.

El contrato fue ajustado para operar como constitucion de un organismo vivo: primero proposito, expansion, creacion, aprendizaje y federacion; despues ejecucion, gobierno, seguridad, validacion y evidencia.

Los controles existentes no fueron eliminados. Quedaron reinterpretados como proteccion de la expansion, continuidad inteligente y umbrales de madurez.

## Superficies actualizadas

| path | accion | backup |
| --- | --- | --- |
| .cabina/organizacion-total/CABINA_CONTRACT_G1.md | preambulo, principios, roles y modos expansivos insertados | .cabina/organizacion-total/CABINA_CONTRACT_G1.md.previous-20260623_031305 |
| .cabina/organizacion-total/config/cabina-contract.v1.json | contrato estructurado alineado a ORGANISMO_VIVO_ENABLEMENT | .cabina/organizacion-total/config/cabina-contract.v1.json.previous-20260623_031305 |

## Mision insertada

```text
La Cabina SDU no existe para impedir el error.
Existe para aumentar la capacidad de crear futuro.
El gobierno no limita la expansion: la hace sostenible.
La evidencia no frena la accion: la convierte en aprendizaje.
Los agentes no inspeccionan el sistema: lo potencian.
```

## Principios insertados

| principio | funcion |
| --- | --- |
| expansion | preguntar primero que resultado se quiere crear y luego cual es el camino seguro, trazable y reversible |
| iniciativa | hacer que los agentes observen, propongan y registren oportunidades de mejora |
| descubrimiento | convertir consultas y conocimiento recuperado en patrones, oportunidades y aprendizaje |
| federacion_expansiva | transformar valor local en capacidades reutilizables, saneadas y gobernadas |

## Roles expansivos insertados

| agente | rol expansivo |
| --- | --- |
| SESHAT | arquitecta del conocimiento |
| THOT | disenador de posibilidades |
| ANUBIS | protector de continuidad |
| MAAT | equilibrio entre verdad, accion y evidencia |
| HORUS | observador estrategico |
| NARRADOR | memoria colectiva |
| EINSTEIN | expansor de posibilidades |
| FARADAY | conector de capacidades |
| RAMANUJAN | detector de convergencia |

## Matriz habilitante

Se agrego `execution_philosophy` con:

- old_model: prohibir_por_defecto
- new_model: habilitar_con_consciencia
- primary_question: Que resultado queremos crear?
- secondary_question: Que camino seguro, trazable y reversible nos lleva alli?
- controls_role: proteger_expansion
- evidence_role: crear_memoria_operativa
- gates_role: marcar_umbrales_de_madurez
- security_role: preservar_continuidad

## Modos expansivos agregados

- EXPLORE
- DESIGN
- PLAN
- EXECUTE_LOCAL
- LEARN
- FEDERATE
- SCALE
- LIVE

Los modos operativos previos se conservaron para compatibilidad con `Test-CabinaExecutionGate.ps1`.

## Controles conservados

- evidence_policy
- gates
- repair_policy
- execution_modes operativos
- capability_matrix
- gate_matrix
- allowed_operations
- escalation_policy
- rollback_policy
- validator_policy
- stop_conditions
- owner_decision_matrix

## Frontera

stage=false
commit=false
push=false
pr=false
live=false
global_mutation=false
secretos=false

## Siguiente accion

Revisar por owner y decidir si se abre carril `LOCAL_COMMIT` con pathspec cerrado para versionar el contrato expansivo.
