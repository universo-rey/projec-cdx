# Preflight Gobernado

## Entrada

Antes de tocar archivos o superficies.

## Pasos

1. Confirmar raiz.
2. Declarar archivos a leer y escribir.
3. Confirmar que no hay secretos ni runtime sensible.
4. Declarar rollback.
5. Declarar postcheck.
6. Revisar stop conditions.

## Salida

Semaforo previo al delta.

## Stop Condition

`workspace_root_mismatch`, `secret_or_runtime_state_requested`, `live_surface_without_order`
