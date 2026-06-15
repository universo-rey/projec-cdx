# Arranque Codex Cloud

Uso oficial para levantar el carril vivo desde la raiz canonica de `PROJEC CDX`.

La receta de configuracion de entorno de la UI vive en [recipes/configuracion-entorno-codex-ui.md](C:/Users/enzo1/PROJEC%20CDX/recipes/configuracion-entorno-codex-ui.md). Si la UI queda apuntando a otro contexto, reabrir el proyecto correcto antes de seguir.

La entrada minima para abrir la UI con el carril correcto vive en [operativa/SETUP_APERTURA_CODEX_UI.md](C:/Users/enzo1/PROJEC%20CDX/operativa/SETUP_APERTURA_CODEX_UI.md).

## Comando unico

```powershell
pwsh -NoProfile -File ".\tools\codex-cloud-live.ps1"
```

## Verificacion rapida

```powershell
.\.venv\Scripts\python main.py --smoke
```

## Notas

- El arranque usa la `.venv` del root cuando existe.
- El texto de entrada se cambia con `-Prompt`.
- El carril vivo se activa cuando el target y la cadena estan declarados.
