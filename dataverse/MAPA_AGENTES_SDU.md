# Mapa De Agentes SDU

Roster SDU confirmado para `HUBDesarrollo` bajo `SDUCapabilityControlPlane`.

## Fuente

- Readback: `C:\Users\enzo1\.codex\worktrees\pr155-ci-fix-cabina-universal-d\.agents\codex\readbacks\2026-06-08_sdu_agents_dataverse_registry_readback.md`
- Mapa de capacidad: `C:\Users\enzo1\.codex\matrices\sdu\SDU_ENVIRONMENT_CAPABILITY_MAP.csv`
- Solucion: `SDUCapabilityControlPlane`
- Tabla: `mon_sdu_agent_connection_mapping`

## Roster Activo

| Agente | Canonical ID | Estado |
| --- | --- | --- |
| `seshat-normativa` | `sdu.agent.seshat_normativa.runtime_actions` | `POSTCHECKED` |
| `thot-tecnico` | `sdu.agent.thot_tecnico.runtime_actions` | `POSTCHECKED` |
| `anubis-gate` | `sdu.agent.anubis_gate.runtime_actions` | `POSTCHECKED` |
| `maat-cumplimiento` | `sdu.agent.maat_cumplimiento.runtime_actions` | `POSTCHECKED` |
| `horus-riesgo` | `sdu.agent.horus_riesgo.runtime_actions` | `POSTCHECKED` |
| `narrador-normativo` | `sdu.agent.narrador_normativo.runtime_actions` | `POSTCHECKED` |

## Lectura Operativa

- Los seis agentes estan registrados y postcheckeados.
- El modelo es orientado a colas y no depende de Power Automate para el roster base.
- Las superficies de cola del entorno siguen siendo las 8 `SDU.*` ya inventariadas.
- `cre3c-reconciliar-shell` queda como fila extra local, no como parte del roster activo.

## Queue Facing

- `IngestSharePointEvent`
- `ProcessOneQueueItem`
- `ProcessNextQueueItem`

## Criterio

Si aparece un nuevo agente SDU, primero debe existir evidencia de registro en la capa Dataverse y luego el mapa corto debe actualizarse con su canonical id y estado.
