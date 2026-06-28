# Setup Apertura Codex UI

Entrada corta para abrir Codex en el carril correcto de `PROJEC CDX`.

## Objetivo

Abrir la UI sobre el proyecto correcto, leer la config local correcta y salir con un humo minimo verificable.

## Campos Manuales

En la UI de Codex Cloud, estos paths apuntan al contenedor Linux, no a Windows local.

- `Nombre`: `PROJEC CDX`
- `Directorio del espacio de trabajo`: `/workspace/projec-cdx`
- `Variables de entorno del script de instalación`:
  - `CODEX_SOURCE_TREE_PATH`: `/workspace/projec-cdx`
  - `CODEX_WORKTREE_PATH`: `/workspace/projec-cdx`
- `Script de configuración`:

```bash
#!/usr/bin/env bash
set +e

echo "SCRIPT_ID=projec_cdx_codex_cloud_setup_noop_20260616"
pwd || true
echo "NOOP_SETUP_PASS=True"

exit 0
```

- `Script de limpieza`:

```bash
#!/usr/bin/env bash
set +e

echo "SCRIPT_ID=projec_cdx_codex_cloud_maintenance_noop_20260616"
pwd || true
echo "NOOP_MAINTENANCE_PASS=True"

exit 0
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

1. Abrir Codex sobre `C:/CEO/project-cdx`.
2. Confirmar que la UI lea `.codex/config.toml` del carril abierto.
3. Verificar que el entorno visible muestre:
   - `OPENAI_MODEL=gpt-5.5`
   - `CODEX_CLOUD_ENABLED=1`
   - `CODEX_CLOUD_MODE=cloud`
   - `CODEX_CLOUD_GATE=metadata-only`
   - `CODEX_CLOUD_PROFILE=projec-cdx`
   - `CODEX_CLOUD_REPO_ROOT=C:/CEO/project-cdx`
   - `CODEX_CLOUD_WORKTREE=C:/CEO/project-cdx`
   - `CODEX_CLOUD_BRANCH=codex/consume-bound-workbook-next-delta`
4. Si la UI muestra otro contexto, cerrar, reabrir el proyecto correcto y volver a validar.
5. Correr humo local.

## Humo Local

```powershell
./.venv/Scripts/python main.py --smoke --json
```

## Regla

- No guardar secretos en `.codex/config.toml`.
- El live se activa cuando el carril y el target estan declarados.
- Si el worktree no coincide con el carril, reabrir antes de seguir.
- La UI selecciona el entorno desde `.codex/environments/environment.toml`.
- Este carril no-op es solo para destrabar la UI. La ejecucion real se deja para una pasada gobernada aparte.
