# WORKBENCH_SYNC_POLICY_PATCH_20260626

## 1. Identidad

- `generated_at_local`: `2026-06-26T08:39:54.3434879-03:00`
- `generated_at_utc`: `2026-06-26T11:39:54.0388423Z`
- `agente`: `validation_agent + contracts_agent + diagnostic_agent + narrador-normativo`
- `orden`: `OWNER_GATE_APPLY_WORKBENCH_SYNC_POLICY_PATCH_NO_MERGE`
- `root`: `C:\CEO\project-cdx`
- `rama_viva`: `codex/live-state-g10-governed-20260626`
- `HEAD_vivo`: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- `modo`: `LOCAL_CONTROLLED_MUTATION_NO_MERGE_NO_PR_NO_LIVE`

## 2. Evidencia previa versionada

- Policy review versionado y publicado en `codex/version-snapshot-decision-20260626`.
- Commit de policy review: `d71757b4fe3611fe8201434eec190905325b7038`.
- La rama viva quedo limpia antes de aplicar este patch.

## 3. Archivos tocados

- `tools/validate_proj_cdx_sync.ps1`
- `tools/validate_proj_cdx_workbench.ps1`
- `operativa/repairs/20260626/WORKBENCH_SYNC_POLICY_PATCH_20260626.md`
- `operativa/repairs/20260626/WORKBENCH_SYNC_POLICY_PATCH_20260626.json`

No se tocaron:

- `VERSION_STATE.json`
- `README.md`
- `MAPA_MAESTRO.md`
- documentos masivos
- links de contenido
- `main`
- G11
- live
- Microsoft Graph, SharePoint, Dataverse, Power Platform o secretos

## 4. Politica aplicada

### Sync

- Se agrego `RuntimePath` con default `outputs`.
- Se dejo de dereferenciar el literal `<RUNTIME_PATH>`.
- Los requeridos runtime se resuelven contra `$ResolvedRuntimePath`.
- Los links repo-local relativos quedan aceptados como preferidos.
- Los links absolutos internos bajo el alias fisico `C:/Users/enzo1/PROJEC%20CDX` quedan aceptados si son equivalentes.
- No se normalizaron links en documentos.

Politica efectiva:

```text
MIXED_POLICY_INTERNAL_ABSOLUTE_ALLOWED
```

### Workbench

- Se agrego `RuntimePath` con default `outputs`.
- Se dejo de exigir el literal `<RUNTIME_PATH>`.
- Los docs operativos historicos ausentes quedan como `OBSERVED`, no `FAIL`.
- Los links legacy locales bajo `Documents/Codex`, `Documents/CodexLocal` y `Documents/README.md` quedan como `OBSERVED`, no `FAIL`.
- Se excluyeron caches/venv/generados transitorios del escaneo recursivo.
- No se crearon README/MAPA masivos.

Politica efectiva:

```text
ALLOWLIST_GENERATED_AND_EVIDENCE_DIRS
```

## 5. Diff resumido

```text
tools/validate_proj_cdx_sync.ps1      | 39 ++++++++++++++++++++----------
tools/validate_proj_cdx_workbench.ps1 | 45 ++++++++++++++++++++++++++++++++---
2 files changed, 68 insertions(+), 16 deletions(-)
```

Advertencia no bloqueante:

```text
LF will be replaced by CRLF the next time Git touches the validator files.
```

## 6. Validadores antes / despues

| Validador | Antes | Despues | Clasificacion |
| --- | --- | --- | --- |
| `tools/validate_proj_cdx_sync.ps1 -Root C:\CEO\project-cdx -Json` | `ERROR/FAIL` por `<RUNTIME_PATH>` literal y politica de links absolutos | `PASS` con 49 checks PASS | `PASS` |
| `tools/validate_proj_cdx_workbench.ps1 -Root C:\CEO\project-cdx -Json` | `FAIL` por requeridos hardcoded, `<RUNTIME_PATH>` literal y links legacy rotos | `OBSERVED`; 1103 PASS, 68 OBSERVED, 0 FAIL | `OBSERVED` |
| `tools/validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -ResolverPy C:\CEO\project-cdx\tools\sdu_chain_resolver.py -Json` | `PASS` | `PASS`; 41 checks PASS | `PASS` |
| `tools/sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json` | `PASS` | `PASS`; 39 checks PASS | `PASS` |
| `tools/validate_sdu_dataverse_metadata_wave.ps1 -Root C:\CEO\project-cdx` | `PASS` | `PASS`; `STATUS: PASS`; 65 filas | `PASS` |
| `git diff --check` | `PASS` | `PASS`; solo warning LF/CRLF | `PASS` |

## 7. Decision final

```text
SNAPSHOT_RETRY_ALLOWED_WITH_POLICY_REVIEW
```

Motivo:

- No quedan `FAIL` hard en `sync`.
- `workbench` queda sin `FAIL` real; conserva observaciones gobernadas de deuda documental/legacy.
- La cadena operacional, boot local, Dataverse metadata wave y diff-check pasan.
- El retry debe ser owner-only y no implica PR, merge, live, G11 ni normalizacion documental.

## 8. Rollback

- Revertir solamente:
  - `tools/validate_proj_cdx_sync.ps1`
  - `tools/validate_proj_cdx_workbench.ps1`
- Eliminar solamente esta evidencia si el owner descarta el patch antes de versionarlo.
- No borrar carpetas.
- No tocar docs canonicos ni links de contenido.

## 9. Stop condition

```text
no PR / no merge / no live / no G11 apply / no snapshot retry without owner-only decision
```

## 10. Proximo carril

```text
SNAPSHOT_VERSION_DECISION_RETRY_OWNER_ONLY
```

## 11. Contrato de cierre

| Campo | Valor |
| --- | --- |
| `agente` | `validation_agent + contracts_agent + diagnostic_agent + narrador-normativo` |
| `orden` | `OWNER_GATE_APPLY_WORKBENCH_SYNC_POLICY_PATCH_NO_MERGE` |
| `superficie` | `C:\CEO\project-cdx` |
| `skill` | `no-inference-runtime-write-guard`, `repo-agent-tool-governance`, `cabina-commit-work` |
| `receta` | `temp-index publication + validator policy patch + no-merge evidence` |
| `tool` | `apply_patch`, `git commit-tree`, `git update-ref`, `git push explicit ref`, validadores locales |
| `estado` | `POLICY_PATCH_READY_FOR_VERSIONING` |
| `evidencia` | `operativa/repairs/20260626/WORKBENCH_SYNC_POLICY_PATCH_20260626.md`, `operativa/repairs/20260626/WORKBENCH_SYNC_POLICY_PATCH_20260626.json` |
| `validador` | `sync PASS; workbench OBSERVED no FAIL; operational_chain PASS; sdu_boot PASS; metadata_wave PASS; diff-check PASS` |
| `riesgo_principal` | `tratar OBSERVED como aprobacion de documentacion faltante sin owner gate` |
| `rollback` | `revertir solo los dos validadores y eliminar evidencia de repair si no se versiona` |
| `stop_condition` | `no mutation outside explicit owner gate` |
| `proximos_carriles` | `SNAPSHOT_VERSION_DECISION_RETRY_OWNER_ONLY` |
