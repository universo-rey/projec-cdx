# 00 - Preflight Gobernado

Validacion minima antes de tocar cualquier archivo o superficie de `PROJEC CDX`.

## Entrada

- Objetivo del delta.
- Superficie exacta.
- Archivos a leer.
- Archivos a escribir.
- Criterio de cierre.

## Lectura Obligatoria

1. `README.md`
2. `MAPA_MAESTRO.md`
3. `operativa/CONTROL.md`
4. `operativa/CURRENT.md`
5. `operativa/NEXT.md`
6. `operativa/BLOCKERS.md`
7. `dataverse/GATE.md` si aparece Dataverse, Power Platform, Power Automate, Microsoft live o ambiente.

## Gate

Semaforo verde solo si:

- La raiz es `C:\Users\enzo1\PROJEC CDX`.
- El delta no requiere secretos.
- El delta no toca `auth.json`, `cap_sid`, global-state ni SQLite.
- El delta no ejecuta live writes.
- El rollback es simple: revertir o reemplazar los archivos del delta.
- El postcheck esta declarado.

## Stop Conditions

- `target_identity_ambiguous`
- `secret_or_runtime_state_requested`
- `live_surface_without_order`
- `rollback_missing`
- `postcheck_missing`
- `workspace_root_mismatch`

## Salida

Registrar:

- Semaforo.
- Superficie.
- Archivos afectados.
- Riesgos.
- Postcheck.
- Proximo movimiento unico.
