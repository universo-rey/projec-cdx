# Normalizacion de la cabina local Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Separar control plane, workspace real y superficies generadas para que la cabina local lea una sola autoridad por capa y los agentes normalicen sin mezclar `C:\CEO` con `C:\Users\enzo1\PROJEC CDX`.

**Architecture:** La normalizacion se hace por capas, no por una sola carpeta. `C:\CEO` queda como hub de gobierno, `C:\CEO\project-cdx` queda como entrada canonica, y `C:\Users\enzo1\PROJEC CDX` queda como el workspace fisico real. La limpieza debe conservar evidencia, workbook y mapas, pero eliminar ambiguedad entre alias, destino fisico y cachE/generado.
Este plan alimenta el plan rector de cobertura total y no compite con la familia Dataverse visible.

**Tech Stack:** Markdown, PowerShell, workbook `.xlsx`, inventarios `.csv`, PDF de mapa local, junctions de Windows, agentes declarativos.

---

## Error conceptual a corregir

- `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX` no son dos centros iguales.
- `C:\CEO` no es otra carpeta mas del proyecto: es la capa de gobierno.
- `tmp`, `.cache`, `.venv` y `node_modules` no deben pesar como una superficie de verdad.
- El mapa y el workbook deben mostrar una sola autoridad por capa.

## Agentes y roles

- **Seshat:** canon documental, voz, actas y frases de cierre.
- **Thot:** taxonomia, nombres, indices y rutas legibles.
- **Anubis:** fronteras, legacy, seguridad y superficies que no deben volverse canon.
- **Maat:** validacion, consistencia y stop conditions.
- **Horus:** lectura visual, flechas, mapa de capas y jerarquia.

---

### Task 1: Separar la autoridad de las superficies

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\README.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\AGENTS.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md`
- Modify: `C:\CEO\README.md`
- Modify: `C:\CEO\Start-CEO.ps1`
- Modify: `C:\CEO\CodexProfile.ps1`

- [ ] **Step 1: Leer las declaraciones de raiz actuales**

  Reabrir los archivos listados y marcar cada frase que hoy haga parecer que `C:\CEO` y `C:\Users\enzo1\PROJEC CDX` son pares equivalentes.

- [ ] **Step 2: Reescribir la frontera canonica**

  Dejar `C:\CEO` como hub de gobierno, `C:\CEO\project-cdx` como entrada canonica y `C:\Users\enzo1\PROJEC CDX` como workspace fisico real.

- [ ] **Step 3: Bajar `workbench` a legacy**

  Mantener `workbench` solo como referencia historica, sin tratarlo como superficie rectora.

- [ ] **Step 4: Verificar que no quede doble autoridad**

  Reabrir los archivos y confirmar que ninguna linea presente dos superficies como si fueran el mismo centro operativo.

### Task 2: Normalizar el mapa y las rutas de lectura

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\MAPA_CORTO.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\MAPA.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md`

- [ ] **Step 1: Repartir las capas con nombres estables**

  Reescribir el mapa para que la lectura quede en cuatro capas claras: verdad, control, generado/cache y legacy.

- [ ] **Step 2: Unificar el camino de entrada**

  Hacer que la entrada visible siempre empiece en `README.md`, siga por `MAPA_MAESTRO.md` y termine en las superficies reales.

- [ ] **Step 3: Bajar el ruido de rutas secundarias**

  Marcar `node_modules`, `tmp`, `.cache` y `.venv` como soporte, no como superficie principal.

- [ ] **Step 4: Confirmar que las flechas cuentan una sola historia**

  Validar que las flechas del mapa siempre lleven de la autoridad al soporte, y nunca al reves.

### Task 3: Rehacer el workbook como tablero de verdad unica

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\workbooks\CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`
- Modify: `C:\Users\enzo1\PROJEC CDX\workbooks\control_operativo.xlsx`
- Modify: `C:\Users\enzo1\PROJEC CDX\workbooks\tracker.xlsx`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\SKILLS_UNIFIED_TABLE.csv`
- Modify: `C:\Users\enzo1\PROJEC CDX\inventarios\CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv`

- [ ] **Step 1: Inventariar las hojas y campos vigentes**

  Revisar que hojas y tablas existen hoy, y separar lo que es decision, operacion, inventario y legacy.

- [ ] **Step 2: Definir una sola taxonomia de superficies**

  Normalizar nombres de hojas para que cada una tenga una funcion unica: `Roots`, `ControlPlane`, `WorkspaceReal`, `Generated`, `Legacy`, `AgentLanes`, `Validation`.

- [ ] **Step 3: Eliminar duplicados semanticos**

  Borrar o consolidar entradas que repitan la misma idea con distinto nombre.

- [ ] **Step 4: Rehacer el tablero para decision operable**

  Dejar el workbook listo para responder: cual es la raiz, cual es el alias, cual es el respaldo, cual es cache y cual es legacy.

### Task 4: Despachar agentes por dominio y guardar su lectura

**Files:**
- Create: `C:\CEO\agents\normalizacion\seshat.md`
- Create: `C:\CEO\agents\normalizacion\thot.md`
- Create: `C:\CEO\agents\normalizacion\anubis.md`
- Create: `C:\CEO\agents\normalizacion\maat.md`
- Create: `C:\CEO\agents\normalizacion\horus.md`
- Create: `C:\CEO\chains\normalizacion.md`
- Create: `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_NORMALIZACION_CABINA_LOCAL_20260619.md`

- [ ] **Step 1: Dar un solo objetivo a cada agente**

  Seshat redacta y compacta; Thot ordena nombres y rutas; Anubis protege limites y legacy; Maat valida coherencia; Horus arma la vista visual final.

- [ ] **Step 2: Poner stop conditions honestas**

  Cada agente debe parar cuando encuentre equivalencia falsa entre capas, duplicacion de autoridad o ruta sin propietario claro.

- [ ] **Step 3: Reunir las respuestas en un readback corto**

  Escribir un readback unico con hallazgos, pendientes y deltas aceptados.

- [ ] **Step 4: Conservar solo lo que suma evidencia**

  Lo que no ayude a decidir, se baja a referencia o se marca legacy.

### Task 5: Verificar y cerrar el delta

**Files:**
- Modify: `C:\Users\enzo1\PROJEC CDX\output\pdf\MAPA_COMPUTADORA_LOCAL_HP_20260619_clean.pdf`
- Modify: `C:\Users\enzo1\PROJEC CDX\tmp\local_map_20260619_clean\page-1.png`
- Modify: `C:\Users\enzo1\PROJEC CDX\tmp\local_map_20260619_clean\page-2.png`
- Modify: `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md`

- [ ] **Step 1: Verificar que la raiz canonica no se duplique**

  Confirmar que la lectura final distingue `C:\CEO\project-cdx` de `C:\Users\enzo1\PROJEC CDX` sin presentarlos como dos centros iguales.

- [ ] **Step 2: Reabrir el mapa y el workbook**

  Revisar que el mapa visual y el workbook digan lo mismo sobre capas, rutas y legacy.

- [ ] **Step 3: Regenerar el PDF si cambia alguna ruta**

  Si el texto o la jerarquia cambian, volver a emitir el PDF limpio para que la evidencia quede alineada.

- [ ] **Step 4: Cerrar solo cuando haya una autoridad por capa**

  No cerrar hasta que verdad, control, generado/cache y legacy queden separados y legibles.

## Self-review

- La separacion entre `C:\CEO` y `C:\Users\enzo1\PROJEC CDX` esta clara.
- Las tareas estan divididas por dominio y pueden correr con agentes distintos.
- Los archivos listados son exactos y estan en la cabina local.
- No hay placeholders ni pasos vacios.
