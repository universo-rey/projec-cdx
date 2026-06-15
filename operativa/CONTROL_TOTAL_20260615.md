# Control Total General 20260615

## Estado

`GREEN_OPERABLE`: 21 checks gobernados, 0 red.

## Lectura Operativa

No hay bloqueo rojo. Los guardrails de seguridad quedan activos, pero ya no son bloqueo de semaforo:

- `.codex` tiene backup root; comparar generaciones antes de mover o limpiar.
- Repos principales estan limpios en `main`; crear rama antes de cambios.

## Green

- `git`, `gh`, `rg`, `python` disponibles.
- `pwsh` disponible.
- Layout PowerShell Codex OK.
- `.codex` existe.
- Terminal integrada apunta a `pwsh`.
- Marcadores sensibles detectados solo como marcador: `auth.json`, `cap_sid`.
- Operativa Guardian disponible.

## Guardrails Activos

- `codex-root / global-state backup root`
- `cabina-universal-d` en `main`
- `torre-gemela-escribania` en `main`
- `seshat-bootstrap-sdu-cn` en `main`
- `tcu-agentic-runtime-control` en `main`
- `tge-agentic-runtime-control-escribania` en `main`

## Regla

- No limpiar `.codex` a ciegas.
- No tocar repos en `main`; abrir rama o artefacto separado antes de cambios.
- No leer secretos.

## Cierre 2026-06-15

Los 6 guardrails historicos quedan reclasificados como `GREEN_OPERABLE`: reglas permanentes de operacion, no bloqueo pendiente.
