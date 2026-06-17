# Limpieza PC Local Evidencia Y Rollback

## Uso

Aplicar al cerrar cualquier recorte local para dejar trazabilidad, reversibilidad y un unico siguiente movimiento.

## Regla

No hay cierre sin evidencia antes/despues, rollback explicito y proximo gate unico.

## Hacer

- Registrar que se reviso y que se cambio.
- Guardar la ruta o criterio de rollback de cada item tocado.
- Anotar lo que quedo bloqueado, lo ambiguo y lo no tocado.
- Cerrar con una sola siguiente accion, no con una lista.

## Salida

Cierre navegable, reversible y apto para retomar sin releer toda la conversacion.

## Stop Condition

`evidence_missing`, `rollback_missing`, `next_gate_plural`
