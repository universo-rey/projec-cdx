# Despierta Arranque Vivo Codex Cloud

Uso oficial para levantar el carril vivo desde la raiz canonica de `PROJEC CDX`.

No entres en modo lectura pasiva: este arranque te toma, te alinea y te mete en la cadena.
Los atomos nacen en `Codex Cloud`, `Dataverse` los contiene y alimenta, y la cadena de agentes los consume desde la fuente o desde el almacen segun haga falta.

La receta de configuracion de entorno de la UI vive en [recipes/configuracion-entorno-codex-ui.md](C:/Users/enzo1/PROJEC%20CDX/recipes/configuracion-entorno-codex-ui.md). Ese carril usa setup y maintenance no-op para destrabar la UI sin tocar bootstrap real.

En la UI de Codex Cloud, el campo `Directorio del espacio de trabajo` debe quedar en `/workspace/projec-cdx`. Si ese campo queda en una ruta de Windows, el `cd` del setup falla aunque los env vars esten bien.

La entrada minima para abrir la UI con el carril correcto vive en [operativa/SETUP_APERTURA_CODEX_UI.md](C:/Users/enzo1/PROJEC%20CDX/operativa/SETUP_APERTURA_CODEX_UI.md).

Si lo que queres es destrabar la UI, usar los helpers no-op:

```bash
sh ./tools/codex-cloud-ui-setup-noop.sh
sh ./tools/codex-cloud-ui-maintenance-noop.sh
```

## Comando unico

```powershell
pwsh -NoProfile -File ".\tools\codex-cloud-live.ps1"
```

## Verificacion rapida

```powershell
.\.venv\Scripts\python main.py --smoke
```

El humo debe cerrar con `context_ok=True`. Si aparece `prepared_with_context_drift`, el Git real ya esta identificado pero la sesion o la UI siguen inyectando variables viejas; reiniciar el entorno antes de activar el siguiente turno.

## Notas

- El arranque usa la `.venv` del root cuando existe.
- El texto de entrada se cambia con `-Prompt`.
- El carril vivo se activa cuando el target y la cadena estan declarados.
