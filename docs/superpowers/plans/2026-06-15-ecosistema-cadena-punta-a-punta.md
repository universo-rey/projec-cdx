# PROJEC CDX Ecosystem End-To-End Chain Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Leave the full `PROJEC CDX` ecosystem chained from micro to macro, with short entry points, map layers, references, residuals, and evidence aligned across `.codex`, `.agents`, `PROJEC CDX`, Dataverse, and repo surfaces.

**Architecture:** Use one compact chain per domain: entry, short map, master map, reference, residual, and evidence. Keep `.codex` as the operating canon, `.agents` as catalog/support, and `PROJEC CDX` as the workbench. Treat Dataverse and repo surfaces as governed external lanes that must show exact target, owner, rollback, postcheck, and evidence before any live action.

**Tech Stack:** Markdown, PowerShell, local filesystem, `rg`, `Get-Content`, `Test-Path`, `apply_patch`, `codex-surface-map`, `repo-agent-tool-governance`, `matrix-recipe-skill-sync`, `parallel-agentic-repo-audit`, `dataverse-agent-surface-discovery`, `dispatching-parallel-agents`, `subagent-driven-development`.

---

### Task 1: Lock the `.codex` chain

**Files:**
- Modify: `C:\Users\enzo1\.codex\README.md`
- Modify: `C:\Users\enzo1\.codex\README_CORTO.md`
- Modify: `C:\Users\enzo1\.codex\MAPA.md`
- Modify: `C:\Users\enzo1\.codex\MAPA_CORTO.md`
- Modify: `C:\Users\enzo1\.codex\MAPA_MAESTRO.md`
- Modify: `C:\Users\enzo1\.codex\AGENTS.md`
- Modify: `C:\Users\enzo1\.codex\AGENTS_CORTO.md`
- Modify: `C:\Users\enzo1\.codex\AGENTS.reference.md`
- Modify: `C:\Users\enzo1\.codex\CAPACIDADES.md`
- Modify: `C:\Users\enzo1\.codex\CAPACIDADES_CORTO.md`
- Modify: `C:\Users\enzo1\.codex\CAPACIDADES.reference.md`

- [ ] **Step 1: Read the current root chain**

Run:
```powershell
Get-Content -LiteralPath 'C:\Users\enzo1\.codex\README.md','C:\Users\enzo1\.codex\MAPA.md','C:\Users\enzo1\.codex\MAPA_MAESTRO.md','C:\Users\enzo1\.codex\AGENTS.md','C:\Users\enzo1\.codex\CAPACIDADES.md'
```

- [ ] **Step 2: Verify the short chain exists and is linked**

Expected:
- `README.md` points to `README_CORTO.md`
- `MAPA.md` points to `MAPA_CORTO.md`
- `AGENTS.md` points to `AGENTS_CORTO.md`
- `CAPACIDADES.md` points to `CAPACIDADES_CORTO.md`

- [ ] **Step 3: Keep the residual technical buckets explicit**

Keep bucket-only surfaces documented, not inflated, and keep `node_modules/` as a technical residual.

### Task 2: Lock the `.agents` chain

**Files:**
- Modify: `C:\Users\enzo1\.agents\README.md`
- Modify: `C:\Users\enzo1\.agents\MAPA.md`
- Modify: `C:\Users\enzo1\.agents\skills\README.md`
- Modify: `C:\Users\enzo1\.agents\skills\MAPA.md`
- Modify: `C:\Users\enzo1\.agents\scripts\README.md`
- Modify: `C:\Users\enzo1\.agents\scripts\MAPA.md`
- Modify: `C:\Users\enzo1\.agents\plugins\README.md`
- Modify: `C:\Users\enzo1\.agents\plugins\MAPA.md`
- Modify: `C:\Users\enzo1\.agents\AGENTS_INDEX.csv` only if the visible inventory changed

- [ ] **Step 1: Read the visible catalog and support roots**

Run:
```powershell
Get-Content -LiteralPath 'C:\Users\enzo1\.agents\README.md','C:\Users\enzo1\.agents\MAPA.md','C:\Users\enzo1\.agents\skills\REY_MODO_SKILLS_REGISTRY_V1.md'
```

- [ ] **Step 2: Verify each support root has a short entry**

Expected:
- `skills/` has `README.md` and `MAPA.md`
- `scripts/` has `README.md` and `MAPA.md`
- `plugins/` has `README.md` and `MAPA.md`

- [ ] **Step 3: Preserve the local catalog contract**

Do not rewrite the registry content; only keep the entry points and references aligned.

### Task 3: Finish the `PROJEC CDX` chain

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\README_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_CAPAS.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\README_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\MAPA_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\ROOT_SWEEP_RESIDUALS_20260615.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\SWEEP_RESIDUALS_20260615.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\workbooks\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\workbooks\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\hitos\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\hitos\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\outputs\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\outputs\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\tools\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\tools\MAPA.md`

- [ ] **Step 1: Read the workbench entry and the current map layers**

Run:
```powershell
Get-Content -LiteralPath 'C:\Users\enzo1\PROJEC CDX\README.md','C:\Users\enzo1\PROJEC CDX\MAPA_CORTO.md','C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md','C:\Users\enzo1\PROJEC CDX\MAPA_CAPAS.md'
```

- [ ] **Step 2: Keep the workbench chain short and explicit**

Expected:
- `README.md` exposes the compact entry points first
- `MAPA_CORTO.md` summarizes work, evidence, support, and residuals
- `MAPA_MAESTRO.md` preserves the detailed visible graph
- `MAPA_CAPAS.md` stays as the layered quick-view

- [ ] **Step 3: Leave root residuals documented**

Keep `node_modules/` and any bucket-only folders explicitly categorized rather than flattened into the visible chain.

### Task 4: Tie Dataverse and repo lanes into the same chain

**Files:**
- Read/modify: `C:\Users\enzo1\PROJEC CDX\dataverse\PLAN_SEGUNDA_PASADA.md`
- Read/modify: `C:\Users\enzo1\PROJEC CDX\dataverse\MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md`
- Read/modify: `C:\Users\enzo1\PROJEC CDX\inventarios\GITHUB_REPOS_CANONICAL_20260615.csv`
- Read/modify: `C:\Users\enzo1\PROJEC CDX\inventarios\AUDITAR_SURFACE_INDEX_20260615.csv`
- Read/modify: `C:\Users\enzo1\PROJEC CDX\inventarios\PROJEC_CDX_ROOT_INVENTORY.md`
- Read/modify: `C:\Users\enzo1\PROJEC CDX\operativa\NOMENCLATURA_CADENA_OPERATIVA_20260615.md`
- Read/modify: `C:\Users\enzo1\PROJEC CDX\operativa\TAXONOMIA_NOMENCLATURA_20260615.md`

- [ ] **Step 1: Map the governed lanes**

Document:
- exact Dataverse gate surface
- exact repo canonical surface
- exact evidence surface
- exact stop condition for each lane

- [ ] **Step 2: Assign agent and skill boundaries**

Use the narrowest appropriate skill per lane, then keep the lane bounded:
- `dataverse-agent-surface-discovery`
- `dataverse-atomic-segment-runner`
- `dataverse-metadata-only-provisioning`
- `parallel-agentic-repo-audit`
- `repo-agent-tool-governance`
- `matrix-recipe-skill-sync`

- [ ] **Step 3: Keep live writes gated**

No live Dataverse or repo write without exact target, owner, rollback, postcheck, and evidence.

### Task 5: Parallel review and residual closure

**Files:**
- Update: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-15-ecosistema-cadena-punta-a-punta.md`
- Read-only verification of all files modified by Tasks 1-4

- [ ] **Step 1: Verify the short chain on every touched surface**

Confirm each surface reads as:
- short entry
- map short
- master map
- reference or residual

- [ ] **Step 2: Check for broken or duplicated visible links**

Use:
```powershell
Test-Path -LiteralPath 'PATH-HERE'
```

- [ ] **Step 3: Summarize residuals explicitly**

List anything that remains bucket-only or intentionally long-form, and keep it documented in one place.

### Task 6: Closeout

**Files:**
- Update: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_CIERRE_20260615.md`
- Update: `C:\Users\enzo1\PROJEC CDX\operativa\CONTROL_TOTAL_20260615.md`
- Update: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`
- Update: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`

- [ ] **Step 1: Record the final chain status**

Include:
- `agente`
- `orden`
- `superficie`
- `skill`
- `receta`
- `tool`
- `estado`
- `evidencia`
- `validador`
- `riesgo`
- `rollback`
- `stop_condition`
- `proximos_carriles`

- [ ] **Step 2: Write the readback as a short, operational closeout**

Keep it brief, actionable, and aligned with the residuals documented earlier.

- [ ] **Step 3: Preserve the pattern**

Leave a note that future expansions should keep the same atomic pattern: short entry, map, master map, reference, residual.
