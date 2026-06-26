---
artifact_id: operativa/tasks/20260623/READBACK_VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_20260623.md
etiquetas:
  - vscode-insiders
  - perfiles
  - mesa-viva
  - local-only
relacionados:
  - operativa/tasks/20260623/VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_20260623.csv
  - .cabina/organizacion-total/.vscode/sdu-organizacion-total.code-workspace
  - .cabina/organizacion-total/.vscode/tasks.json
descripcion: Readback de preparacion de matriz para implementar VS Code Insiders como cabina por perfiles.
---

# READBACK VSCODE INSIDERS PROFILE IMPLEMENTATION MATRIX

## Estado

`VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_READY`

## Mesa viva usada

- `SESHAT`: clasificacion por universo y frontera de conocimiento.
- `THOT`: arquitectura de workspace, terminal y tasks.
- `ANUBIS`: gates, rollback, stop condition y no secretos.
- `MAAT`: evidencia, metadata y trazabilidad.
- `HORUS`: riesgo, drift y orden de implementacion.

## Matriz creada

- `operativa/tasks/20260623/VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_20260623.csv`
- `operativa/tasks/20260623/VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_20260623.csv.meta.json`

## Decision

El perfil piloto recomendado es `SDU-FEDERAL-CONTROL`.

Motivo:

- Ya existe workspace operativo en `.cabina/organizacion-total/.vscode/sdu-organizacion-total.code-workspace`.
- Ya existen tasks locales SDU.
- No requiere abrir datos sensibles SGIN.
- No requiere modificar settings globales de VS Code Insiders.

## Orden recomendado

1. `SDU-FEDERAL-CONTROL`
2. `SHARED-LAB`
3. `SGIN-ESCRIBANIA`
4. `MODO-ON`
5. `CODEX-ROOT-READONLY` solo con orden tecnica explicita.

## Frontera

- No live.
- No MCP execution.
- No secretos.
- No settings globales.
- No push.
- No PR.
- No stage.
- No commit.

## Resultado

`READY_FOR_SDU_FEDERAL_CONTROL_PROFILE_DRAFT`
