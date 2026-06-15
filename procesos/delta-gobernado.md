# Delta Gobernado

## Entrada

Objetivo acotado.

## Pasos

1. Declarar objetivo y superficie.
2. Mover el trabajo a `CURRENT`.
3. Ejecutar el minimo cambio verificable.
4. Registrar evidencia.
5. Cerrar en `TRACE`.
6. Versionar si es durable.
7. Validar.

## Salida

Cambio reversible o versionado.

## Stop Condition

`rollback_missing`, `postcheck_missing`
