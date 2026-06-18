# Wave Atomica Documentos, PC Y Raiz Codex Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:dispatching-parallel-agents` to split the work into disjoint lanes. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Atomize the document and knowledge surfaces of the PC, promote repeated observations into canon, and turn the heavy Codex/code root into a short, governed, maintainable surface with explicit rules instead of drift.

**Operating Model:** Run the work as three repeatable waves, each with fresh agents and narrow fan-in:

1. wave A: reconnaissance and classification
2. wave B: transformation into canon, recipes, and procedures
3. wave C: punta-a-punta registration, maintenance, and validation

Within each wave, keep lanes disjoint:
- lane A: document atlas and knowledge surfaces on the PC
- lane B: Codex-visible roots, mirrors, and references
- lane C: the heavy code root that currently weighs about 19 GB, measured first and only then classified
- lane D: maintenance rules, retention, and validation

Never treat an unmeasured root as canonical. If the 19 GB surface is not confirmed, keep it as `NO_CONSTA` until inventory proves the exact target.

**Tech Stack:** Markdown, CSV, PowerShell, `rg`, `Get-Content`, `Get-ChildItem`, `Measure-Object`, `Test-Path`, `apply_patch`, `git`, `matrix-recipe-skill-sync`, `codex-surface-map`, `normalizacion-perfil-windows`, `cierre-wave-documental`, and `tcu-redactor-planes-operativos`.

## Punta A Punta

This packet is ready as an end-to-end operating plan. Use it in the same order every time:

1. Recolectar la superficie real.
2. Clasificar la superficie en canon, espejo, cronologia, cache y evidencia.
3. Transformar solo lo que se repite en patron, receta o proceso.
4. Registrar la salida en hitos, indices y trazas visibles.
5. Mantener con reglas diarias, semanales y mensuales.
6. Validar con el validador local y cerrar con readback corto.

## Mapa De Agentes

Use agents only on disjoint lanes, with narrow fan-in:

- Agent 1: atlas y clasificacion de `Documents`, `Documents\Codex` y `Documents\GitHub`.
- Agent 2: canon documental y promocion de patrones, recetas y procesos.
- Agent 3: medida y clasificacion del root pesado de `Documents\Cumplimiento`.
- Agent 4: mantenimiento, retention, indexes y reglas de no-guess.
- Agent 5: empaquetado de hito, readback y validacion final.

Recommended coordination rule:

- one agent per lane
- no shared write targets
- fan-in only after evidence is visible
- if a lane is ambiguous, stop and remeasure

Recommended local mapping if parallel workers are used:

- Carson: atlas y reconocimiento
- Nash: canon y crosslinks
- Lorentz: root pesado y mantenimiento
- Fermat: hito y registro
- Goodall: validation and readback

## Contracto De Ejecucion

The plan must always produce these artifacts in order:

1. surface inventory
2. short map
3. canon files
4. maintenance rules
5. hito package
6. validation result
7. short readback

If any artifact is missing, the wave is not complete.

---

### Wave 1: Reconocimiento y clasificacion

**Files:**
- Modify or create: `C:\Users\enzo1\Documents\README.md`
- Modify or create: `C:\Users\enzo1\Documents\MAPA.md`
- Modify or create: `C:\Users\enzo1\Documents\Codex\README.md`
- Modify or create: `C:\Users\enzo1\Documents\Codex\MAPA.md`
- Modify or create: `C:\Users\enzo1\Documents\GitHub\README.md`
- Modify or create: `C:\Users\enzo1\Documents\GitHub\MAPA.md`

- [x] **Step 1: Inventory the real top level**

Read the actual top-level entries under `C:\Users\enzo1\Documents`, `C:\Users\enzo1\Documents\Codex`, and `C:\Users\enzo1\Documents\GitHub`.

Classify each entry as:
- canonical
- synced alias
- shortcut or junction
- chronology
- work in progress
- archive
- cache

- [x] **Step 2: Keep aliases explicit**

Do not merge `Documents`, `OneDrive`, shortcut shells, or historical aliases unless the target path is confirmed and the rollback is written.

- [x] **Step 3: Rewrite the visible maps**

Make each `README.md` and `MAPA.md` short, navigable, and honest about what is canonical versus what is only mirrored.

### Wave 2: Transformacion

**Files:**
- Modify or create: `C:\Users\enzo1\Documents\Codex\INDICE.csv`
- Modify or create: `C:\Users\enzo1\Documents\Codex\README.md`
- Modify or create: `C:\Users\enzo1\Documents\Codex\MAPA.md`
- Modify or create: `C:\Users\enzo1\PROJEC CDX\patrones\documentos-canon-atomico.md`
- Modify or create: `C:\Users\enzo1\PROJEC CDX\recipes\documentos-canon-atomico.md`
- Modify or create: `C:\Users\enzo1\PROJEC CDX\procesos\documentos-canon-atomico.md`

- [x] **Step 1: Split the document atlas from the knowledge canon**

Keep the raw document inventory separate from the reusable canon. The atlas says what exists; the canon says what repeats.

- [x] **Step 2: Promote only repeated evidence**

Promote patterns into `patrones/`, recipes into `recipes/`, and procedures into `procesos/` only after they repeat or survive a validated wave.

- [x] **Step 3: Keep chronology and cache separate**

Chronology stays chronological. Cache stays cache. Nothing becomes canon just because it is recent.

### Wave 3: Registro punta a punta

**Files:**
- Modify or create: `C:\Users\enzo1\PROJEC CDX\inventarios\CODEX_ROOT_INVENTORY.md`
- Modify or update: `C:\Users\enzo1\PROJEC CDX\inventarios\CODEX_ROOT_INVENTORY.csv`
- Modify or update: `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md`
- Modify or update: `C:\Users\enzo1\PROJEC CDX\README.md`

- [x] **Step 1: Measure the exact 19 GB surface**

Use size inventory first. Identify the exact path that is consuming the heavy root before proposing any move or cleanup.

Confirmed surface: `C:\Users\enzo1\Documents\Cumplimiento` at `19.53 GB`, with `AUDITORIA_CODEX_LOCAL` at `16.76 GB` and `.git` at `2.77 GB`.

Next delta target inside that surface: `07_SHAREPOINT_POWER_PLATFORM_SGIN` at `9.80 GB`.

- [x] **Step 2: Classify the root into durable lanes**

Separate the measured surface into:
- canonical repo or workspace
- generated artifacts
- history and evidence
- caches and temp
- worktrees or mirrors

- [x] **Step 3: Define a no-guess rule for code root**

If a folder is not confirmed as canonical, keep it as a mirror, alias, or archive. Do not promote a guess.

### Wave 3.1: Maintenance rules

**Files:**
- Modify or update: `C:\Users\enzo1\PROJEC CDX\operativa\RETENCION.md`
- Modify or update: `C:\Users\enzo1\PROJEC CDX\operativa\TRACE.md`
- Modify or update: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify or update: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`

- [x] **Step 1: Define a daily rule**

Every new artifact gets classified the day it appears: canonical, mirror, transient, or discardable.

- [x] **Step 2: Define a weekly rule**

Every week, reindex visible roots and check whether any folder has drifted into duplicate-surface territory.

- [x] **Step 3: Define a monthly rule**

Every month, measure the heavy roots, refresh retention, and refresh the maintenance map.

- [x] **Step 4: Define move gates**

No move happens without:
- exact source and target
- rollback
- evidence
- postcheck
- validator

### Wave 3.2: Publish the wave entrypoints

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\ANCLAS_ON_DEMAND.md`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-pc-root-codex-mantenimiento-v1\README.md`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-pc-root-codex-mantenimiento-v1\READBACK.md`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-pc-root-codex-mantenimiento-v1\MANIFEST.yaml`
- Create: `C:\Users\enzo1\PROJEC CDX\hitos\20260616-wave-atomica-documentos-pc-root-codex-mantenimiento-v1\INDICE.csv`

- [x] **Step 1: Make the plan visible**

Expose the new plan from the plans index and the plans map so it can be reopened in one hop.

- [x] **Step 2: Add one on-demand anchor**

Add a short on-demand anchor so the plan can be resumed without replaying the full thread.

- [x] **Step 3: Package the wave**

When execution starts, version the result as a compact hito bundle with a readback and index.

### Wave 3.3: Validate and hand off

**Files:**
- Read-only verification with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_workbench.ps1`
- Read-only verification with `C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_sync.ps1`

- [x] **Step 1: Verify links and anchors**

Confirm the plan is reachable from the plans index, the map, and the on-demand anchor.

- [x] **Step 2: Verify surface boundaries**

Confirm that document surfaces, PC surfaces, and the heavy code root are all classified before any cleanup.

- [x] **Step 3: Keep the closeout short**

Return the exact visible result, the next single lane, and the rollback surface.

## Self-Review

### 1. Spec Coverage

- Document and knowledge atomization: covered in Tasks 1 and 2.
- Wave 1 reconnaissance and classification: covered in `Wave 1`.
- Wave 2 transformation: covered in `Wave 2`.
- Wave 3 measurement, maintenance, publication, and validation: covered in `Wave 3`.

## Reusable Wave Pattern

This plan is meant to repeat fast:

1. Reconocer y clasificar la superficie.
2. Transformar solo lo que repite en canon, recipes y procesos.
3. Registrar punta a punta con mantenimiento, anchors y validacion.

Recommended recipe pair:
- `agentes-atomicos-algoritmicos-en-waves`
- `cierre-wave-documental`

Recommended tools:
- `codex-surface-map`
- `normalizacion-perfil-windows`
- `matrix-recipe-skill-sync`
- `tcu-redactor-planes-operativos`

### 2. Placeholder Scan

- No `TBD`.
- No `TODO`.
- No vague "clean up later" language.

### 3. Type Consistency

- `canonical`, `mirror`, `archive`, `cache`, `rollback`, `validator`, `postcheck`, and `maintenance` are used consistently across the plan.
