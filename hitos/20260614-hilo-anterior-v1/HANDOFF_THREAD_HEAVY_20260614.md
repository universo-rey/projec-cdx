# Handoff - corte por hilo pesado

## agente
Codex / workspace_guardian

## orden
Cerrar hilo pesado y continuar en hilo fresco con estado verificado, sin arrastrar todo el historial.

## superficie
- `C:\Users\enzo1\PROJEC CDX`
- `C:\Users\enzo1\.codex`
- repos principales en `C:\Users\enzo1\Documents\GitHub`

## verified
- Se corrigio `C:\Users\enzo1\.codex\config.toml` para usar `integratedTerminalShell = "pwsh"`.
- `pwsh` disponible: PowerShell 7.6.2.
- Perfil PowerShell de Codex validado con `LAYOUT_OK`.
- Se creo `C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1`.
- `codex-control-total.ps1` corrio en modo rapido con estado `yellow`, `15 green`, `6 yellow`, `0 red`.
- Los amarillos observados son esperados: repos limpios en `main` y backup raiz de `global-state` que no debe limpiarse a ciegas.
- `auth.json` y `cap_sid` solo deben tratarse como marcadores sensibles; no leer ni imprimir contenido.

## stale
- El hilo actual es muy largo y puede degradar razonamiento, busquedas y decisiones.
- El estado historico de `.codex-global-state.json` es persistente y grande; no usarlo como unica fuente de verdad.
- La capa activa de Codex tambien incluye SQLite en `C:\Users\enzo1\.codex\sqlite`.

## missing
- No se creo hilo nuevo todavia desde este handoff.
- No se versionaron cambios de `PROJEC CDX` en Git, porque esta carpeta no fue tratada como repo Git en esta ronda.

## risk
- Seguir trabajando en este hilo puede mezclar decisiones antiguas con estado actual.
- Tocar `global-state`, SQLite, `auth.json` o `cap_sid` sin plan puede romper runtime o exponer secretos.
- Ejecutar control general sobre todos los targets puede tardar; preferir `codex-control-total.ps1` rapido y luego `-Full` si hace falta.

## rollback
- Para revertir el cambio de shell integrado, volver en `C:\Users\enzo1\.codex\config.toml` a:
  `integratedTerminalShell = "powershell"`
- No recomendado salvo que `pwsh` falle.

## next_lane
Abrir hilo fresco y empezar con este prompt:

```txt
Continuar desde el handoff:
C:\Users\enzo1\PROJEC CDX\outputs\handoffs\HANDOFF_THREAD_HEAVY_20260614.md

Objetivo:
Trabajar desde estado limpio, usando primero:
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1"

Reglas:
- No leer secretos.
- No tocar auth.json ni cap_sid.
- No editar global-state ni SQLite sin orden explicita.
- Si hay cambios, abrir rama o artefacto separado antes de tocar repos.
- Mantener respuestas cortas y operativas.
```

## stop_condition
- Si `codex-control-total.ps1` devuelve `red`, detener y diagnosticar solo ese rojo.
- Si aparece live/API/tenant/secret, pedir orden atomica explicita antes de escribir.
