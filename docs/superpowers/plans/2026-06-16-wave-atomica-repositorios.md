# Wave Atomica de Repositorios Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare a governed atomic wave across the 13 canonical Git repositories so each lane leaves a small reusable atom of energy and knowledge without shared-state interference.

**Architecture:** Use the existing repo matrix as the source of truth, split the work into disjoint lanes by repo family, and keep `PROJEC CDX` as the orchestration hub. Reuse `operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md`, `recipes/agentes-atomicos-algoritmicos-en-waves.md`, and `procesos/agentes-atomicos-algoritmicos-en-waves.md` so each wave is one scope, one owner, one validator, one stop condition.

**Tech Stack:** Markdown, PowerShell, `rg`, `Get-Content`, `Test-Path`, `apply_patch`, `git`, `parallel-order-governance`, `repo-agent-tool-governance`, `matrix-recipe-skill-sync`, `dispatching-parallel-agents`, `subagent-driven-development`.

---

### Task 1: Freeze canonical repo lanes

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\ACTA_CIERRE_REPOS_GIT_MAIN_ONLY_20260615.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\TRACE.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md`

- [ ] **Step 1: Read the canonical repo set**

Use the existing matrix as the source of truth for the 13 canonical repos:
`cabina-universal-d`, `cdf-soluciones`, `jara-consultores`, `microsoft-agents-governed-lab`, `modo-on-foundation`, `organizacion`, `sdu-canon`, `seshat-bootstrap-sdu-cn`, `Sgin`, `sgin-cumplimiento`, `tcu-agentic-runtime-control`, `tge-agentic-runtime-control-escribania`, and `torre-gemela-escribania`.

- [ ] **Step 2: Split the scope into disjoint lanes**

Define lanes such as:
- repo core
- hub documentation
- residual and archive

Keep each lane disjoint and declare `lead_agent`, `owner_agent`, `reviewer_agent`, `lock_key`, `validator`, `rollback`, and `stop_condition` before any execution.

- [ ] **Step 3: Record the lane contract**

Write the exact repo slugs for each lane so the next agent can continue without guessing or rereading the whole matrix.

### Task 2: Publish the wave entrypoints

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\ANCLAS_ON_DEMAND.md`

- [ ] **Step 1: Add the new plan to the visible plan index**

Expose `2026-06-16-wave-atomica-repositorios.md` from `docs/superpowers/plans/README.md` so the wave can be found from the plans surface in one hop.

- [ ] **Step 2: Point current state at the next atomic move**

Update `CURRENT.md` with a short note that the next preparatory wave is the atomic repo wave, but keep the earlier closeout history intact.

- [ ] **Step 3: Make NEXT.md the single entry point**

Keep `NEXT.md` as the one-place handoff for the atomic repo wave so no other fresh delta starts by accident.

- [ ] **Step 4: Add an on-demand anchor**

Add a short reference in `ANCLAS_ON_DEMAND.md` so the new plan is reachable from the existing wave entry path without hunting.

### Task 3: Define the reusable atom packet

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\recipes\agentes-atomicos-algoritmicos-en-waves.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\procesos\agentes-atomicos-algoritmicos-en-waves.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md`

- [ ] **Step 1: Add the repo-wave packet fields**

Every agent return for this wave must include:
- `repo`
- `lane`
- `scope`
- `evidence`
- `validator`
- `rollback`
- `fan_in`

- [ ] **Step 2: Keep each wave atomically small**

One lane, one review, one closeout. If the lane grows, split it before continuing.

- [ ] **Step 3: Keep the matrix aligned**

Make the matrix point to the wave recipe whenever the work spans multiple repos, so the capability path stays visible and reusable.

### Task 4: Validate and hand off

**Files:**
- Read-only verification with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_workbench.ps1`
- Read-only verification with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_sync.ps1`
- Optional chain check with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_operational_chain.ps1`

- [ ] **Step 1: Run the validators after the links are updated**

Confirm the plan file is reachable from the plan index and from the on-demand anchors.

- [ ] **Step 2: Promote the wave only after validation**

Do not write fan-in to `TRACE.md` until the wave actually starts executing.

- [ ] **Step 3: Keep the closeout short**

When execution starts, close each lane with the required contract fields and one exact next move.

## Self-Review

### 1. Spec Coverage

- Canonical repo set: covered in Task 1.
- Entry points and discoverability: covered in Task 2.
- Reusable agent packet: covered in Task 3.
- Validation and handoff: covered in Task 4.

### 2. Placeholder Scan

- No `TBD`.
- No `TODO`.
- No unresolved scope language.

### 3. Type Consistency

- `lead_agent`, `owner_agent`, `reviewer_agent`, `lock_key`, `validator`, `rollback`, `stop_condition`, and `fan_in` are used consistently across the plan.
