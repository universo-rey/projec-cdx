# Hito 20260616 - Perfil Windows Canon v1

Bundle corto que reúne el perfil Windows ya normalizado como canon reusable.

## Alcance

- Patron de normalizacion de perfil Windows.
- Subpatron de junctions y compatibilidad.
- Subpatron de snapshots y `@GMT`.
- Nota de entrenamiento para agentes.

## Estado

- `GREEN_LOCAL`: canon reusable del perfil Windows.
- `FINAL_ATOMIC_SIGNAL`: cierre compacto, verificable y listo para reusar.
- `NO_LIVE_WRITE`: no se tocaron live ni secretos.

## Evidencia

- [patrones/normalizacion-perfil-windows.md](C:/Users/enzo1/PROJEC%20CDX/patrones/normalizacion-perfil-windows.md)
- [patrones/perfil-windows-junctions-compatibilidad.md](C:/Users/enzo1/PROJEC%20CDX/patrones/perfil-windows-junctions-compatibilidad.md)
- [patrones/perfil-windows-snapshots-gmt.md](C:/Users/enzo1/PROJEC%20CDX/patrones/perfil-windows-snapshots-gmt.md)
- [operativa/archive/legacy-root/undated/ENTRENAMIENTO_AGENTES_NORMALIZACION_PERFIL_WINDOWS.md](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/undated/ENTRENAMIENTO_AGENTES_NORMALIZACION_PERFIL_WINDOWS.md)
- [hitos/20260616-normalizacion-perfil-windows-v1/README.md](C:/Users/enzo1/PROJEC%20CDX/hitos/20260616-normalizacion-perfil-windows-v1/README.md)
- [hitos/20260616-normalizacion-perfil-windows-v1/READBACK.md](C:/Users/enzo1/PROJEC%20CDX/hitos/20260616-normalizacion-perfil-windows-v1/READBACK.md)

## Regla

- No volver a inferir superficie activa, junction o snapshot sin rehidratar, leer y validar el delta.
