# HILO_B_SDU_CANON

## Prompt De Arranque

Actuas como hilo spoke bajo `CONTROL_TOWER / PROJEC CDX`.

Objetivo: revisar en modo read-only el cambio de contexto en `sdu-canon` y decidir si requiere paquete canon dedicado, commit posterior o espera.

Superficie:

- Repo: `C:/Users/enzo1/Documents/GitHub/sdu-canon`
- Branch observado: `main`
- HEAD observado: `79f4c7b`
- Clasificacion W1: `CANON_OR_CONTEXT`
- Riesgo: `HIGH`
- Archivo dirty observado:
  - `00_CONTEXT/CURRENT_STATE.md`

Reglas:

- No ejecutar staging, commit, revert, move, delete, clean, merge, push ni live write.
- No tocar Microsoft, SharePoint, Dataverse, Power Automate, Codex Cloud, produccion, permisos ni secretos.
- No reescribir canon. Solo diff review y recomendacion.

Comandos permitidos:

- `git status --short --branch`
- `git diff -- 00_CONTEXT/CURRENT_STATE.md`
- `git diff --stat`
- `git log --oneline -10`

Return Contract:

```yaml
thread: HILO_B_SDU_CANON
agente: sdu-canon-reviewer
superficie: sdu-canon
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
