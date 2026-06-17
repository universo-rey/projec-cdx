# HILO_E_CDF_SOLUCIONES

## Prompt De Arranque

Actuas como hilo spoke bajo `CONTROL_TOWER / PROJEC CDX`.

Objetivo: revisar en modo read-only `cdf-soluciones`, separando cambios de contexto de paquetes de evidencia/operacion antes de cualquier commit.

Superficie:

- Repo: `C:/Users/enzo1/Documents/GitHub/cdf-soluciones`
- Branch observado: `main`
- HEAD observado: `211a2de`
- Clasificacion W1: `CANON_OR_CONTEXT_PLUS_EVIDENCE`
- Riesgo: `HIGH`
- Dirty observado:
  - `00_CONTEXT/CURRENT_STATE.md`
  - `00_CONTEXT/START_HERE.md`
  - `README.md`
  - `03_OPERACION/SESHAT_HOME_BINDING_DELEGATION/`
  - `03_OPERACION/SESHAT_RESTO_CORTE_DELEGATION/`
  - `08_EVIDENCIA/2026-06-16_CDF_SESHAT_HOME_BINDING_DELEGATION/`
  - `08_EVIDENCIA/2026-06-16_CDF_SESHAT_RESTO_CORTE_DELEGATION/`

Reglas:

- No ejecutar staging, commit, revert, move, delete, clean, merge, push ni live write.
- No tocar CDF fuera de los paths listados.
- No publicar ni ejecutar delegaciones.
- No tocar Microsoft, SharePoint, Dataverse, Power Automate, Codex Cloud, produccion, permisos ni secretos.

Comandos permitidos:

- `git status --short --branch`
- `git diff -- 00_CONTEXT/CURRENT_STATE.md`
- `git diff -- 00_CONTEXT/START_HERE.md`
- `git diff -- README.md`
- `git diff --stat`
- `Get-ChildItem -Recurse -File` sobre `03_OPERACION/...` y `08_EVIDENCIA/...`, solo nombres y tamanos.

Return Contract:

```yaml
thread: HILO_E_CDF_SOLUCIONES
agente: cdf-soluciones-reviewer
superficie: cdf-soluciones
branch:
head:
files_read:
commands_run:
mutations_executed: false
live_writes_executed: false
classification:
risk:
context_package:
evidence_package:
recommendation:
evidence:
validator:
rollback:
stop_condition:
next_delta:
```

Stop condition: `context_evidence_overlap`.
