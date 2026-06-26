# BRANCH_GOVERNANCE_PR_SELECTIVE_PLAN_20260626

## 1. Identidad

- fecha local: 2026-06-26T09:08:10.6102968-03:00
- fecha UTC: 2026-06-26T12:08:10.9041674Z
- agente: contracts_agent + validation_agent + narrador-normativo
- orden: BRANCH_GOVERNANCE_PR_SELECTIVE_PLAN
- root solicitado: C:\CEO\project-cdx
- root resuelto: C:\Users\enzo1\PROJEC CDX
- rama viva: codex/live-state-g10-governed-20260626
- HEAD vivo: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
- modo: plan_only_no_pr_no_merge
- superficie: repo local, evidencia documental, remoto read-only

## 2. Decision marco

- PLAN_ONLY
- NO_PR_CREATED
- NO_MERGE
- NO_LIVE
- NO_G11_APPLY
- NO_FREEZE_DIRECT_MERGE
- OWNER_GATE_REQUIRED_FOR_EACH_PR
- OWNER_GATE_REQUIRED_FOR_EACH_MERGE

## 3. Estado base

- rama viva: codex/live-state-g10-governed-20260626
- HEAD vivo: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
- worktree limpio: true
- index limpio: true
- snapshot acta publicada: true, commit ea00fe739644e139b17fc17e55adc5776eb855c3
- snapshot ready with conditions: true
- repair branch publicada: true, commit 6b796603e14f6d053d133ec214dc0c5a219e8f8a
- matriz publicada: true, commit 309a84c9c1219b04641262c31b71d4c8e254ca0a
- freeze branch verificada: true, commit 0291d185fc27de7e6d7c4b86a4614de2e182705f
- freeze tag verificado: true, freeze/2026-06-26-g10-reconciled

## 4. Tabla de ramas

| branch | local_exists | remote_exists | local_head | remote_head | local_remote_match | merge_base_with_live | changed_files_count | changed_files_summary | last_commit_subject | lane_type | recommended_action | pr_allowed | merge_allowed | target_branch_suggested | dependencies | risks | owner_gate_required | notes |
|---|---:|---:|---|---|---:|---|---:|---|---|---|---|---:|---:|---|---|---|---:|---|
| codex/version-validator-tooling-20260626 | true | true | 8af84c81 | 8af84c815285253376662b22733c540d2dfa708d | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 2 | M:2 | chore: split validator tooling 20260626 | PR_CANDIDATE_FIRST | PR_SELECTIVE_AFTER_OWNER_GATE | true | false | codex/integration-g10-snapshot-20260626 | none | validator drift; policy assumptions | true | soporte de validacion antes del core |
| codex/version-snapshot-blocker-repair-20260626 | true | true | 6b796603 | 6b796603e14f6d053d133ec214dc0c5a219e8f8a | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 7 | A:4 M:3 | snapshot(repair): apply workbench sync policy patch 20260626 | PR_CANDIDATE_REPAIR | PR_SELECTIVE_AFTER_VALIDATOR_TOOLING | true | false | codex/integration-g10-snapshot-20260626 | codex/version-validator-tooling-20260626 | repair applied without diff review; workbench OBSERVED ignored | true | VERSION_STATE repair plus sync/workbench policy patch |
| codex/version-core-g10-20260626 | true | true | 63b98344 | 63b983447d40442f2cfe214b3d00be53771c5323 | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 12 | A:2 M:10 | chore: split core G10 canon 20260626 | PR_CANDIDATE_CORE | PR_SELECTIVE_AFTER_REPAIR | true | false | codex/integration-g10-snapshot-20260626 | codex/version-snapshot-blocker-repair-20260626 | core fan-in before repair; canon drift | true | canon G10 y operativa central |
| codex/version-control-plane-canvas-20260626 | true | true | 1ffafe29 | 1ffafe291bae5f61e4e29c45db6cc87cce06d3ae | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 6 | A:1 M:5 | chore: split control plane canvas 20260626 | PR_CANDIDATE_CONTROL_PLANE | PR_SELECTIVE_AFTER_CORE | true | false | codex/integration-g10-snapshot-20260626 | codex/version-core-g10-20260626 | canvas applied before canon | true | control plane / AgileAgentCanvas |
| codex/version-readbacks-and-sdu-package-20260626 | true | true | e2477509 | e2477509295b672330acec5649108fa942f357ac | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 5 | A:4 M:1 | readback(post-remote): record verified remote publication state 20260626 | PR_CANDIDATE_EVIDENCE_PACKAGE | PR_SELECTIVE_AFTER_CORE_OR_REFERENCE_ONLY | true | false | codex/integration-g10-snapshot-20260626 | codex/version-core-g10-20260626 | evidence treated as runtime; large readback noise | true | decidir si entra como evidencia versionada o solo referencia |
| codex/version-total-reconciliation-evidence-20260626 | true | true | 68ac60ad | 68ac60ad6d500e066b1b8cb72bff5dd341522554 | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 14 | A:14 | docs: split total reconciliation evidence 20260626 | EVIDENCE_REFERENCE_ONLY | REFERENCE_ONLY_NO_PR | false | false | none | none | evidence-only mixed into runtime | true | referencia documental; no incluir automaticamente |
| codex/version-local-reconciliation-evidence-20260626 | true | true | 82b25d12 | 82b25d121d729b42195fb941768998370a02ece8 | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 11 | A:11 | docs: split local reconciliation evidence 20260626 | EVIDENCE_REFERENCE_ONLY | REFERENCE_ONLY_NO_PR | false | false | none | none | very large evidence payload; noise fan-in | true | referencia documental local; no runtime |
| codex/version-ceo-watchdog-evidence-20260626 | true | true | 1014aa2b | 1014aa2b90c16c819039c7d37d046ca0976c53af | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 7 | A:7 | docs: split CEO watchdog evidence 20260626 | EVIDENCE_REFERENCE_ONLY | REFERENCE_ONLY_NO_PR | false | false | none | none | watch/watchdog authority confusion | true | evidencia CEO watch/watchdog; no aplicar |
| codex/version-branch-governance-evidence-20260626 | true | true | 309a84c9 | 309a84c9c1219b04641262c31b71d4c8e254ca0a | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 10 | A:10 | docs(governance): add branch PR matrix 20260626 | EVIDENCE_REFERENCE_ONLY | REFERENCE_ONLY_NO_PR | false | false | none | none | governance evidence merged as runtime | true | ya cumple funcion de matriz/gobierno |
| codex/version-snapshot-decision-20260626 | true | true | ea00fe73 | ea00fe739644e139b17fc17e55adc5776eb855c3 | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 10 | A:10 | snapshot(acta): record formal snapshot acta 20260626 | EVIDENCE_REFERENCE_ONLY | REFERENCE_ONLY_NO_PR | false | false | none | none | snapshot acta treated as runtime integration | true | acta y decisiones snapshot; no integracion runtime |
| codex/version-g11-review-only-20260626 | true | true | cf2a2cc4 | cf2a2cc4dc49256a8f409374faae2b0068541b0a | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 1 | A:1 | docs: split G11 review-only proposal 20260626 | REVIEW_ONLY | REVIEW_ONLY_NO_APPLY | false | false | none | G11_OWNER_DECISION | G11 apply accidental | true | no apply |
| codex/version-freeze-state-20260626 | true | true | 0291d185 | 0291d185fc27de7e6d7c4b86a4614de2e182705f | true | e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11 | 2 | A:1 M:1 | freeze(state): VERSION_STATE reconciled + evidence 20260626 | FREEZE_REFERENCE_ONLY | FREEZE_REFERENCE_NO_DIRECT_MERGE | false | false | none | freeze/2026-06-26-g10-reconciled | freeze merged instead of referenced | true | freeze formalizado por tag; no merge directo |

## 5. Clasificacion inicial obligatoria

1. codex/version-validator-tooling-20260626
   - lane_type: PR_CANDIDATE_FIRST
   - recommended_action: PR_SELECTIVE_AFTER_OWNER_GATE
   - motivo: soporte de validacion antes del core.
2. codex/version-snapshot-blocker-repair-20260626
   - lane_type: PR_CANDIDATE_REPAIR
   - recommended_action: PR_SELECTIVE_AFTER_VALIDATOR_TOOLING
   - dependencia: codex/version-validator-tooling-20260626
   - motivo: contiene reparacion de VERSION_STATE, sync/workbench policy patch.
3. codex/version-core-g10-20260626
   - lane_type: PR_CANDIDATE_CORE
   - recommended_action: PR_SELECTIVE_AFTER_REPAIR
   - dependencia: codex/version-snapshot-blocker-repair-20260626
4. codex/version-control-plane-canvas-20260626
   - lane_type: PR_CANDIDATE_CONTROL_PLANE
   - recommended_action: PR_SELECTIVE_AFTER_CORE
   - dependencia: codex/version-core-g10-20260626
5. codex/version-readbacks-and-sdu-package-20260626
   - lane_type: PR_CANDIDATE_EVIDENCE_PACKAGE
   - recommended_action: PR_SELECTIVE_AFTER_CORE_OR_REFERENCE_ONLY
   - motivo: evidencia/paquete, no runtime critico.
6. codex/version-total-reconciliation-evidence-20260626
   - lane_type: EVIDENCE_REFERENCE_ONLY
   - pr_allowed: false
7. codex/version-local-reconciliation-evidence-20260626
   - lane_type: EVIDENCE_REFERENCE_ONLY
   - pr_allowed: false
8. codex/version-ceo-watchdog-evidence-20260626
   - lane_type: EVIDENCE_REFERENCE_ONLY
   - pr_allowed: false
9. codex/version-branch-governance-evidence-20260626
   - lane_type: EVIDENCE_REFERENCE_ONLY
   - pr_allowed: false
   - note: ya cumple funcion de matriz/gobierno.
10. codex/version-snapshot-decision-20260626
    - lane_type: EVIDENCE_REFERENCE_ONLY
    - pr_allowed: false
    - note: acta y decisiones snapshot, no integracion runtime.
11. codex/version-g11-review-only-20260626
    - lane_type: REVIEW_ONLY
    - pr_allowed: false
    - merge_allowed: false
    - note: no apply.
12. codex/version-freeze-state-20260626
    - lane_type: FREEZE_REFERENCE_ONLY
    - pr_allowed: false
    - merge_allowed: false
    - note: freeze formalizado por tag; no merge directo.

## 6. Orden recomendado de PR selectivo

No crear PR. Solo plan.

1. PR-01 validator tooling
   - source: codex/version-validator-tooling-20260626
   - target sugerido: codex/integration-g10-snapshot-20260626
   - condicion: diff review de tools/validate_proj_cdx_sync.ps1 y tools/validate_proj_cdx_workbench.ps1.
2. PR-02 snapshot blocker repair
   - source: codex/version-snapshot-blocker-repair-20260626
   - condicion: validar que solo toca VERSION_STATE, sync/workbench validators y evidencia repair.
3. PR-03 core G10
   - source: codex/version-core-g10-20260626
   - condicion: validadores despues de repair.
4. PR-04 control plane / canvas
   - source: codex/version-control-plane-canvas-20260626
   - condicion: core aceptado.
5. PR-05 readbacks/sdu package
   - source: codex/version-readbacks-and-sdu-package-20260626
   - condicion: decidir si entra como evidencia versionada o solo referencia.

No incluir automaticamente:

- evidence-only
- freeze
- G11
- snapshot decision branch

## 7. Targets recomendados

Opcion A - Integracion conservadora:

- target: codex/integration-g10-snapshot-20260626
- uso: rama de integracion controlada, con PRs selectivos y validaciones por paso.

Opcion B - Integracion directa controlada:

- target: main
- uso: solo si owner gate lo autoriza explicitamente.

Recomendacion:

- usar Opcion A si se quiere preservar main sin riesgo.
- no usar main directamente sin acta de PR/merge.

## 8. Validaciones requeridas por PR

Para cada PR candidato exigir:

- git diff review
- git diff --check
- validate_proj_cdx_sync
- validate_proj_cdx_workbench
- validate_proj_cdx_operational_chain con -ResolverPy
- sdu_boot -NoExternal -DryRun
- dataverse metadata wave local si aplica
- no live
- no G11 apply

Validadores publicados como evidencia:

- sync: PASS
- workbench: OBSERVED, 0 FAIL
- operational_chain: PASS
- sdu_boot -NoExternal -DryRun: PASS
- dataverse metadata wave: PASS
- git diff --check: PASS con warnings LF/CRLF no bloqueantes

## 9. Riesgos

- fan-in prematuro.
- PR contra main sin rama de integracion.
- mezclar evidencia-only como runtime.
- aplicar G11 accidentalmente.
- freeze mergeado en vez de referenciado.
- repair branch aplicada sin revisar diff.
- workbench OBSERVED ignorado.
- live write accidental.

## 10. Decision final del plan

DECISION:
PR_SELECTIVE_PLAN_READY

No autorizado:

- PR creation
- merge
- live
- G11 apply

Proximo carril recomendado:
OWNER_GATE_CREATE_INTEGRATION_BRANCH_PLAN_NO_PR

## 11. Contrato de cierre

- agente: contracts_agent + validation_agent + narrador-normativo
- orden: BRANCH_GOVERNANCE_PR_SELECTIVE_PLAN
- superficie: C:\CEO\project-cdx, evidencia local y remoto read-only
- skill: no-inference-runtime-write-guard; repo-agent-tool-governance; writing-plans
- receta: branch diff inventory + remote HEAD verification + selective PR governance plan
- tool: git status; git diff; git merge-base; git log; git show; git ls-remote; ConvertFrom-Json; apply_patch
- estado: PR_SELECTIVE_PLAN_READY
- evidencia: operativa/pr-plans/20260626/BRANCH_GOVERNANCE_PR_SELECTIVE_PLAN_20260626.md; operativa/pr-plans/20260626/BRANCH_GOVERNANCE_PR_SELECTIVE_PLAN_20260626.json
- validadores/evidencia: snapshot acta publicada; matrix publicada; repair validators PASS/OBSERVED 0 FAIL; remote heads match
- riesgo principal: crear PR o merge sin owner gate por rama y sin rama de integracion controlada
- rollback: borrar solo los dos archivos del plan antes de versionarlos si el owner descarta este carril
- stop_condition: no PR/no merge/no live/no G11 apply without owner gate
- proximos carriles: OWNER_GATE_CREATE_INTEGRATION_BRANCH_PLAN_NO_PR; OWNER_GATE_PR_01_VALIDATOR_TOOLING_ONLY

