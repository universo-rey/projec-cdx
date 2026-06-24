---
artifact_id: operativa/tasks/20260623/READBACK_VSCODE_INSIDERS_PROFILE_PACKAGE_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_VSCODE_INSIDERS_PROFILE_PACKAGE_20260623.md
etiquetas:
  - vscode-insiders
  - perfiles
  - lenguaje-generativo
  - local-only
relacionados:
  - operativa/tasks/20260623/VSCODE_INSIDERS_PROFILE_IMPLEMENTATION_MATRIX_20260623.csv
  - .cabina/organizacion-total/vscode-insiders-profiles/README.md
  - .cabina/organizacion-total/vscode-insiders-profiles/docs/POLITICA_LENGUAJE_GENERATIVO_GOBERNADO.md
descripcion: Readback del paquete local para perfil piloto VS Code Insiders SDU-FEDERAL-CONTROL.
---

# READBACK VSCODE INSIDERS PROFILE PACKAGE

## Estado

`VSCODE_INSIDERS_PROFILE_PACKAGE_PREPARED_LOCAL_ONLY`

## Paquete preparado

Ruta:

```text
.cabina/organizacion-total/vscode-insiders-profiles/
```

Contenido:

- `README.md`
- `PROFILES.yaml`
- `WORKSPACES/SDU-FEDERAL-CONTROL.code-workspace`
- `SETTINGS/federal.settings.json`
- `TASKS/federal.tasks.json`
- `LAUNCHERS/open-federal.ps1`
- `docs/POLITICA_LENGUAJE_GENERATIVO_GOBERNADO.md`

## Decision

El paquete toma como piloto `SDU-FEDERAL-CONTROL`.

No reemplaza `.cabina/organizacion-total/.vscode/tasks.json`; lo usa como base viva y agrega un paquete de apertura/perfil separado.

## Frontera

- No se abrio VS Code Insiders.
- No se ejecutaron tasks.
- No se tocaron settings globales.
- No MCP.
- No live.
- No secretos.
- No push.
- No PR.
- No stage.
- No commit.

## Siguiente accion

Validar el paquete y, si el owner lo autoriza, abrir el perfil:

```powershell
.\.cabina\organizacion-total\vscode-insiders-profiles\LAUNCHERS\open-federal.ps1
```

Resultado esperado:

```text
SDU_FEDERAL_CONTROL_PROFILE_READY_FOR_LOCAL_USE
```
