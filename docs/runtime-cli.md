---
artifact_id: docs/runtime-cli.md
categoria: procesos
tipo: plan
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: docs/runtime-cli.md
etiquetas:
  - runtime
  - cli
  - snapshots
  - restore
  - g7
relacionados:
  - VERSION_POLICY.md
  - VERSION_STATE.json
  - operativa/archive/legacy-root/20260622/ACTA_RUNTIME_CLI_REAL_20260622.md
descripcion: Guia operativa de comandos runtime para snapshots, restore, sentinel, status y G7.
---

# Runtime CLI

## Comandos canonicos

- `ceo-runtime-save`: crea un snapshot gobernado.
- `ceo-runtime-list`: lista snapshots disponibles.
- `ceo-runtime-restore`: valida o restaura un snapshot.
- `ceo-runtime-sentinel`: ejecuta el watchdog runtime local.
- `ceo-runtime-status`: muestra el estado ejecutivo del runtime.
- `ceo-runtime-continuous`: ejecuta el ciclo G7 de auditoria, divergencias, reconciliacion e indicadores.

## Alias

Cuando el paquete esta instalado, tambien puede usarse:

```powershell
ceo runtime status --json
ceo runtime save --version v0.6.0-rc1 --event-type manual --json
ceo runtime list --json
ceo runtime sentinel --json
ceo runtime restore CEORUNTIME_20260623_0008 --json
ceo runtime continuous --event manual --json
```

## PowerShell local

Los wrappers del repo resuelven la raiz de forma relativa, usan `.venv\Scripts\python.exe` si existe y hacen fallback a `python` del PATH.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\ceo-runtime-save.ps1 --json
powershell -NoProfile -ExecutionPolicy Bypass -File tools\ceo-runtime-list.ps1 --json
powershell -NoProfile -ExecutionPolicy Bypass -File tools\ceo-runtime-status.ps1 --json
powershell -NoProfile -ExecutionPolicy Bypass -File tools\ceo-runtime-sentinel.ps1 --json
powershell -NoProfile -ExecutionPolicy Bypass -File tools\ceo-runtime-restore.ps1 CEORUNTIME_20260623_0008 --json
powershell -NoProfile -ExecutionPolicy Bypass -File tools\ceo-runtime-continuous.ps1 --event manual --json
```

## Restore seguro

Por defecto, restore es `DRY_RUN`.

```powershell
ceo-runtime-restore CEORUNTIME_20260623_0008 --json
```

Para aplicar restore real se requiere confirmacion explicita:

```powershell
ceo-runtime-restore CEORUNTIME_20260623_0008 --apply --confirm --json
```

El restore real queda bloqueado si el workspace esta dirty.

## Sentinel local

`ceo-runtime-sentinel` escribe `operativa/sentinel/SENTINEL_REPORT.json`, que es reporte vivo local ignorado por Git. Si detecta drift, registra alerta local en `operativa/sentinel/DRIFT_LOG.json`.

## G7 mejora continua

`ceo-runtime-continuous` crea snapshot previo, clasifica divergencias, calcula indicadores y genera evidencia bajo `operativa/g7/` y `operativa/runtime-events/`.

En GitHub Actions se usa como analisis gobernado: produce JSON de evidencia y mantiene cerradas las superficies live.

## Frontera

- No push.
- No PR.
- No live.
- No MCP.
- No workflow dispatch.
- No lectura de secretos.
