# READBACK_W1_ISSUE_44_RECONCILIATION_20260826

## Estado

HECHO_VERIFICADO: las 14 filas `AUTHORIZATION_REQUIRED` de `projec-cdx #44` quedaron adjudicadas sin modificar la cola fuente.

```text
AUTHORIZATION_ROWS=14
AUTHORIZATION_UNIQUE_IDS=14
STALE_POLICY_PROJECTION=13
HUMAN_RESERVED=1
UNRESOLVED_OPERATIONAL=0
CURRENT_BINDING_PROMOTED=0
RETIRE_AS_STALE=13
SOURCE_RETIREMENT_PENDING=13
GATE_STATE=BLOCKED
```

Las cuatro filas `NO_D_RECTOR_ID` se clasifican como `STALE_POLICY_PROJECTION / RETIRE_AS_STALE` únicamente porque reúnen simultáneamente `DERIVED_NOT_IMPORTED`, `candidate_count=0` y contradicción interna de tuple. Esta adjudicación elimina el bucket operacional `UNRESOLVED`; no inventa `rector_id`, no crea `CURRENT_BINDING` y no ejecuta el retiro en la cola fuente.

## Sistemas tocados

- `C:/CEO/worktrees/w1-project-cdx-20260826/.agents/codex/matrices/W1_ISSUE_44_AUTHORIZATION_ADJUDICATION_20260826.csv`.
- `C:/CEO/worktrees/w1-project-cdx-20260826/.agents/codex/matrices/W1B_ISSUE_44_EXACTNESS_AND_RETIREMENT_20260826.csv`.
- `.agents/codex/matrices/W1_ISSUE_44_VALIDATOR_COVERAGE_20260826.csv` y `.agents/codex/matrices/AGENTS_INSTRUCTION_SURFACE_MATRIX.csv`.
- `.agents/codex/tools/local_validate_agents_instruction_hierarchy.ps1` y `.agents/codex/maps/AGENTS_INSTRUCTION_HIERARCHY.md`.
- `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/agent-task.yml` y `.github/ISSUE_TEMPLATE/runtime-approval.yml`.
- Este readback, `READBACK_W1B_STALE_POLICY_RETIREMENT_PROPOSAL_20260826.md` y el fan-in central `READBACK_W1_TGE_GOVERNADA_FAN_IN_20260826.md`.

Estas superficies pertenecen a carriles W1-B disjuntos: evidencia/adjudicación, preflight/hierarchy y fan-in. Se integran en el mismo worktree para validación conjunta.

## Sistemas no tocados

- `C:/CEO/sdu-control-plane/SDU_WORK_QUEUE_CURRENT.csv`: solo lectura y hash.
- D canon, tenant, Planner, SharePoint, Power Platform, Graph, GitHub remoto, producción, permisos y secretos.
- Ningún commit, push, merge, branch mutation ni cierre institucional.

## Cambios

- La matriz de adjudicación contiene 14/14 IDs únicos: 13 stale y 1 reserva humana.
- Las cuatro filas previamente `UNRESOLVED` conservan `candidate_count=0`, `exact_binding=NONE` y `proposed_binding=NONE`.
- La matriz W1B registra 13/13 decisiones de retiro, todas `PENDING_SOURCE_OWNER_RETIREMENT`.
- No se promovió ningún candidato por semejanza semántica.

## Evidencia y hashes

```text
SDU_WORK_QUEUE_CURRENT_SHA256=8CF83EE9A3CC8942A79514760D63322A2ED8C2B849EE07998A92CF3DDD553FA7
AGENT_CATALOG_V46_SHA256=947A02F204422B2A633DE433735EBFF815E7DBE17618E6A9FF27D7AFE36F92C4
D_DRIVE_FILE_REGISTRY_SHA256=F3E8F750D0A52C2FC5DAADD72A56D9DFDC9CBD10C3AC28340541B8849773BD92
W1_AUTHORIZATION_ADJUDICATION_SHA256=59F171042077F495C3438D3D85B60F561465C2A4F2E4B524B96881F9FF071714
W1B_EXACTNESS_RETIREMENT_SHA256=6C9349F1768BEDCEC1ED7F1D4AA294480431DFFA8B5B4FEE8AA3F18DA012A238
```

## Validación

```text
CSV_AUTHORIZATION_ROWS=14
CSV_AUTHORIZATION_UNIQUE_IDS=14
CSV_AUTHORIZATION_STALE=13
CSV_AUTHORIZATION_HUMAN_RESERVED=1
CSV_AUTHORIZATION_UNRESOLVED=0
W1B_RETIREMENT_ROWS=13
W1B_RETIREMENT_UNIQUE_IDS=13
W1B_RETIRE_AS_STALE=13
W1B_SOURCE_RETIREMENT_PENDING=13
NO_D_RECTOR_ID_ROWS_WITH_CANDIDATE_ZERO=4
CURRENT_BINDING_PROMOTED=0
AGENT_LAYER=PASS_ERRORS_0_WARNINGS_3_EXPECTED_NESTED_SKIPS
```

Resultados exact-root posteriores a la reparación repo-local:

- `local_validate_operational_chain.ps1`: `PASS`; 12 filas, 14 agentes, 62 skills, 32 recipes, 71 tools, 0 warnings y 0 errores.
- `local_validate_agents_instruction_hierarchy.ps1`: `PASS`; 8 superficies, raíz exacta W1, 0 warnings y 0 errores.
- `local_validate_agent_layer.ps1 -SkipWorkflowNestedValidators`: `PASS`; 0 errores, 0 secretos y 3 warnings esperados por validadores nested ejecutados separadamente.
- `local_validate_skill_metadata.ps1` y `local_validate_parallel_order_governance.ps1`: `PASS`.
- La preflight repo-local aplicable queda verde. El gate permanece bloqueado exclusivamente por materialización de fuente, reserva humana, cobertura externa pendiente y canary.

## Riesgos

- Confundir retiro adjudicado con retiro materializado en la cola fuente.
- Convertir un agente candidato por superficie en `CURRENT_BINDING` sin tuple exacto.
- Declarar PASS usando un resultado ejecutado desde otra raíz o con templates distribuidos ausentes.
- Tocar artefactos de preflight, templates, validators o fan-in pertenecientes a otros carriles.

## Rollback

Revertir solamente las tres superficies repo-locales de este carril. La cola fuente no requiere rollback porque no fue modificada. Las 13 decisiones vuelven a su adjudicación anterior hasta que el owner las rematerialice.

## Postcheck

1. Parsear ambos CSV.
2. Confirmar 14/14 y 13/13 IDs únicos.
3. Confirmar 13 `STALE_POLICY_PROJECTION`, 1 `HUMAN_RESERVED`, 13 `RETIRE_AS_STALE` y cero `CURRENT_BINDING` promovidos.
4. Confirmar que `SDU_WORK_QUEUE_CURRENT.csv` conserva SHA-256 `8CF83EE9A3CC8942A79514760D63322A2ED8C2B849EE07998A92CF3DDD553FA7`.
5. Revisar el diff limitado a las tres rutas owned por W1B.

## Bloqueadores residuales

```text
PRIMARY_BLOCKER=SOURCE_RETIREMENT_NOT_MATERIALIZED
SOURCE_RETIREMENT_PENDING=13
OPERATIONAL_CHAIN_EXACT_ROOT=PASS
INSTRUCTION_HIERARCHY_EXACT_ROOT=PASS
HUMAN_RESERVED_DECISION=PENDING
END_TO_END_CANARY_PROVEN=false
GATE_GREEN=false
```

## Criterio de cierre

```text
GATE_CLOSE =
  AUTHORIZATION_REQUIRED_CLASSIFIED == 14/14
  AND STALE_SOURCE_RETIREMENT_RECEIPTS == 13/13
  AND HUMAN_RESERVED_REMAINS_GATED_OR_IS_EXPLICITLY_DECIDED
  AND CURRENT_BINDING_PROMOTED_BY_INFERENCE == 0
  AND ALL_APPLICABLE_EXACT_ROOT_VALIDATORS == PASS
  AND DOWNSTREAM_POLICY_RECONCILED == true
  AND END_TO_END_CANARY_PROVEN == true
  AND FAN_IN_EVIDENCE_ACCEPTED == true
  AND HUMAN_MERGE_CLOSE_DECISION == GRANTED
```

## Próximos carriles

1. El owner de la cola fuente materializa el retiro de las 13 proyecciones stale con receipt y postcheck.
2. Los owners de templates y jerarquía corrigen los baselines exact-root; W1B no invade esas superficies.
3. Reejecutar la cadena completa y probar el canary antes de solicitar cierre humano.

## Cadena de capacidad

```text
agente=cdf.evidence_validator
orden=W1B_EVIDENCE_WRITE
superficie=C:/CEO/worktrees/w1-project-cdx-20260826
skill=no-inference-runtime-write-guard|governed-readback-closeout
receta=issue_44_exactness_and_stale_source_retirement
tool=apply_patch|Import-Csv|Get-FileHash|git_diff_check
estado=EVIDENCE_MATERIALIZED_GATE_BLOCKED
evidencia=.agents/codex/matrices/W1_ISSUE_44_AUTHORIZATION_ADJUDICATION_20260826.csv|.agents/codex/matrices/W1B_ISSUE_44_EXACTNESS_AND_RETIREMENT_20260826.csv
validador=csv_14_of_14_unique|retirement_13_of_13_unique|exact_root_validator_readback
riesgo=false_green_or_inferred_binding
rollback=revert_only_three_w1b_owned_paths
stop_condition=candidate_promoted_by_inference|source_queue_mutation|scope_overlap
proximos_carriles=source_owner_retirement|exact_root_validator_owners|canary|human_gate
```
