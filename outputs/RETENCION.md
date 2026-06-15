# Retencion De Outputs

Regla para corridas dentro de `outputs/`.

## Mantener

- Corridas enlazadas desde `outputs/README.md` y `outputs/MAPA.md`.
- Workbooks exportados y sus inspecciones si validan formulas o layout.
- Imagenes de render cuando prueban legibilidad.
- `formula_errors.ndjson` cuando exista.

## Compactar Solo Con Orden

No borrar ni mover salidas sin orden explicita. Si se compacta:

- conservar README/MAPA,
- registrar que se movio,
- dejar ruta nueva,
- validar links.

## Estado

`outputs/` queda como evidencia historica, no como carpeta de trabajo activa.
