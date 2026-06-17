# Thread Architecture 5 Plus 1 20260617

Estado: `THREAD_PACKETS_PREPARED_NOT_CREATED`
Owner humano: `Enzo Figueroa`
Control tower: `PROJEC CDX`
Control tower branch: `codex/dataverse-corte-ejecutora-v1`
Control tower HEAD: `41cbb42`
Modo Corte: `CORTE_EJECUTORA_GOVERNED`

## Principio

El trabajo deja de ser lineal, pero no deja de ser gobernado.

El control tower coordina, versiona y decide.
Los hilos spoke inspeccionan frentes acotados y devuelven evidencia.
Ningun spoke hace live write, staging, commit, revert, move, delete o cleanup sin volver al control tower.

## Frentes

| Thread | Estado | Riesgo | Scope | Siguiente salida |
| --- | --- | --- | --- | --- |
| `HILO_A_CABINA_CANON` | `ACTIVE_READY_NOT_CREATED` | HIGH | `cabina-universal-d` | diff review canon/context |
| `HILO_B_SDU_CANON` | `ACTIVE_READY_NOT_CREATED` | HIGH | `sdu-canon` | diff review SDU context |
| `HILO_C_RUNTIME_README_BATCH` | `ACTIVE_READY_NOT_CREATED` | LOW | 8 README-only repos | batch readback |
| `HILO_D_SESHAT_SGIN_EVIDENCE` | `ACTIVE_READY_NOT_CREATED` | MEDIUM | `seshat-bootstrap-sdu-cn`, `Sgin`, `sgin-cumplimiento` | evidence package review |
| `HILO_E_CDF_SOLUCIONES` | `ACTIVE_READY_NOT_CREATED` | HIGH | `cdf-soluciones` | split context/evidence plan |
| `HILO_F_CLOUD_DATAVERSE_READY` | `PREFLIGHT_WAITING_NOT_CREATED` | CONTROL | Codex Cloud, tenant, Dataverse | preflight after repo fan-in |

## Fan-In Contract

Every thread returns:

```yaml
thread:
agente:
superficie:
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

## Creation Gate

This architecture prepares thread packets only.

Actual Codex thread creation remains pending until the owner gives a separate opening order.

## Thread Tool Readiness

The current Codex app exposes thread tools (`create_thread`, `fork_thread`, `send_message_to_thread`, `read_thread`, `handoff_thread`, `set_thread_title`).

Use those only after explicit order to open or route hilos.
