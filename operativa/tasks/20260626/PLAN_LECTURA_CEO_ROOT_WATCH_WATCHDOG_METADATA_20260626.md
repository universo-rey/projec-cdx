# Plan de lectura gobernada - C:\CEO

Fecha UTC: 2026-06-26T09:11:02Z
Modo: CEO_ROOT_READING_PLAN_G1
Alcance: `C:\CEO`, `C:\CEO\watch`, `C:\CEO\watchdog`, `C:\CEO\.metadata`

## Objetivo

Identificar el estado maximo alcanzado y la autoridad real de la superficie `C:\CEO` sin contaminar runtime, Git remoto ni secretos.

El resultado esperado es una cartografia por capas que diga que es canon, que es runtime vivo, que es evidencia, que es generado, que es soporte local, que esta obsoleto y que debe quedar fuera de lectura por riesgo.

## Reglas De Operacion

- Solo lectura hasta nuevo gate explicito.
- No ejecutar `.ps1`, `.cmd`, `.bat`, dashboards, runners, watchdogs ni loops.
- No abrir secretos ni archivos por nombre sensible: `.env`, `secret`, `token`, `credential`, `password`, `.pem`, `.pfx`, `.key`.
- No reanclar `CEO_ROOT`.
- No mover, borrar, limpiar, renombrar ni normalizar.
- No tocar Git remoto.
- No stage.
- No servicios, tareas programadas, firewall, Defender, red, SharePoint ni Dataverse.
- Primero metadatos, despues contenido seguro y pequeno, despues contratos.

## Contexto Inicial

Inventario metadata-only ya medido:

| Root | Rol inicial | Senal viva |
|---|---|---|
| `C:\CEO` | Hub local y fachada operativa | 21 elementos top-level, incluye junction `project-cdx` |
| `C:\CEO\watch` | Watch historico/minimo | `CEO-Watchdog.ps1`, `pid.txt`, `events` |
| `C:\CEO\watchdog` | Runtime/watchdog mas denso | `telemetry.json`, `run-documentlocation-loop.ps1`, `run-telemetry.ps1`, `noc-web`, `state`, `alerts`, `incidents` |
| `C:\CEO\.metadata` | Backups/configuracion/evidencia local | `audit`, `env-backups`, `local-config-backups`, `vscode-insiders` |

## Agentes

| Agente | Carril | Entrada | Salida |
|---|---|---|---|
| Maat | Gobierno y freeze | Git status, `VERSION_STATE.json`, reglas AGENTS | Estado reconciliado y stop conditions |
| Seshat | Cartografia raiz | `C:\CEO` top-level | Mapa de superficies y autoridad inicial |
| Horus | Watch | `C:\CEO\watch` | Lectura de eventos/pid/scripts solo como texto seguro |
| Anubis | Watchdog runtime | `C:\CEO\watchdog` | Matriz bus/telemetria/runner/watchdog/NOC sin ejecucion |
| Thot | Metadata | `C:\CEO\.metadata` | Indice de backups/config local con exclusiones sensibles |
| Ptah | Integracion repo | `C:\CEO\project-cdx` junction | Cruce con `MAPA_MAESTRO.md`, `SYSTEM_NERVOUS_INDEX.json`, contratos y herramientas |

## Skills Y Recetas

- `codex-surface-map`: inventario top-level, clasificacion visible/mapa/referencia.
- `governed-readback-closeout`: readback con estado, sistemas tocados/no tocados, validacion y rollback.
- `planning-with-files`: persistir plan, avances y hallazgos en archivos locales.
- `parallel-agentic-repo-audit`: solo si se habilita despacho paralelo real.
- `superpowers:dispatching-parallel-agents`: solo si se habilita subagentes con fan-in.
- `openai-developers:agents-sdk`: solo para mapear assets SDK si aparecen contratos reales de agentes; no crear claves ni ejecutar llamadas.

## Fases

1. Freeze y alineacion
   - Releer `git status`, branch, HEAD, ahead.
   - Reconciliar `VERSION_STATE.json` con el delta vivo.
   - Registrar que cualquier staged existente es previo y no pertenece a esta operacion.

2. Inventario raiz `C:\CEO`
   - Listar primer nivel con `Mode`, `Attributes`, `LinkType`, `Target`, `LastWriteTime`, `Length`.
   - Marcar junctions, archivos de entrada, scripts, politicas, docs, evidence, snapshots, worktrees.
   - Clasificar cada entrada como canon, runtime, evidencia, generado, soporte, sensible-posible, deprecated o externo.

3. Lectura `C:\CEO\watch`
   - Leer primero nombres, tamanos y fechas.
   - Revisar `active-baseline.txt` y `pid.txt` solo si se confirma que no contienen secreto.
   - Leer `CEO-Watchdog.ps1` como texto solo para dependencias, entradas/salidas y rutas; no ejecutar.
   - Leer `events` por conteos y ultimos archivos, no por contenido completo inicialmente.

4. Lectura `C:\CEO\watchdog`
   - Separar bus, telemetria, runner, watchdog, NOC web, state, alerts, incidents, outbox, scheduler.
   - Leer JSON pequenos de config/estado con parser.
   - Leer scripts como texto para mapa de funciones y rutas, no para invocacion.
   - Revisar `telemetry.json`, `watchdog.actions.json`, `watchdog.seen.txt` por schema y timestamp.
   - Evitar backups grandes salvo comparacion dirigida.

5. Lectura `C:\CEO\.metadata`
   - Agrupar backups, auditorias, devdrive, devcontainers, VS Code Insiders y cleanup local.
   - Excluir contenido sensible por nombre y por patron antes de abrir archivos.
   - Leer solo manifiestos, indices, README, CSV de auditoria y configs no sensibles.

6. Reconciliacion de autoridad
   - Cruzar `C:\CEO\policy.json`, `Start-CEO.ps1`, `core`, `tools`, `watch`, `watchdog`.
   - Cruzar con `C:\CEO\project-cdx\VERSION_STATE.json`, `SYSTEM_NERVOUS_INDEX.json`, `MAPA_MAESTRO.md`.
   - Declarar una sola autoridad por capacidad: bus, telemetria, watchdog, runner, NOC, evidencia, snapshots.

7. Fan-in y freeze siguiente
   - Crear readback final de lectura.
   - Actualizar mapa/estado solo si el delta es documental y local.
   - Dejar pendientes que requieran gate de ejecucion o lectura sensible.

## Deliverables

- `CEO_ROOT_SURFACE_INVENTORY_20260626.json`: inventario metadata-only ampliado.
- `CEO_ROOT_AUTHORITY_MATRIX_20260626.md`: autoridad por capacidad.
- `CEO_WATCH_WATCHDOG_DELTA_20260626.md`: diferencias `watch` vs `watchdog`.
- `CEO_METADATA_INDEX_20260626.md`: indice seguro de `.metadata`.
- `READBACK_CEO_ROOT_READING_20260626.md`: cierre gobernado con riesgos y proximos gates.

## Stop Conditions

- Archivo con nombre sensible detectado y requerido para avanzar.
- Script o config que exija ejecucion para confirmar estado.
- Junction o ruta externa que salga de la frontera aprobada.
- Error de acceso que requiera elevacion.
- Necesidad de tocar runtime, red, servicios, Git remoto o Microsoft live.

## Primer Comando Permitido En La Ejecucion

Solo metadata:

```powershell
Get-ChildItem -LiteralPath 'C:\CEO' -Force | Select-Object Name,FullName,Mode,Length,LastWriteTime,Attributes,LinkType,Target
```

## Output Contract

- `PLAN`: CEO_ROOT_READING_PLAN_G1
- `SCOPE`: C:\CEO; C:\CEO\watch; C:\CEO\watchdog; C:\CEO\.metadata
- `MODE`: READ_ONLY_METADATA_FIRST
- `NO_EXEC`: true
- `NO_SECRET_READ`: true
- `NO_STAGE`: true
- `NO_REMOTE`: true
- `NEXT_GATE`: autorizar ejecucion de lectura por fases
