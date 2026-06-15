# Setup Apertura Codex UI

Entrada corta para abrir Codex en el carril correcto de `PROJEC CDX`.

## Objetivo

Abrir la UI sobre el proyecto correcto, leer la config local correcta y salir con un humo minimo verificable.

## Campos Manuales

- `Nombre`: `PROJEC CDX`
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

## Orden

## Paso Unico

1. Abrir Codex sobre `C:\Users\enzo1\PROJEC CDX` o sobre el worktree activo `C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX`.
2. Confirmar que la UI lea `.codex/config.toml` del carril abierto.
3. Verificar que el entorno visible muestre:
   - `OPENAI_MODEL=gpt-5.4-mini`
   - `CODEX_CLOUD_ENABLED=1`
   - `CODEX_CLOUD_MODE=cloud`
   - `CODEX_CLOUD_GATE=metadata-only`
   - `CODEX_CLOUD_PROFILE=projec-cdx`
   - `CODEX_CLOUD_REPO_ROOT=C:\Users\enzo1\PROJEC CDX`
   - `CODEX_CLOUD_WORKTREE=C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX`
   - `CODEX_CLOUD_BRANCH=codex/revisar-procesos-del-equipo`
4. Si la UI muestra otro contexto, cerrar, reabrir el proyecto correcto y volver a validar.
5. Correr humo local.

## Humo Local

```powershell
.\.venv\Scripts\python main.py --smoke --json
```

## Regla

- No guardar secretos en `.codex/config.toml`.
- El live se activa cuando el carril y el target estan declarados.
- Si el worktree no coincide con el carril, reabrir antes de seguir.
- La UI selecciona el entorno desde `.codex/environments/environment.toml`.
