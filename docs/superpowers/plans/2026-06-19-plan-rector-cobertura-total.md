# Plan Rector de Cobertura Total de la Cabina Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dejar un plan rector y una matriz de cobertura para que toda superficie activa tenga su plan, su dueño, su stop condition y su punto de lectura canónico sin mezclar gobierno, workspace real y legado.

**Architecture:** Este plan no reemplaza los planes de dominio ya existentes; los ordena. `docs/superpowers/plans` funciona como registro visible, `MAPA_MAESTRO.md` como navegación humana, y cada plan de dominio cubre una sola superficie o familia de superficies. La tarea es cerrar huecos de cobertura, fijar una sola narrativa de autoridad y hacer que cada entrada visible apunte al plan correcto.

**Tech Stack:** Markdown, índices de planes, rutas Windows, workbook `.xlsx`, inventarios `.csv`, agentes declarativos, mapas de superficie.

---

## Cobertura ya existente

- `2026-06-13-codex-dotcodex-surface-split.md` cubre el split `.codex` vs `PROJEC CDX`.
- `2026-06-16-wave-atomica-repositorios.md` cubre repositorios y wave de repos.
- `2026-06-16-wave-atomica-documentos-conocimiento.md` cubre documentos y conocimiento.
- `2026-06-16-wave-atomica-documentos-pc-root-codex-mantenimiento.md` cubre mantenimiento del PC raíz y Codex local.
- `2026-06-19-normalizacion-cabina-local.md` cubre la normalización de `C:\CEO`, `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX`.
- `2026-06-19-dataverse-familia-cobertura.md` cubre la familia Dataverse como un solo camino visible.

## Hueco que corrige este plan

- Hoy hay planes de dominio, pero falta un plan rector que explique cómo se conectan entre sí.
- Falta una matriz visible de cobertura: qué plan cubre qué superficie, quién lo mantiene y cuál es su stop condition.
- Falta alinear los entry points visibles para que el agente no tenga que adivinar dónde empieza cada frente.

## Agentes y roles

- **Seshat:** redacta el registro visible y las actas de cobertura.
- **Thot:** normaliza nombres, títulos y rutas canónicas.
- **Anubis:** marca límites, legado y superficies que no deben reabrirse.
- **Maat:** valida cobertura, coherencia y stop conditions.
- **Horus:** arma la vista de navegación y las flechas entre planos.

---

### Task 1: Construir la matriz de cobertura visible

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md`

- [ ] **Step 1: Inventariar los planes existentes**

  Releer los planes ya presentes y sacar una línea por plan con: superficie, objetivo, owner lógico y stop condition.

- [ ] **Step 2: Escribir la matriz de cobertura**

  Agregar una tabla visible con columnas `Plan`, `Superficie`, `Estado`, `Owner`, `Stop condition` y `Siguiente revisión`.

- [ ] **Step 3: Señalar huecos reales**

  Marcar lo que todavía no tiene plan propio y lo que vive solo como referencia histórica.

- [ ] **Step 4: Verificar la navegación**

  Confirmar que un agente pueda entrar por `docs/superpowers/plans/README.md`, llegar al plan de dominio correcto y volver al mapa maestro sin perder contexto.

### Task 2: Alinear los entry points de la cabina con la matriz

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\AGENTS.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\README_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\workbooks\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\launch-desk\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\recipes\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\playbooks\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\tools\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\packages\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\src\README.md`

- [ ] **Step 1: Reescribir cada entrada visible para apuntar al plan correcto**

  Cada README corto debe decir desde dónde entra, qué plan lo gobierna y cuándo bajar a referencia.

- [ ] **Step 2: Eliminar dobles autoridades**

  Ningún README visible debe presentar `C:\CEO`, `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX` como si fueran la misma capa.

- [ ] **Step 3: Bajar el detalle a referencia**

  Si un entry point crece demasiado, mover el detalle a su `reference.md` o a la página de mapa correspondiente.

- [ ] **Step 4: Validar que el punto de entrada siempre llegue a un plan**

  No debe existir una superficie visible sin plan asociado o sin etiqueta explícita de `legacy`.

### Task 3: Cubrir cada familia de trabajo con un plan propio

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-13-codex-dotcodex-surface-split.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-16-wave-atomica-repositorios.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-16-wave-atomica-documentos-conocimiento.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-16-wave-atomica-documentos-pc-root-codex-mantenimiento.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-19-normalizacion-cabina-local.md`

- [ ] **Step 1: Unificar formato de plan**

  Cada plan de dominio debe arrancar con el mismo encabezado, el mismo tipo de objetivos y una lista clara de archivos.

- [ ] **Step 2: Agregar owner y stop condition**

  Cada plan debe decir qué agente lo mantiene y en qué condición se corta sin seguir improvisando.

- [ ] **Step 3: Quitar referencias duplicadas**

  Si dos planes repiten la misma superficie, uno debe quedar como dominio principal y el otro como contexto o legado.

- [ ] **Step 4: Marcar estado de cobertura**

  Cada plan debe indicar si está listo, en revisión o supersedido por un plan más nuevo.

### Task 4: Dejar la capa de agentes lista para ejecutar planes

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\chains\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\agents\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\skills\README.md`
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_COBERTURA_PLANES_20260619.md`

- [ ] **Step 1: Definir el reparto de roles**

  Dejar explícito qué hace Seshat, Thot, Anubis, Maat y Horus cuando el plan se ejecuta por subagentes.

- [ ] **Step 2: Alinear cadenas y habilidades**

  Hacer que las cadenas y skills apunten al mismo esquema de cobertura que usa el plan rector.

- [ ] **Step 3: Preparar el readback estándar**

  Crear un readback corto para que cada agente informe: cobertura, huecos, riesgos y siguiente delta.

- [ ] **Step 4: Confirmar que no se mezclan ejecución y gobierno**

  El registro de planes no debe convertirse en ejecución accidental; el plan gobierna, los agentes ejecutan después.

### Task 5: Cerrar con verificación de cobertura total

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`

- [ ] **Step 1: Verificar que cada superficie visible tenga plan**

  Revisar que cada entrada principal del workspace apunte a un plan o a una nota explícita de legado.

- [ ] **Step 2: Confirmar que los planes no se pisan**

  Si dos planes reclaman la misma superficie, resolver el conflicto y dejar un solo dueño.

- [ ] **Step 3: Registrar el cierre de cobertura**

  Escribir el estado final en `CURRENT.md` y el siguiente delta en `NEXT.md`.

- [ ] **Step 4: Cerrar la wave solo cuando la matriz quede completa**

  No cerrar hasta que no queden huecos de cobertura ni entradas huérfanas.

## Self-review

- La planimetría cubre las superficies principales del workspace y la cabina.
- Los planes existentes se respetan, no se pisan.
- Cada tarea apunta a archivos exactos y a una sola responsabilidad.
- No hay placeholders ni pasos vacíos.
