# BRANCH_GOVERNANCE_PR_MATRIX_20260626

## 1. Identidad

- `matrix_id`: `BRANCH_GOVERNANCE_PR_MATRIX_20260626`
- `generated_at_utc`: `2026-06-26T10:57:39.0006602Z`
- `root_operativo`: `C:\CEO\project-cdx`
- `agente`: `contracts_agent + narrador-normativo`
- `skill`: `governed-readback-closeout`, `cabina-decision-matrix`, `repo-agent-tool-governance`
- `receta`: `BRANCH_GOVERNANCE_PR_MATRIX`
- `tooling`: `git rev-parse`, `git branch`, `git status`, `git show`, `git diff`, `git merge-base`, `git ls-remote`
- `modo`: `LOCAL_READ_ONLY_EXCEPT_NEW_EVIDENCE`
- `remote_mode`: `READ_ONLY_LS_REMOTE_ONLY`
- `base_comparison`: `codex/live-state-g10-governed-20260626`

## 2. Decision Marco

- `NO_MERGE_DIRECTO`
- `NO_PR_MASIVO`
- `FAN_IN_SOLO_CON_MATRIZ`
- `OWNER_GATE_REQUIRED_FOR_PR`
- `OWNER_GATE_REQUIRED_FOR_MERGE`
- `G11_REVIEW_ONLY_NO_APPLY`

Resultado marco: ninguna rama queda autorizada para PR, merge, push, tag, live write o aplicacion automatica en esta corrida. La salida formal es matriz de governance y decision owner-only posterior.

## 3. Estado Base

| Campo | Estado |
| --- | --- |
| `live_branch` | `codex/live-state-g10-governed-20260626` |
| `live_head` | `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11` |
| `worktree` | `CLEAN` antes de escribir evidencia |
| `freeze_branch_remote` | `codex/version-freeze-state-20260626` -> `0291d185fc27de7e6d7c4b86a4614de2e182705f` |
| `freeze_tag_remote` | `freeze/2026-06-26-g10-reconciled` -> `0291d185fc27de7e6d7c4b86a4614de2e182705f` |
| `readbacks_branch_remote` | `codex/version-readbacks-and-sdu-package-20260626` -> `e2477509295b672330acec5649108fa942f357ac` |
| `prs_created` | `NO_LOCAL_EVIDENCE`; no PR creado ni autorizado en esta corrida |
| `remote_publication` | 10/10 ramas detectadas en `origin` por `git ls-remote --heads` |
| `local_remote_match` | 10/10 ramas coinciden local/remoto |
| `merge_base_status` | 10/10 ramas tienen merge-base igual al HEAD live |

## 4. Matrix

### 4.1 Huella De Rama

| Branch | local_head | remote_head | match | last_commit_subject | file_count | changed_files_summary | lane_type |
| --- | --- | --- | --- | --- | ---: | --- | --- |
| `codex/version-core-g10-20260626` | `63b983447d40442f2cfe214b3d00be53771c5323` | `63b983447d40442f2cfe214b3d00be53771c5323` | true | `chore: split core G10 canon 20260626` | 12 | `M:10 A:2; core canon, SDU contract/state, docs, operativa indexes` | `MERGE_CANDIDATE` |
| `codex/version-control-plane-canvas-20260626` | `1ffafe291bae5f61e4e29c45db6cc87cce06d3ae` | `1ffafe291bae5f61e4e29c45db6cc87cce06d3ae` | true | `chore: split control plane canvas 20260626` | 6 | `M:5 A:1; AgileAgentCanvas SDU context and artifact export` | `MERGE_CANDIDATE_DEPENDS_CORE` |
| `codex/version-total-reconciliation-evidence-20260626` | `68ac60ad6d500e066b1b8cb72bff5dd341522554` | `68ac60ad6d500e066b1b8cb72bff5dd341522554` | true | `docs: split total reconciliation evidence 20260626` | 14 | `A:14; total reading, 47-entry plan, API agents plan, reconciliation matrix` | `EVIDENCE_ONLY` |
| `codex/version-local-reconciliation-evidence-20260626` | `82b25d121d729b42195fb941768998370a02ece8` | `82b25d121d729b42195fb941768998370a02ece8` | true | `docs: split local reconciliation evidence 20260626` | 11 | `A:11; local file inventory, classification, cleanup dry-run, asset maps` | `EVIDENCE_ONLY` |
| `codex/version-ceo-watchdog-evidence-20260626` | `1014aa2b90c16c819039c7d37d046ca0976c53af` | `1014aa2b90c16c819039c7d37d046ca0976c53af` | true | `docs: split CEO watchdog evidence 20260626` | 7 | `A:7; C:\CEO, watch, watchdog, metadata readbacks and inventory` | `EVIDENCE_ONLY` |
| `codex/version-branch-governance-evidence-20260626` | `a83e2037e838f0b87920186b8ed0fd1a8b64e81e` | `a83e2037e838f0b87920186b8ed0fd1a8b64e81e` | true | `docs: split branch governance evidence 20260626` | 8 | `A:8; prior branch review plan, taxonomy, fan-in, plugin gate matrix` | `EVIDENCE_ONLY` |
| `codex/version-readbacks-and-sdu-package-20260626` | `e2477509295b672330acec5649108fa942f357ac` | `e2477509295b672330acec5649108fa942f357ac` | true | `readback(post-remote): record verified remote publication state 20260626` | 5 | `M:1 A:4; SDU readbacks, final package, post-remote readback MD/JSON` | `MERGE_CANDIDATE_EVIDENCE_PACKAGE` |
| `codex/version-validator-tooling-20260626` | `8af84c815285253376662b22733c540d2dfa708d` | `8af84c815285253376662b22733c540d2dfa708d` | true | `chore: split validator tooling 20260626` | 2 | `M:2; project sync/workbench validators` | `MERGE_CANDIDATE_SUPPORT` |
| `codex/version-g11-review-only-20260626` | `cf2a2cc4dc49256a8f409374faae2b0068541b0a` | `cf2a2cc4dc49256a8f409374faae2b0068541b0a` | true | `docs: split G11 review-only proposal 20260626` | 1 | `A:1; policy adjustment proposal` | `REVIEW_ONLY` |
| `codex/version-freeze-state-20260626` | `0291d185fc27de7e6d7c4b86a4614de2e182705f` | `0291d185fc27de7e6d7c4b86a4614de2e182705f` | true | `freeze(state): VERSION_STATE reconciled + evidence 20260626` | 2 | `M:1 A:1; VERSION_STATE reconciled plus evidence snapshot` | `FREEZE_REFERENCE` |

### 4.2 Decision Por Rama

| Branch | recommended_target | pr_allowed_now | merge_allowed_now | requires_owner_gate | dependencies | risks | evidence_basis |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `codex/version-core-g10-20260626` | `codex/live-state-g10-governed-20260626` despues de snapshot owner | false | false | true | `OWNER_SNAPSHOT_DECISION` | Cambia canon SDU y operativa; debe liderar fan-in, no entrar mezclado. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-control-plane-canvas-20260626` | `codex/live-state-g10-governed-20260626` despues de core | false | false | true | `codex/version-core-g10-20260626` | Canvas depende del canon core; riesgo de publicar representacion antes de autoridad. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-total-reconciliation-evidence-20260626` | `evidence archive / selective doc intake` | false | false | true | `CORE_DECISION_CONTEXT` | Volumen documental alto; no debe mezclarse como runtime. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-local-reconciliation-evidence-20260626` | `evidence archive / selective doc intake` | false | false | true | `NOISE_CLASSIFICATION_REVIEW` | Evidencia muy grande; riesgo de inflar repo si se integra sin curacion. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-ceo-watchdog-evidence-20260626` | `evidence archive / selective doc intake` | false | false | true | `CEO_SURFACE_REVIEW` | Evidencia de superficies locales; no implica activar watchdog/live. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-branch-governance-evidence-20260626` | `evidence archive / selective doc intake` | false | false | true | `MATRIX_REVIEW` | Documento de governance previo; debe evitar recursividad de decision. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-readbacks-and-sdu-package-20260626` | `codex/live-state-g10-governed-20260626` como paquete evidencia, despues de core | false | false | true | `codex/version-core-g10-20260626` | Puede formalizar narrativa final; debe alinearse con core aprobado. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-validator-tooling-20260626` | `codex/live-state-g10-governed-20260626` como soporte controlado | false | false | true | `CORE_DECISION_CONTEXT` | Toca validadores; requiere postcheck antes de entrar a base. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-g11-review-only-20260626` | `NO_APPLY_REVIEW_ONLY` | false | false | true | `G11_OWNER_DECISION` | Propuesta de politica; prohibido aplicar por inferencia. | `rev-parse/show/diff/merge-base + ls-remote` |
| `codex/version-freeze-state-20260626` | `FREEZE_REFERENCE_ONLY` | false | false | true | `TAG_FREEZE_PUBLISHED` | Referencia congelada; no merge directo, tag ya formalizado. | `rev-parse/show/diff/merge-base + ls-remote` |

## 5. Recommended Fan-In Order

No ejecutar en esta corrida.

1. `FREEZE_REFERENCE`: usar `codex/version-freeze-state-20260626` y tag `freeze/2026-06-26-g10-reconciled` como referencia, no como merge directo.
2. `MERGE_CANDIDATE`: revisar `codex/version-core-g10-20260626` como primera decision owner-only.
3. `MERGE_CANDIDATE_SUPPORT`: revisar `codex/version-validator-tooling-20260626` despues del core.
4. `MERGE_CANDIDATE_DEPENDS_CORE`: revisar `codex/version-control-plane-canvas-20260626` solo si core queda aprobado.
5. `MERGE_CANDIDATE_EVIDENCE_PACKAGE`: revisar `codex/version-readbacks-and-sdu-package-20260626` despues de core y antes del cierre narrativo.
6. `EVIDENCE_ONLY`: curar o archivar selectivamente total/local/watchdog/branch-governance sin PR masivo.
7. `REVIEW_ONLY`: mantener `codex/version-g11-review-only-20260626` fuera de apply hasta orden owner explicita.

## 6. Risks

- `NO_PR_MASIVO`: las ramas mezclan canon, evidencia, tooling, canvas y propuesta G11; un PR masivo perderia trazabilidad.
- `CORE_FIRST`: core G10 es la autoridad candidata y debe resolver el orden de lo demas.
- `EVIDENCE_VOLUME`: la rama local reconciliation agrega evidencia muy grande; requiere curacion antes de intake.
- `VALIDATOR_IMPACT`: validator-tooling cambia herramientas de verificacion; requiere postcheck antes de merge.
- `G11_REVIEW_ONLY`: propuesta de politica no se aplica sin gate owner.
- `FREEZE_REFERENCE_ONLY`: freeze/tag son referencia formal, no carril de merge directo.

## 7. Formal Decision

- `BRANCH_GOVERNANCE_PR_MATRIX_WRITTEN`
- `PR_CREATION_NOT_AUTHORIZED`
- `MERGE_NOT_AUTHORIZED`
- `NEXT_LANE_SNAPSHOT_VERSION_DECISION_OWNER_ONLY`

## 8. Next Lanes

Carril recomendado unico:

- `SNAPSHOT_VERSION_DECISION_OWNER_ONLY`

Condiciones para abrirlo: matriz escrita, dirty final limitado a los dos archivos de matriz, sin divergencias criticas local/remoto, y owner decide que rama se convierte en snapshot/version decision.

## 9. Closeout Contract

| Campo | Valor |
| --- | --- |
| `agente` | `contracts_agent + narrador-normativo` |
| `orden` | `BRANCH_GOVERNANCE_PR_MATRIX` |
| `superficie` | `C:\CEO\project-cdx` |
| `skill` | `governed-readback-closeout`, `cabina-decision-matrix`, `repo-agent-tool-governance` |
| `receta` | `local read-only + remote ls-remote + evidence-only write` |
| `tool` | `git rev-parse`, `git status`, `git diff`, `git show`, `git merge-base`, `git ls-remote`, `apply_patch` |
| `estado` | `BRANCH_GOVERNANCE_PR_MATRIX_WRITTEN` |
| `evidencia` | `operativa/governance/20260626/BRANCH_GOVERNANCE_PR_MATRIX_20260626.md`, `operativa/governance/20260626/BRANCH_GOVERNANCE_PR_MATRIX_20260626.json` |
| `validador` | `branch/head unchanged; worktree dirty esperado solo por matrix files; JSON parseable` |
| `riesgo_principal` | `PR/merge prematuro sin owner gate ni orden fan-in` |
| `rollback` | eliminar solo los dos archivos nuevos de matriz antes de versionar; no requiere reset ni checkout |
| `stop_condition` | `No PR, no merge, no push, no live write; esperar owner gate para snapshot/version decision` |
| `proximos_carriles` | `SNAPSHOT_VERSION_DECISION_OWNER_ONLY` |

