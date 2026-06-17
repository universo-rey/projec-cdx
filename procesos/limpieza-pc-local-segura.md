# Limpieza PC Local Segura

## Entrada

Pedido de limpiar y ordenar una PC Windows local sin perder control.

## Subpatrones

- [Inventario y gate](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-inventario-y-gate.md)
- [Auxiliares y temporales](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-auxiliares-y-temporales.md)
- [Evidencia y rollback](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-evidencia-y-rollback.md)

## Pasos

1. Confirmar gate local y leer el inventario antes de tocar nada.
2. Separar base Windows de ruido auxiliar por nombre exacto, ruta exacta y efecto observable.
3. Limpiar solo temporales y auxiliares ya aprobados.
4. Verificar que la base de Windows sigue intacta.
5. Guardar evidencia, rollback y un unico siguiente gate.

## Salida

Inventario final, recorte de ruido y registro local navegable.

## Validador

- inventario guardado;
- base Windows intacta;
- rollback anotado;
- next gate unico.

## Stop Condition

`no_evidence`, `base_windows_at_risk`, `target_ambiguous`, `next_gate_plural`
