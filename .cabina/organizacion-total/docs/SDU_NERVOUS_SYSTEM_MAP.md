# SDU Nervous System Map

## Principio

El sistema nervioso es la prioridad. Todo nodo se interpreta como capacidad funcional antes que como bloqueo.

La degradacion inteligente es la regla:

- Si falta Cloud: `CLOUD_READY_PACKAGE`.
- Si falta Dataverse live: `LOCAL_MEMORY_ACTIVE`.
- Si falta owner: `OWNER_INPUT_NEEDED + PLAN_READY`.
- Si falta secreto: `SECRET_REQUIRED_READBACK + CONTINUE_LOCAL`.
- Si no puede LIVE: `EXECUTE_LOCAL + PREPARE_SCALE`.

## Nodos Funcionales

| Nodo | Estado | Funcion |
| --- | --- | --- |
| CEO_RUNTIME | CONNECTED | fachada operativa local |
| CEO_CORE | CONNECTED | nucleo runtime |
| CEO_POLICY | CONNECTED | politica runtime |
| CEO_EVIDENCE | CONNECTED | evidencia local |
| CEO_SNAPSHOTS | CONNECTED | memoria de snapshots |
| CEO_WATCHDOG | CONNECTED | vigilancia local |
| PROJECT_CDX | CONNECTED | repo/workbench fisico |
| CABINA_ORG_TOTAL | FUNCTIONAL | runner SDU |
| CABINA_CONTRACT | FUNCTIONAL | constitucion operativa |
| CODEX_LOCAL | FUNCTIONAL | ejecucion local asistida |
| CODEX_CLOUD | FUNCTIONAL_REMOTE_READ_TESTED_REDACTED | memoria rapida/handoff |
| VSCODE_INSIDERS | FUNCTIONAL | interfaz operativa |
| AGENT_CELL | FUNCTIONAL | celula de agentes |
| MCP_LAYER | FUNCTIONAL_DECLARATIVE | conexion de capacidades |
| MONITORING_TRACES | FUNCTIONAL | observabilidad |
| AUTOMATION_QUEUE | FUNCTIONAL_DECLARATIVE | cola de revision |
| DATAVERSE_MEMORY | LOCAL_DECLARED | memoria estructural futura |
| SHAREPOINT_VISIBLE_MEMORY | OWNER_INPUT_REQUIRED | memoria visible gobernada |
| GITHUB_TECHNICAL_CANON | FUNCTIONAL_LOCAL | canon tecnico |

## Conexiones Clave

- `PROJECT_CDX` conecta repo fisico, cabina, Codex local y Git.
- `CABINA_CONTRACT` gobierna los modos expansivos.
- `CODEX_CLOUD` queda conectado como memoria rapida y handoff saneado.
- `FUNCTIONAL_AGENT_RUNTIME` adapta modo antes de bloquear.
- `DATAVERSE_MEMORY` no bloquea: persiste despues; localmente queda activo como puente declarativo.
