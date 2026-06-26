# Tcu Redactor Planes Operativos

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Revisar y reconciliar las ramas locales de `PROJEC CDX` con agentes, recetas, skills, tools y plugins sin abrir writes externos ni mutaciones no gobernadas.

**Architecture:** El plan opera en modo local-first: primero congela frontera, luego divide ramas por carriles independientes, despues ejecuta fan-in de agentes y solo promueve cambios con owner gate. No se hace checkout, merge, delete, push, PR, fetch, secret-read ni live-write por inferencia.

**Tech Stack:** Git local read-only, PowerShell validators, Python `sdu_chain_resolver.py`, `multi_agent_v1` subagents, skills locales, recetas `recipes/`, contratos `contracts/*.json`, plugins/connectors solo bajo gate.

---

## Contexto Vivo

Base verificada:

- Root operativo: `C:\CEO\project-cdx`
- Alias fisico: `C:\Users\enzo1\PROJEC CDX`
- Rama actual: `codex/m365-escribania-dataverse-restore`
- HEAD actual: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- Estado: dirty; no stage/commit/merge/release hasta cierre owner.
- Frontera: `LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC`, `NO_EXTERNAL`.

Fan-in usado para este plan:

- Jason: taxonomia local de ramas, refs-only.
- Locke: mapa agentes/skills/recetas/tools/gaps.
- Anscombe: validadores, gates y comandos permitidos.

## Archivos y Responsabilidades

- Crear: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-taxonomy.json`
  - Taxonomia consolidada: absorbidas, livianas, pesadas, aliases y bloqueos.
- Crear: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/agent-lane-map.json`
  - Mapa `carril -> owner_agent -> skill -> recipe -> tool -> validator -> evidence -> stop_condition`.
- Crear: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/plugin-gate-matrix.json`
  - Plugins/tools disponibles y su gate: `multi_agent_v1`, GitHub plugin read-only, OpenAI/Microsoft bloqueados sin gate.
- Crear: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-review-matrix.csv`
  - Decision por rama: `ABSORBED`, `LIGHT_REVIEW`, `AUDIT_ONLY`, `DUPLICATE_ALIAS`, `HOLD`.
- Crear: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/fan-in-readback.md`
  - Readback de subagentes y evidencia de comandos.
- Crear: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1.md`
  - Cierre operativo con comandos, archivos tocados, sistemas no tocados, gates, riesgos y proxima accion.
- Modificar opcional, solo con owner gate: `VERSION_STATE.json`
  - Actualizar rama/commit/delta si se decide cerrar versionado.
- No modificar: ramas Git, `.env.local`, `.cabina` runtime, `outputs`, `node_modules`, Microsoft, Dataverse, SharePoint, Power Platform, OpenAI API, Codex Cloud.

## Matriz de Agentes

| Carril | Owner agent | Skill | Receta | Tool | Validador | Evidencia | Stop condition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AUTHORITY_SNS` | `sns_agent` / `orchestrator_agent` | `repo-agent-tool-governance` | `agentes-atomicos-algoritmicos-en-waves` | `ceo-sns-unify.ps1` | `run-integration-smoke.ps1` | `SYSTEM_NERVOUS_INDEX.json` | fuente primaria ausente o contradiccion dura |
| `CONTRACTS_SCHEMA` | `contracts_agent` / `validation_agent` | `repo-agent-tool-governance` | `cierre-wave-documental` | `ceo-validate-event.ps1` | `run-contract-tests.ps1` | `contracts/agent-map.json` | schema critico faltante |
| `BOUNDARY_GUARD` | `path_sanitizer_agent` / `federation_enforcer_agent` | `no-inference-runtime-write-guard` | `agentes-atomicos-algoritmicos-en-waves` | `ceo-path-sanitizer.ps1` | `run-integration-smoke.ps1` | `repo-boundary-map.json` | external write, secret-read o runtime mutation |
| `VALIDATION_SAFE` | `validation_agent` | `repo-agent-tool-governance` | `agentes-atomicos-algoritmicos-en-waves` | `validate_proj_cdx_*` | validators locales | consola read-only | validador escribe estado no autorizado |
| `RISK_DRIFT` | `observability_agent` / `diagnostic_agent` | `parallel-agentic-repo-audit` | `cierre-wave-documental` | `git diff`, `git rev-list` | revision manual | `branch-taxonomy.json` | workspace dirty usado para merge/release |
| `EVIDENCE_READBACK` | `evidence_agent` / `narrador-normativo` | `governed-readback-closeout` | `cierre-wave-documental` | `manual-map-update` | readback checklist | `FINAL_READBACK...md` | evidencia faltante o no trazable |
| `CONTROL_PLANE_PLUGIN` | `control_plane_agent` | `agileagentcanvas-help` | `agentes-atomicos-algoritmicos-en-waves` | `ceo-control-plane-sync.ps1` | `run-integration-smoke.ps1` | `.agileagentcanvas-context` | canvas live-write o mapa stale |

## Plugins y Herramientas

| Capability | Estado | Uso permitido | Gate para ampliar |
| --- | --- | --- | --- |
| `multi_agent_v1` | DISPONIBLE | Explorers read-only y workers por carril si hay plan cerrado | `OWNER_GATE_SUBAGENT_WRITE` para workers que editen |
| GitHub plugin | DISPONIBLE | Branch search/fetch read-only si el owner habilita `GIT_REMOTE_READ_ONLY` | `GIT_REMOTE_READ_ONLY`; nunca write/update_ref/create_branch sin gate nuevo |
| OpenAI Developers plugin | DISPONIBLE ON-DEMAND | No usar en esta wave | `OPENAI_API_LIVE_GATE` |
| Microsoft/SharePoint/Teams/Outlook plugins | DISPONIBLE ON-DEMAND | No usar en esta wave | `MICROSOFT_LIVE_READ_GATE` o write gate literal |
| Data Analytics plugin | DISPONIBLE ON-DEMAND | No usar salvo dashboard/report solicitado | `DATA_ARTIFACT_GATE` |
| Local PowerShell tools | DISPONIBLE | Validacion local read-only/dry-run | Stop si escriben `out`, `logs`, evidence o bus |

## Taxonomia Inicial de Ramas

Absorbidas por rama actual:

- `main`
- `codex/consume-bound-workbook-next-delta`
- `codex/projec-cdx-docs-evidence-20260618`
- `codex/projec-cdx-launch-desk-20260618`
- `codex/runtime-versioning-snapshots`

Revision liviana:

- `codex/pipeline-baseline-workflows-20260621`
- `codex/projec-cdx-runtime-config-20260618`
- `codex/projec-cdx-control-autostash-a-20260618`
- `codex/projec-cdx-control-autostash-b-20260618`
- `codex/audit-governance-hardening`

Audit-only pesado:

- `codex/multirepo-alignment-16`
- `codex/dataverse-corte-ejecutora-v1`
- `codex/cabina-canon-agents-runtime-audit`
- `feature/docs-refactor`
- `copilot/featureschema-validation`
- `codex/mesa-archivo-20260620`
- `codex/cloud-setup-ui-v1`
- `codex/wave-mapas-uniformes-v1`
- `codex/revisar-procesos-del-equipo`

Aliases duplicados exactos:

- `backup/main-ahead-34-20260620-040104`
- `codex/windows-boot-origin-normalization-v1`
- `control-plane/verde-gobernado-20260620`

## Task 1: Congelar Frontera y Baseline

**Files:**
- Read: `operativa/CURRENT.md`
- Read: `operativa/NEXT.md`
- Read: `operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json`
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-taxonomy.json`

- [ ] **Step 1: Confirmar rama, HEAD y dirty state**

Run:

```powershell
git branch --show-current
git rev-parse HEAD
git status --short --branch
```

Expected:

```text
codex/m365-escribania-dataverse-restore
e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
## codex/m365-escribania-dataverse-restore
```

El status puede tener delta; no debe estar limpio por inferencia.

- [ ] **Step 2: Confirmar frontera NO_EXTERNAL**

Run:

```powershell
Get-Content -LiteralPath .\operativa\CURRENT.md | Select-String -Pattern 'LIVE_TOTAL_GOVERNED_ARMED_NOT_AUTOMATIC|No live|No secretos|No push|No PR|No stage'
Get-Content -LiteralPath .\operativa\SDU_RUNTIME_BOUNDARY_MATRIX.json | Select-String -Pattern 'NO_EXTERNAL|BLOCKED_WITHOUT_GATE|no_external_without_gate'
```

Expected: cada patron aparece al menos una vez.

- [ ] **Step 3: Crear carpeta de evidencia local**

Run only after owner starts this plan:

```powershell
New-Item -ItemType Directory -Force -Path .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1
```

Expected:

```text
Directory: ...\operativa\tasks\20260626
BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1
```

- [ ] **Step 4: Escribir `branch-taxonomy.json`**

Content:

```json
{
  "command": "BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1",
  "status": "BASELINE_READY_NO_MUTATION",
  "root": "C:\\CEO\\project-cdx",
  "current_branch": "codex/m365-escribania-dataverse-restore",
  "current_head": "e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11",
  "remote_state": "LOCAL_CACHE_ONLY_NO_FETCH",
  "frontier": {
    "no_checkout": true,
    "no_merge": true,
    "no_delete_branch": true,
    "no_fetch": true,
    "no_push": true,
    "no_pr": true,
    "no_secret_read": true,
    "no_external_write": true
  },
  "absorbed": [
    "main",
    "codex/consume-bound-workbook-next-delta",
    "codex/projec-cdx-docs-evidence-20260618",
    "codex/projec-cdx-launch-desk-20260618",
    "codex/runtime-versioning-snapshots"
  ],
  "light_review": [
    "codex/pipeline-baseline-workflows-20260621",
    "codex/projec-cdx-runtime-config-20260618",
    "codex/projec-cdx-control-autostash-a-20260618",
    "codex/projec-cdx-control-autostash-b-20260618",
    "codex/audit-governance-hardening"
  ],
  "audit_only": [
    "codex/multirepo-alignment-16",
    "codex/dataverse-corte-ejecutora-v1",
    "codex/cabina-canon-agents-runtime-audit",
    "feature/docs-refactor",
    "copilot/featureschema-validation",
    "codex/mesa-archivo-20260620",
    "codex/cloud-setup-ui-v1",
    "codex/wave-mapas-uniformes-v1",
    "codex/revisar-procesos-del-equipo"
  ],
  "duplicate_alias_group_a98ab81e": [
    "backup/main-ahead-34-20260620-040104",
    "codex/windows-boot-origin-normalization-v1",
    "control-plane/verde-gobernado-20260620"
  ]
}
```

- [ ] **Step 5: Validate JSON**

Run:

```powershell
python -m json.tool .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\branch-taxonomy.json
```

Expected: JSON pretty-prints and exits `0`.

## Task 2: Revisar Ramas Livianas con Agentes Exploradores

**Files:**
- Read: Git refs only.
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-review-matrix.csv`

- [ ] **Step 1: Despachar un explorer por dominio liviano**

Use `multi_agent_v1.spawn_agent` with `agent_type=explorer`, `fork_context=false`.

Agent prompts:

```text
Repo: C:\CEO\project-cdx. Read-only. Do not edit files, checkout, fetch, pull, push, merge, rebase, delete branches, read secrets or .env.local.
Review branch codex/pipeline-baseline-workflows-20260621 against codex/m365-escribania-dataverse-restore using local refs only.
Return: unique commits, changed files, risk, candidate action ABSORB/HOLD/AUDIT_ONLY, and exact evidence commands.
```

```text
Repo: C:\CEO\project-cdx. Read-only. Do not edit files, checkout, fetch, pull, push, merge, rebase, delete branches, read secrets or .env.local.
Review branch codex/audit-governance-hardening against codex/m365-escribania-dataverse-restore using local refs only.
Return: unique commits, changed files, risk, candidate action ABSORB/HOLD/AUDIT_ONLY, and exact evidence commands.
```

```text
Repo: C:\CEO\project-cdx. Read-only. Do not edit files, checkout, fetch, pull, push, merge, rebase, delete branches, read secrets or .env.local.
Review branches codex/projec-cdx-runtime-config-20260618, codex/projec-cdx-control-autostash-a-20260618 and codex/projec-cdx-control-autostash-b-20260618 against codex/m365-escribania-dataverse-restore using local refs only.
Return: unique commits, changed files, risk, candidate action ABSORB/HOLD/AUDIT_ONLY, and exact evidence commands.
```

- [ ] **Step 2: Run local evidence commands for each branch**

Run:

```powershell
$base = 'codex/m365-escribania-dataverse-restore'
$branches = @(
  'codex/pipeline-baseline-workflows-20260621',
  'codex/audit-governance-hardening',
  'codex/projec-cdx-runtime-config-20260618',
  'codex/projec-cdx-control-autostash-a-20260618',
  'codex/projec-cdx-control-autostash-b-20260618'
)
foreach ($branch in $branches) {
  "BRANCH=$branch"
  git rev-list --left-right --count "$base...$branch"
  git log --oneline --max-count=10 "$base..$branch"
  git diff --name-status "$base...$branch"
}
```

Expected: command completes without checkout. Any branch with runtime/config/security files remains `HOLD` unless owner approves target and rollback.

- [ ] **Step 3: Write branch-review matrix**

CSV content:

```csv
branch,classification,owner_agent,required_recipe,required_tool,validator,evidence,decision,stop_condition
codex/pipeline-baseline-workflows-20260621,LIGHT_REVIEW,validation_agent,agentes-atomicos-algoritmicos-en-waves,git diff local refs,validate_proj_cdx_operational_chain.ps1,branch-review-matrix.csv,HOLD_UNTIL_OWNER_SELECTS_PATCH,workflow change touches CI
codex/audit-governance-hardening,LIGHT_REVIEW,maat-cumplimiento,cierre-wave-documental,git diff local refs,run-integration-smoke.ps1,branch-review-matrix.csv,HOLD_UNTIL_SECURITY_REVIEW,security/governance change
codex/projec-cdx-runtime-config-20260618,LIGHT_REVIEW,sentinel-runtime,agentes-atomicos-algoritmicos-en-waves,git diff local refs,validate_proj_cdx_operational_chain.ps1,branch-review-matrix.csv,HOLD_UNTIL_RUNTIME_OWNER_GATE,runtime/config sensitive
codex/projec-cdx-control-autostash-a-20260618,LIGHT_REVIEW,narrador-normativo,cierre-wave-documental,git diff local refs,validate_proj_cdx_sync.ps1,branch-review-matrix.csv,HOLD_UNTIL_EVIDENCE_DECISION,autostash/evidence branch
codex/projec-cdx-control-autostash-b-20260618,LIGHT_REVIEW,narrador-normativo,cierre-wave-documental,git diff local refs,validate_proj_cdx_sync.ps1,branch-review-matrix.csv,HOLD_UNTIL_EVIDENCE_DECISION,autostash/evidence branch
```

- [ ] **Step 4: Validate CSV shape**

Run:

```powershell
Import-Csv .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\branch-review-matrix.csv | Format-Table branch,classification,decision
```

Expected: five rows.

## Task 3: Aislar Ramas Pesadas como Audit-Only

**Files:**
- Modify: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/branch-review-matrix.csv`
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/heavy-branches-audit-notes.md`

- [ ] **Step 1: Add audit-only rows**

Append CSV rows:

```csv
codex/multirepo-alignment-16,AUDIT_ONLY,seshat-normativa,cierre-wave-documental,git diff local refs,json-parse-lightweight,heavy-branches-audit-notes.md,HOLD_HEAVY_123_COMMITS,large release/alignment history
codex/dataverse-corte-ejecutora-v1,AUDIT_ONLY,seshat-normativa,dataverse-rehidratacion,git diff local refs,validate_sdu_dataverse_metadata_wave.ps1,heavy-branches-audit-notes.md,HOLD_DATAVERSE_OWNER_GATE,Dataverse/history heavy
codex/cabina-canon-agents-runtime-audit,AUDIT_ONLY,horus-riesgo,cierre-wave-documental,git diff local refs,validate_proj_cdx_operational_chain.ps1,heavy-branches-audit-notes.md,HOLD_RUNTIME_AUDIT,runtime audit branch
feature/docs-refactor,AUDIT_ONLY,narrador-normativo,canon-documental,git diff local refs,validate_proj_cdx_workbench.ps1,heavy-branches-audit-notes.md,HOLD_DOCS_REFACTOR,docs restructure
copilot/featureschema-validation,AUDIT_ONLY,validation_agent,agentes-atomicos-algoritmicos-en-waves,git diff local refs,validate_proj_cdx_workbench.ps1,heavy-branches-audit-notes.md,HOLD_DIVERGED_UPSTREAM,upstream diverged
codex/mesa-archivo-20260620,AUDIT_ONLY,narrador-normativo,cierre-wave-documental,git diff local refs,validate_proj_cdx_sync.ps1,heavy-branches-audit-notes.md,HOLD_ARCHIVE_REVIEW,archive/control history
codex/cloud-setup-ui-v1,AUDIT_ONLY,thot-tecnico,configuracion-entorno-codex-ui,git diff local refs,validate_proj_cdx_operational_chain.ps1,heavy-branches-audit-notes.md,HOLD_UI_SETUP_REVIEW,cloud/ui setup historical
codex/wave-mapas-uniformes-v1,AUDIT_ONLY,narrador-normativo,cierre-wave-documental,git diff local refs,validate_proj_cdx_workbench.ps1,heavy-branches-audit-notes.md,HOLD_MAP_WAVE,map wave historical
codex/revisar-procesos-del-equipo,AUDIT_ONLY,seshat-normativa,dataverse-rehidratacion,git diff local refs,validate_sdu_dataverse_metadata_wave.ps1,heavy-branches-audit-notes.md,HOLD_DATAVERSE_CACHE_REVIEW,startup cache evidence
```

- [ ] **Step 2: Document duplicate alias group**

Write:

```markdown
# Heavy Branches Audit Notes

## Duplicate Alias Group

These branches point to the same tip and must be reviewed once:

- `backup/main-ahead-34-20260620-040104`
- `codex/windows-boot-origin-normalization-v1`
- `control-plane/verde-gobernado-20260620`

Decision: `DUPLICATE_ALIAS_HOLD`.

No delete, rename, move, merge, reset or branch cleanup is authorized by this plan.

## Heavy Branch Rule

Every `AUDIT_ONLY` branch requires a future owner decision with:

- target branch,
- expected files,
- rollback,
- postcheck,
- evidence file,
- validator,
- explicit stop condition.
```

- [ ] **Step 3: Validate no branch operation happened**

Run:

```powershell
git branch --show-current
git status --short --branch
```

Expected: still on `codex/m365-escribania-dataverse-restore`.

## Task 4: Mapear Plugins, Skills, Recetas y Tools

**Files:**
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/agent-lane-map.json`
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/plugin-gate-matrix.json`

- [ ] **Step 1: Write agent lane map**

Content:

```json
{
  "status": "AGENT_LANE_MAP_READY",
  "source_files": [
    "contracts/agent-map.json",
    "SYSTEM_NERVOUS_INDEX.json",
    "inventarios/AGENTES_SKILLS_RECETAS_20260616.md",
    "recipes/INDICE_RECETAS.md",
    "operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json"
  ],
  "lanes": [
    {
      "lane": "BRANCH_LIGHT_REVIEW",
      "owner_agent": "validation_agent",
      "skill": "repo-agent-tool-governance",
      "recipe": "agentes-atomicos-algoritmicos-en-waves",
      "tool": "git diff local refs",
      "validator": "validate_proj_cdx_operational_chain.ps1",
      "evidence": "branch-review-matrix.csv",
      "stop_condition": "branch requires checkout, merge, fetch or write"
    },
    {
      "lane": "BRANCH_HEAVY_AUDIT",
      "owner_agent": "horus-riesgo",
      "skill": "parallel-agentic-repo-audit",
      "recipe": "cierre-wave-documental",
      "tool": "git rev-list and git diff local refs",
      "validator": "manual owner gate checklist",
      "evidence": "heavy-branches-audit-notes.md",
      "stop_condition": "owner target or rollback missing"
    },
    {
      "lane": "DATAVERSE_BRANCH_AUDIT",
      "owner_agent": "seshat-normativa",
      "skill": "dataverse-rehidratacion",
      "recipe": "dataverse-rehidratacion",
      "tool": "validate_sdu_dataverse_metadata_wave.ps1",
      "validator": "metadata-only validator",
      "evidence": "branch-review-matrix.csv",
      "stop_condition": "live Dataverse read/write requested without gate"
    },
    {
      "lane": "EVIDENCE_CLOSEOUT",
      "owner_agent": "narrador-normativo",
      "skill": "governed-readback-closeout",
      "recipe": "cierre-wave-documental",
      "tool": "manual-map-update",
      "validator": "readback checklist",
      "evidence": "FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1.md",
      "stop_condition": "missing commands, files touched, systems not touched, gates, risks or next action"
    }
  ],
  "gaps": [
    ".agents/codex/matrices/REPO_AGENT_TOOL_GOVERNANCE_MATRIX.csv not present in this checkout",
    ".agents/codex/maps/SURFACE_BOUNDARY_MAP.csv not present in this checkout",
    "agileagentcanvas-help duplicated in .agents and .cursor; cleanup requires owner decision"
  ]
}
```

- [ ] **Step 2: Write plugin gate matrix**

Content:

```json
{
  "status": "PLUGIN_GATE_MATRIX_READY",
  "plugins": [
    {
      "name": "multi_agent_v1",
      "state": "AVAILABLE",
      "allowed_now": ["spawn explorer read-only", "wait for fan-in", "close agents"],
      "blocked_now": ["worker file edits without owner write gate"],
      "gate": "OWNER_GATE_SUBAGENT_WRITE"
    },
    {
      "name": "github",
      "state": "AVAILABLE",
      "allowed_now": ["read-only branch search or file fetch if GIT_REMOTE_READ_ONLY is opened"],
      "blocked_now": ["create_branch", "update_ref", "PR", "workflow dispatch"],
      "gate": "GIT_REMOTE_READ_ONLY for reads; separate literal gate for writes"
    },
    {
      "name": "openai_developers",
      "state": "AVAILABLE_ON_DEMAND",
      "allowed_now": [],
      "blocked_now": ["api calls", "keys", "Codex Cloud execution"],
      "gate": "OPENAI_API_LIVE_GATE"
    },
    {
      "name": "microsoft_sharepoint_dataverse_power_platform",
      "state": "AVAILABLE_ON_DEMAND",
      "allowed_now": [],
      "blocked_now": ["tenant read/write", "SharePoint write", "Dataverse write", "flow mutation"],
      "gate": "MICROSOFT_LIVE_READ_GATE or literal write gate"
    }
  ]
}
```

- [ ] **Step 3: Validate JSON files**

Run:

```powershell
python -m json.tool .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\agent-lane-map.json
python -m json.tool .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\plugin-gate-matrix.json
```

Expected: both JSON files pretty-print and exit `0`.

## Task 5: Ejecutar Validadores Permitidos

**Files:**
- Read: local repo files only.
- Create/Modify: none unless owner explicitly allows evidence writes.

- [ ] **Step 1: Run workbench validator**

Run:

```powershell
pwsh -NoProfile -File .\tools\validate_proj_cdx_workbench.ps1 -Root C:\CEO\project-cdx -Json
```

Expected: `status` is `PASS` or `OBSERVED`; `fail` count is `0`.

- [ ] **Step 2: Run sync validator**

Run:

```powershell
pwsh -NoProfile -File .\tools\validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json
```

Expected: `status` is `PASS`.

- [ ] **Step 3: Run operational chain validator**

Run:

```powershell
pwsh -NoProfile -File .\tools\validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -ResolverPy C:\CEO\project-cdx\tools\sdu_chain_resolver.py -Json
```

Expected: local chain resolves; no external call.

- [ ] **Step 4: Run metadata-only Dataverse validator**

Run:

```powershell
pwsh -NoProfile -File .\tools\validate_sdu_dataverse_metadata_wave.ps1 -Root C:\CEO\project-cdx
```

Expected: metadata-only PASS; no live Dataverse action.

- [ ] **Step 5: Run SDU dry-run chain**

Run:

```powershell
pwsh -NoProfile -File .\tools\sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json
python .\tools\sdu_chain_resolver.py --root C:\CEO\project-cdx --mode all --agent All --no-external --dry-run --json
```

Expected: dry-run only; no external, no secret read, no runtime mutation.

## Task 6: Cierre y Decision Owner

**Files:**
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/fan-in-readback.md`
- Create: `operativa/tasks/20260626/BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1/FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1.md`
- Optional with owner gate: `VERSION_STATE.json`

- [ ] **Step 1: Write fan-in readback**

Content:

```markdown
# Fan-In Readback

## Subagents

- Jason: branch taxonomy local refs-only.
- Locke: agent, skill, recipe, tool and governance lane map.
- Anscombe: allowed validators and blocked surfaces.

## No Touch

- No checkout.
- No fetch.
- No pull.
- No push.
- No PR.
- No branch deletion.
- No secrets.
- No Microsoft, Dataverse, SharePoint, Power Platform, OpenAI API or Codex Cloud.
```

- [ ] **Step 2: Write final readback**

Content:

```markdown
# FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1

## Estado

BRANCH_GOVERNANCE_AGENTIC_REVIEW_READY_NO_MUTATION

## Comandos Ejecutados

- `git branch --show-current`
- `git rev-parse HEAD`
- `git status --short --branch`
- `git branch --merged HEAD`
- `git branch --no-merged HEAD`
- `git rev-list --left-right --count <base>...<branch>`
- `git diff --name-status <base>...<branch>`
- validators locales permitidos si fueron ejecutados

## Archivos Tocados

- `branch-taxonomy.json`
- `branch-review-matrix.csv`
- `agent-lane-map.json`
- `plugin-gate-matrix.json`
- `fan-in-readback.md`
- `FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1.md`

## Sistemas No Tocados

- Git remoto write.
- Microsoft.
- Dataverse live.
- SharePoint.
- Power Platform.
- OpenAI API.
- Codex Cloud.
- `.env.local` y secretos.

## Gates Pendientes

- `OWNER_GATE_BRANCH_PATCH_SELECT`
- `GIT_REMOTE_READ_ONLY` si se requiere refrescar remoto sin fetch.
- `OWNER_GATE_VERSION_STATE_UPDATE` si se actualiza `VERSION_STATE.json`.
- `OWNER_GATE_STAGE_COMMIT` si se decide versionar el plan.

## Riesgos Abiertos

- Workspace actual sigue dirty.
- Rama actual no tiene upstream.
- Algunas ramas pesadas conservan historia amplia no absorbida.
- Matrices `.agents/codex` no estan presentes en este checkout.

## Proxima Accion Recomendada

Elegir una sola rama liviana para patch review, empezando por `codex/pipeline-baseline-workflows-20260621`, o cerrar primero el delta actual antes de revisar ramas.
```

- [ ] **Step 3: Validate closeout contains required fields**

Run:

```powershell
$path = '.\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\FINAL_READBACK_BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1.md'
$required = @('Estado','Comandos Ejecutados','Archivos Tocados','Sistemas No Tocados','Gates Pendientes','Riesgos Abiertos','Proxima Accion Recomendada')
$text = Get-Content -LiteralPath $path -Raw
$missing = $required | Where-Object { $text -notmatch [regex]::Escape($_) }
if ($missing) { throw "Missing sections: $($missing -join ', ')" }
'FINAL_READBACK_SHAPE_OK'
```

Expected:

```text
FINAL_READBACK_SHAPE_OK
```

- [ ] **Step 4: Decide owner action**

Allowed decisions:

```text
DECISION_A: stop after readback; no stage, no commit.
DECISION_B: review one light branch as patch candidate.
DECISION_C: update VERSION_STATE.json to current branch/head/delta.
DECISION_D: stage/commit only the plan evidence.
```

Blocked decisions:

```text
merge all branches
delete stale branches
reset current branch
push current branch
open PR
fetch and rewrite local taxonomy
touch Microsoft/Dataverse/SharePoint/Power Platform/OpenAI/Codex Cloud
```

## Verification

Minimum verification before closeout:

```powershell
python -m json.tool .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\branch-taxonomy.json
python -m json.tool .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\agent-lane-map.json
python -m json.tool .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\plugin-gate-matrix.json
Import-Csv .\operativa\tasks\20260626\BRANCH_GOVERNANCE_AGENTIC_REVIEW_G1\branch-review-matrix.csv | Measure-Object
pwsh -NoProfile -File .\tools\validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json
```

Expected:

- JSON parse OK.
- CSV rows >= 14.
- `validate_proj_cdx_sync.ps1` PASS.

## Stop Conditions

- Any command requires checkout, merge, rebase, reset, restore, branch delete, fetch, pull, push, PR or workflow dispatch.
- Any command reads `.env.local`, token files, cookies, certs or secrets.
- Any command writes outside `C:\CEO\project-cdx`.
- Any Microsoft, Dataverse, SharePoint, Power Platform, OpenAI API or Codex Cloud action is requested without literal gate.
- Any agent output proposes direct merge of heavy branches.
- `VERSION_STATE.json` update is requested without owner deciding whether current dirty delta becomes the source of truth.

## Execution Handoff

Recommended mode: subagent-driven execution, one worker/explorer per branch lane, with parent review after each branch. Inline execution is acceptable only for the baseline, matrices and validators.
