# Matriz Cadena Operativa En Dataverse

Fecha: `2026-06-15`

## Decision

La matriz fuente de cadena operativa debe vivir en Dataverse.

El CSV local `PROJEC_CDX_CARRIL4_OPERATIONAL_CHAIN_INDEX.csv` queda degradado a proyeccion/cache local verificable. No es la fuente canonica cuando exista o se confirme la tabla Dataverse.

## Fuente Canonica Esperada

- superficie: `Dataverse`
- tipo: matriz gobernada
- nombre funcional: `DATAVERSE_OPERATIONAL_CHAIN_MATRIX`
- logical surfaces vivas: ver `DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv`
- solucion confirmada: `SDUCapabilityControlPlane`
- runtime/colas confirmadas: `sdu_runtime_control_plane`
- ambiente confirmado por lectura: `HUBDesarrollo`
- estado local: `DATAVERSE_CANON_EXPECTED_LOCAL_PROJECTION`
- verificacion live: `CONTROL_PLANE_CONFIRMADO / FILAS_MATRIX_NO_MATERIALIZADAS_EN_SOURCE_ARTIFACT`

## Campos Minimos Dataverse

- `repo`
- `universe`
- `tower`
- `subnivel`
- `owner_agent`
- `execution_agent`
- `counterpart_agent`
- `agent_family`
- `skill`
- `recipe`
- `tool_or_carril`
- `validator`
- `evidence`
- `readback`
- `stop_condition`
- `live_boundary`
- `source_matrix`
- `gap_status`
- `atomic_action_type`
- `atomic_energy_phase`
- `atomic_terminal_state`
- `atomic_idempotency_key`
- `atomic_next_impulse`

## ATOMICA

La parte atomica no es solo control de tamano. Es la energia inicial de cada fila:

- `CONCENTRATE`: concentra intencion, owner y frontera.
- `DISPERSE`: reparte la energia hacia el carril/agente correcto.
- `MULTIPLY`: multiplica capacidad cuando skill, receta y tool ya estan visibles.
- `IMPULSE`: impulsa el siguiente desbloqueo, gate o validacion.

## Proyeccion Local

- [PROJEC_CDX_CARRIL4_OPERATIONAL_CHAIN_INDEX.csv](C:/Users/enzo1/Documents/Codex/2026-06-14/projec-cdx-handoff-20260614/outputs/PROJEC_CDX_CARRIL4_OPERATIONAL_CHAIN_INDEX.csv)
- [PROJEC_CDX_OPERATIONAL_CHAIN_SCHEMA_20260615.csv](C:/Users/enzo1/Documents/Codex/2026-06-14/projec-cdx-handoff-20260614/outputs/PROJEC_CDX_OPERATIONAL_CHAIN_SCHEMA_20260615.csv)
- [DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv](C:/Users/enzo1/PROJEC%20CDX/dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv)

## Mapeo A Superficie Real

`DATAVERSE_OPERATIONAL_CHAIN_MATRIX` no se trata como placeholder. Es el nombre funcional canonico de la matriz fuente. Su implementacion Dataverse actual se resuelve por mapa compuesto:

- `mon_sdu_source_artifact`
- `mon_sdu_validation_gate`
- `mon_sdu_stop_condition`
- `mon_sdu_evidence`
- `mon_sdu_apply_log`
- `mon_sdu_agent_connection_mapping`
- `workqueue`
- `workqueueitem`

La consulta viva de lectura confirmo ambiente y soluciones. La busqueda por `matrix` en `mon_sdu_source_artifact` no devolvio filas materializadas; por eso el siguiente delta natural no es descubrir el ecosistema, sino materializar o sincronizar la fila fuente de matriz en la superficie ya gobernada.

## Stop Conditions

- `dataverse_source_not_declared`
- `atomic_fields_missing`
- `target_identity_ambiguous`
- `secret_detected`
- `source_map_missing`
- `matrix_source_row_not_materialized`
