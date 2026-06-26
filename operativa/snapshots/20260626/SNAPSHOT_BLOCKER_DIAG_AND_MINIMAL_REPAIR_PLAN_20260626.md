# SNAPSHOT_BLOCKER_DIAG_AND_MINIMAL_REPAIR_PLAN_20260626

## 1. Estado

- `generated_at_local`: `2026-06-26T08:14:17.9977659-03:00`
- `generated_at_utc`: `2026-06-26T11:14:18.3090960Z`
- `root`: `C:\CEO\project-cdx`
- `live_branch`: `codex/live-state-g10-governed-20260626`
- `live_head`: `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`
- `snapshot_decision_branch`: `codex/version-snapshot-decision-20260626`
- `snapshot_decision_commit`: `adca9f36797e14752dfec21c22228a9d469a566b`
- `snapshot_decision_remote_verified`: `true`
- `mode`: `READ_ONLY_DIAG_PLUS_REPAIR_PLAN_ONLY`

## 2. Publicacion De Decision

HECHO_VERIFICADO:

- La decision `SNAPSHOT_BLOCKED` fue versionada en una rama aislada.
- Rama publicada: `codex/version-snapshot-decision-20260626`.
- Remote head verificado: `adca9f36797e14752dfec21c22228a9d469a566b`.
- La rama viva no cambio de branch ni de HEAD.
- No hubo PR, merge, tag ni live write.

## 3. Separacion De Bloqueantes

| Bloqueante | Clasificacion | Evidencia | Implicancia |
| --- | --- | --- | --- |
| `VERSION_STATE_LIVE_MISMATCH` | `FAIL_REAL_LIVE_STATE` | `VERSION_STATE.json` vivo declara `codex/runtime-versioning-snapshots`, commit `c856fa9b`, `PENDING_STAGE`; la rama freeze contiene `VERSION_STATE.json` reconciliado contra `codex/live-state-g10-governed-20260626` y `e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`. | Bloqueo real para snapshot institucional si se exige que la rama viva cargue el estado reconciliado. |
| `VALIDATOR_OPERATIONAL_CHAIN_EXACT_ORDER_FAIL` | `FAIL_POR_INVOCACION` | La invocacion anterior uso `-Root C:\CEO\project-cdx\tools\sdu_chain_resolver.py`; el script espera repo root. Re-ejecutado con `-Root C:\CEO\project-cdx` dio `PASS`. | No requiere reparar el sistema; requiere corregir la orden/invocacion o agregar guardrail de parametro. |
| `VALIDATOR_SYNC_FAIL` | `FAIL_POR_IMPLEMENTACION_VALIDATOR` | `tools/validate_proj_cdx_sync.ps1` contiene rutas literales `<RUNTIME_PATH>\README.md` y luego hace `Get-Content` sobre esa ruta. `C:\CEO\project-cdx\<RUNTIME_PATH>\README.md` no existe; `outputs\README.md` si existe. | Falla del validador por placeholder no resuelto. |
| `VALIDATOR_WORKBENCH_FAIL` | `FAIL_REAL_DE_POLITICA_O_DRIFT_VALIDATOR` | El validador exige archivos ausentes en la rama viva como `operativa\START_HERE.md`, `operativa\BLOCKERS.md`, `operativa\MANIFESTS.md`, `operativa\RETENCION.md`, `operativa\ACTA_REPOS_SURFACE_GITHUB_20260615.md` y tambien usa `<RUNTIME_PATH>`. | Requiere decidir si la politica actual exige esos docs o si el validador quedo viejo frente al canon actual. |
| `sdu_boot` | `PASS` | `tools\sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json` devolvio `PASS`. | Cadena local viva es verificable sin external/live. |
| `metadata_wave` | `PASS` | `tools\validate_sdu_dataverse_metadata_wave.ps1 -Root C:\CEO\project-cdx` devolvio `STATUS: PASS`. | No bloquea snapshot. |
| `git diff --check` | `PASS` | Sin salida de error. | No bloquea snapshot. |

## 4. Diagnostico

La decision `SNAPSHOT_BLOCKED` queda sostenida, pero el bloqueo se achica:

- Bloqueo real principal: `VERSION_STATE_LIVE_MISMATCH`.
- Bloqueo real o de politica: `VALIDATOR_WORKBENCH_FAIL`.
- Bloqueo por validador: `VALIDATOR_SYNC_FAIL`.
- Bloqueo por invocacion: `VALIDATOR_OPERATIONAL_CHAIN_EXACT_ORDER_FAIL`.

Conclusion: no hace falta una reparacion masiva. El sistema necesita una reparacion minima y separada por carril:

1. sincronizar o aceptar formalmente `VERSION_STATE` reconciliado;
2. corregir la invocacion operational-chain;
3. resolver placeholder `<RUNTIME_PATH>` en validadores;
4. revisar politica del workbench antes de crear documentos nuevos.

## 5. Reparacion Minima Preparada

No aplicar en esta corrida.

### 5.1 VERSION_STATE

Reparacion candidata:

- Traer al carril owner-gated el `VERSION_STATE.json` reconciliado que ya existe en `codex/version-freeze-state-20260626`.
- Preservar evidencia `operativa/evidence/version_state/VERSION_STATE_RECON_20260626_070601.json`.
- No hacer merge directo de la rama freeze; usar aplicacion selectiva o commit-tree en rama de reparacion.
- Postcheck esperado: `VERSION_STATE.branch == codex/live-state-g10-governed-20260626`, `VERSION_STATE.commit == e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11`, `integrity == RECONCILED_OWNER_APPLIED`, worktree limpio.

### 5.2 Operational Chain

Reparacion candidata:

- Cambiar la orden de validacion a:

```powershell
tools/validate_proj_cdx_operational_chain.ps1 -Root C:\CEO\project-cdx -Json
```

- Opcional minimo en script: si `-Root` apunta a archivo, devolver error explicito `ROOT_MUST_BE_REPO_DIRECTORY` antes de invocar el resolver.

### 5.3 Sync Validator

Reparacion candidata:

- Parametrizar `tools/validate_proj_cdx_sync.ps1` con `RuntimePath`, default `outputs`.
- Resolver todo literal `<RUNTIME_PATH>` antes de `Test-Path` o `Get-Content`.
- No crear carpeta literal `<RUNTIME_PATH>`.
- Postcheck esperado: ya no falla en `C:\CEO\project-cdx\<RUNTIME_PATH>\README.md`.

### 5.4 Workbench Validator

Reparacion candidata:

- Separar requisitos `REQUIRED_CURRENT` de `LEGACY_EXPECTED`.
- Mover `operativa\START_HERE.md`, `operativa\BLOCKERS.md`, `operativa\MANIFESTS.md`, `operativa\RETENCION.md`, `operativa\ACTA_REPOS_SURFACE_GITHUB_20260615.md` a `OBSERVED` si el canon actual los reemplazo por `operativa\README.md`, `CONTROL.md`, `CURRENT.md`, `NEXT.md`, `TRACE.md`.
- Resolver `<RUNTIME_PATH>` igual que en sync.
- No crear duplicados documentales hasta que owner confirme que esos docs son canon vigente.

## 6. Orden Minimo Siguiente

Carril recomendado:

```text
OWNER_GATE_MINIMAL_SNAPSHOT_BLOCKER_REPAIR_NO_MERGE
```

Alcance minimo del carril:

1. patch selectivo de `VERSION_STATE.json` y evidencia si owner decide que debe vivir en la rama snapshot/live;
2. patch de `tools/validate_proj_cdx_sync.ps1` para resolver `<RUNTIME_PATH>`;
3. patch de `tools/validate_proj_cdx_operational_chain.ps1` para guardrail de `-Root` archivo o solo correccion de orden;
4. decision explicita sobre `validate_proj_cdx_workbench.ps1`: actualizar politica o mantener bloqueo real.

## 7. Stop Conditions

- No PR.
- No merge.
- No live.
- No G11 apply.
- No crear documentos canonicos duplicados para satisfacer un validador viejo.
- No tocar secretos ni `.env`.
- No reemplazar la decision `SNAPSHOT_BLOCKED` hasta que los validadores o la politica owner lo justifiquen.

