# Retencion Gobernada

## Entrada

Pedido de limpieza, compactacion, mover o borrar.

## Pasos

1. Leer `operativa/archive/legacy-root/undated/RETENCION.md`.
2. Separar frente, evidencia, historico y excluido.
3. Declarar ruta exacta.
4. Declarar rollback.
5. Declarar postcheck.
6. No mover ni borrar sin orden explicita.

## Salida

Evidencia preservada o movimiento gobernado.

## Stop Condition

`unexpected_external_write`
