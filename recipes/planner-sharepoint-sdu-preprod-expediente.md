# Receta - Planner SharePoint SDU Preprod Expediente

## Cuando Usar

Usar cuando Planner, SharePoint y SDU deben quedar listos para produccion
bajo un modelo de expediente notarial completo, con trazabilidad cruzada y
persistencia institucional.

## Estado Base

| clave | valor |
| --- | --- |
| SYSTEM_MODE | PRE_PRODUCTION |
| READBACK_STRATEGY | HYBRID (Planner + Teams + Outlook + SharePoint) |
| plannerTask | TRUSTED |
| Teams history | TRUSTED |
| Details | PARTIAL |
| READBACK_UNTRUSTED | false |
| READBACK_PARTIAL_DETAILS | true |

## Matrices De Cuenta

| fuente | uso |
| --- | --- |
| `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\STATE_SEMANTICS_OWNER_IDENTITY_NORMALIZATION\CDF_OWNER_IDENTITY_NORMALIZATION_MATRIX.csv` | normalizacion de owner e identidad |
| `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\TENANT_DICTAMEN_READINESS\CDF_TENANT_AGENT_ROLE_ASSIGNMENT_MATRIX.csv` | asignacion de agente, rol y tenant |
| `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\TGE_CDF_STAFF_TENANT_LIVE_READONLY_PREFLIGHT_REPORT_20260527.md` | preflight live readonly y frontera de acceso |
| `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\MICROSOFT_365_CONNECTION_SURFACE_MATRIX.csv` | surface de conexion Microsoft |
| `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\PLANNER_ROLE_MATRIX.csv` | rol Planner, evidencia y restriccion |

## Cadena SDU

| paso | agente | skill | tool | salida |
| --- | --- | --- | --- | --- |
| 1 | `sdu-agent-comms` | `teams:teams-planner-task-management` | Teams planner readback + Outlook fallback + matrices CDF/TGE | inventario task-level y origen de cuenta |
| 2 | `sdu-agent-expediente` | `sdu-live-sharepoint-audit` | SharePoint site/drives/folders + surface guard | expediente_id y carpeta objetivo |
| 3 | `sdu-agent-runtime` | `sdu-snapshot-publisher` | `tools/build_planner_task_level_snapshot.ps1`, `tools/update_planner_hybrid_readback.ps1` | snapshot task-level y estado hibrido |
| 4 | `sdu-agent-governance` | `governed-readback-closeout` | validador local + readback firmado | gate preprod, bloqueo o readiness |

## Reglas

- No marcar `missing_task` si existe en snapshot previo.
- No asumir ausencia de comments.
- No avanzar si falta `expediente_id`, carpeta, responsable o consistencia
  menor que 2.
- El link de SharePoint en notas es obligatorio.
- La matriz CDF/TGE es la fuente de identidad y rol; no se inventa.
- `SharePoint` se trata como superficie gobernada, no como memoria implícita.

## Salida

- Inventario task-level normalizado.
- Mapa de expedientes con carpeta objetiva.
- Snapshot SDU preprod.
- Lista de bloqueos y duplicados.
- Preparacion para `SDU_PLANNER_ENFORCEMENT_G8`.

## Stop Condition

- `live_sharepoint_write_without_governed_order`
- `target_identity_ambiguous`
- `rollback_missing`
- `postcheck_missing`
- `missing_account_matrix_source`

