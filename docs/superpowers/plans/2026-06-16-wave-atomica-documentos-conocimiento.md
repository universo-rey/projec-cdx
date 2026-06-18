# Wave Atomica Documentos Y Conocimiento Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the visible document surfaces into atomic, navigable, reusable canon and promote repeated observations into patterns, recipes, processes, and future skill candidates.

**Architecture:** Treat `C:\Users\enzo1\Documents` as the root document atlas, `C:\Users\enzo1\Documents\GitHub` as the repo atlas, `C:\Users\enzo1\Documents\Codex` as the Codex chronology and inventory subatlas, and the `PROJEC CDX` repository as the promotion layer for patterns and reusable canon. Execute one fresh agent per lane: root atlas, repo atlas, Codex chronology, canon promotion, and publication/validation. No folder moves happen unless the lane classifies a path as durable and the rollback is explicit.

**Tech Stack:** Markdown, CSV, PowerShell, `rg`, `Get-Content`, `Get-ChildItem`, `apply_patch`, local readbacks, the existing `canon-documental` pattern, and `skill-creator` only after the pattern stabilizes.

---

### Task 1: Freeze the root `Documents` atlas

**Files:**
- Modify: `C:\Users\enzo1\Documents\README.md`
- Modify: `C:\Users\enzo1\Documents\DOCUMENTS_INDEX.csv`

- [ ] **Step 1: Read the live root surface**

Inventory the actual top level of `C:\Users\enzo1\Documents`, then classify the entries into:
- canonical hubs
- documentary hubs
- synchronized media
- work in progress
- preserved history

Keep `Mis documentos` as the same tree as `Documents`, not a second root.

- [ ] **Step 2: Rebuild the root narrative**

Rewrite `README.md` so the order is visible at a glance and the root surface is understandable without hunting.

- [ ] **Step 3: Rebuild the quick index**

Update `DOCUMENTS_INDEX.csv` so it mirrors the README classification and preserves the root catalog as the fast lookup path.

- [ ] **Step 4: Keep the index honest**

If a folder is only a shortcut, synced alias, or working residue, mark it that way instead of treating it as canon.

### Task 2: Atomize `Documents\Codex`

**Files:**
- Modify: `C:\Users\enzo1\Documents\Codex\README.md`
- Modify: `C:\Users\enzo1\Documents\Codex\CODEX_INDEX.csv`

- [ ] **Step 1: Read the chronology tree**

Inventory the dated branches under `C:\Users\enzo1\Documents\Codex` and keep them as atomic chronology nodes:
- `2026-04-29`
- `2026-05-02`
- `2026-05-17`
- `2026-06-04`
- `2026-06-13`
- `2026-06-14`
- `99_INVENTARIOS`

- [ ] **Step 2: Separate durable history from derived cache**

Make `README.md` state clearly that `99_INVENTARIOS` is the snapshot lane and that dated folders are chronology, not a generic dump.

- [ ] **Step 3: Repair the index**

Bring `CODEX_INDEX.csv` in sync with the visible chronology and keep it sorted by the same visible order as the README.

- [ ] **Step 4: Preserve the no-move rule**

Do not move dated branches unless the lane first proves the new target and the rollback path.

### Task 3: Atomize `Documents\GitHub`

**Files:**
- Modify: `C:\Users\enzo1\Documents\GitHub\README.md`
- Modify: `C:\Users\enzo1\Documents\GitHub\GITHUB_INDEX.csv`

- [ ] **Step 1: Read the repo atlas**

Inventory the visible children of `C:\Users\enzo1\Documents\GitHub` and classify them into:
- canonical repos
- support surfaces
- clone or staging containers
- worktree or derivative folders

Keep `Auditar` as support, not as a versioned repo.

- [ ] **Step 2: Rebuild the repo narrative**

Rewrite `README.md` so canonical repos and derivative surfaces are obvious without scanning the whole tree.

- [ ] **Step 3: Rebuild the fast index**

Update `GITHUB_INDEX.csv` so it mirrors the README classification and keeps the repo atlas searchable in one hop.

- [ ] **Step 4: Keep the atlas honest**

If a folder is a clone, staging payload, or derivative worktree, mark it that way instead of promoting it to canonical repo status.

### Task 4: Promote reusable canon from repeated observations

**Files:**
- Create: `C:\Users\enzo1\PROJEC CDX\patrones\documentos-canon-atomico.md`
- Create: `C:\Users\enzo1\PROJEC CDX\recipes\documentos-canon-atomico.md`
- Create: `C:\Users\enzo1\PROJEC CDX\procesos\documentos-canon-atomico.md`

- [ ] **Step 1: Extract stable patterns**

Promote only rules that repeat across `Documents`, `Documents\Codex`, and future document surfaces:
- inventory before move
- classify before promote
- evidence before index
- one source of truth per surface
- keep root, cache, and chronology separate

- [ ] **Step 2: Encode the reusable recipe**

Describe how to take a messy document surface and return it as a short, navigable, atomic catalog.

- [ ] **Step 3: Encode the executable process**

Turn the recipe into a short operational process with a clear stop condition:
- missing evidence
- ambiguous root
- duplicate source of truth
- attempted promotion without a stable pattern

- [ ] **Step 4: Defer the skill until it survives the first wave**

Only after the pattern survives one execution wave should it be promoted into a new skill candidate.

### Task 5: Publish the wave entrypoints

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\ANCLAS_ON_DEMAND.md`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-conocimiento-v1\README.md`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-conocimiento-v1\READBACK.md`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-conocimiento-v1\MANIFEST.yaml`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-conocimiento-v1\INDICE.csv`

- [ ] **Step 1: Make the plan visible**

Add this plan to the plan index and the plan map so it can be found in one hop.

- [ ] **Step 2: Add one on-demand anchor**

Add a short anchor in `ANCLAS_ON_DEMAND.md` so the wave can be reopened without hunting through history.

- [ ] **Step 3: Package the wave**

Create the hito bundle so the plan has a durable, lightweight readback and a clean index row.

### Task 6: Validate and hand off

**Files:**
- Read-only verification with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_workbench.ps1`
- Read-only verification with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_sync.ps1`

- [ ] **Step 1: Verify links and indices**

Confirm the plan is reachable from the plan index, the plan map, and the on-demand anchor.

- [ ] **Step 2: Verify the document atomization boundaries**

Confirm the root README, `Codex` README, and canon promotion files all point to one clear source of truth per surface.

- [ ] **Step 3: Keep the closeout short**

Return the exact visible result, the next single lane, and the rollback surface.

## Self-Review

### 1. Spec Coverage

- Root `Documents` atlas: covered in Task 1.
- `Documents\Codex` chronology and index repair: covered in Task 2.
- `Documents\GitHub` repo atlas and classification: covered in Task 3.
- Pattern/recipe/process promotion: covered in Task 4.
- Wave visibility and validation: covered in Tasks 5 and 6.

### 2. Placeholder Scan

- No `TBD`.
- No `TODO`.
- No vague "handle edge cases" language.

### 3. Type Consistency

- `Documents`, `Codex`, `pattern`, `recipe`, `process`, `hito`, and `anchor` are used consistently across the plan.
