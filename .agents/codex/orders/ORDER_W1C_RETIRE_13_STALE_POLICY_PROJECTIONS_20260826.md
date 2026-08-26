# Governed Order Preparation Packet

- order_class: agent_global_operability_next_lane_execution
- surface: `C:\CEO\sdu-control-plane\SDU_WORK_QUEUE_CURRENT.csv`
- owner: `rey.control_plane_orchestrator`
- identity: `W1C_RETIRE_13_STALE_POLICY_PROJECTIONS_20260826`
- canon_as_of: `2026-08-26; SDU_WORK_QUEUE_CURRENT_SHA256=8CF83EE9A3CC8942A79514760D63322A2ED8C2B849EE07998A92CF3DDD553FA7`
- source_authority: `AUTHORITY_CLASS=DERIVED_PROJECTION; RECTOR_SOURCE=D:\.agents\codex\matrices\LIVE_DELTA_RECONCILIATION_MATRIX_20260603.csv; W1B_ISSUE_44_EXACTNESS_AND_RETIREMENT_20260826.csv`
- data_boundary: `local control-plane queue metadata only; 13 enumerated stale projection rows; no tenant, regulated payload, secret, GitHub or production data`
- base_branch: `main`
- work_branch: `codex/w1-reconcile-20260826`
- lane_id: `W1C_SOURCE_OWNER_RETIREMENT`
- lead_agent: `rey.control_plane_orchestrator`
- owner_agent: `rey.control_plane_orchestrator`
- reviewer_agent: `rey.frontier_guardian`
- read_scope: `C:\CEO\sdu-control-plane\SDU_WORK_QUEUE_CURRENT.csv|C:\CEO\worktrees\w1-project-cdx-20260826\.agents\codex\matrices\W1B_ISSUE_44_EXACTNESS_AND_RETIREMENT_20260826.csv`
- write_scope: `future_only:C:\CEO\sdu-control-plane\SDU_WORK_QUEUE_CURRENT.csv|C:\CEO\sdu-control-plane\backups\SDU_WORK_QUEUE_CURRENT.pre-W1C-20260826.csv|C:\CEO\sdu-control-plane\09_READBACKS\READBACK_W1C_RETIRE_13_STALE_POLICY_PROJECTIONS_20260826.md`
- lock_key: `lock.sdu_control_plane.w1c.source_retirement`
- dependency: `W1B_ISSUE_44_EXACTNESS_AND_RETIREMENT_20260826 -> W1C_SOURCE_OWNER_RETIREMENT`
- max_parallel: `1`
- allowed_actions: `prepare_only|local_matrix_update_after_separate_approval|read_source_queue|verify_precheck_hash|create_future_backup|apply_only_a_canonical_retirement_state_after_separate_approval|write_receipt|postcheck`
- blocked_actions: `execute_now|invent_retirement_state|promote_candidate_by_inference|modify_HUMAN_RESERVED|tenant_write|planner_write|sharepoint_write|power_platform_write|graph_write|github_write|production|permissions|secrets|commit|push`
- rollback: `Before any future queue write, copy the hash-matched source to C:\CEO\sdu-control-plane\backups\SDU_WORK_QUEUE_CURRENT.pre-W1C-20260826.csv; on failed postcheck restore only that backup, recompute SHA-256, and emit a failed receipt. No backup or rollback action is executed by this packet.`
- postcheck: `Require source precheck hash match; 20 total rows; 13 enumerated IDs each matched exactly once; ESCRIBANIA-AUTH-001 unchanged; all non-target rows byte-equivalent by canonical CSV projection; resulting state values must belong to an explicitly approved canonical state vocabulary; receipt written to C:\CEO\sdu-control-plane\09_READBACKS\READBACK_W1C_RETIRE_13_STALE_POLICY_PROJECTIONS_20260826.md.`
- evidence: `C:\CEO\sdu-control-plane\SDU_WORK_QUEUE_CURRENT.csv@sha256:8CF83EE9A3CC8942A79514760D63322A2ED8C2B849EE07998A92CF3DDD553FA7|C:\CEO\worktrees\w1-project-cdx-20260826\.agents\codex\matrices\W1B_ISSUE_44_EXACTNESS_AND_RETIREMENT_20260826.csv|C:\CEO\worktrees\w1-project-cdx-20260826\.agents\codex\matrices\W1_ISSUE_44_AUTHORIZATION_ADJUDICATION_20260826.csv`
- validator: `.agents/codex/tools/local_validate_order_packets.ps1; future execution also requires an exact queue-state vocabulary validator and receipt postcheck`
- expiration_rule: `expires_on_source_hash_change|expires_on_W1B_matrix_change|expires_when_any_target_row_is_not_DERIVED_NOT_IMPORTED|expires_when_a_canonical_retirement_state_is_defined_or_changed`
- stop_condition: `order_packet_missing_required_fields|missing_keys_or_target_guess|write_without_order|source_hash_mismatch|canonical_retirement_state_absent|candidate_promoted_by_inference|source_queue_mutation_during_prepare|scope_overlap`
- preparer_agent: `codex.workspace_guardian`
- gate_reviewer: `court.sdu_gate`
- approver_role: `operator`

## Estado de preparación

```text
STATUS=PREPARED_NOT_EXECUTED
EXECUTION=BLOCKED
SOURCE_QUEUE_MUTATION=false
BACKUP_CREATED=false
RECEIPT_CREATED=false
CANONICAL_RETIREMENT_STATE_FOUND=false
TARGET_ROWS=13
HUMAN_RESERVED_EXCLUDED=true
```

La cola vigente contiene solamente estos valores canónicos de `state`:

```text
AUTHORIZATION_REQUIRED
COMPLETE
IN_PROGRESS
LOCAL_CONSUMER_REBOUND_POST_03D
SUPERSEDED
```

Ninguno expresa retiro de una proyección stale. `RETIRE_AS_STALE` es una decisión probatoria de W1B, no un valor canónico de `state` en la cola. Por ello esta orden no define `state_after`, no transforma filas y no puede ejecutarse hasta que el owner apruebe un valor canónico existente o materialice formalmente una ampliación de vocabulario mediante una orden separada.

## Delta exacto preparado

Las columnas y valores siguientes ya existen en la cola fuente o en la matriz W1B. `execution=BLOCKED` describe esta orden y no se proyecta como valor de la cola.

| WORK_ITEM_ID | state | AUTHORITY_CLASS | PROJECTION_STATUS | RECTOR_WORK_ITEM_ID | adjudication_class | retirement_decision | retirement_status | execution |
|---|---|---|---|---|---|---|---|---|
| `CONTROL_PLANE-ACTOR-001` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-002` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-003` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `ESCRIBANIA-ACTOR-004` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.tge.control` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CODEX_CLOUD-ACTOR-010` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `NO_D_RECTOR_ID` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-011` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-012` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-013` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-014` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `CONTROL_PLANE-ACTOR-015` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `lane.integration.shared-index` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `GITHUB-ACTOR-009` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `NO_D_RECTOR_ID` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `MICROSOFT_365-ACTOR-006` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `NO_D_RECTOR_ID` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |
| `MICROSOFT_365-ACTOR-008` | `AUTHORIZATION_REQUIRED` | `DERIVED_PROJECTION` | `DERIVED_NOT_IMPORTED` | `NO_D_RECTOR_ID` | `STALE_POLICY_PROJECTION` | `RETIRE_AS_STALE` | `PENDING_SOURCE_OWNER_RETIREMENT` | `BLOCKED` |

## Exclusión expresa

`ESCRIBANIA-AUTH-001` queda fuera del write scope futuro. Conserva `state=AUTHORIZATION_REQUIRED`, `adjudication_class=HUMAN_RESERVED` y su decisión humana P031-P034.

## Secuencia futura condicionada

1. Revalidar SHA-256 exacto de la cola.
2. Resolver y aprobar el vocabulario canónico de retiro; detenerse si no existe un único valor autorizado.
3. Crear el backup exacto en el destino declarado.
4. Aplicar solamente el delta de los 13 IDs enumerados.
5. Ejecutar los postchecks y emitir el receipt exacto.
6. Ante cualquier fallo, restaurar el backup y emitir receipt fallido.

Esta secuencia requiere una autorización posterior. El presente artefacto no la concede.

## Receta

`recipe.governed_order_preparation`
