# Normalizacion Perfil Windows

Complementa la [receta](C:/Users/enzo1/PROJEC%20CDX/recipes/normalizacion-perfil-windows.md) y el [patron](C:/Users/enzo1/PROJEC%20CDX/patrones/normalizacion-perfil-windows.md).

## Entrada

Un perfil Windows con rutas conocidas mezcladas entre local, OneDrive y junctions.

## Pasos

1. Registrar el estado inicial de `User Shell Folders` y `Shell Folders`.
2. Resolver `Desktop`, `Pictures` y `Documents` con la ruta real del sistema.
3. Inspeccionar junctions y accesos heredados dentro de `C:\Users\enzo1`.
4. Definir que va a local y que debe quedarse sincronizado.
5. Copiar el contenido al destino local confirmado.
6. Reconciliar cambios, mover el remanente y dejar respaldo temporal.
7. Reescribir rutas conocidas al destino canónico sin cambiar la identidad de la carpeta.
8. Validar compatibilidad con las apps que dependan de la ruta vieja.
9. Cerrar con postcheck y evidencia corta.

## Salida

Perfil normalizado, rutas coherentes y compatibilidad preservada donde fue necesario.

## Validador

- La ruta resuelta de `Desktop`, `Pictures` y `Documents` coincide con el destino esperado.
- `User Shell Folders` y `Shell Folders` quedaron alineados.
- No hay junctions rotas ni referencias cruzadas innecesarias.
- OneDrive ya no captura la carpeta que se movio a local, salvo excepcion confirmada.

## Readback final

- Decir que quedo local, que quedo sincronizado y que quedo como compatibilidad.
- Cerrar con una sola señal atomica: cambio, estado y proximo delta.

## Stop Conditions

- El target final no esta confirmado.
- El contenido esta en uso o bloqueado.
- La reescritura rompe compatibilidad y no hay ruta alternativa aprobada.
- El cambio depende de una decision sobre OneDrive que aun no existe.
- Aparece una junction o redireccion heredada que no se puede validar.

## Entrenamiento para agentes futuros

- No asumir que el perfil visible es el perfil real.
- Verificar siempre rutas resueltas, claves de shell y estado de sync antes de mover.
- No mover `Desktop`, `Pictures`, `Documents` ni junctions sin confirmar origen, destino y rollback.
