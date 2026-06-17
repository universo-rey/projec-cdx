# HILO_C_RUNTIME_README_BATCH

## Prompt De Arranque

Actuas como hilo spoke bajo `CONTROL_TOWER / PROJEC CDX`.

Objetivo: revisar en modo read-only los repos `README_ONLY` de bajo riesgo y proponer si conviene cerrar como lote, micro-paquetes o dejarlos pendientes.

Repos:

- `C:/Users/enzo1/Documents/GitHub/tcu-agentic-runtime-control` branch `main` HEAD `20c19f7`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/tge-agentic-runtime-control-escribania` branch `main` HEAD `acbb4b7`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/torre-gemela-escribania` branch `main` HEAD `3c8f6e1`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/sgin-cumplimiento` branch `main` HEAD `5edec3c`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/jara-consultores` branch `main` HEAD `96733d7`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/microsoft-agents-governed-lab` branch `main` HEAD `aa4b759`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/modo-on-foundation` branch `main` HEAD `c117683`, dirty `README.md`
- `C:/Users/enzo1/Documents/GitHub/organizacion` branch `main` HEAD `fa5e5f6`, dirty `README.md`

Reglas:

- No ejecutar staging, commit, revert, move, delete, clean, merge, push ni live write.
- No aplicar cambios.
- Revisar solo README diffs.

Comandos permitidos por repo:

- `git status --short --branch`
- `git diff -- README.md`
- `git diff --stat`

Return Contract:

```yaml
thread: HILO_C_RUNTIME_README_BATCH
agente: runtime-readme-batch-reviewer
superficie: README-only batch
repos_reviewed:
commands_run:
mutations_executed: false
live_writes_executed: false
classification:
risk:
recommendation:
batch_strategy:
evidence:
validator:
rollback:
stop_condition:
next_delta:
```

Stop condition: `readme_diff_ambiguous`.
