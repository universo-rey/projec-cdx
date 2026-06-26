# INTEGRATION_BRANCH_PLAN_20260626

## 1. Identidad

- fecha local: 2026-06-26T09:17:39.0324554-03:00
- fecha UTC: 2026-06-26T12:17:39.0497331Z
- agente: contracts_agent + validation_agent + narrador-normativo
- orden: OWNER_GATE_CREATE_INTEGRATION_BRANCH_PLAN_NO_PR
- root solicitado: C:\CEO\project-cdx
- root resuelto: C:\Users\enzo1\PROJEC CDX
- rama viva: codex/live-state-g10-governed-20260626
- HEAD vivo: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
- modo: plan_only_no_branch_no_pr_no_merge
- superficie: repo local, evidencia documental, remoto read-only

## 2. Decision marco

- PLAN_ONLY
- NO_BRANCH_CREATED
- NO_PR
- NO_MERGE
- NO_LIVE
- NO_G11_APPLY
- OWNER_GATE_REQUIRED_TO_CREATE_BRANCH
- OWNER_GATE_REQUIRED_FOR_EACH_INTEGRATION_STEP

## 3. Estado base verificado

- rama viva: codex/live-state-g10-governed-20260626
- HEAD vivo: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
- worktree limpio: true
- index limpio: true
- snapshot acta publicada: true, codex/version-snapshot-decision-20260626 @ ea00fe739644e139b17fc17e55adc5776eb855c3
- PR selective plan publicado: true, codex/version-branch-governance-evidence-20260626 @ 0ba11767aa5101013c523f24a0c3bc2d15eedf4c
- repair branch publicada: true, codex/version-snapshot-blocker-repair-20260626 @ 6b796603e14f6d053d133ec214dc0c5a219e8f8a
- freeze branch verificada: true, codex/version-freeze-state-20260626 @ 0291d185fc27de7e6d7c4b86a4614de2e182705f
- freeze tag verificado: true, freeze/2026-06-26-g10-reconciled @ 0291d185fc27de7e6d7c4b86a4614de2e182705f
- rama de integracion local: INTEGRATION_BRANCH_NOT_FOUND_LOCAL
- rama de integracion remota: INTEGRATION_BRANCH_NOT_FOUND_REMOTE
- origin/main remoto: 56a4eda1dd36c545c12546bb37fc2046dbb7fb05
- main local observado: 93dedd16, merge-base con live: 93dedd165a9a5e987cfd452e0fc700580a02566d

## 4. Rama de integracion propuesta

- nombre: codex/integration-g10-snapshot-20260626
- estado: PLANNED_ONLY
- base recomendada: codex/live-state-g10-governed-20260626
- alternativa: origin/main
- decision recomendada: CREATE_FROM_LIVE_BRANCH

Respuesta a las preguntas del gate:

1. Conviene crear una rama de integracion antes de PR contra main: si.
2. La base debe ser codex/live-state-g10-governed-20260626.
3. Debe partir desde live, no desde origin/main, salvo nuevo owner gate con control de divergencia.
4. Entran primero validator tooling, snapshot blocker repair, core G10, control plane canvas y readbacks/sdu package.
5. Quedan fuera evidence-only, snapshot decision, freeze y G11 review-only.
6. Deben correr validadores locales despues de cada paso futuro.
7. Hace falta owner gate para crear rama y owner gate por cada integracion.
8. Siguen prohibidos PR, merge, live write, G11 apply, freeze merge e integracion sin gate.

La opcion A conserva el estado vivo exacto. La opcion B, origin/main, existe remotamente pero exige control adicional porque main local observado queda en 93dedd16 mientras live esta en e9fcd7e9.

## 5. Orden de integracion propuesto

No ejecutar, solo plan:

1. validator tooling
   - source: codex/version-validator-tooling-20260626
   - merge-base con live: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
   - cambios: M:2, tools/validate_proj_cdx_sync.ps1 y tools/validate_proj_cdx_workbench.ps1

2. snapshot blocker repair
   - source: codex/version-snapshot-blocker-repair-20260626
   - merge-base con live: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
   - cambios: A:4 M:3, VERSION_STATE, evidencia repair y validators sync/workbench

3. core G10
   - source: codex/version-core-g10-20260626
   - merge-base con live: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
   - cambios: A:2 M:10, canon SDU, docs y operativa central

4. control plane canvas
   - source: codex/version-control-plane-canvas-20260626
   - merge-base con live: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
   - cambios: A:1 M:5, .agileagentcanvas-context/sdu

5. readbacks/sdu package
   - source: codex/version-readbacks-and-sdu-package-20260626
   - modo: integrar o referenciar segun owner gate posterior
   - cambios: A:4 M:1, readbacks y docs/SDU_FINAL_PACKAGE

No integrar:

- evidence-only branches
- snapshot decision branch
- freeze branch
- G11 review-only

## 6. Ramas excluidas del fan-in

Referencia/no merge:

- codex/version-total-reconciliation-evidence-20260626
- codex/version-local-reconciliation-evidence-20260626
- codex/version-ceo-watchdog-evidence-20260626
- codex/version-branch-governance-evidence-20260626
- codex/version-snapshot-decision-20260626
- codex/version-g11-review-only-20260626
- codex/version-freeze-state-20260626

## 7. Validaciones requeridas tras cada paso futuro

Despues de cada integracion futura, exigir:

- git diff --check
- tools/validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json
- tools/validate_proj_cdx_workbench.ps1 -Root C:\CEO\project-cdx -Json
- tools/validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -ResolverPy C:\CEO\project-cdx\tools\sdu_chain_resolver.py -Json
- tools/sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json
- tools/validate_sdu_dataverse_metadata_wave.ps1 -Root C:\CEO\project-cdx

Evidencia publicada previa:

- sync: PASS
- workbench: OBSERVED, 0 FAIL
- operational_chain: PASS
- sdu_boot -NoExternal -DryRun: PASS
- dataverse metadata wave: PASS
- git diff --check: PASS con warnings LF/CRLF no bloqueantes

## 8. Riesgos

- crear rama de integracion desde base incorrecta.
- integrar repair sin validator tooling.
- integrar core antes de repair.
- mezclar evidence-only como runtime.
- aplicar G11 por accidente.
- mergear freeze.
- PR contra main sin validar rama de integracion.
- live write accidental.

## 9. Decision final

DECISION:
INTEGRATION_BRANCH_PLAN_READY

NEXT_LANE:
OWNER_GATE_CREATE_INTEGRATION_BRANCH_NO_MERGE

NO AUTORIZADO:

- crear PR
- merge
- live
- G11 apply
- integrar ramas

## 10. Contrato de cierre

- agente: contracts_agent + validation_agent + narrador-normativo
- orden: OWNER_GATE_CREATE_INTEGRATION_BRANCH_PLAN_NO_PR
- superficie: C:\CEO\project-cdx, evidencia local y remoto read-only
- skill: no-inference-runtime-write-guard; repo-agent-tool-governance; writing-plans
- receta: remote evidence verification + base selection + integration branch plan
- tool: git status; git diff; git merge-base; git log; git show; git ls-remote; ConvertFrom-Json; apply_patch
- estado: INTEGRATION_BRANCH_PLAN_READY
- evidencia: operativa/integration/20260626/INTEGRATION_BRANCH_PLAN_20260626.md; operativa/integration/20260626/INTEGRATION_BRANCH_PLAN_20260626.json
- validadores/evidencia: snapshot acta publicada; PR selective plan publicado; repair validators PASS/OBSERVED 0 FAIL; integration branch no existe local/remoto
- riesgo principal: crear rama o integrar ramas sin owner gate posterior y sin preservar live como base
- rollback: borrar solo los dos archivos del plan antes de versionarlos si el owner descarta este carril
- stop_condition: no branch/no PR/no merge/no live/no G11 apply without owner gate
- proximos carriles: OWNER_GATE_CREATE_INTEGRATION_BRANCH_NO_MERGE

