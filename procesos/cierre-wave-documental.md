# Cierre Wave Documental

## Entrada

Delta documental nuevo, archivo nuevo o hito nuevo que debe quedar absorbido por capas.

Se abre desde `operativa/ANCLAS_ON_DEMAND.md` cuando el delta pide el proceso ejecutable.

## Pasos

1. Leer `CONTROL.md`, `CURRENT.md`, `NEXT.md` y `TRACE.md`.
2. Identificar el delta nuevo real.
3. Clasificar si entra en un archivo existente o si requiere hito nuevo.
4. Si hay archivo compañero, crear o actualizar la matriz o workbook visible.
5. Reflejar el cambio en `README.md`, `MAPA.md`, `README_CORTO.md` y `MAPA_CORTO.md` cuando corresponda.
6. Registrar salida y evidencia en `TRACE.md`.
7. Actualizar `CURRENT.md` si el delta ya cerró.
8. Versionar en `hitos/` si la salida es durable.
9. Actualizar los indices visibles de `hitos/`, `procesos/` y `recipes/`.
10. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Salida

Cierre navegable, versionado y listo para continuar sin repetir el patrón manual.

## Stop Condition

`no_evidence`, `no_validator`, `live_write_by_inference`
