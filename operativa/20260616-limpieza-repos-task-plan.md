# Tcu Redactor Planes Operativos

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reducir el peso de `C:\Users\enzo1\.codex` con waves atomicas, agentes especializados, evidencia y rollback claro, sin tocar secretos, identidades ni worktrees activos.

**Architecture:** Ejecutar por carriles independientes. Cada wave tiene una skill y una receta asociadas, y cada agente trabaja un contenedor distinto para evitar solapamiento. Primero se mide, luego se clasifica, despues se recorta solo lo reconstruible, y al final se verifica el delta.

**Tech Stack:** PowerShell local, filesystem Windows, skills/recipes `.agents`, matrices de sincronizacion locales.

---

### Task 1: Restos y temporales

**Files:**
- Create: `C:/Users/enzo1/.agents/skills/codex-root-surface-cleanup/SKILL.md`
- Create: `C:/Users/enzo1/.agents/recipes/codex-root-surface-cleanup-wave-v1.md`
- Modify: `C:/Users/enzo1/.agents/AGENTS_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/skills/REY_MODO_SKILLS_REGISTRY_V1.md`
- Modify: `C:/Users/enzo1/.agents/recipes/RECIPE_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_USAGE_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_METADATA_QUALITY_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/recipes/RECIPE_INDEX.csv`

- [x] **Step 1: Medir la raiz y ubicar restos obvios**

```powershell
$root = 'C:\Users\enzo1\.codex'
Get-ChildItem -LiteralPath $root -Force -Recurse -File |
  Measure-Object -Property Length -Sum
```

- [x] **Step 2: Recortar restos reconstruibles**

```powershell
Remove-Item -LiteralPath 'C:\Users\enzo1\.codex\.tmp\codex-app-asar-extract-20260530' -Recurse -Force
```

- [x] **Step 3: Verificar delta**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex' -Force -Recurse -File |
  Measure-Object -Property Length -Sum
```

### Task 2: Sesiones y worktrees

**Files:**
- Create: `C:/Users/enzo1/.agents/skills/codex-session-worktree-surface-cleanup/SKILL.md`
- Create: `C:/Users/enzo1/.agents/recipes/codex-session-worktree-cleanup-wave-v1.md`
- Modify: `C:/Users/enzo1/.agents/AGENTS_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/skills/REY_MODO_SKILLS_REGISTRY_V1.md`
- Modify: `C:/Users/enzo1/.agents/recipes/RECIPE_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_USAGE_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_METADATA_QUALITY_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/recipes/RECIPE_INDEX.csv`

- [x] **Step 1: Inventariar sesiones, archivados y worktrees**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\sessions','C:\Users\enzo1\.codex\archived_sessions','C:\Users\enzo1\.codex\worktrees' -Force
```

- [x] **Step 2: Marcar lo vivo y lo historico**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\worktrees' -Force | Select-Object Name,LastWriteTime
```

- [x] **Step 3: Verificar que no se toque lo activo**

```powershell
Get-Process | Select-Object ProcessName,Id | Where-Object { $_.ProcessName -match 'codex|node|python' }
```

### Task 3: Archivados y runtime historico

**Files:**
- Create: `C:/Users/enzo1/.agents/skills/codex-archived-runtime-surface-cleanup/SKILL.md`
- Create: `C:/Users/enzo1/.agents/recipes/codex-archived-runtime-cleanup-wave-v1.md`
- Modify: `C:/Users/enzo1/.agents/AGENTS_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/skills/REY_MODO_SKILLS_REGISTRY_V1.md`
- Modify: `C:/Users/enzo1/.agents/recipes/RECIPE_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_USAGE_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_METADATA_QUALITY_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/recipes/RECIPE_INDEX.csv`

- [x] **Step 1: Medir `archived_sessions` y `cache/codex-runtimes`**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\archived_sessions','C:\Users\enzo1\.codex\cache\codex-runtimes' -Force
```

- [x] **Step 2: Separar historico viejo de runtime vivo**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\archived_sessions' -Force | Sort-Object LastWriteTime -Descending
```

- [x] **Step 3: Mantener intacto el runtime activo**

```powershell
Get-Item -LiteralPath 'C:\Users\enzo1\.codex\cache\codex-runtimes\codex-primary-runtime\runtime.json'
```

### Task 4: SQLite y logs pesados

**Files:**
- Create: `C:/Users/enzo1/.agents/skills/codex-sqlite-log-surface-cleanup/SKILL.md`
- Create: `C:/Users/enzo1/.agents/recipes/codex-sqlite-log-compact-wave-v1.md`
- Modify: `C:/Users/enzo1/.agents/AGENTS_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/skills/REY_MODO_SKILLS_REGISTRY_V1.md`
- Modify: `C:/Users/enzo1/.agents/recipes/RECIPE_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_USAGE_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_METADATA_QUALITY_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/recipes/RECIPE_INDEX.csv`

- [x] **Step 1: Medir `logs_2.sqlite`, `state_5.sqlite` y auxiliares**

```powershell
Get-Item -LiteralPath 'C:\Users\enzo1\.codex\logs_2.sqlite','C:\Users\enzo1\.codex\state_5.sqlite','C:\Users\enzo1\.codex\logs_2.sqlite-wal','C:\Users\enzo1\.codex\logs_2.sqlite-shm'
```

- [x] **Step 2: Confirmar si son bases vivas o historicas**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex' -Force -File | Sort-Object Length -Descending
```

- [x] **Step 3: Solo compactar o archivar lo reconstruible**

```powershell
Remove-Item -LiteralPath 'C:\Users\enzo1\.codex\python-cache-test' -Recurse -Force
```

### Task 5: Cache de runtimes

**Files:**
- Create: `C:/Users/enzo1/.agents/skills/codex-runtime-cache-surface-cleanup/SKILL.md`
- Create: `C:/Users/enzo1/.agents/recipes/codex-runtime-cache-wave-v1.md`
- Modify: `C:/Users/enzo1/.agents/AGENTS_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/skills/REY_MODO_SKILLS_REGISTRY_V1.md`
- Modify: `C:/Users/enzo1/.agents/recipes/RECIPE_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_USAGE_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_METADATA_QUALITY_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/recipes/RECIPE_INDEX.csv`

- [x] **Step 1: Medir `cache/codex-runtimes`**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\cache\codex-runtimes' -Force
```

- [x] **Step 2: Recortar solo cache regenerable**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\cache\codex-runtimes\codex-primary-runtime\dependencies\python\Lib' -Force -Directory -Filter '__pycache__' -Recurse
```

- [x] **Step 3: Verificar ahorro real**

```powershell
Get-ChildItem -LiteralPath 'C:\Users\enzo1\.codex\cache\codex-runtimes' -Force -Recurse -File |
  Measure-Object -Property Length -Sum
```

### Task 6: Cierre y sincronizacion

**Files:**
- Modify: `C:/Users/enzo1/.agents/AGENTS_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/skills/REY_MODO_SKILLS_REGISTRY_V1.md`
- Modify: `C:/Users/enzo1/.agents/recipes/RECIPE_INDEX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_USAGE_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/skills/SKILL_METADATA_QUALITY_MATRIX.csv`
- Modify: `C:/Users/enzo1/.agents/codex/recipes/RECIPE_INDEX.csv`

- [x] **Step 1: Releer índices y corregir tamaños**
- [x] **Step 2: Confirmar que cada skill tiene receta asociada**
- [x] **Step 3: Cerrar con un resumen de deltas y próximos carriles**
