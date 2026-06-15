# Limpieza PC Local Segura

## Entrada

Pedido de limpiar y ordenar una PC Windows local sin perder control.

## Pasos

1. Leer `operativa/CURRENT.md`, `operativa/TRACE.md` y `operativa/ANCLAS_ON_DEMAND.md`.
2. Confirmar gate local y, si hace falta, sesion elevada.
3. Inventariar procesos, servicios, startup, PATH y superficie de busqueda.
4. Separar ruido auxiliar de infraestructura base.
5. Limpiar solo temporales autorizados y activos de usuario aprobados.
6. Deshabilitar solo auxiliares aprobados por nombre exacto.
7. Verificar que la base de Windows sigue intacta.
8. Guardar evidencia, rollback y registro en Dataverse local.
9. Cerrar con un unico siguiente paso.

## Salida

Inventario final, recorte de ruido y registro local navegable.

## Validador

- inventario guardado;
- no live write;
- no base windows touched;
- rollback anotado;
- next gate unico.

## Stop Condition

`no_evidence`, `no_elevation`, `base_windows_at_risk`, `target_ambiguous`, `live_write_by_inference`
