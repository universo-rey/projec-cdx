# Atomic Power Project Local Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Conectar `ATOMIC POWER PROJECT CDX` en ChatGPT con la version local de Codex Desktop/CEO sin configuraciones estaticas, cerrando el pendiente de variables, perfiles de terminal, source pack y validacion viva.

**Architecture:** ChatGPT Project funciona como cerebro vivo con bootloader, project sources, memoria de proyecto y respuestas guardadas. La version local funciona como runtime operativo: `C:\CEO` gobierna, `C:\CEO\project-cdx` abre la cabina y `C:\Users\enzo1\PROJEC CDX` conserva el workspace fisico real. Este plan no reemplaza `2026-06-19-normalizacion-cabina-local.md`; lo usa como frontera local y agrega el puente entre ChatGPT Project, Codex Desktop, terminal y source pack.

**Tech Stack:** Markdown, PowerShell 7, Windows Terminal, Codex Desktop, ChatGPT Project, project sources, readbacks, source packs, AGENTS, skills, chains.

---

## Alcance

Este plan cubre:

- Investigacion local de Codex Desktop, perfiles, variables y ruta de arranque.
- Reconciliacion del pendiente anterior de variables de entorno y perfiles de terminal.
- Preparacion del source pack para `ATOMIC POWER PROJECT CDX`.
- Configuracion gobernada de ChatGPT Project como bootloader vivo.
- Validacion cruzada entre ChatGPT Project y runtime local.

Este plan no cubre:

- Writes en Dataverse, SharePoint, Power Platform o Git remoto.
- Borrado destructivo.
- Cambios en variables de maquina.
- Activacion de MCP/write actions sin gate especifico.

## Agentes y carriles

| Agente | Carril | Salida esperada |
| --- | --- | --- |
| Seshat | Redaccion y acta | Prompt final, readback y source pack compacto. |
| Thot | Taxonomia y rutas | Tabla local/cloud con una autoridad por capa. |
| Anubis | Fronteras y seguridad | Semaforo, stop conditions y rollback. |
| Maat | Validacion | Postcheck local y coherencia del plan. |
| Horus | Mapa y navegacion | Camino de lectura desde entrada local hasta project sources. |
| Atomic | Compresion | Atomo de cierre para agentes futuros. |

---

### Task 1: Rehidratar el estado actual antes de tocar configuracion

**Files:**
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\INVESTIGACION_CONFIG_CHATGPT_PROJECT_ATOMIC_POWER_20260619.md`
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\PROMPT_CHATGPT_PROJECT_ATOMIC_POWER_PROJEC_CDX_V2_BOOTLOADER_20260619.md`
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_CEO_ENV_TERMINAL_20260619.md`
- Review: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-19-normalizacion-cabina-local.md`
- Review: `C:\Users\enzo1\PROJEC CDX\recipes\normalizacion-perfil-windows.md`
- Review: `C:\Users\enzo1\PROJEC CDX\patrones\normalizacion-perfil-windows.md`
- Review: `C:\Users\enzo1\PROJEC CDX\procesos\normalizacion-perfil-windows.md`

- [ ] **Step 1: Leer las fuentes vigentes**

  Abrir los archivos listados y marcar cuatro cosas: `hecho`, `pendiente`, `riesgo`, `siguiente delta`.

- [ ] **Step 2: Separar lo resuelto de lo abierto**

  Mantener como cerrado el readback `READBACK_CEO_ENV_TERMINAL_20260619.md` salvo que falle un postcheck nuevo.

- [ ] **Step 3: Declarar la frontera de este plan**

  Registrar que la frontera local la define `2026-06-19-normalizacion-cabina-local.md`; este plan solo agrega el puente ChatGPT Project/local runtime.

- [ ] **Step 4: Stop condition**

  Parar si aparece una contradiccion real entre `C:\CEO`, `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX` que no este resuelta en el plan de normalizacion local.

### Task 2: Investigar la version local sin inferir rutas

**Files:**
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_ATOMIC_POWER_LOCAL_RUNTIME_20260619.md`
- Review: `C:\CEO\Start-CEO.ps1`
- Review: `C:\CEO\CodexProfile.ps1`
- Review: `C:\CEO\windows-terminal\settings.json`
- Review: `C:\Users\enzo1\.codex\README.md`
- Review: `C:\Users\enzo1\.codex\MAPA_MAESTRO.md`
- Review: `C:\Users\enzo1\.codex\AGENTS_CORTO.md`
- Review: `C:\Users\enzo1\.codex\AGENTS.reference.md`

- [ ] **Step 1: Levantar variables activas**

  Ejecutar:

  ```powershell
  'CEO_ROOT','CEO_PROJECT_CDX_ROOT','CEO_REPOS_ROOT','CEO_WORKTREES_ROOT','CEO_AGENTS_ROOT','CEO_SKILLS_ROOT','CEO_CHAINS_ROOT','CEO_M365_ROOT','CEO_DATAVERSE_ROOT','CEO_RUNTIME_ROOT','CODEX_START_ROOT','CODEX_WORKBENCH_ROOT','CODEX_PROJECT_ROOT','CODEX_SOURCE_TREE_PATH','CODEX_WORKTREE_PATH','CODEX_METADATA_ROOT','CODEX_CABINA_ROOT','SOURCE_TREE_PATH' |
    ForEach-Object {
      [pscustomobject]@{ Name = $_; Value = [Environment]::GetEnvironmentVariable($_, 'User') }
    } | Format-Table -AutoSize
  ```

  Expected: las rutas CEO usan `C:\...`, no `C:/...`, y ninguna variable apunta a `C:\` como superficie operativa amplia.

- [ ] **Step 2: Validar arranque de terminal**

  Ejecutar:

  ```powershell
  if (Test-Path -LiteralPath 'C:\CEO\Start-CEO.ps1') { 'START_CEO_PRESENT=True' } else { 'START_CEO_PRESENT=False' }
  if (Test-Path -LiteralPath 'C:\CEO\windows-terminal\settings.json') { 'TERMINAL_SETTINGS_PRESENT=True' } else { 'TERMINAL_SETTINGS_PRESENT=False' }
  ```

  Expected: ambas senales en `True`.

- [ ] **Step 3: Validar cadena de lectura local**

  Confirmar que la lectura visible sea:

  ```text
  C:\Users\enzo1\.codex\README.md
  -> C:\Users\enzo1\.codex\MAPA_MAESTRO.md
  -> C:\Users\enzo1\PROJEC CDX\README.md
  -> C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md
  -> plan o readback especifico
  ```

- [ ] **Step 4: Guardar readback local**

  Escribir `READBACK_ATOMIC_POWER_LOCAL_RUNTIME_20260619.md` con esta forma:

  ```markdown
  # READBACK_ATOMIC_POWER_LOCAL_RUNTIME_20260619

  ## Estado
  OBSERVED

  ## Local Runtime
  - CEO hub:
  - Entrada canonica:
  - Workspace fisico:
  - Terminal:
  - Codex Desktop:

  ## Deltas
  - 

  ## Stop Condition
  - No cambiar variables, perfiles ni rutas si el postcheck no muestra drift real.
  ```

### Task 3: Resolver el pendiente anterior de variables y perfiles

**Files:**
- Modify only if drift is found: `C:\CEO\Start-CEO.ps1`
- Modify only if drift is found: `C:\CEO\CodexProfile.ps1`
- Modify only if drift is found: `C:\CEO\windows-terminal\settings.json`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_ATOMIC_POWER_LOCAL_RUNTIME_20260619.md`

- [ ] **Step 1: Comparar contra el readback cerrado**

  Usar `READBACK_CEO_ENV_TERMINAL_20260619.md` como baseline. No reabrir si coincide.

- [ ] **Step 2: Aplicar criterio de normalizacion de perfil**

  Si hay drift, seguir la receta `normalizacion-perfil-windows.md`: resolver rutas reales, confirmar origen/destino, preservar compatibilidad, postcheck antes de cerrar.

- [ ] **Step 3: Mantener User scope**

  No escribir variables en scope `Machine`. El scope permitido es `User`.

- [ ] **Step 4: Postcheck**

  Ejecutar:

  ```powershell
  $expected = @{
    CEO_ROOT = 'C:\CEO'
    CEO_PROJECT_CDX_ROOT = 'C:\CEO\project-cdx'
    CODEX_START_ROOT = 'C:\CEO'
    CODEX_WORKBENCH_ROOT = 'C:\CEO\project-cdx'
    CODEX_PROJECT_ROOT = 'C:\CEO\project-cdx'
    CODEX_SOURCE_TREE_PATH = 'C:\CEO\repos'
    CODEX_WORKTREE_PATH = 'C:\CEO\worktrees'
  }
  $expected.GetEnumerator() | ForEach-Object {
    $actual = [Environment]::GetEnvironmentVariable($_.Key, 'User')
    [pscustomobject]@{ Name = $_.Key; Expected = $_.Value; Actual = $actual; Pass = ($actual -eq $_.Value) }
  } | Format-Table -AutoSize
  ```

  Expected: todos `Pass=True`.

### Task 4: Preparar el source pack local para ChatGPT Project

**Files:**
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619.md`
- Review: `C:\Users\enzo1\PROJEC CDX\README.md`
- Review: `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md`
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Review: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`
- Review: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Review: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`
- Review: `C:\Users\enzo1\PROJEC CDX\dataverse\README.md`
- Review: `C:\Users\enzo1\PROJEC CDX\dataverse\MAPA.md`
- Review: `C:\Users\enzo1\PROJEC CDX\dataverse\GATE.md`
- Review: `C:\Users\enzo1\PROJEC CDX\agents\README.md`
- Review: `C:\Users\enzo1\PROJEC CDX\skills\README.md`
- Review: `C:\Users\enzo1\PROJEC CDX\chains\README.md`

- [ ] **Step 1: Verificar existencia de fuentes**

  Ejecutar:

  ```powershell
  $sources = @(
    'C:\Users\enzo1\PROJEC CDX\README.md',
    'C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md',
    'C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md',
    'C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md',
    'C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md',
    'C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md',
    'C:\Users\enzo1\PROJEC CDX\dataverse\README.md',
    'C:\Users\enzo1\PROJEC CDX\dataverse\MAPA.md',
    'C:\Users\enzo1\PROJEC CDX\dataverse\GATE.md',
    'C:\Users\enzo1\PROJEC CDX\agents\README.md',
    'C:\Users\enzo1\PROJEC CDX\skills\README.md',
    'C:\Users\enzo1\PROJEC CDX\chains\README.md'
  )
  $sources | ForEach-Object { [pscustomobject]@{ Path = $_; Exists = (Test-Path -LiteralPath $_) } } | Format-Table -AutoSize
  ```

  Expected: todos `Exists=True`.

- [ ] **Step 2: Construir source pack compacto**

  Escribir `SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619.md` con secciones:

  ```markdown
  # SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619

  ## Estado
  SOURCE_PACK_BORRADOR

  ## Como leer
  Este archivo compacta fuentes locales para ChatGPT Project. Si una fuente local cambia, regenerar este pack.

  ## Frontera local
  - Hub:
  - Entrada canonica:
  - Workspace fisico:

  ## Camino de lectura
  - 

  ## Estado vivo
  - 

  ## Planes rectores
  - 

  ## Dataverse
  - 

  ## Agentes Skills Chains
  - 

  ## Stop condition
  - 
  ```

- [ ] **Step 3: No copiar todo el repo**

  Compactar decisiones y rutas. No pegar archivos completos si un resumen con puntero alcanza.

- [ ] **Step 4: Marcar vigencia**

  Incluir fecha `2026-06-19` y decir que cualquier cambio posterior requiere nuevo source pack o respuesta guardada en el proyecto.

### Task 5: Configurar ChatGPT Project como cerebro vivo

**Files:**
- Use as input: `C:\Users\enzo1\PROJEC CDX\operativa\PROMPT_CHATGPT_PROJECT_ATOMIC_POWER_PROJEC_CDX_V2_BOOTLOADER_20260619.md`
- Use as source: `C:\Users\enzo1\PROJEC CDX\operativa\SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619.md`
- Update after manual config: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_ATOMIC_POWER_CHATGPT_PROJECT_CONFIG_20260619.md`

- [ ] **Step 1: Crear o abrir proyecto**

  Proyecto: `ATOMIC POWER PROJECT CDX`.

- [ ] **Step 2: Memoria**

  Si el proyecto se crea desde cero y aparece la opcion, elegir `Project-only memory`.

- [ ] **Step 3: Instrucciones**

  Pegar el bloque principal de `PROMPT_CHATGPT_PROJECT_ATOMIC_POWER_PROJEC_CDX_V2_BOOTLOADER_20260619.md` en `Project settings`.

- [ ] **Step 4: Fuentes**

  Subir `SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619.md` como project source. Si el proyecto permite varios archivos sin ruido, subir tambien el prompt v2 y la investigacion.

- [ ] **Step 5: No activar writes**

  No conectar apps con permisos write. Si se conectan apps, dejarlas read-only cuando el workspace lo permita.

### Task 6: Validar que no quedo estatico

**Files:**
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_ATOMIC_POWER_CHATGPT_PROJECT_CONFIG_20260619.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`

- [ ] **Step 1: Smoke prompt en ChatGPT Project**

  En el proyecto, enviar:

  ```text
  Rehidratate desde las fuentes del proyecto. Decime estado, superficie, delta siguiente y stop condition. No uses memoria externa.
  ```

  Expected: responde citando o usando el source pack, no solo el texto del prompt.

- [ ] **Step 2: Smoke prompt local**

  En Codex Desktop/local, confirmar que el camino de lectura sigue `AGENTS -> README -> MAPA_MAESTRO -> plan/readback`.

- [ ] **Step 3: Guardar respuesta util**

  Si ChatGPT Project devuelve una sintesis correcta, guardarla como project source.

- [ ] **Step 4: Cierre**

  Escribir `READBACK_ATOMIC_POWER_CHATGPT_PROJECT_CONFIG_20260619.md` con:

  ```markdown
  # READBACK_ATOMIC_POWER_CHATGPT_PROJECT_CONFIG_20260619

  ## Estado
  OBSERVED

  ## Configuracion
  - Project:
  - Instructions:
  - Sources:
  - Memory:
  - Apps/MCP:

  ## Validacion
  - 

  ## Deltas
  - 

  ## Stop Condition
  - No activar writes ni conectores externos sin gate exacto.
  ```

### Task 7: Publicar el cierre en estado vivo

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`

- [ ] **Step 1: CURRENT**

  Registrar que `ATOMIC POWER PROJECT CDX` queda como proyecto ChatGPT vivo conectado a source pack local, si Task 6 pasa.

- [ ] **Step 2: NEXT**

  Dejar un solo delta siguiente: regenerar source pack cuando cambie canon local o activar conectores read-only con gate.

- [ ] **Step 3: Indice de planes**

  Agregar este plan a la matriz visible solo si se ejecuta y queda vigente.

- [ ] **Step 4: Stop condition final**

  No cerrar si ChatGPT Project responde solo desde el prompt y no demuestra rehidratacion desde fuentes.

## Validation

- Una terminal nueva inicia en `C:\CEO`.
- Las variables `CEO_*` y `CODEX_*` no apuntan a `C:\` como superficie amplia.
- El proyecto ChatGPT usa bootloader v2 y source pack.
- La respuesta de smoke referencia estado/fuentes, no una personalidad estatica.
- `CURRENT.md` y `NEXT.md` reflejan el mismo estado que los readbacks.
- No hay apps/MCP con writes activados sin aprobacion explicita.

## Stop Condition General

Detener la ejecucion si aparece cualquiera de estos casos:

- Rutas locales ambiguas entre `C:\CEO`, `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX`.
- Variables de maquina requeridas para completar el cambio.
- Conectores o MCP con permisos write antes de gate.
- Source pack incompleto o con archivos inexistentes.
- ChatGPT Project no permite memoria de proyecto ni carga de fuentes suficiente; en ese caso usar prompt ultra corto y subir el source pack minimo.

## Self-review

- El plan no reemplaza la normalizacion local; la referencia.
- El plan separa ChatGPT Project, Codex Desktop, terminal y workspace fisico.
- El plan resuelve el pendiente anterior solo por postcheck, no por intuicion.
- El plan contiene comandos exactos y expected outputs.
- No incluye writes sensibles ni acciones externas sin gate.
