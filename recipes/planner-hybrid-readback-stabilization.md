# Planner Hybrid Readback Stabilization

Recipe para estabilizar observabilidad de Planner cuando `plannerTask` y Teams
ya son confiables, pero `plannerTaskDetails` o raw Graph siguen parciales.

## Cuándo Usarla

Usar cuando el sistema no debe depender 100% de Graph raw para diagnosticar
comentarios, actividad o falsas desapariciones de tarjetas.

## Declaración De Estado

| capa | estado |
| --- | --- |
| plannerTask | TRUSTED |
| Teams history | TRUSTED |
| Details | PARTIAL |
| READBACK_UNTRUSTED | false |
| READBACK_PARTIAL_DETAILS | true |

## Cadena SDU

| paso | agente | skill | tool | salida |
| --- | --- | --- | --- | --- |
| 1 | sdu-agent-comms | teams-planner-task-management | list/fetch planner task | plannerTask base |
| 2 | sdu-agent-comms | teams-history-readback | search/list chat messages | comments efectivos |
| 3 | sdu-agent-expediente | outlook-notification-fallback | local snapshot builder | fallback historico |
| 4 | sdu-agent-governance | read-consistency-window | local state validator | estado estabilizado |

## Fuentes Híbridas

1. PlannerTask desde Teams connector.
2. Teams messages como fuente primaria de comentarios efectivos.
3. Outlook notifications como fallback historico.
4. CDF/TGE para matrices de cuenta, identidad y roles.

## Reglas

- No marcar task como desaparecida si existe en snapshot previo.
- No asumir ausencia de comments cuando details/raw Graph no responde.
- Usar Teams como fuente primaria de comentarios efectivos.
- Evitar actualizar estado durante una escritura local activa.
- `missing_task = false` si la task existe en snapshot previo.
- `missing_comments = false` si Teams tiene actividad asociada.
- `REAL_ANOMALY` requiere ausencia simultanea en Planner, Teams y snapshot.
- `FALSE_ANOMALY` aplica cuando existe evidencia en alguna fuente.

## Consistency Guard

| senal | puntaje |
| --- | --- |
| plannerTask present | +1 |
| Teams activity present | +1 |
| Outlook fallback present | +1 |

| umbral | estado |
| --- | --- |
| `>= 1` | task valida |
| `>= 2` | task confiable |
| `0` | task no confirmada |

## Snapshot Evolution

Cada registro task-level debe incluir:

- `consistency_score`
- `source_flags`
- `activity_detected`
- `confidence_class`
- `missing_task`
- `missing_comments`
- `anomaly_classification`

## Read Guard

El refresh híbrido usa lock/mutex propio para evitar ejecuciones solapadas:

- mutex: `Global\PROJEC_CDX_PLANNER_HYBRID_READBACK`
- lockfile: `C:\CEO\project-cdx\.cabina\execution-runtime\planner\planner-hybrid-readback.lock.json`

## Matrices De Cuenta

- `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\STATE_SEMANTICS_OWNER_IDENTITY_NORMALIZATION\CDF_OWNER_IDENTITY_NORMALIZATION_MATRIX.csv`
- `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\TENANT_DICTAMEN_READINESS\CDF_TENANT_AGENT_ROLE_ASSIGNMENT_MATRIX.csv`
- `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\TGE_CDF_STAFF_TENANT_LIVE_READONLY_PREFLIGHT_REPORT_20260527.md`
- `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\MICROSOFT_365_CONNECTION_SURFACE_MATRIX.csv`
- `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\PLANNER_ROLE_MATRIX.csv`

## Eventos

- `SDU_OBSERVABILITY_HARDENED`
- `SDU_FALSE_POSITIVE_BLOCKED`
- `SDU_TASK_CONFIRMED_REAL`
- `SDU_PLANNER_STABILIZED`
- `SDU_HYBRID_READBACK_ACTIVE`
- `SDU_FALSE_ANOMALY_RESOLVED`

## Stop Condition

- Un paso intenta escribir en Planner, Teams, Outlook, Graph, Entra o SharePoint.
- Hay un writer local activo sobre control-flow/noc-panel y no se autorizo ventana.
- No hay snapshot task-level de base para sostener la regla anti falso missing.
