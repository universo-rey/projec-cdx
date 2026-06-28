# Ancla Cierre Wave Dataverse

Ancla corta para waves de cierre cuando el frente toca Dataverse.

Se abre solo desde [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md) cuando el delta pide Dataverse.

## Orden

1. Leer `dataverse/GATE.md`.
2. Leer `dataverse/README.md`.
3. Leer `dataverse/MAPA.md`.
4. Leer `operativa/START_HERE_CIERRE_WAVE.md`.
5. Leer `recipes/cierre-wave-documental.md`.
6. Leer `procesos/cierre-wave-documental.md`.

## Regla

- Dataverse no se toca live sin orden explicita.
- Metadata-only y evidencia local si no hay target claro.
- Si aparece write live, volver al gate con `target`, `owner`, `rollback`, `postcheck` y `evidencia`.

## Flujo

1. Clasificar el delta.
2. Confirmar si es metadata-only, preparado o live.
3. Reflejar solo la superficie tocada.
4. Si hace falta, versionar la salida en hito.
5. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Stop Condition

- Falta gate.
- Falta target.
- Falta evidencia.
- Se intenta inferir write live.
