# Codex .codex Surface Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `.codex` navigable with short visible entry points while preserving every important connection through reference files and internal maps.

**Architecture:** Use a two-layer pattern for each important surface: a short index file for quick reading, plus a reference file for full detail. Preserve existing cross-links instead of flattening or moving content blindly. Treat `README.md`, `AGENTS.md`, `environment/README.md`, and `skills/README.md` as the visible layer, and place long-form material in companion `*.reference.md`, `MAPA.md`, or `STACK.md` files.

**Tech Stack:** Markdown, PowerShell, local filesystem, `rg`, `Get-Content`, `apply_patch`.

---

### Task 1: Lock the visible entry points

**Files:**
- Modify: `C:\Users\enzo1\.codex\README.md`
- Modify: `C:\Users\enzo1\.codex\AGENTS.md`
- Modify: `C:\Users\enzo1\.codex\environment\README.md`
- Modify: `C:\Users\enzo1\.codex\skills\README.md`

- [ ] **Step 1: Read the current short-entry files**

Run:
```powershell
Get-Content -LiteralPath 'C:\Users\enzo1\.codex\README.md','C:\Users\enzo1\.codex\AGENTS.md','C:\Users\enzo1\.codex\environment\README.md','C:\Users\enzo1\.codex\skills\README.md'
```

- [ ] **Step 2: Confirm each file only points to its reference layer**

Expected:
- `README.md` points to `README.reference.md`
- `AGENTS.md` points to `AGENTS.reference.md`
- `environment/README.md` points to `MAPA.md` and `reference.md`
- `skills/README.md` points to `STACK.md` and `MATRIZ_OPERATIVA.md`

- [ ] **Step 3: Preserve the existing cross-links**

Keep links to:
- `workpapers/codex_evolutionary/README.md`
- `matrices/README.md`
- `sessions/README.md`
- `readbacks/README.md`
- `rules/README.md`
- `plugins/README.md`
- `worktrees/README.md`
- `log/README.md`

### Task 2: Keep the reference layer complete

**Files:**
- Modify: `C:\Users\enzo1\.codex\README.reference.md`
- Modify: `C:\Users\enzo1\.codex\AGENTS.reference.md`
- Modify: `C:\Users\enzo1\.codex\environment\reference.md`
- Modify: `C:\Users\enzo1\.codex\skills\STACK.md`
- Modify: `C:\Users\enzo1\.codex\skills\MATRIZ_OPERATIVA.md`
- Modify: `C:\Users\enzo1\.codex\skills\PROMPT_ARRANQUE.md`

- [ ] **Step 1: Verify the reference files still expose the full detail**

Run:
```powershell
Get-Content -LiteralPath 'C:\Users\enzo1\.codex\README.reference.md','C:\Users\enzo1\.codex\AGENTS.reference.md','C:\Users\enzo1\.codex\environment\reference.md','C:\Users\enzo1\.codex\skills\STACK.md','C:\Users\enzo1\.codex\skills\MATRIZ_OPERATIVA.md','C:\Users\enzo1\.codex\skills\PROMPT_ARRANQUE.md'
```

- [ ] **Step 2: Keep all dependency and session references intact**

Do not remove:
- PowerShell profile paths
- Power Platform bridge script paths
- skills root paths in `.codex` and `.agents`
- session, plugin, workpaper, and worktree indices

- [ ] **Step 3: Keep the stack and matrix consistent**

`STACK.md` should remain the visible grouping of the local skill stack, and `MATRIZ_OPERATIVA.md` should remain the small 3-carril router.

### Task 3: Audit the remaining local surfaces in parallel

**Files:**
- Read-only audit of: `C:\Users\enzo1\.codex\workpapers\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\plugins\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\matrices\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\sessions\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\readbacks\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\rules\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\worktrees\README.md`
- Read-only audit of: `C:\Users\enzo1\.codex\log\README.md`

- [ ] **Step 1: Read each surface and note whether it is already short enough**

Use parallel reads and record:
- whether the file is already a concise index
- whether it references a longer companion
- whether it points to live surfaces or only local support

- [ ] **Step 2: Decide which files need a reference companion**

Only split a surface if it is carrying too much context or too many responsibilities.

- [ ] **Step 3: Leave already-short surfaces alone**

Do not create extra files just to normalize styling if the current README is already a useful single-purpose index.

### Task 4: Verify the link graph

**Files:**
- Read-only verification of all `.codex` index and reference files touched in Tasks 1-3

- [ ] **Step 1: Open the visible entry points**

Confirm the reader can move from:
- `README.md` -> `README.reference.md`
- `AGENTS.md` -> `AGENTS.reference.md`
- `environment/README.md` -> `MAPA.md` and `reference.md`
- `skills/README.md` -> `STACK.md` and `MATRIZ_OPERATIVA.md`

- [ ] **Step 2: Confirm no broken paths were introduced**

Check every explicit path with:
```powershell
Test-Path -LiteralPath 'PATH-HERE'
```

- [ ] **Step 3: Confirm the visible layer stays short**

The visible files should read like entry points, not encyclopedias.

### Task 5: Closeout

**Files:**
- Update: whichever reference file needs a final pointer note

- [ ] **Step 1: Summarize what moved to visible maps and what stayed in reference**

- [ ] **Step 2: Confirm the structure still preserves every important connection**

- [ ] **Step 3: Leave a final note that future refactors should follow the same pattern**
