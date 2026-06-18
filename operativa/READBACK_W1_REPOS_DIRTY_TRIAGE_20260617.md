# Readback W1 Repos Dirty Triage 20260617

Estado: `OBSERVED_READ_ONLY`
Fecha: `2026-06-17`
Modo: `CORTE_EJECUTORA_GOVERNED`
Owner humano: `Enzo Figueroa`
Delta: `delta_repo_dirty_worktree_triage_by_surface`

## Fuente

El owner aprobo avanzar despues de la revision de Corte del Plan Maestro Atomico.

## Proceso

Se ejecuto una pasada read-only sobre `C:/Users/enzo1/Documents/GitHub` para detectar repos Git con worktree dirty y clasificarlos por superficie.

Comandos usados por repo:

- `git status --porcelain=v1`
- `git branch --show-current`
- `git rev-parse --short HEAD`
- `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
- `git remote -v`
- `git diff --stat`

No se ejecuto staging, revert, move, delete, commit ni live write.

## Salida

- `inventarios/W1_REPOS_DIRTY_TRIAGE_20260617.csv`
- `inventarios/W1_REPOS_DIRTY_TRIAGE_20260617.json`

## Resultado

- Repos dirty actuales: `13`.
- Riesgo `HIGH`: `3`.
- Riesgo `MEDIUM`: `2`.
- Riesgo `LOW`: `8`.

## Clasificacion

| Clasificacion | Count | Lectura |
| --- | ---: | --- |
| `CANON_OR_CONTEXT` | 2 | Cambios en canon/contexto; requieren paquete dedicado. |
| `CANON_OR_CONTEXT_PLUS_EVIDENCE` | 1 | Contexto mas evidencia operativa; requiere split o paquete propio. |
| `EVIDENCE_OR_OPERATION_PACKAGE` | 2 | Evidencia/operacion nueva; requiere manifest y decision de incorporacion. |
| `README_ONLY` | 8 | Bajo riesgo; revisar diff y cerrar por lote o micro-paquetes. |

## Orden De Ataque

1. `cabina-universal-d`: `CANON_OR_CONTEXT`, riesgo `HIGH`.
2. `sdu-canon`: `CANON_OR_CONTEXT`, riesgo `HIGH`.
3. `tcu-agentic-runtime-control`: `README_ONLY`, riesgo `LOW`.
4. `tge-agentic-runtime-control-escribania`: `README_ONLY`, riesgo `LOW`.
5. `torre-gemela-escribania`: `README_ONLY`, riesgo `LOW`.
6. `seshat-bootstrap-sdu-cn`: `EVIDENCE_OR_OPERATION_PACKAGE`, riesgo `MEDIUM`.
7. `Sgin`: `EVIDENCE_OR_OPERATION_PACKAGE`, riesgo `MEDIUM`.
8. `sgin-cumplimiento`: `README_ONLY`, riesgo `LOW`.
9. `cdf-soluciones`: `CANON_OR_CONTEXT_PLUS_EVIDENCE`, riesgo `HIGH`.
10. Repos README-only de cierre: `jara-consultores`, `microsoft-agents-governed-lab`, `modo-on-foundation`, `organizacion`.

## Sistemas Tocados

- Filesystem local: lectura y escritura de inventarios en `PROJEC CDX`.
- Git local read-only dentro de repos de `Documents/GitHub`.

## Sistemas No Tocados

- Repos dirty: no se stageo, no se commiteo, no se revirtio, no se movio nada.
- Microsoft live write.
- SharePoint write.
- Dataverse live write.
- Power Automate flow run.
- Codex Cloud task creation.
- Produccion.
- Secretos.

## Postcheck

- `13` repos dirty clasificados.
- `stage_allowed=false` en todas las filas.
- `mutation_allowed=false` en todas las filas.
- Stop condition vigente: `repo_diff_unclassified`.

## Validacion

- `git diff --check`: `PASS`.
- `tools/validate_proj_cdx_workbench.ps1`: `STATUS: OBSERVED`; solo carpetas tecnicas conocidas.
- `tools/validate_proj_cdx_sync.ps1`: `STATUS: PASS`.
- `tools/validate_proj_cdx_operational_chain.ps1`: `STATUS: PASS`.

## Proximo Delta Unico

`delta_cabina_universal_d_canon_context_package`

Abrir el primer paquete sobre `cabina-universal-d` en modo read-only/diff review antes de decidir commit, branch o archivo.
