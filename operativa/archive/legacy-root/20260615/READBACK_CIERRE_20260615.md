# READBACK_PROJEC_CDX_20260615

## Estado

HECHO_VERIFICADO: `PROJEC CDX` queda como workbench operativo local, navegable, versionado y validable por delta.

## Sistemas Tocados

- `C:/Users/enzo1/PROJEC CDX/operativa`
- `C:/Users/enzo1/PROJEC CDX/playbooks`
- `C:/Users/enzo1/PROJEC CDX/tools`
- `C:/Users/enzo1/PROJEC CDX/workbooks`
- `C:/Users/enzo1/PROJEC CDX/outputs`
- `C:/Users/enzo1/PROJEC CDX/hitos`
- `C:/Users/enzo1/PROJEC CDX/README.md`
- `C:/Users/enzo1/PROJEC CDX/MAPA_MAESTRO.md`

## Sistemas No Tocados

- Secretos.
- `auth.json`.
- `cap_sid`.
- Global-state.
- SQLite.
- Dataverse live.
- Power Platform live.
- Power Automate live.
- Microsoft live.
- Git remoto.

## Cambios

- Entrada de continuidad: `operativa/archive/legacy-root/undated/START_HERE.md`.
- Prompt reutilizable: `operativa/archive/legacy-root/undated/PROMPT_NUEVO_HILO.md`.
- Playbooks completos: `playbooks/00-preflight-gobernado.md` a `playbooks/06-dataverse-gobernado.md`.
- Validador local: `tools/validate_proj_cdx_workbench.ps1`.
- Workbook de control real: `workbooks/control_operativo.xlsx`.
- Corrida generada: `outputs/control_operativo_20260615`.
- Manifest de corrida: `outputs/control_operativo_20260615/MANIFEST.json`.
- Hito versionado: `hitos/20260615-cierre-workbench-v1`.
- Politicas: `operativa/archive/legacy-root/undated/MANIFESTS.md`, `operativa/archive/legacy-root/undated/RETENCION.md`, `outputs/RETENCION.md`.
- Segundo orden versionado: `hitos/20260615-dataverse-conexiones-drift-v1`, `hitos/20260615-corte-ejecutora-vs-sdu-v1`.

## Registros Completados

- `operativa/CURRENT.md` actualizado con los ultimos deltas cerrados.
- `operativa/NEXT.md` reescrito para dejar la mesa sin delta activo.
- `operativa/archive/legacy-root/undated/MANIFESTS.md` reforzado con la regla de segundo orden.
- `operativa/archive/legacy-root/undated/RETENCION.md` reforzado con los hitos nuevos al frente.

## Validacion

Comando esperado:

```powershell
pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_proj_cdx_workbench.ps1"
```

Resultado esperado: `PASS`.

Control total rapido:

- Resultado: `GREEN_OPERABLE`.
- Evidencia: `operativa/archive/legacy-root/20260615/CONTROL_TOTAL_20260615.md`.
- Lectura: 0 rojos; guardrails gobernados por no limpiar `.codex` a ciegas y no tocar repos en `main`.

## Riesgos

- `PROJEC CDX` no es repo git; el versionado local depende de `hitos/`, manifests e indices.
- `outputs/` contiene evidencia historica; no compactar sin orden explicita.
- Dataverse esta documentado como carril local/metadata-only; no asumir estado live.

## Rollback

- Revertir los archivos del delta local.
- Usar `hitos/20260615-cierre-workbench-v1` como readback del ultimo cierre bueno.
- Regenerar `workbooks/control_operativo.xlsx` con `tools/build_control_workbook.mjs` si el workbook queda desalineado.

## Proximos Carriles

- Carril A: abrir nuevo delta desde `operativa/NEXT.md`.
- Carril B: si aparece live Dataverse, exigir `dataverse/GATE.md`.
- Carril C: si aparece limpieza o compactacion, exigir orden explicita y `operativa/archive/legacy-root/undated/RETENCION.md`.

## Output Contract

- agente: `Codex local`
- orden: `continuar desde cierre verde local`
- superficie: `PROJEC CDX`
- skill: `codex-surface-map`, `tcu-redactor-planes-operativos`, `governed-readback-closeout`
- receta: `preflight -> delta -> validar -> hito -> readback`
- tool: `tools/validate_proj_cdx_workbench.ps1`
- estado: `HECHO_VERIFICADO`
- evidencia: `hitos/20260615-cierre-workbench-v1`, `outputs/control_operativo_20260615/MANIFEST.json`
- validador: `validate_proj_cdx_workbench.ps1`
- riesgo: `sin repo git; live surfaces no tocadas`
- rollback: `revertir archivos locales o restaurar desde hito`
- stop_condition: `secret_or_runtime_state_requested`, `live_surface_without_order`, `rollback_missing`, `postcheck_missing`
- proximos_carriles: `NEXT`, `Dataverse Gate`, `Retencion`
