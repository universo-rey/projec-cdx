---
artifact_id: operativa/tasks/20260623/READBACK_IDE_CONTROL_INDEX_G1_STEP1_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: CABINA_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_STEP1_IDE_INDEX
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_IDE_CONTROL_INDEX_G1_STEP1_20260623.md
etiquetas:
  - vscode-insiders
  - ide-control-plane
  - step1
  - index
  - local-only
relacionados:
  - operativa/tasks/20260623/IDE_CONTROL_INDEX_G1_STEP1_20260623.json
  - operativa/tasks/20260623/READBACK_CEO_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_20260623.md
  - operativa/tasks/20260623/IDE_SKILL_RECIPE_PROMOTION_PACK_G1_INDEX_20260623.json
descripcion: Readback del primer indice operativo de control sobre Visual Studio Code Insiders.
---

# CABINA_IDE_CONTROL_PLANE_VSCODE_INSIDERS_G1_STEP1_IDE_INDEX - READBACK

## 1. Dictamen ejecutivo

`IDE_CONTROL_INDEX_READY`

VS Code Insiders queda con primer indice operativo de control, basado en comandos reales y no en plan narrativo.

## 2. Control aumentado

Workspace:
- Estado: `IDE_WORKSPACE_CONTROL_READY`.
- Raiz rectora: `C:\CEO\project-cdx`.
- Alias fisico: `C:\Users\enzo1\PROJEC CDX`.
- Politica: `TARGET_ONLY_NOT_WORKSPACE`.
- Repos anidados: observados, no absorbidos.

Terminal:
- Estado: `IDE_TERMINAL_GOVERNED_READY`.
- Perfil default: `CEO PowerShell`.
- CWD: `C:\CEO\project-cdx`.
- Python: `.venv\Scripts\python.exe`.
- `node`: `NOT_FOUND_IN_GOVERNED_TERMINAL_PATH`, registrado como gap local no bloqueante para STEP1.

Comandos:
- Estado: `IDE_COMMAND_SURFACE_READY`.
- Comandos CEO detectados: 28.
- Critico no accesible: `remote-ready`.

Tasks:
- Estado: `IDE_TASKS_PRODUCTIVE_READY`.
- Tasks productivas: 31.
- Rotas: 0.
- Candidato pendiente: `remote-ready`.

Extensiones:
- Estado: `IDE_EXTENSION_CONTROL_READY`.
- Extensiones observadas: 137.
- Allow: 44.
- Support: 27.
- Hold: 53.
- Review: 13.
- Duplicados: 8.
- Desinstalaciones automaticas: 0.

Evidencia:
- Estado: `IDE_EVIDENCE_CAPTURE_READY`.
- Categorias faltantes: 0.
- Tasks sin evidencia minima: 0.
- Estandar minimo: timestamp, workspace, comando/task, salida, estado, agente responsable y proximo paso.

Telemetry:
- Estado: `IDE_TELEMETRY_STATUS_READY`.
- Runtime: `OPERACION_CONTINUA_GOBERNADA`.
- Baseline: `v0.6.0-rc1`.
- Sentinel: `WARN_EXPECTED_DIRTY`.
- Metadata: `PASS`.
- Snapshot: `PASS`.

## 3. Comandos candidatos

- `tools\ceo-vscode-insiders-status.ps1 -Json`
- `tools\ceo-ide-workspace-status.ps1 -Json`
- `tools\ceo-ide-terminal-status.ps1 -Json`
- `tools\ceo-ide-command-index.ps1 -Json`
- `tools\ceo-ide-tasks-status.ps1 -Json`
- `tools\ceo-ide-extension-policy.ps1 -Json`
- `tools\ceo-ide-evidence-status.ps1 -Json`
- `tools\ceo-ide-telemetry-status.ps1 -Json`

## 4. Tasks candidatas

- `CEO IDE: Workspace Control`
- `CEO IDE: Terminal Status`
- `CEO Command: Index`
- `CEO IDE: Tasks Status`
- `CEO IDE: Extension Policy`
- `CEO IDE: Evidence Status`
- `CEO IDE: Telemetry Status`
- `CEO IDE: Control Plane G1`

## 5. Skills promovibles

El paquete promovible vive en:

- `operativa\tasks\20260623\IDE_SKILL_RECIPE_PROMOTION_PACK_G1_INDEX_20260623.json`

## 6. Recetas promovibles

- `recipe-open-cabina-in-governed-ide`
- `recipe-repair-ide-terminal-runtime`
- `recipe-build-ide-command-surface`
- `recipe-promote-script-to-vscode-task`
- `recipe-classify-vscode-insiders-extensions`
- `recipe-map-agent-tools-in-ide`
- `recipe-capture-ide-operation-evidence`
- `recipe-ide-remote-readiness-without-push`
- `recipe-ide-drift-detection`
- `recipe-promote-ide-pattern-to-capability`

## 7. Cambios realizados

- Creado indice operativo STEP1 en JSON.
- Creado metadata del indice.
- Creado readback breve.
- No se crearon comandos nuevos.
- No se crearon tasks nuevas.
- No se tocaron extensiones.

## 8. Cambios no realizados

- No se creo `ceo-remote-ready`.
- No se agrego `node` al PATH gobernado.
- No se ejecuto MCP.
- No se actualizo `SKILLS_UNIFIED_TABLE.csv`.
- No se materializaron carpetas `SKILL.md`.

## 9. Riesgos bloqueados

- Doble workspace: bloqueado por `OPEN_CANONICAL_ENTRY_ONLY`.
- Repos anidados: `OBSERVE_ONLY_NO_ABSORB`.
- MCP execution: bloqueado.
- Remote publication: bloqueada por gate.
- Secret read: bloqueado.

## 10. Proxima accion ejecutable

`STEP2_IDE_TASKS_AND_COMMANDS`

Orden recomendada:

```text
Materializar solo comandos/tasks faltantes que ya tengan script real o gate explicito.
Primero resolver si `ceo-remote-ready` se crea como comando local read-only o queda diferido.
No ejecutar push, PR, live ni MCP.
```

## Frontera

- No borrar.
- No push.
- No PR.
- No live.
- No secretos.
- No MCP execution.
- No absorber repos anidados.
