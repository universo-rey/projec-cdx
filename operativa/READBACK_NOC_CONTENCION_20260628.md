---
artifact_id: operativa/READBACK_NOC_CONTENCION_20260628.md
categoria: operativa
tipo: readback
estado: live
version: 2026.06.28
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/READBACK_NOC_CONTENCION_20260628.md
etiquetas:
- operativa
- noc
- readback
- contencion
relacionados:
- operativa/README.md
- noc/noc-state.json
- .cabina/execution-runtime/control-flow/control-flow.lock.json
- .cabina/execution-runtime/real-operation-loop.lock.json
descripcion: Readback corto de contencion del NOC local sin tocar sistemas vivos.
---

# READBACK_NOC_CONTENCION_20260628

## Estado
HECHO_VERIFICADO: el NOC no muestra un outage activo; muestra observabilidad degradada, locks huérfanos y sesiones duplicadas de Codex.

## Sistemas tocados
- Inspeccion read-only de `noc/noc-state.json`.
- Inspeccion read-only de `real-operation-state.json`, `control-flow.lock.json`, `real-operation-loop.lock.json` y `control-flow-errors.jsonl`.
- Inspeccion read-only de procesos locales `Codex`, `codex`, `pwsh`, `node` y `node_repl`.
- Escritura de este readback local.

## Sistemas no tocados
- Microsoft live.
- SharePoint live.
- Dataverse live.
- Git destructivo.
- Terminacion de procesos.

## Cambios
- NOC en `YELLOW` con `94` alertas activas y `readback` parcial.
- `control-flow.lock.json` apunta a PID `23084`, pero ese PID ya no existe.
- `real-operation-loop.lock.json` apunta a PID `9372`, pero ese PID ya no existe.
- `control-flow-errors.jsonl` registra contencion sobre `noc-panel.json` con PID `22240`, ya inexistente.
- Hay 9 procesos de Codex vivos: 7 `Codex.exe` de WindowsApps y 2 `codex.exe` locales.

## Validacion
- Chequeo de procesos por PID.
- Lectura de estado NOC y locks.
- Lectura de errores de control flow.

## Riesgos
- Ambiguedad entre sesiones vivas y residuos de sesiones previas.
- Locks huérfanos pueden volver a disparar loops de coordinacion si se reusan sin saneamiento.
- La observabilidad parcial puede seguir generando falsos positivos si se interpreta como ausencia real.

## Rollback
- Sin rollback necesario porque no se toco produccion ni se terminaron procesos.
- Si se decide contener de forma activa, el rollback es volver a dejar todo en solo lectura y documentar el cierre.

## Proximos carriles
- Confirmar si queres que mate las sesiones Codex sobrantes.
- Revalidar y sanear locks obsoletos solo con confirmacion.
- Seguir el analisis de anomalias del NOC hasta separar lo vivo de lo historico.

agente: Codex
orden: contener NOC sin mutar sistemas vivos
superficie: local / NOC / observabilidad
skill: governed-readback-closeout
receta: read-only triage + evidence packet
tool: PowerShell + filesystem read
estado: HECHO_VERIFICADO
evidencia: noc-state, locks, control-flow errors, process snapshot
validador: chequeo directo de PIDs y archivos de estado
riesgo: medio
rollback: ninguno; no hubo mutacion
stop_condition: cualquier accion de terminacion de proceso o limpieza de lock requiere confirmacion
proximos_carriles: sesiones Codex sobrantes, saneamiento de locks, revalidacion NOC
