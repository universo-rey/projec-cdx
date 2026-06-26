# PLAN_LECTURA_47_ENTRADAS_MAX_REACHED_20260626

## Estado

PLAN_ARMADO_LOCAL_READONLY_NO_STAGE_NO_COMMIT

HECHO_VERIFICADO:

Plan creado para leer y clasificar las 47 entradas vivas del dirty set actual
despues de elevar el freeze al maximo estado acreditado:

- max_state: `SDU_DOCUMENTAL_PRODUCTION_READY_GOVERNED`
- max_level: `G10_REPO_CANONICAL_BOUNDARY_WITH_G8_5_DOCUMENTAL_CERTIFICATION`
- mode: `LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC`
- branch: `codex/live-state-g10-governed-20260626`
- head: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- status_count: 47
- modified: 19
- added: 3
- untracked: 25

Este plan no es permiso de stage, commit, push, PR, live, secretos ni writes
externos.

## Objetivo

Leer las 47 entradas nuevas/vivas, decidir que representa cada una y preparar
una matriz de reconciliacion para `VERSION_STATE.json` sin modificar todavia el
snapshot de version.

Resultado esperado:

- identificar canon, soporte, evidencia, propuesta y ruido gobernado;
- detectar faltantes que deban entrar a `VERSION_STATE.status`;
- separar campos dinamicos stale de contenido canonico valido;
- dejar un readback de fan-in con decision de promocion o gate.

## Frontera

Permitido:

- lectura local del repo;
- `git status`, `git diff --name-only`, `git diff --check`;
- parseo local de JSON/CSV/Markdown;
- validadores repo-local con `-NoExternal` o modo dry-run;
- clasificacion por buckets y agentes;
- escritura local de readback/matriz dentro de `operativa/tasks/20260626`.

Bloqueado:

- `git add`, commit, push, fetch, pull, PR, workflow dispatch;
- Microsoft, SharePoint, Dataverse, Power Platform, OpenAI API, Codex Cloud;
- secretos, `.env.local`, `secrets/`, `.sandbox-secrets/`, `private/`;
- deletes, moves, cleanup o apply de G11;
- cambios a runtime/live por inferencia.

## Orden De Lectura

1. `CORE_G10_VERSION_STATE`
   - Leer primero porque define canon, estado vivo, validadores y contratos.
   - Decidir si cada archivo es source of truth, indice, contrato o adaptador.
2. `READBACKS`, `FINAL_PACKAGE_G10`, `TASK_READBACKS_AND_PLANS`
   - Confirmar evidencia, autoridad y relacion con el freeze.
   - No promover duplicados si ya existe canon.
3. `BRANCH_GOVERNANCE_REVIEW_G1`
   - Leer matriz y fan-in para decidir si aporta a version-state o solo a
     gobernanza de ramas.
4. `LOCAL_FILES_RECONCILIATION_G1`
   - Leer como inventario/plan de limpieza, no ejecutar cleanup.
   - Archivos grandes: metadata primero; deep-read solo si son necesarios para
     decidir.
5. `PLANS_SUPERPOWERS`
   - Tratar como plan operativo de soporte.
6. `G11_POLICY_PROPOSAL`
   - Leer solo para revision. No aplicar sin `ALLOW_G11_POLICY_TUNING_APPLY`.

## Agentes

| Agente | Carril | Responsabilidad | Output |
| --- | --- | --- | --- |
| Seshat / Linnaeus | Canon y version | Contrastar `VERSION_STATE`, G10, G8.5, readbacks y docs | `canon_version_decision` |
| Maat | Validacion | JSON/CSV parse, esquemas, drift, validadores locales | `validation_matrix` |
| Anubis | Gates | Confirmar fronteras no-live, no-remoto, no-secretos, no-G11-apply | `gate_report` |
| Horus | Riesgo | Clasificar cleanup/noise/local reconciliation y riesgo de promocion | `risk_map` |
| Thot / Euler | Git | Estado, diff, tipos de cambio, staged/untracked, upstream local | `git_delta_matrix` |
| Narrador | Fan-in | Unificar dictamen y preparar readback de lectura | `READBACK_LECTURA_47_ENTRADAS_20260626.md` |

## Recetas Y Skills

- `governed-readback-closeout`: cierre con sistemas tocados/no tocados,
  validacion, riesgos, rollback y proximos carriles.
- `tcu-redactor-planes-operativos`: orden ejecutable, reversible y validada.
- `repo-agent-tool-governance`: separar tool real, wrapper repo-local y gate.
- `parallel-agentic-repo-audit`: usar solo si se decide dividir lectura por
  buckets.
- Receta base: `cierre-wave-documental`.

## Buckets

| Bucket | Cantidad | Lectura | Decision esperada |
| --- | ---: | --- | --- |
| `CORE_G10_VERSION_STATE` | 22 | full-read/diff | Promover a version-state o marcar stale |
| `LOCAL_FILES_RECONCILIATION_G1` | 11 | metadata + selective read | Gate de cleanup/noise |
| `BRANCH_GOVERNANCE_REVIEW_G1` | 7 | full-read de matrices/readback | Fan-in de ramas |
| `TASK_READBACKS_AND_PLANS` | 3 | full-read | Evidencia/plan |
| `READBACKS` | 1 | full-read | Autoridad documental |
| `FINAL_PACKAGE_G10` | 1 | full-read | Paquete final |
| `PLANS_SUPERPOWERS` | 1 | full-read | Soporte operativo |
| `G11_POLICY_PROPOSAL` | 1 | review-only | No apply |

## Entradas Exactas

### CORE_G10_VERSION_STATE

- `M .agileagentcanvas-context/sdu/README.md`
- `A .agileagentcanvas-context/sdu/artifacts/sdu-system.json`
- `M .agileagentcanvas-context/sdu/exports/sdu-native-project.json`
- `M .agileagentcanvas-context/sdu/exports/sdu-native-project.md`
- `M .agileagentcanvas-context/sdu/project.json`
- `M .agileagentcanvas-context/sdu/relationships.json`
- `M 08_READBACKS/SDU_AGENT_CANVAS.md`
- `M MAPA_MAESTRO.md`
- `A SDU_STATE_G10.md`
- `A SDU_SYSTEM_CONTRACT.md`
- `M SYSTEM_NERVOUS_INDEX.json`
- `M VERSION_STATE.json`
- `M contracts/schemas/system-nervous-index.schema.json`
- `M docs/MAPA.md`
- `M docs/README.md`
- `M docs/index.md`
- `M operativa/CONTROL.md`
- `M operativa/CURRENT.md`
- `M operativa/NEXT.md`
- `M operativa/TRACE.md`
- `M tools/validate_proj_cdx_sync.ps1`
- `M tools/validate_proj_cdx_workbench.ps1`

### READBACKS

- `?? 08_READBACKS/20260626_SDU_MAX_LEVEL_PROMOTION.md`

### FINAL_PACKAGE_G10

- `?? docs/SDU_FINAL_PACKAGE/README.md`

### PLANS_SUPERPOWERS

- `?? docs/superpowers/plans/2026-06-26-branch-governance-agentic-review.md`

### BRANCH_GOVERNANCE_REVIEW_G1

- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1.md`
- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/agent-lane-map.json`
- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-review-matrix.csv`
- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-taxonomy.json`
- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/fan-in-readback.md`
- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/heavy-branches-audit-notes.md`
- `?? operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/plugin-gate-matrix.json`

### LOCAL_FILES_RECONCILIATION_G1

- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/agent-assets-map.json`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/cleanup-actions-require-gate.md`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/cleanup-actions-safe.md`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/cleanup-dryrun.json`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/local-file-classification.json`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/local-file-inventory.json`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/noise-reduction-plan.md`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/repo-boundary-map.json`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/reversal-plan.md`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/sdk-assets-map.json`
- `?? operativa/tasks/20260626/CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1/skills-recipes-map.json`

### TASK_READBACKS_AND_PLANS

- `?? operativa/tasks/20260626/CONTROL_TOTAL_AGENTES_PLAN_20260626.md`
- `?? operativa/tasks/20260626/MAX_REACHED_LIVE_REMOTE_IDENTIFICATION_20260626.md`
- `?? operativa/tasks/20260626/READBACK_STATE_FREEZE_20260626_0509.md`

### G11_POLICY_PROPOSAL

- `?? policy-adjustment-proposal.json`

## Validadores

Minimo antes de dictamen:

- `git status --short --branch --untracked-files=all`
- `git diff --check`
- JSON parse para archivos `.json`
- CSV parse para `branch-review-matrix.csv`
- `tools/validate_proj_cdx_workbench.ps1 -Root C:\CEO\project-cdx -Json`
- `tools/validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json`
- `tools/validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -ResolverPy C:\CEO\project-cdx\tools\sdu_chain_resolver.py -Json`
- `tools/sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json`

## Stop Conditions

- aparece secreto, `.env.local`, token, key o contenido sensible;
- ruta fuera de `C:\CEO\project-cdx` no autorizada;
- se requiere red, remoto, GitHub, Microsoft, SharePoint, Dataverse, OpenAI API
  o Codex Cloud;
- se necesita aplicar G11 o cleanup real;
- JSON/CSV no parsea;
- `git diff --check` falla con error distinto de warnings CRLF;
- el conteo de 47 cambia durante la lectura y requiere nuevo freeze.

## Outputs

Crear al ejecutar la lectura:

- `operativa/tasks/20260626/READBACK_LECTURA_47_ENTRADAS_20260626.md`
- opcional: `operativa/tasks/20260626/MATRIX_LECTURA_47_ENTRADAS_20260626.csv`

## Rollback

Rollback de este plan:

- eliminar `operativa/tasks/20260626/PLAN_LECTURA_47_ENTRADAS_MAX_REACHED_20260626.md`;
- revertir la seccion `Actualizacion 47 entradas` del freeze.

No hay rollback runtime porque este plan no toca runtime, red, remoto, tenant ni
secretos.

## Contrato

- agente: `narrador-normativo`
- orden: `preparar_plan_lectura_47_entradas_maximo_alcanzado`
- superficie: `repo-local`
- skill: `governed-readback-closeout`, `tcu-redactor-planes-operativos`
- receta: `cierre-wave-documental`
- tool: PowerShell local, `apply_patch`
- estado: `PLAN_LECTURA_47_ENTRADAS_ARMADO`
- evidencia: este archivo
- validador: status/diff-check/json-parse/csv-parse/workbench/sync/operational_chain/sdu_boot
- riesgo: `VERSION_STATE_DYNAMIC_FIELDS_STALE_AND_DIRTY_SET_NOT_RECONCILED`
- rollback: borrar este plan y revertir la seccion 47 entradas del freeze
- stop_condition: no stage/commit/push/fetch/live/secrets/G11-apply/cleanup
- proximos_carriles: lectura 47 entradas, matriz, readback fan-in, gate owner para VERSION_STATE
