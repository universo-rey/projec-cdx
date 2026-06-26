# Nomenclatura Fina De Cadena Operativa

Fecha: `2026-06-15`

## Proposito

Fijar nombres y valores para completar el indice puente:

```text
repo -> subnivel -> agente -> skill -> recipe -> tool/carril -> validador -> evidencia -> stop_condition
```

## Regla De Fila

Cada fila debe representar una unidad operativa verificable. Si un campo no aplica, usar `NO_APLICA`. Si falta evidencia, usar `PENDIENTE_EVIDENCIA`. Si falta fuente, usar `PENDIENTE_FUENTE`.

## Campos Canonicos

| campo | formato | ejemplo | regla |
| --- | --- | --- | --- |
| `repo` | slug repo o carpeta gobernada | `torre-gemela-escribania` | usar nombre real de repo/carpeta |
| `universe` | MAYUS snake | `ESCRIBANIA` | no inferir si no aparece en matriz fuente |
| `tower` | MAYUS snake | `TGE_CANON` | mantener valor de matriz repo |
| `subnivel` | `NN_NOMBRE` | `04_TORRES_DE_UNIVERSO` | debe existir en capa de agentes |
| `owner_agent` | namespace con punto | `universe.escribania_tower` | agente responsable de gobierno |
| `execution_agent` | namespace con punto o slug | `cdf.project_manager_delegador` | agente ejecutor o `NO_APLICA` |
| `counterpart_agent` | slug o namespace | `anubis-gate` | contraparte SDU/CDF si existe |
| `agent_family` | MAYUS snake | `CDF_STAFF` | familia del agente |
| `skill` | `skill_*` | `skill_tge_controlled_activation_gate` | una skill primaria por fila |
| `recipe` | `recipe_*` | `recipe_tge_agent_mesh_governed` | una receta primaria por fila |
| `tool_or_carril` | lista `;` | `github_cli;github_connector` | herramientas o carriles permitidos |
| `validator` | path o `tool.*` | `tool.local_validate_agent_layer` | requerido salvo `NO_APLICA` justificado |
| `evidence` | lista `;` | `readback;gate_packet` | evidencia esperada |
| `readback` | path o id | `08_READBACKS/...` | cierre verificable |
| `stop_condition` | lista `|` | `secret_detected|live_write_requested` | condiciones de corte |
| `live_boundary` | enum gobernado | `NO_LIVE_WITHOUT_ORDER` | frontera antes de ejecutar |
| `source_matrix` | lista `;` | `REPO_GOVERNANCE_ASSIGNMENT_MATRIX.csv` | fuente de verdad usada |
| `gap_status` | enum gobernado | `OK_CHAIN_VISIBLE` | estado de cobertura |
| `dataverse_source_table` | MAYUS snake | `DATAVERSE_OPERATIONAL_CHAIN_MATRIX` | tabla canonica esperada |
| `dataverse_source_status` | enum gobernado | `DATAVERSE_CANON_EXPECTED_LOCAL_PROJECTION` | estado de confirmacion fuente |
| `dataverse_row_key` | clave estable | `opchain_0123456789abcdef` | identidad idempotente de fila |
| `atomic_action_type` | `ATOMIC_*` | `ATOMIC_PATCH_PLAN` | tipo de accion atomica inicial |
| `atomic_energy_phase` | enum gobernado | `MULTIPLY` | energia de arranque de la fila |
| `atomic_terminal_state` | enum gobernado | `NOOP` | estado terminal esperado para la proyeccion |
| `atomic_idempotency_key` | clave estable | `atom_0123456789abcdef01234567` | clave anti-duplicacion |
| `atomic_next_impulse` | slug | `fan_out_skill_recipe_tool_validator` | impulso operativo siguiente |

## Separadores

- Usar `;` para listas de herramientas, evidencias o fuentes.
- Usar `|` para stop conditions alternativas.
- No usar comas dentro de celdas CSV salvo que la celda este entre comillas.
- Mantener `NO_APLICA`, `PENDIENTE_EVIDENCIA`, `PENDIENTE_FUENTE` en mayusculas.

## Vocabulario De `live_boundary`

| valor | sentido |
| --- | --- |
| `NO_LIVE` | no toca live |
| `NO_LIVE_WITHOUT_ORDER` | podria tocar live solo con orden atomica |
| `REPO_ONLY_LOCAL_DOCUMENTAL_ACTIVE` | solo repo/local documental |
| `MICROSOFT_LIVE_GOVERNED_REQUIRES_ORDER_EVIDENCE_POSTCHECK` | Microsoft live requiere orden, evidencia y postcheck |
| `OPENAI_LIVE_GOVERNED_REQUIRES_ORDER_EVIDENCE_POSTCHECK` | OpenAI live requiere orden, evidencia y postcheck |
| `DATAVERSE_LIVE_GOVERNED_REQUIRES_GATE68` | Dataverse live requiere Gate 68 |

## Vocabulario De `gap_status`

| valor | sentido |
| --- | --- |
| `OK_GOVERNED` | fila completa desde matriz de gobierno |
| `OK_REPO_OWNER` | repo tiene owner y frontera |
| `OK_CHAIN_VISIBLE` | cadena operativa visible |
| `OK_GATE_VISIBLE` | gate visible y trazable |
| `INDEX_ONLY` | existe indice, falta matriz full-chain |
| `INDEX_ONLY_NEEDS_MATRIX_JOIN` | requiere join con matrices fuente |
| `PENDING_SKILL` | falta skill primaria |
| `PENDING_RECIPE` | falta receta primaria |
| `PENDING_TOOL` | falta tool o carril |
| `PENDING_VALIDATOR` | falta validador |
| `PENDING_EVIDENCE` | falta evidencia |
| `PENDING_STOP_CONDITION` | falta stop condition |

## Vocabulario De `dataverse_source_status`

| valor | sentido |
| --- | --- |
| `DATAVERSE_CANON_EXPECTED_LOCAL_PROJECTION` | Dataverse declarado fuente canonica; CSV es proyeccion local |
| `LIVE_ROWS_CONFIRMED` | filas vivas confirmadas con orden y ambiente exacto |
| `METADATA_ONLY` | existe metadata, no filas vivas confirmadas |
| `TARGET_AMBIGUOUS` | target o tabla ambiguos |

## Vocabulario De `atomic_energy_phase`

| valor | sentido |
| --- | --- |
| `CONCENTRATE` | concentra intencion, owner y frontera |
| `DISPERSE` | reparte hacia carril, agente o matriz fuente |
| `MULTIPLY` | multiplica capacidad por skill, receta, tool y validador |
| `IMPULSE` | empuja gate, validacion o desbloqueo siguiente |

Toda superficie gobernada debe declarar una fase atomica energetica o enlazarla desde su entrada visible minima.

## Regla Dataverse

Dataverse es fuente canonica de la matriz. `DATAVERSE_OPERATIONAL_CHAIN_MATRIX` es el nombre funcional canonico; su logical surface real se resuelve por `dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv`.
El control plane vivo confirmado usa `SDUCapabilityControlPlane`, `sdu_runtime_control_plane`, tablas `mon_sdu_*`, `workqueue` y `workqueueitem`.
El CSV local es proyeccion/cache para versionado, validacion y trabajo de cabina.

## Stop Conditions

- `row_without_repo`
- `row_without_owner_agent`
- `row_without_live_boundary`
- `row_without_stop_condition`
- `dataverse_source_not_declared`
- `dataverse_row_key_missing`
- `atomic_fields_missing`
- `atomic_idempotency_missing`
- `source_map_missing`
- `matrix_source_row_not_materialized`
- `skill_recipe_tool_not_joined`
- `validator_missing_without_no_aplica`
- `source_matrix_missing`
- `secret_or_live_surface_requested`
- `atomic_energy_phase_missing`
