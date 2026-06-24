# Hito 20260616 - Normalizacion Perfil Windows v1

Wave de normalizacion del perfil Windows con rehidratacion, readback y señal atomica por cierre.

## Alcance

- `Desktop`
- `Pictures`
- `Documents`
- Junctions de compatibilidad bajo `C:\Users\enzo1`
- Rutas heredadas de OneDrive y referencias `@GMT`

## Estado

- `GREEN_LOCAL`: perfil local alineado y canon reusable creado.
- `COMPATIBILITY_PRESERVED`: junctions heredadas se conservaron donde fueron necesarias.
- `VISIBLE_RESULT`: la regla de rehidratacion/readback/explosion quedo canonizada.

## Evidencia

- [READBACK.md](C:/Users/enzo1/PROJEC%20CDX/hitos/20260616-normalizacion-perfil-windows-v1/READBACK.md)
- [INDICE.csv](C:/Users/enzo1/PROJEC%20CDX/hitos/20260616-normalizacion-perfil-windows-v1/INDICE.csv)
- [MANIFEST.yaml](C:/Users/enzo1/PROJEC%20CDX/hitos/20260616-normalizacion-perfil-windows-v1/MANIFEST.yaml)
- [operativa/archive/legacy-root/undated/ENTRENAMIENTO_AGENTES_NORMALIZACION_PERFIL_WINDOWS.md](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/undated/ENTRENAMIENTO_AGENTES_NORMALIZACION_PERFIL_WINDOWS.md)
- [recipes/normalizacion-perfil-windows.md](C:/Users/enzo1/PROJEC%20CDX/recipes/normalizacion-perfil-windows.md)
- [procesos/normalizacion-perfil-windows.md](C:/Users/enzo1/PROJEC%20CDX/procesos/normalizacion-perfil-windows.md)

## Regla

- No volver a inferir local/OneDrive/snapshot sin leer rutas resueltas y claves de shell.
