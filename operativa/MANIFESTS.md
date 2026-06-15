# Manifests

Politica local para registrar salidas durables de `PROJEC CDX`.

## Regla

Todo paquete, hito, workbook generado o corrida relevante debe tener manifest o indice equivalente.

## Minimo

- `id`
- `fecha`
- `superficie`
- `tipo`
- `fuente`
- `salida`
- `estado`
- `rollback`
- `postcheck`
- `evidencia`

## Ubicacion

- Hitos: `hitos/YYYYMMDD-nombre-vN/MANIFEST.yaml`.
- Outputs: `outputs/<corrida>/README.md` y `outputs/<corrida>/MAPA.md`.
- Workbooks: entrada en `workbooks/EXCEL_AL_FRENTE.md`.
- Operativa: cierre en `operativa/TRACE.md`.

## Regla De Segundo Orden

Cuando un hito padre absorbe hitos hijos o de segundo orden, el padre tambien debe declarar esas referencias en su README, manifest, indice y readback para no perder el arbol versionado.

## Estado Permitido

- `draft`
- `prepared`
- `verified`
- `closed`
- `blocked`

## Nota

El manifest documenta evidencia local. No autoriza live writes ni lectura de secretos.
