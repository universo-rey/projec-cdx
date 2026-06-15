# Configuracion Entorno Codex UI

Receta para declarar el entorno necesario en la UI de Codex y dejar listo el carril vivo de `PROJEC CDX` sin mezclarlo con live write.

La configuracion real queda en `.codex/config.toml` en la raiz del proyecto y en el worktree activo.

El worktree activo tambien debe estar confiado en `~/.codex/config.toml` para que su configuracion local cargue.

No guardar secretos en `.codex/config.toml`. Si hace falta una clave para humo o live, se maneja por el flujo autorizado de secretos, no como texto plano en la receta.

## Cuándo Usarla

Cuando hace falta:

- cargar o revisar variables de entorno en la UI de Codex;
- dejar el runner listo para humo y arranque vivo;
- alinear la UI con la raiz canonica y el worktree activo;
- evitar improvisar variables, rutas o gates.

## Campos Manuales

Usar estos valores en la UI de Codex cuando la configuracion se cargue manualmente:

- `Nombre`: `PROJEC CDX`
- `Agente`: `EATOMIC`
- `Variables de entorno del script de instalación`:
  - `CODEX_SOURCE_TREE_PATH`: `C:\Users\enzo1\PROJEC CDX`
  - `CODEX_WORKTREE_PATH`: `C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX`
- `Script de configuración`:

```bash
cd "$CODEX_WORKTREE_PATH"
python -m pip install -e ".[dev,agents-sdk,openai-orchestration]"
pwsh -NoProfile -File ".\tools\codex-cloud-bootstrap.ps1"
```

- `Script de limpieza`:

```bash
docker compose down --remove-orphans
Remove-Item -Recurse -Force .cache\tmp -ErrorAction SilentlyContinue
```

## Personalidad EATOMIC

- `Nombre del agente`: `EATOMIC`
- `Rol`: operador de resultado, no redactor.
- `Tono`: directo, firme y util.
- `Reglas`: un eslabon por vez; si no hay resultado, no se abre el siguiente.
- `Prioridad`: cadena completa, evidencia minima y siguiente paso unico.

## Cadena EATOMIC

1. Abrir.
2. Ejecutar.
3. Verificar resultado.
4. Registrar evidencia.
5. Pasar al siguiente eslabon.

Notas:

- El script de configuración se ejecuta en la raíz del proyecto al crear el worktree.
- El script de limpieza se ejecuta en la raíz del proyecto antes de limpiar el worktree.
- Si la UI usa otro shell, traducir los comandos al shell activo sin cambiar el orden ni el propósito.
- La selección visible en la UI sale de `.codex/environments/environment.toml`.

## Derivación

1. Confirmar la raiz canonica `C:\Users\enzo1\PROJEC CDX`.
2. Confirmar el worktree activo `C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX`.
3. Abrir la UI de Codex sobre la raiz correcta o sobre el worktree correcto, segun el carril activo.
4. Confirmar que la UI muestre la configuracion del proyecto y que lea la capa local desde `.codex/config.toml`.
5. Verificar que las variables de entorno de control queden presentes:
   - `OPENAI_MODEL=gpt-5.4-mini`
   - `CODEX_CLOUD_ENABLED=1`
   - `CODEX_CLOUD_MODE=cloud`
   - `CODEX_CLOUD_GATE=metadata-only`
   - `CODEX_CLOUD_PROFILE=projec-cdx`
   - `CODEX_CLOUD_REPO_ROOT=C:\Users\enzo1\PROJEC CDX`
   - `CODEX_CLOUD_WORKTREE=C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX`
   - `CODEX_CLOUD_BRANCH=codex/revisar-procesos-del-equipo`
6. Si la UI sigue mostrando otro contexto, cerrar y reabrir el proyecto correcto antes de seguir.
7. Verificar humo en la raiz:

```powershell
.\.venv\Scripts\python main.py --smoke --json
```

8. Verificar arranque vivo con el acceso unico:

```powershell
pwsh -NoProfile -File ".\tools\codex-cloud-live.ps1" -Prompt "Responde solo: OK."
```

9. Registrar la actualizacion en `operativa/CURRENT.md` y `operativa/TRACE.md` si la UI cambio de estado real.

## Salida

Entorno de Codex UI alineado, runner local usable y gate mantenido en `metadata-only`.

## Stop Condition

- La UI no expone un entorno editable para el workspace.
- La raiz o el worktree no coinciden con el carril activo.
- Se intenta abrir live write sin target declarado.
- Falta la `.venv` local o el humo no pasa.
