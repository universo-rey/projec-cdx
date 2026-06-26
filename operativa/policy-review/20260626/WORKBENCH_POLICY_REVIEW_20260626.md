# WORKBENCH_POLICY_REVIEW_20260626

## 1. Identidad

- fecha local: `2026-06-26T08:29:22.0645348-03:00`
- fecha UTC: `2026-06-26T11:29:22.2689086Z`
- agente: `contracts_agent + validation_agent + diagnostic_agent + narrador-normativo`
- orden: `WORKBENCH_POLICY_REVIEW_OWNER_GATE`
- root solicitado: `C:\CEO\project-cdx`
- root resuelto: `C:/Users/enzo1/PROJEC CDX`
- rama viva: `codex/live-state-g10-governed-20260626`
- HEAD vivo: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- modo: `review_only`
- superficie: `repo-local-policy-review`

## 2. Decision marco

- `REVIEW_ONLY`
- `NO_REPAIR`
- `NO_PR`
- `NO_MERGE`
- `NO_LIVE`
- `NO_DOC_DUPLICATION`
- `OWNER_GATE_REQUIRED_FOR_POLICY_PATCH`

## 3. Estado base

- rama viva: `codex/live-state-g10-governed-20260626`
- HEAD vivo: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- worktree limpio antes de evidencia: `true`
- index limpio antes de evidencia: `true`
- reparacion minima publicada: `true_by_input_and_local_ref`
- snapshot retry blocked: `true`

Nota: la rama viva no contiene la reparacion minima aplicada. La evidencia publicada en `codex/version-snapshot-blocker-repair-20260626` muestra el estado post-reparacion, pero este gate no hizo checkout, fetch ni push.

## 4. Resultado de validadores

| validador | comando usado | estado | resumen | clasificacion |
| --- | --- | --- | --- | --- |
| `validate_proj_cdx_workbench` | `tools/validate_proj_cdx_workbench.ps1 -Root C:\CEO\project-cdx -Json` | `FAIL` | En sandbox corto por acceso a `.pytest_cache`; en ejecucion read-only elevada produjo JSON y fallo por requeridos hardcoded, `<RUNTIME_PATH>` literal y links legacy rotos. | `REVIEW_REQUIRED` |
| `validate_proj_cdx_sync` | `tools/validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json` | `ERROR` | La rama viva falla por `Get-Content` contra `<RUNTIME_PATH>\README.md`. En la rama de reparacion ese placeholder queda resuelto y persisten 3 expectativas de links absolutos. | `IMPLEMENTATION_ARTIFACT` |
| `validate_proj_cdx_operational_chain` | `tools/validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -ResolverPy C:\CEO\project-cdx\tools\sdu_chain_resolver.py -Json` | `PASS` | 41 checks PASS; no external; dry-run; `.env.local` no leido. | `PASS` |
| `sdu_boot` | `tools/sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json` | `PASS` | Cadena local PASS; 6 perfiles; 128 skills; 17 recipes. | `PASS` |
| `validate_sdu_dataverse_metadata_wave` | `tools/validate_sdu_dataverse_metadata_wave.ps1 -Root C:\CEO\project-cdx` | `PASS` | `STATUS: PASS`; 65 filas; metadata-only preparada. | `PASS` |
| `git diff --check` | `git diff --check` | `PASS` | Sin errores. | `PASS` |
| `repo-agent-tool-governance matrices` | `Get-Content .agents\codex\matrices\*.csv` | `NOT_FOUND` | Las matrices requeridas por el skill no existen en esta rama bajo `.agents\codex\matrices` ni `.agents\codex\maps`. | `NOT_FOUND` |

## 5. Analisis sync

Regla detectada:

- En `tools/validate_proj_cdx_sync.ps1`, la lista `$linkChecks` exige coincidencias literales de links absolutos como `C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx` en `README.md` y `MAPA_MAESTRO.md`.
- La rama viva todavia dereferencia `Get-Content` sobre `<RUNTIME_PATH>\README.md`; la rama de reparacion publicada cambia eso por `RuntimePath = outputs`.
- Post-reparacion, el fallo residual no es de existencia de archivos sino de politica de string esperado.

Ejemplos observados:

- `README.md` usa links relativos vivos: `workbooks/control_operativo.xlsx` y `workbooks/tracker.xlsx`.
- `MAPA_MAESTRO.md` usa links relativos vivos: `workbooks/control_operativo.xlsx`, `workbooks/tracker.xlsx`, `outputs/tracker_general_20260613/README.md` y `outputs/tracker_workbook_20260613/README.md`.
- `workbooks/EXCEL_AL_FRENTE.md` conserva links absolutos internos a `C:/Users/enzo1/PROJEC%20CDX/...`.

Clasificacion:

```text
MIXED_POLICY_REQUIRED
```

Politica recomendada:

```text
B. MIXED_POLICY_INTERNAL_ABSOLUTE_ALLOWED
```

Decision:

- Repo-local relativo debe ser preferido para `README.md`, `MAPA_MAESTRO.md` y artefactos versionados.
- Absolutos internos bajo `C:\CEO\project-cdx` o alias fisico `C:\Users\enzo1\PROJEC CDX` pueden ser aceptables si apuntan a artefactos controlados y existentes.
- Absolutos externos, live, tenant, SharePoint, Graph, Dataverse o Power Platform deben quedar bloqueados o en review.
- El validador no debe exigir un unico string absoluto cuando existe un link relativo equivalente y el archivo existe.

## 6. Analisis workbench

Regla detectada:

- `$requiredFiles` exige archivos operativos hardcoded: `operativa\START_HERE.md`, `operativa\BLOCKERS.md`, `operativa\MANIFESTS.md`, `operativa\RETENCION.md`, `operativa\ACTA_REPOS_SURFACE_GITHUB_20260615.md` y `<RUNTIME_PATH>\dataverse_blocker_frontier_20260614\README.md`.
- `$visibleDirs` marca carpetas visibles sin README/MAPA como `OBSERVED`, no como `FAIL`.
- `$linkPattern` revisa links absolutos `C:/Users/enzo1/...` en todos los markdown y falla si el destino no existe.
- `$dataverseRequiredFiles` repite el requerimiento literal `<RUNTIME_PATH>\dataverse_blocker_frontier_20260614\README.md`.

Rutas afectadas:

- Faltantes hardcoded: `operativa\START_HERE.md`, `operativa\BLOCKERS.md`, `operativa\MANIFESTS.md`, `operativa\RETENCION.md`, `operativa\ACTA_REPOS_SURFACE_GITHUB_20260615.md`.
- Falso literal de runtime: `<RUNTIME_PATH>\dataverse_blocker_frontier_20260614\README.md`.
- Equivalente real existente: `outputs\dataverse_blocker_frontier_20260614\README.md`.
- Links legacy rotos: `dataverse\MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md` apunta a `C:/Users/enzo1/Documents/Codex/2026-06-14/projec-cdx-handoff-20260614/outputs/...`.
- Carpetas observadas sin README/MAPA incluyen caches, tooling, evidencia o superficies transitorias: `.agent`, `.agents`, `.bmad-backup`, `.cursor`, `.github`, `.pytest_cache`, `.ruff_cache`, `.venv_clean`, `.venv_test`, `08_READBACKS`, `adapters`, `contracts`, `examples`, `graphify-out`, `scripts`, `tests`, `tmp-owner-action-layer`, `web`, `work`.

Clasificacion por tipo:

- `operativa` faltante hardcoded: `policy_or_legacy_required_review`
- `<RUNTIME_PATH>` literal: `IMPLEMENTATION_ARTIFACT`
- `outputs\dataverse_blocker_frontier_20260614`: `evidence/generated`
- links a `Documents/Codex/2026-06-14`: `legacy_external_local_reference`
- carpetas cache/venv/tmp/generated: `generated_or_transient`
- carpetas repo/tooling: `tooling_or_support_surface`

Politica recomendada:

```text
B. ALLOWLIST_GENERATED_AND_EVIDENCE_DIRS
```

Decision:

- No crear README/MAPA masivos.
- No tratar carpetas generadas, cache, evidencia o transitorias como incumplimiento hard.
- Los requisitos de `operativa` deben alinearse con el canon vivo actual (`CURRENT.md`, `NEXT.md`, `TRACE.md`, `CONTROL.md`) antes de exigir docs nuevos.
- Los links historicos a paquetes `Documents/Codex/2026-06-14` deben ser `OBSERVED` o `LEGACY_EXPECTED` salvo que el owner decida repararlos.

## 7. Reparacion minima propuesta

No aplicada.

### Reparacion permitida sugerida

- Tocar solo `tools/validate_proj_cdx_sync.ps1` y `tools/validate_proj_cdx_workbench.ps1`.
- En `sync`, reemplazar checks de string literal absoluto por una funcion de politica que acepte:
  - link relativo repo-local existente;
  - link absoluto interno bajo root canonico;
  - link absoluto interno bajo alias fisico;
  - runtime path resuelto por parametro `RuntimePath`.
- En `workbench`, agregar `RuntimePath` o resolver `<RUNTIME_PATH>` a `outputs`.
- En `workbench`, allowlist/reclasificar como `OBSERVED` carpetas cache, venv, temporales, evidencia generada y superficies de soporte no canonicas.
- En `workbench`, reclasificar links historicos locales rotos como `LEGACY_EXPECTED` u `OBSERVED` si el archivo que los contiene esta en contexto legacy.
- Mantener hard fail solo para frontdoors canonicos activos, archivos runtime activos y links activos rotos.

Validadores esperados despues:

- `validate_proj_cdx_sync`: `PASS` u `OBSERVED` sin fallar por links relativos equivalentes.
- `validate_proj_cdx_workbench`: `PASS` u `OBSERVED`, salvo que el owner confirme docs operativos como requeridos.
- `validate_proj_cdx_operational_chain`: `PASS`.
- `sdu_boot -NoExternal -DryRun`: `PASS`.
- `validate_sdu_dataverse_metadata_wave`: `PASS`.
- `git diff --check`: `PASS`.

Riesgo:

- Bajar demasiado la politica podria ocultar links activos rotos.
- Mantenerla demasiado estricta bloquea snapshots por deuda historica o rutas generadas.

Rollback:

- Revertir solo los cambios de politica en los dos validadores.
- No borrar evidencia.
- No tocar documentos canonicos ni carpetas.

### Reparacion prohibida sin nuevo gate

- crear README/MAPA masivos.
- borrar carpetas.
- normalizar links masivamente.
- modificar contenido funcional.
- merge.
- PR.
- live.
- G11 apply.

## 8. Decision final

```text
POLICY_PATCH_RECOMMENDED
```

El snapshot no debe reintentarse antes del policy patch. Despues del patch y de validadores en `PASS` u `OBSERVED` gobernado, el retry puede volver a evaluarse.

## 9. Proximo carril

```text
OWNER_GATE_APPLY_WORKBENCH_SYNC_POLICY_PATCH_NO_MERGE
```

## 10. Contrato de cierre

| Campo | Valor |
| --- | --- |
| `agente` | `contracts_agent + validation_agent + diagnostic_agent + narrador-normativo` |
| `orden` | `WORKBENCH_POLICY_REVIEW_OWNER_GATE` |
| `superficie` | `C:\CEO\project-cdx` |
| `skill` | `no-inference-runtime-write-guard`, `repo-agent-tool-governance` |
| `receta` | `review-only policy diagnosis + no-repair evidence` |
| `tool` | `Get-Content`, `Test-Path`, `Select-String`, `git show`, validadores locales |
| `estado` | `WORKBENCH_POLICY_REVIEW_WRITTEN` |
| `evidencia` | `operativa/policy-review/20260626/WORKBENCH_POLICY_REVIEW_20260626.md`, `operativa/policy-review/20260626/WORKBENCH_POLICY_REVIEW_20260626.json` |
| `validador` | `operational_chain PASS; sdu_boot PASS; metadata_wave PASS; diff-check PASS; sync implementation artifact in live and review-required post-repair; workbench review-required` |
| `riesgo_principal` | `forzar snapshot retry con politica de validadores todavia en exit 1` |
| `rollback` | `eliminar solo evidencia de policy-review si el owner descarta este review` |
| `stop_condition` | `no mutation without owner gate` |
| `proximos_carriles` | `OWNER_GATE_APPLY_WORKBENCH_SYNC_POLICY_PATCH_NO_MERGE` |
