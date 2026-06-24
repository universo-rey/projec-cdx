# Patrones A Skills 20260615

## Objetivo

Cruzar los patrones operativos probados con las skills locales ya existentes para evitar duplicacion y detectar huecos reales.

## Regla

- Si ya existe una skill reutilizable, no crear otra.
- Si el patron vive mejor como proceso, playbook o matriz, dejarlo ahi.
- Solo proponer skill nueva cuando haya repeticion clara y no exista cobertura cercana.

## Cruce Inicial

| Patron | Cobertura actual | Decision | Nota |
| --- | --- | --- | --- |
| P-001 Delta Gobernado | `delta-gobernado`, `tcu-redactor-planes-operativos`, `parallel-order-governance`, `playbooks/00-preflight-gobernado.md` a `04-validar-delta.md` | Skill propia creada | Ya estaba cubierto y ahora queda visible como skill local. |
| P-002 Mapa Visible Corto | `codex-surface-map` | Sin skill nueva | La skill existe y coincide con el patron. |
| P-003 Fuente-Proceso-Salida-Hito-Cierre | `canon-documental`, `governed-readback-closeout`, `cabina-session-handoff`, `cabina-continuity-readback` | Skill propia creada | Ya tiene una skill para convertir documentos dispersos en canon reutilizable. |
| P-004 Gate Antes De Live | `dataverse-*`, `sdu-*`, `tcu-gate-api-no-sensible`, `no-inference-runtime-write-guard` | Sin skill nueva | Ya hay carriles por superficie y por frontera. |
| P-005 Workbook Al Frente | `excel-workbook-builder` | Sin skill nueva | La skill cubre el caso de workbook operativo. |
| P-006 Hito Versionado | `canon-documental`, `cabina-session-handoff`, `governed-readback-closeout`, `hitos/` | Sin skill nueva | El durable vive mejor como hito versionado, con canon documental de apoyo. |
| P-007 Retencion Gobernada | `operativa/archive/legacy-root/undated/RETENCION.md`, `no-inference-runtime-write-guard` | Sin skill nueva | Es una politica transversal, no una sola accion. |
| P-008 Validador Antes De Cierre | `governed-readback-closeout`, `skill-judge`, validadores locales | Sin skill nueva | El patron ya depende de validacion, no de una skill unica. |
| P-009 Agente Revisor Read-Only | `parallel-agentic-repo-audit`, `tcu-harness-evals-agentes` | Sin skill nueva | El trabajo paralelo y read-only ya tiene soporte. |
| P-010 Amarillo Guardrail | `rey-modo-verificacion-previa-cierre`, `operativa/CONTROL_TOTAL_*.md` | Sin skill nueva | Es una lectura de estado, no una capacidad nueva. |
| P-011 Workbench Atomico Accionable | `cabina-start-paper`, `cabina-4field-paper`, `tcu-planificador-con-archivos` | Sin skill nueva | Conviene seguir como contrato de entrada visible. |
| P-012 No Confundir Estados | `no-inference-runtime-write-guard`, `rey-modo-repo-code-recovery` | Sin skill nueva | Es una guardia conceptual y de clasificacion. |
| P-013 Sincronizacion Tiempo Real | `matrix-recipe-skill-sync`, `sdu-sharepoint-context-refresh`, `dataverse-*` | Sin skill nueva | Ya existe la infraestructura para alinear capas. |
| P-014 Canon Documental | `canon-documental`, `codex-surface-map`, `governed-readback-closeout` | Skill propia creada | Los hilos y docs pasan a canon navegable y reusable. |

## Resultado

Se creo una skill propia para `P-001 Delta Gobernado`, `P-003 Fuente-Proceso-Salida-Hito-Cierre` y `P-014 Canon Documental`.
El resto de los patrones sigue absorbido por skills existentes, procesos, playbooks o matrices.

## Siguiente Paso Sugerido

Elegir un solo hueco real y materializarlo como skill nueva, si queres convertir uno de estos patrones en capacidad propia.
