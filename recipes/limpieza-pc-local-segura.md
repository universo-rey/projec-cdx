# Limpieza PC Local Segura

Receta reusable para reducir ruido en una PC Windows local sin tocar la base del sistema ni superficies live.

## Subpatrones

- [Inventario y gate](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-inventario-y-gate.md)
- [Auxiliares y temporales](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-auxiliares-y-temporales.md)
- [Evidencia y rollback](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-evidencia-y-rollback.md)

## Cuando Usarla

Usar esta receta cuando el delta pida:

- diagnosticar lentitud, duplicacion o ruido de arranque;
- limpiar temporales locales autorizados;
- cerrar o desactivar auxiliares aprobados por nombre exacto;
- recortar la superficie de busqueda local;
- cerrar con evidencia, rollback y un unico siguiente gate.

## Flujo

1. Aplicar [inventario y gate](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-inventario-y-gate.md).
2. Aplicar [auxiliares y temporales](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-auxiliares-y-temporales.md).
3. Cerrar con [evidencia y rollback](C:/Users/enzo1/PROJEC%20CDX/patrones/limpieza-pc-local-evidencia-y-rollback.md).

## Guardrails

- No tocar `C:\Windows`, Defender, Windows Update ni servicios base por inferencia.
- No borrar repos, `.git`, `node_modules`, credenciales ni tokens.
- No cerrar procesos con trabajo abierto.
- No convertir este flujo en una escritura live sin orden explicita.

## Salida

PC mas gobernable, con ruido recortado y evidencia reusable.

## Stop Condition

- Falta el gate de inventario.
- El recorte toca base Windows.
- Falta evidencia o rollback.
- El proximo gate no es unico.
