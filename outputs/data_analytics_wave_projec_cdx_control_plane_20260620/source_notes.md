# Source Notes - Data Analytics Wave PROJEC CDX Control Plane 20260620

## Decision Frame

Pregunta: si `PROJEC CDX` ya esta suficientemente configurado para operar con Data Analytics y cual es el siguiente delta real.

Decision: operar con confianza desde el canon actual, pero no cerrar total hasta alinear el validador operativo y ordenar el dirty state.

## Evidence Read

| Fuente | Resultado |
| --- | --- |
| `README.md` | Entrada viva declara hub `C:\CEO`, canon `C:\CEO\project-cdx`, workspace fisico `C:\Users\enzo1\PROJEC CDX` y workbook vigente. |
| `MAPA_MAESTRO.md` | Cobertura visible apunta a planes, Dataverse, agents, chains, skills, workbooks y tools. |
| `docs\superpowers\plans\README.md` | Matriz de cobertura tiene planes de dominio y stop condition estables. |
| `workbooks\README.md` | Workbook vigente contiene agentes, entornos, colas, conexiones, repositorios, skills, recetas, tools y fuentes Dataverse. |
| `workbooks\CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx` | Abre correctamente; 56 hojas detectadas. |
| `dataverse\README.md` | Dataverse queda como familia gobernada, no raiz de gobierno. |
| `dataverse\GATE.md` | Live Dataverse requiere ambiente, target, owner, rollback, postcheck, evidencia y stop condition. |
| `operativa\MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md` | La capa skills/tools/recipes ya existe; no crear duplicado. |
| `operativa\SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619.md` | Codex Cloud cache es acelerador, no memoria canonica. |
| `tools\validate_proj_cdx_operational_chain.ps1` | Falla por dos CSV legacy faltantes; mapa Dataverse y matriz atomica pasan. |
| Git `main` | `main...origin/main [ahead 4]`; muchos cambios mezclados y archivos no trackeados. |

## Workbook Coverage

| Familia | Hojas |
| --- | ---: |
| D / absorption layer | 22 |
| Decision and navigation | 13 |
| Agents and capabilities | 6 |
| Repos, branches, cloud | 5 |
| Dataverse and tenant | 5 |
| Atomic governance | 5 |

## Visual Omission

Se intento crear un PNG con Matplotlib/Seaborn segun contrato de Data Analytics HTML reports. Resultado:

- Runtime empaquetado de Codex: `ModuleNotFoundError: No module named 'matplotlib'`.
- `.venv` local: `ModuleNotFoundError: No module named 'matplotlib'`.

Decision: no instalar paquetes durante esta wave; no crear chart no conforme. La evidencia cuantitativa queda como tabla HTML y este note registra el motivo.

## Stop Condition

No abrir estructuras nuevas. El siguiente delta real es alinear `tools\validate_proj_cdx_operational_chain.ps1` con fuentes actuales o declarar explicitamente su frontera legacy.
