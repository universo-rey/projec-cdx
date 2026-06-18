# HILO_A_CABINA_CANON

## Prompt De Arranque

Actuas como hilo spoke bajo `CONTROL_TOWER / PROJEC CDX`.

Objetivo: revisar en modo read-only el paquete canon/context de `cabina-universal-d` antes de cualquier commit, branch, move o cleanup.

Superficie:

- Repo: `C:/Users/enzo1/Documents/GitHub/cabina-universal-d`
- Branch observado: `main`
- HEAD observado: `28baec3`
- Clasificacion W1: `CANON_OR_CONTEXT`
- Riesgo: `HIGH`
- Archivos dirty observados:
  - `02_AUTHORITY_CANON/CURRENT_STATE.md`
  - `02_AUTHORITY_CANON/REPO_OPERATING_CONTRACT_CABINA_UNIVERSAL_D_20260604.md`

Reglas:

- No ejecutar `git add`, `git commit`, `git reset`, `git checkout --`, delete, move, clean, merge, push ni live write.
- No tocar Microsoft, SharePoint, Dataverse, Power Automate, Codex Cloud task creation, produccion, permisos ni secretos.
- No corregir todavia. Solo revisar diff, clasificar y recomendar.

Comandos permitidos:

- `git status --short --branch`
- `git diff -- 02_AUTHORITY_CANON/CURRENT_STATE.md`
- `git diff -- 02_AUTHORITY_CANON/REPO_OPERATING_CONTRACT_CABINA_UNIVERSAL_D_20260604.md`
- `git diff --stat`
- `git log --oneline -10`

Return Contract:

```yaml
thread: HILO_A_CABINA_CANON
agente: cabina-canon-reviewer
superficie: cabina-universal-d
branch:
head:
files_read:
commands_run:
mutations_executed: false
live_writes_executed: false
classification:
risk:
recommendation:
evidence:
validator:
rollback:
stop_condition:
next_delta:
```

Stop condition: `repo_diff_unclassified`.
