# Configuracion Entorno Codex UI

Receta para declarar el entorno necesario en la UI de Codex y dejar listo el carril local de `PROJEC CDX` sin mezclarlo con live write ni con un workspace cloud.

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

Usar este carril cuando queres un arranque seguro estilo `cabina-universal-d`, sin bootstrap real en la UI.
En esta superficie local los paths son de Windows normalizados con `/`:

- `Nombre`: `PROJEC CDX`
- `Agente`: `EATOMIC`
- `Directorio del espacio de trabajo`: `C:/CEO/project-cdx`
- `Variables de entorno del script de instalación`:
  - `CODEX_RUNTIME_SURFACE`: `local-desktop`
  - `CODEX_SOURCE_TREE_PATH`: `C:/CEO/project-cdx`
  - `CODEX_WORKTREE_PATH`: `C:/CEO/project-cdx`
- `Script de configuración`:

```powershell
pwsh -NoProfile -File ".\tools\codex-environment-setup.ps1"
```

- `Script de limpieza`:

```powershell
pwsh -NoProfile -File ".\tools\codex-environment-cleanup.ps1"
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
- Si queres el carril estilo `cabina-universal-d`, usa estos scripts no-op en la UI y deja la ejecucion real para otra pasada gobernada.

## Derivación

1. Confirmar la raiz canonica de repos `C:/Users/enzo1/Documents/GitHub`.
2. Confirmar el repo canonico de Cabina `C:/Users/enzo1/Documents/GitHub/cabina-universal-d`.
3. Confirmar el workbench/metadata root `C:/CEO/project-cdx`.
4. Abrir la UI de Codex sobre la raiz correcta o sobre el workspace correcto, segun el carril activo.
5. Confirmar que la UI muestre la configuracion del proyecto y que lea la capa local desde `.codex/config.toml`.
6. Verificar que las variables de entorno de control queden presentes:
   - `OPENAI_MODEL=gpt-5.5`
   - `CODEX_RUNTIME_SURFACE=local-desktop`
   - `CODEX_CLOUD_ENABLED=0`
   - `CODEX_CLOUD_MODE=local`
   - `CODEX_CLOUD_GATE=local-only`
   - `CODEX_CLOUD_PROFILE=projec-cdx`
   - `CODEX_REPOS_ROOT=C:/Users/enzo1/Documents/GitHub`
   - `CODEX_CABINA_REPO_ROOT=C:/Users/enzo1/Documents/GitHub/cabina-universal-d`
   - `CODEX_WORKBENCH_ROOT=C:/CEO/project-cdx`
   - `CODEX_CLOUD_REPO_ROOT=C:/Users/enzo1/Documents/GitHub/cabina-universal-d`
   - `CODEX_CLOUD_METADATA_ROOT=C:/CEO/project-cdx`
   - `CODEX_CLOUD_WORKTREE=C:/CEO/project-cdx`
   - `CODEX_CLOUD_BRANCH=codex/consume-bound-workbook-next-delta`
7. Si la UI sigue mostrando otro contexto, cerrar y reabrir el proyecto correcto antes de seguir.
8. Verificar humo en la raiz:

```powershell
./.venv/Scripts/python main.py --smoke --json
```

9. Verificar arranque local con el acceso unico:

```powershell
C:/Users/enzo1/AppData/Local/Microsoft/WindowsApps/pwsh.exe -NoProfile -File "./tools/codex-environment-setup.ps1"
```

10. Registrar la actualizacion en `operativa/CURRENT.md` y `operativa/TRACE.md` si la UI cambio de estado real.

## Salida

Entorno de Codex UI alineado, runner local usable y gate mantenido en `local-only`.

## Stop Condition

- La UI no expone un entorno editable para el workspace.
- La raiz o el worktree no coinciden con el carril activo.
- Se intenta abrir live write sin target declarado.
- Falta la `.venv` local o el humo no pasa.
