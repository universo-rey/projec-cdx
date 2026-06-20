# Dataverse Family Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unificar la familia Dataverse bajo un solo camino visible de cobertura, sin duplicar autoridad entre `README.md`, `MAPA.md`, `GATE.md` y `PLAN_SEGUNDA_PASADA.md`.

**Architecture:** `docs/superpowers/plans` sigue siendo el registro visible. `dataverse/README.md`, `dataverse/MAPA.md`, `dataverse/GATE.md` e `INDICE_DATAVERSE.md` pasan a ser la ruta de entrada visible; `PLAN_SEGUNDA_PASADA.md` queda como detalle de soporte y evidencia. Este plan no autoriza writes live y no cambia la política read-only del carril.

**Tech Stack:** Markdown, readbacks, gates, índices visibles y superficies Dataverse metadata-only.

---

### Task 1: Declarar el camino visible de Dataverse

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\GATE.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\INDICE_DATAVERSE.md`

- [ ] **Step 1: Releer la familia Dataverse actual**

  Confirmar qué archivos ya sirven como puerta visible y cuáles solo son soporte.

- [ ] **Step 2: Fijar un único plan de familia**

  Dejar visible este plan como el punto rector y bajar `PLAN_SEGUNDA_PASADA.md` a soporte.

- [ ] **Step 3: Quitar el hueco semántico**

  Reemplazar toda frase que diga que falta cobertura de familia por la referencia canónica al plan nuevo.

### Task 2: Absorber la segunda pasada como soporte

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\dataverse\PLAN_SEGUNDA_PASADA.md`

- [ ] **Step 1: Marcarlo como detalle de apoyo**

  Explicar que el plan de segunda pasada ya no es la puerta visible sino el soporte técnico de la familia.

- [ ] **Step 2: Mantener el contenido útil**

  Conservar la segmentación DV1..DV5 y su criterio de cierre, sin duplicar autoridad.

### Task 3: Enlazar la familia desde el rector

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\2026-06-19-plan-rector-cobertura-total.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_COBERTURA_PLANES_20260619.md`

- [ ] **Step 1: Registrar la familia en la matriz visible**

  Añadir la fila de Dataverse con owner, stop condition y siguiente revisión.

- [ ] **Step 2: Actualizar el readback**

  Cerrar el hueco con una frase breve que diga que Dataverse ya tiene un solo camino visible.

### Task 4: Verificar que no queden dos dueños

**Files:**
- Review: `C:\Users\enzo1\PROJEC CDX\dataverse\README.md`
- Review: `C:\Users\enzo1\PROJEC CDX\dataverse\MAPA.md`
- Review: `C:\Users\enzo1\PROJEC CDX\dataverse\GATE.md`

- [ ] **Step 1: Confirmar lectura única**

  Un agente nuevo debe poder entrar por una sola puerta y terminar en el mismo plan de familia.

- [ ] **Step 2: Confirmar stop condition estable**

  La familia Dataverse queda cerrada cuando no hay doble autoridad ni superficie huérfana.

## Validation

- La familia Dataverse aparece una sola vez en la matriz visible.
- `PLAN_SEGUNDA_PASADA.md` queda como soporte, no como puerta paralela.
- El readback y el índice de planes cuentan la misma historia.

## Assumptions

- Este plan es una promoción visible de cobertura, no una apertura de live writes.
- `metadata-only` sigue siendo el carril permitido para la familia Dataverse.
