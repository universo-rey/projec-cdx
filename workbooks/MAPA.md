# Mapa de Workbooks

Vista unica de los libros de trabajo visibles de `PROJEC CDX`.

La wave visible mas reciente queda absorbida en [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

Los workbooks gobernados deben poder leer fase, impulso y estado terminal.

## Contenido

- `RESOLUCION_WORKBOOKS_20260615.md`
- `EXCEL_AL_FRENTE.md`
- `control_operativo.xlsx`
- `control_operativo.xlsx.inspect.ndjson`
- `inicio.xlsx`
- `tracker.xlsx`

## Lectura

- `EXCEL_AL_FRENTE.md` trae al frente fuentes vivas y salidas Excel generadas.
- `control_operativo.xlsx` es el workbook de seguimiento punta a punta con hojas `Resumen`, `Registro`, `Alertas` y `Listas`.
- `control_operativo.xlsx.inspect.ndjson` conserva inspeccion automatica del export.
- Son libros visibles de apoyo.
- Las corridas generadas equivalentes viven en `outputs/` por fecha y corrida.
- `tracker_workbook.xlsx` es una variante alterna de tracker, no el espejo directo de `workbooks/tracker.xlsx`.

## Regla

- Si cambia una fuente, se actualiza el workbook y su corrida equivalente.
