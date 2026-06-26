# Registro De Hitos

## H-001 - Entrada Gobernada

- Estado: `closed`
- Evidencia: `operativa/archive/legacy-root/undated/START_HERE.md`, `operativa/archive/legacy-root/undated/PROMPT_NUEVO_HILO.md`
- Resultado: hilos nuevos tienen orden de lectura, guardrails y preflight.

## H-002 - Playbooks Completos

- Estado: `closed`
- Evidencia: `playbooks/00-preflight-gobernado.md`, `playbooks/04-validar-delta.md`, `playbooks/05-promover-aprendizaje.md`
- Resultado: secuencia operativa completa de preflight a promocion.

## H-003 - Validador Local

- Estado: `closed`
- Evidencia: `tools/validate_proj_cdx_workbench.ps1`
- Resultado: postcheck read-only para mapas, archivos, links, workbooks y formulas.

## H-004 - Workbook Real

- Estado: `closed`
- Evidencia: `workbooks/control_operativo.xlsx`, `outputs/control_operativo_20260615/MANIFEST.json`
- Resultado: tablero con `Resumen`, `Registro`, `Alertas` y `Listas`.

## H-005 - Manifests Y Retencion

- Estado: `closed`
- Evidencia: `operativa/archive/legacy-root/undated/MANIFESTS.md`, `operativa/archive/legacy-root/undated/RETENCION.md`, `outputs/RETENCION.md`
- Resultado: salidas durables y outputs tienen regla minima de gobierno.

## H-006 - Dataverse Gobernado

- Estado: `closed_local`
- Evidencia: `dataverse/GATE.md`, `dataverse/READBACK_EXCEL_BLOCKER_FRONTIER.md`
- Resultado: Dataverse queda local/metadata-only hasta orden explicita.
