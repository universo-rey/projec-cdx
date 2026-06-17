# Normalizacion Perfil Windows

Patron para reconciliar un perfil Windows cuando `Desktop`, `Pictures` o `Documents` se desalinean entre local, OneDrive y junctions.

Subpatrones:
- [Junctions / compatibilidad](C:/Users/enzo1/PROJEC%20CDX/patrones/perfil-windows-junctions-compatibilidad.md)
- [Snapshots / GMT](C:/Users/enzo1/PROJEC%20CDX/patrones/perfil-windows-snapshots-gmt.md)

## Senales

- `User Shell Folders` y `Shell Folders` no coinciden.
- Explorer muestra rutas a OneDrive aunque el contenido ya vive local.
- Hay junctions de compatibilidad o rutas heredadas bajo `C:\Users\enzo1`.
- Aparece `@GMT` y alguien lo trata como carpeta editable.

## Regla

1. Tratar la ruta visible como indicio, no como verdad.
2. Resolver primero la superficie real: local, OneDrive o snapshot.
3. Normalizar al perfil local cuando esa sea la decision confirmada.
4. Mantener compatibilidad solo si una app o acceso heredado la necesita.
5. Cerrar con postcheck de rutas resueltas y sync.

## Salida

Un perfil legible, con carpetas conocidas en rutas locales y compatibilidad controlada.

## Rehidratacion y readback

- Rehidratar la superficie antes de cada ejecucion nueva.
- Cerrar cada wave con un readback corto y una senal atomica.
- La senal atomica debe decir: que cambio, que quedo listo y cual es el siguiente delta.

## Stop Condition

- Origen o destino ambiguos.
- Se confunde snapshot con superficie activa.
- Una junction no puede validarse.
- La compatibilidad exige una excepcion no aprobada.
