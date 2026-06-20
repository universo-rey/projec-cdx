# Perfiles Variables Entornos Aislados Repos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configurar primero perfiles y variables de la cabina `C:\CEO`, y despues proyectar por repo si necesita `.venv`, Node lockfile, devcontainer, worktree o solo validacion documental.

**Architecture:** La maquina se gobierna desde `C:\CEO`; los repos canonicos deben terminar en `C:\CEO\repos`; los worktrees activos deben vivir en `C:\CEO\worktrees`; `C:\Users\enzo1\PROJEC CDX` queda como workspace fisico real de esta cabina hasta que se decida otra migracion. Cada repo recibe un tipo de aislamiento segun evidencia local y criterio oficial: devcontainer para entornos reproducibles, `.venv` para Python, lockfile para Node, worktree para ramas paralelas, y modo documental cuando no hay runtime.

**Tech Stack:** PowerShell 7, Windows Terminal, variables `User`/`Process`, Git worktree, GitHub Codespaces, devcontainer.json, Python venv, Node/npm lockfiles, PAC/Power Platform gates, Markdown, CSV.

---

## Fuentes externas usadas

| Fuente | Regla aplicada |
| --- | --- |
| https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers | `.devcontainer/devcontainer.json` vive en `.devcontainer` o raiz; puede incluir herramientas, extensiones, puertos y multiples configs; debe ser customizacion compartida, no preferencia personal. |
| https://containers.dev/implementors/spec/ | Separar `containerEnv` y `remoteEnv`; `workspaceFolder` debe apuntar al repo para Git correcto. |
| https://docs.github.com/en/codespaces/developing-in-a-codespace/persisting-environment-variables-and-temporary-files | `remoteEnv` es valido para plaintext no sensible; secretos van a development environment secrets. |
| https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces | Secrets pueden limitarse por repo; nombres sin espacios, sin prefijo `GITHUB_`, no empezar con numero. |
| https://git-scm.com/docs/git-worktree | Worktrees permiten multiples ramas en carpetas separadas sin pisar el checkout principal. |
| https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables | PowerShell distingue `Process`, `User` y `Machine`; `$Env:` cambia la sesion actual, `System.Environment` permite persistencia. |
| https://docs.python.org/3/tutorial/venv.html | `.venv` es nombre comun para virtualenv Python por proyecto y evita chocar con archivos `.env`. |

## Estado local observado

| Superficie | Estado |
| --- | --- |
| `C:\CEO` | Existe. |
| `C:\CEO\repos` | Existe, vacio. |
| `C:\CEO\worktrees` | Existe, vacio. |
| `C:\Users\enzo1\Documents\GitHub` | Contiene la mayoria de clones actuales. |
| `C:\Users\enzo1\PROJEC CDX` | Repo Git con `pyproject.toml`, `.venv` y `.env.local`. |
| Variables `CEO_*` y `CODEX_*` | Process y User alineadas a `C:\CEO` y subcapas. |

## Criterio de aislamiento

| Clase | Cuando aplica | Entorno |
| --- | --- | --- |
| `python-runtime` | `pyproject.toml` o deps Python reales | `.venv` local; devcontainer si necesita reproducibilidad cloud. |
| `python-stdlib` | `requirements.txt` vacio o stdlib-only | Sin aislamiento pesado; `.venv` opcional para higiene. |
| `node-agents` | `package.json` + lockfile | `npm ci` sobre lockfile; devcontainer si hay agentes o M365. |
| `devcontainer-powerplatform` | `.devcontainer` + Power Platform/M365/PAC | Devcontainer repo-only/no-live; secrets fuera del repo. |
| `documental-canon` | Markdown/canon sin runtime | Git + validacion documental; sin `.venv` ni `node_modules`. |
| `worktree-lane` | Rama paralela o delta experimental | `C:\CEO\worktrees\<repo>\<branch>` con rama `codex/*`. |

## Agentes asignados

La asignacion operativa vive en `C:\Users\enzo1\PROJEC CDX\inventarios\REPO_ENV_ISOLATION_MATRIX_20260619.csv`. Este resumen evita que el agente tenga que inferir owners:

| Agente | Superficies asignadas | Responsabilidad |
| --- | --- | --- |
| Seshat | `seshat-bootstrap-sdu-cn`, `Sgin`, `sdu-canon` | Canon documental, voz, continuidad y publish documental. |
| Thot | `organizacion`, `modo-on-foundation`, `jara-consultores` | Taxonomia, estructura, rutas y clasificacion de superficies sin runtime. |
| Anubis | `cdf-soluciones`, `torre-gemela-escribania`, `sgin-cumplimiento` | Fronteras Microsoft/Power Platform/compliance, gates, riesgos y stop conditions. |
| Maat | `PROJEC CDX`, `tcu-agentic-runtime-control`, `tge-agentic-runtime-control-escribania` | Validacion, perfiles, variables, `.venv`, postchecks y coherencia de cierre. |
| Horus | `microsoft-agents-governed-lab` | Lectura visual, agentes Node, lockfile y entorno previo a live agent work. |
| Atomic | `cabina-universal-d` | Worktree lanes, compresion de aprendizaje y cierre de deltas gobernados. |

## Recetas existentes reutilizadas

No se parte de cero. Este plan reusa recetas, patrones y procesos ya versionados:

| Recurso | Uso en este plan |
| --- | --- |
| `C:\Users\enzo1\PROJEC CDX\recipes\normalizacion-perfil-windows.md` | Validar rutas reales, shell folders, junctions, OneDrive y postcheck antes de tocar perfiles. |
| `C:\Users\enzo1\PROJEC CDX\patrones\normalizacion-perfil-windows.md` | Detectar drift entre local, OneDrive, snapshots y rutas visibles. |
| `C:\Users\enzo1\PROJEC CDX\procesos\normalizacion-perfil-windows.md` | Orden operativo para copiar, reconciliar, reescribir rutas y cerrar. |
| `C:\Users\enzo1\PROJEC CDX\recipes\limpieza-pc-local-segura.md` | Mantener limpieza reversible y no destructiva. |
| `C:\Users\enzo1\PROJEC CDX\recipes\agentes-atomicos-algoritmicos-en-waves.md` | Ejecutar por waves atomicas, idempotentes y trazables. |
| `C:\Users\enzo1\PROJEC CDX\recipes\cierre-wave-documental.md` | Cerrar cada wave con evidencia compacta. |
| `C:\Users\enzo1\PROJEC CDX\recipes\canon-documental.md` | Mantener canon vivo sin duplicar autoridad. |
| `C:\Users\enzo1\PROJEC CDX\recipes\dataverse-rehidratacion.md` | Rehidratar desde Dataverse cuando el carril lo requiera. |
| `C:\Users\enzo1\PROJEC CDX\recipes\configuracion-entorno-codex-ui.md` | Reutilizar criterios de entorno Codex/UI sin inventar setup nuevo. |
| `C:\Users\enzo1\PROJEC CDX\recipes\sdu-dataverse-metadata-wave.md` | Mantener metadata wave gobernada para Dataverse. |

---

### Task 1: Congelar perfiles y variables antes de repos

**Files:**
- Review: `C:\CEO\Start-CEO.ps1`
- Review: `C:\CEO\CodexProfile.ps1`
- Review: `C:\CEO\windows-terminal\settings.json`
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_CEO_ENV_TERMINAL_20260619.md`
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_PERFILES_VARIABLES_PRE_REPOS_20260619.md`

- [ ] **Step 1: Leer baseline**

  Abrir `READBACK_CEO_ENV_TERMINAL_20260619.md` y tratarlo como baseline cerrado salvo que falle el postcheck.

- [ ] **Step 2: Verificar variables User y Process**

  Ejecutar:

  ```powershell
  $rows = @()
  $names = @(
    'CEO_ROOT','CEO_PROJECT_CDX_ROOT','CEO_REPOS_ROOT','CEO_WORKTREES_ROOT',
    'CEO_AGENTS_ROOT','CEO_SKILLS_ROOT','CEO_CHAINS_ROOT','CEO_M365_ROOT',
    'CEO_DATAVERSE_ROOT','CEO_RUNTIME_ROOT','CODEX_START_ROOT',
    'CODEX_WORKBENCH_ROOT','CODEX_PROJECT_ROOT','CODEX_SOURCE_TREE_PATH',
    'CODEX_WORKTREE_PATH','CODEX_METADATA_ROOT','CODEX_CABINA_ROOT',
    'SOURCE_TREE_PATH'
  )
  foreach ($n in $names) {
    $rows += [pscustomobject]@{
      Name = $n
      Process = [Environment]::GetEnvironmentVariable($n, 'Process')
      User = [Environment]::GetEnvironmentVariable($n, 'User')
    }
  }
  $rows | Format-Table -AutoSize
  ```

  Expected: `Process` y `User` coinciden en todas las variables rectoras.

- [ ] **Step 3: Verificar que no haya raiz amplia**

  Confirmar:

  ```powershell
  $bad = $rows | Where-Object { $_.User -eq 'C:\' -or $_.User -eq 'C:/' -or $_.Process -eq 'C:\' -or $_.Process -eq 'C:/' }
  $bad.Count
  ```

  Expected: `0`.

- [ ] **Step 4: Guardar readback**

  Escribir:

  ```markdown
  # READBACK_PERFILES_VARIABLES_PRE_REPOS_20260619

  ## Estado
  PASS|OBSERVED|FAIL

  ## Variables
  - 

  ## Terminal
  - 

  ## Delta
  - 

  ## Stop Condition
  - No mover repos ni crear entornos si las variables rectoras fallan.
  ```

### Task 2: Validar frontera fisica antes de mover o clonar

**Files:**
- Review: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-19-normalizacion-cabina-local.md`
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_INVESTIGACION_PERFILES_VARIABLES_ENTORNOS_REPOS_20260619.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\REPO_ENV_ISOLATION_MATRIX_20260619.csv`

- [ ] **Step 1: Confirmar raices**

  Ejecutar:

  ```powershell
  $rows = @()
  foreach ($p in @('C:\CEO','C:\CEO\repos','C:\CEO\worktrees','C:\Users\enzo1\Documents\GitHub','C:\Users\enzo1\PROJEC CDX')) {
    $exists = Test-Path -LiteralPath $p
    $count = 0
    if ($exists) { $count = @(Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue).Count }
    $rows += [pscustomobject]@{Path=$p; Exists=$exists; ItemCount=$count}
  }
  $rows | Format-Table -AutoSize
  ```

  Expected: `C:\CEO\repos` y `C:\CEO\worktrees` existen; no importa si estan vacios antes de migrar.

- [ ] **Step 2: Clasificar origen actual**

  Usar `C:\Users\enzo1\Documents\GitHub` como origen actual de clones, no como canon final.

- [ ] **Step 3: Clasificar target canonico**

  Target por repo: `C:\CEO\repos\<repo>`.

- [ ] **Step 4: Stop condition**

  No mover carpeta existente si el repo tiene worktrees, dirty state o rama no confirmada.

### Task 3: Relevar cada repo con marcador de runtime

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\REPO_ENV_ISOLATION_MATRIX_20260619.csv`
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_REPO_ENV_MARKERS_20260619.md`

- [ ] **Step 1: Releer marcadores**

  Ejecutar:

  ```powershell
  Get-ChildItem -LiteralPath 'C:\Users\enzo1\Documents\GitHub' -Directory -Force |
    ForEach-Object {
      $p = $_.FullName
      $markers = @()
      foreach ($m in @('pyproject.toml','requirements.txt','package.json','pnpm-lock.yaml','package-lock.json','yarn.lock','Dockerfile','.devcontainer','pac.json','solution.xml')) {
        if (Test-Path -LiteralPath (Join-Path $p $m)) { $markers += $m }
      }
      [pscustomobject]@{Repo=$_.Name; Git=(Test-Path -LiteralPath (Join-Path $p '.git')); Markers=($markers -join ';')}
    } | Sort-Object Repo | Format-Table -AutoSize
  ```

  Expected: matriz comparable con `REPO_ENV_ISOLATION_MATRIX_20260619.csv`.

- [ ] **Step 2: Confirmar clase**

  Asignar cada repo a una clase: `python-runtime`, `python-stdlib`, `node-agents`, `devcontainer-powerplatform`, `documental-canon`, `worktree-lane`.

- [ ] **Step 3: Confirmar owner agente**

  Asignar owner: Seshat, Thot, Anubis, Maat, Horus o Atomic.

- [ ] **Step 4: Guardar readback**

  Escribir repos con delta real: repos sin marcador, repos con `.devcontainer`, repos con Python, repos con Node.

### Task 4: Definir estrategia de migracion a `C:\CEO\repos`

**Files:**
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\PLAN_MIGRACION_REPOS_CEO_REPOS_20260619.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\REPO_ENV_ISOLATION_MATRIX_20260619.csv`

- [ ] **Step 1: Preferir clone limpio sobre move ciego**

  Para cada repo con remoto GitHub confirmado, usar estrategia:

  ```text
  clone/fetch -> validar branch/remoto -> comparar -> declarar target -> recien despues decidir si archivar origen viejo
  ```

- [ ] **Step 2: Detectar worktrees existentes**

  En cada repo Git, ejecutar:

  ```powershell
  git -C '<repo-path>' worktree list
  git -C '<repo-path>' status --short --branch
  git -C '<repo-path>' remote -v
  ```

  Expected: no migrar si hay dirty state sin clasificar.

- [ ] **Step 3: Crear target**

  Target final:

  ```text
  C:\CEO\repos\<repo>
  C:\CEO\worktrees\<repo>\<branch-or-delta>
  ```

- [ ] **Step 4: Stop condition**

  Si `git status` muestra cambios locales no clasificados, preservar y detener migracion de ese repo.

### Task 5: Configurar entornos por clase, no por impulso

**Files:**
- Modify only per repo after approval: `<repo>\.devcontainer\devcontainer.json`
- Modify only per repo after approval: `<repo>\pyproject.toml`
- Modify only per repo after approval: `<repo>\requirements.txt`
- Modify only per repo after approval: `<repo>\package.json`
- Create per repo if needed: `<repo>\.env.example`

- [ ] **Step 1: Python runtime**

  Para `pyproject.toml`, usar:

  ```powershell
  python -m venv .venv
  .\.venv\Scripts\python.exe -m pip install -e ".[dev]"
  .\.venv\Scripts\python.exe -m pytest
  ```

  Expected: entorno local aislado y pruebas ejecutables.

- [ ] **Step 2: Python stdlib**

  Si `requirements.txt` esta vacio, no instalar nada. Crear `.venv` solo si el repo necesita runner aislado.

- [ ] **Step 3: Node**

  Si hay `package-lock.json`, usar:

  ```powershell
  npm ci
  npm run validate-governance
  ```

  Expected: respetar lockfile; no cambiar package manager sin decision.

- [ ] **Step 4: Devcontainer**

  Mantener `remoteEnv` solo para valores no sensibles. Secretos: GitHub Codespaces secrets con acceso limitado por repo.

- [ ] **Step 5: Documental**

  No crear `.venv`, `node_modules` ni devcontainer si no hay runtime. Usar validacion Markdown/Git.

### Task 6: Definir politica de variables y secretos por superficie

**Files:**
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\POLITICA_VARIABLES_SECRETOS_ENTORNOS_20260619.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\REPO_ENV_ISOLATION_MATRIX_20260619.csv`

- [ ] **Step 1: Variables locales CEO**

  Variables `CEO_*` y `CODEX_*`: scope `User`, no `Machine`.

- [ ] **Step 2: Variables por repo no sensibles**

  Guardar en `.env.example`, `remoteEnv` o README de setup.

- [ ] **Step 3: Secretos**

  No versionar. Usar `.env.local` local o Codespaces secrets por repo.

- [ ] **Step 4: Live gates**

  Microsoft/Dataverse/SharePoint/Power Platform/OpenAI live quedan fuera de setup por defecto. Requieren target, owner, rollback, postcheck y evidencia.

### Task 7: Cerrar con postcheck y matriz viva

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\REPO_ENV_ISOLATION_MATRIX_20260619.csv`

- [ ] **Step 1: Postcheck variables**

  Variables rectoras pasan `Process == User` y ninguna apunta a `C:\`.

- [ ] **Step 2: Postcheck repos**

  Cada repo tiene `CanonicalTarget`, `IsolationClass`, `RecommendedEnvironment`, `OwnerAgent` y `StopCondition`.

- [ ] **Step 3: Postcheck entorno**

  Ningun repo tiene `node_modules`, `.venv` o `.devcontainer` nuevo sin decision registrada.

- [ ] **Step 4: Publicar estado**

  `CURRENT.md` debe decir que perfiles/variables estan listos para migracion/repos; `NEXT.md` debe dejar un solo delta: migracion/clonado controlado por repo.

## Validation

- `C:\CEO\repos` y `C:\CEO\worktrees` existen.
- Variables User y Process coinciden.
- `REPO_ENV_ISOLATION_MATRIX_20260619.csv` cubre repos observados.
- Los repos con `.devcontainer` conservan gates `NO_LIVE` o equivalentes.
- Los repos Python tienen clase `.venv` o stdlib-only.
- Los repos Node respetan lockfile.
- No se movio ni borro ningun repo sin aprobacion posterior.

## Stop Condition General

No ejecutar migracion ni instalacion si:

- hay repo dirty sin clasificar;
- falta remoto GitHub confirmado;
- el repo tiene worktrees activos no registrados;
- hay secreto en `.env`, `.env.local`, `remoteEnv` o configuracion versionable;
- una accion live Microsoft/Dataverse/SharePoint/Power Platform/OpenAI queda implicita;
- se requiere variable `Machine`.

## Self-review

- Este plan empieza por perfiles/variables, no por repos.
- Este plan usa fuentes oficiales actuales y patrones locales existentes.
- Este plan personaliza el aislamiento para `C:\CEO`, no para una estructura generica.
- Este plan no mueve repos ni instala dependencias todavia.
