# Normalizacion Perfil Windows

Receta corta para normalizar un perfil Windows con OneDrive, rutas conocidas y junctions, sin romper compatibilidad.

Patron asociado: [Normalizacion Perfil Windows](C:/Users/enzo1/PROJEC%20CDX/patrones/normalizacion-perfil-windows.md).

Subpatrones asociados:
- [Junctions / compatibilidad](C:/Users/enzo1/PROJEC%20CDX/patrones/perfil-windows-junctions-compatibilidad.md)
- [Snapshots / GMT](C:/Users/enzo1/PROJEC%20CDX/patrones/perfil-windows-snapshots-gmt.md)

## Primero revisar

1. `User Shell Folders`.
2. `Shell Folders`.
3. Junctions y enlaces bajo `C:\Users\enzo1`.
4. Accesos heredados de OneDrive.
5. Estado real de `Desktop`, `Pictures` y `Documents` por ruta resuelta, no por supuesto.

## Movimiento seguro

1. Confirmar la ruta origen y la ruta destino exactas.
2. Copiar primero el contenido, no mover en seco.
3. Verificar que el destino local exista y quede fuera de la zona sincronizada si ese es el objetivo.
4. Validar que no haya archivos bloqueados, en uso o con conflicto de sync.
5. Recién entonces mover el remanente.
6. Mantener una copia de respaldo hasta pasar el postcheck.

## Reescritura de rutas

1. Reescribir las rutas conocidas con el valor canónico local aprobado.
2. Mantener compatibilidad con rutas expandibles cuando aplique.
3. No tocar nombres ni GUIDs de carpetas conocidas si solo cambia el destino.
4. Si una app espera la ruta vieja, dejar compatibilidad mediante redireccionamiento controlado o junction validada, no por inferencia.
5. Reiniciar o cerrar sesion solo si la ruta queda consistente y el postcheck lo exige.

## Postcheck

- `User Shell Folders` y `Shell Folders` apuntan al destino esperado.
- `Desktop`, `Pictures` y `Documents` resuelven a la ruta correcta.
- No quedan junctions rotas.
- OneDrive no sigue capturando la carpeta que se queria sacar del sync.
- El contenido original no quedo duplicado ni perdido.

## Rehidratacion y readback

- Rehidratar la superficie antes de cada ejecucion nueva.
- Cerrar cada wave con un readback corto y una senal atomica.
- La senal atomica debe decir: que cambio, que quedo listo y cual es el siguiente delta.

## Stop Conditions

- Ruta origen o destino ambigua.
- Hay conflicto de sincronizacion activo.
- Aparecen junctions que no se entienden.
- La carpeta esta en uso por una app critica.
- La compatibilidad requiere una excepcion que no fue confirmada.

## Explosion en el resultado

- El cierre tiene que dejar un resultado visible, no una nota tibia.
- Priorizar salidas claras, navegables y accionables.
- Si el cambio no se ve ni se entiende de inmediato, falta un delta o falta readback.

## Entrenamiento corto

- No asumir que `Desktop` o `Documents` viven bajo `%USERPROFILE%`.
- Verificar siempre la ruta resuelta y la clave de shell antes de editar.
- No mover carpetas conocidas, junctions ni contenido heredado sin confirmacion del target final.
