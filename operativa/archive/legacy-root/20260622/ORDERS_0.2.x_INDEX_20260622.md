# SDU ORDERS 0.2.x INDEX

## Estado
SDU_0.2.x_FULL_GATE_QUEUE_PREPARED_LOCAL_ONLY

## Base
- Runtime local: `SDU_v0.1.1_FINALIZED_LOCAL_AUTONOMOUS_RUNTIME`
- Sentinel: enforced
- External mode: `NO_EXTERNAL`
- Push: not allowed
- PR: not opened
- Secrets: not read

## Matriz
- `operativa/archive/legacy-root/20260622/SDU_EXTERNAL_GATE_QUEUE_0.2.x_FULL_20260622.csv`

## Ordenes
1. `operativa/orders_0.2.x/ORDER_0.2.0_DATAVERSE_RUNTIME_ACTION_7_OWNER_CLASSIFICATION.md`
2. `operativa/orders_0.2.x/ORDER_0.2.1_CHANGE_AWARE_EVIDENCE_CABINA_SYNC.md`
3. `operativa/orders_0.2.x/ORDER_0.2.2_PR130_CONSTITUTION_SYNC_CABINA.md`
4. `operativa/orders_0.2.x/ORDER_0.2.3_GITHUB_LABELS_DEPENDABOT_PROJEC_CDX.md`
5. `operativa/orders_0.2.x/ORDER_0.2.4_SDU_CN_ISSUE_PREP_REMOTE_ALIGNMENT.md`

## Regla de apertura
Una orden por vez. Ninguna orden ejecuta externo sin target, owner, rollback, postcheck y evidencia.

## Siguiente estado
READY_FOR_OWNER_GATE_SELECTION
