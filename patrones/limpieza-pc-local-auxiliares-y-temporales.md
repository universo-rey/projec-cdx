# Limpieza PC Local Auxiliares Y Temporales

## Uso

Aplicar solo sobre ruido ya clasificado como auxiliar o temporal y dentro de rutas aprobadas.

## Regla

Se puede recortar lo descartable, no lo estructural. Si el item puede afectar perfil, repos, sincronizacion, credenciales o rastros utiles, no se toca.

## Hacer

- Limpiar temporales locales del usuario o de la app, siempre por ruta exacta.
- Recortar caches y restos efimeros que no sostengan trabajo abierto ni evidencia.
- Deshabilitar auxiliares solo si el nombre exacto ya fue aprobado.
- No tocar `C:\Windows`, instaladores, perfiles completos, repositorios, `node_modules`, sincronizacion ni artefactos de auditoria.
- Si falta certeza sobre el origen o la reversibilidad, parar.

## Salida

Menos ruido, sin alterar la base ni abrir una dependencia nueva.

## Stop Condition

`path_not_approved`, `rollback_missing`, `evidence_at_risk`
