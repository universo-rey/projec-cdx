# Mapa de Packages

Vista unica de los paquetes comprimidos de soporte de `PROJEC CDX`.

## Contenido

| Paquete | Rol | SHA-256 | Contenido |
| --- | --- | --- | --- |
| `codex_evolutionary_blueprint_package.zip` | Fuente/base | `8E7E7F0B218E5A8E6E052C3CE159BDAA4B3406A106C3D9E22AACB6B8C3114739` | 13 entradas: plan, blueprint, matrices, memoria, metricas, riesgos y readback. |
| `codex_evolutionary_runtime_activation_v2.zip` | Activacion | `556A97298B9B3EFD3D8A02F3B9E58086EA7224BEB88C58FA9FDAAFB3E7748AD2` | 6 entradas: delta runtime, gate matrix, manifest y correccion de activacion. |

## Lectura

- `packages/` es el canon visible del workbench.
- `.codex/workpapers/codex_evolutionary/99_archive/source_zips/` es espejo exacto de archivo.
- Los ZIPs se conservan como paquetes fuente y de activacion, no como salidas generadas ni como runtime activo.

## Regla

- No crear nuevos paquetes si existe hito, readback o indice vigente que cubra el delta.
- Para reducir ruido, inspeccionar ZIPs por hash e indice interno antes de cualquier extraccion.
- Si cambia el paquete fuente, se actualiza el artefacto comprimido, este mapa y el README.
