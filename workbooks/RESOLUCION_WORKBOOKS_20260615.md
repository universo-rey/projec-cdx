# Resolucion de Workbooks 20260615

## Estado

`RESUELTO`

## Criterio

- `control_operativo.xlsx` es el workbook maestro de control punta a punta.
- `inicio.xlsx` queda como workbook de entrada / arranque.
- `tracker.xlsx` queda como workbook de seguimiento derivado.
- `control_operativo.xlsx.inspect.ndjson` queda como evidencia de inspeccion del export.

## Que Se Toma De Cada Uno

### `control_operativo.xlsx`

- Seguimiento operativo principal.
- Estructura de control, registro, alertas y listas.
- Fuente prioritaria cuando haya que revisar estado o cerrar un delta.

### `inicio.xlsx`

- Arranque o inicio de flujo.
- Fuente de entrada para hilos nuevos o readbacks iniciales.

### `tracker.xlsx`

- Seguimiento derivado.
- Útil para continuidad, pero no manda sobre `control_operativo.xlsx`.

## Regla de Uso

- Si la pregunta es por control, manda `control_operativo.xlsx`.
- Si la pregunta es por inicio, manda `inicio.xlsx`.
- Si la pregunta es por seguimiento derivado, usa `tracker.xlsx`.
