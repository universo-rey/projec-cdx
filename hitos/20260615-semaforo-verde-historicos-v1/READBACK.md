# READBACK_SEMAFORO_VERDE_HISTORICOS_20260615

## Estado

HECHO_VERIFICADO: amarillos historicos reclasificados como verde gobernado.

## Sistemas Tocados

- `PROJEC CDX/operativa`.
- `PROJEC CDX/hitos`.
- `PROJEC CDX/outputs/live_repo_review_20260615`.
- `PROJEC CDX/workbooks/control_operativo.xlsx`.
- `PROJEC CDX/README.md`.
- `PROJEC CDX/MAPA_MAESTRO.md`.
- GitHub remote read-only.

## Sistemas No Tocados

- Repos Git.
- GitHub write: push, merge, comentarios, labels y branch delete.
- Microsoft/OpenAI live.
- Dataverse live.
- Secretos, `auth.json`, `cap_sid`, global-state y SQLite.

## Cambios

- Historicos 2026-06-14 pasan a `GREEN_ARCHIVED`.
- Control total pasa a `GREEN_OPERABLE`.
- Wave revision total pasa a `GREEN_LOCAL`.
- CodexLocal base pasa a `GREEN_REFERENCE_CLOSED`.
- GitHub live read-only revisa 13 repos canonicos y confirma `live_status=OK`.
- Indices visibles actualizados.

## Validacion

- `validate_proj_cdx_operational_chain.ps1`: `PASS`, 43 filas, sin `INDEX_ONLY`.
- `validate_proj_cdx_workbench.ps1`: `PASS`.
- `validate_proj_cdx_sync.ps1`: `PASS`.
- `control_operativo.xlsx`: regenerado con `DELTA-009` y `ALR-007`.
- GitHub live read-only: 13 repos `OK`, 4 PRs abiertos observados, 0 writes.

## Riesgos

- Los guardrails siguen vigentes; no autorizan live, Git write ni limpieza fisica.

## Rollback

Restaurar estados anteriores en acta, indices y manifiestos.

## Proximos Carriles

- Clasificar hijos de `Auditar`.
- Cierre de procesos PC solo por Id exacto o reinicio controlado.
