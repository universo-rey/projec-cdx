# Resolucion de Outputs 20260615

## Estado

`RESUELTO`

## Criterio

- Las corridas visibles son salidas generadas, no fuentes canónicas.
- `control_operativo_20260615` es la corrida principal de control para esta ronda.
- `dataverse_blocker_frontier_20260614` es la corrida de bloqueos y fronteras.
- `cabina_relationship_audit_20260614` y `universe_relationship_audit_20260614` son evidencias de auditoria.
- `handoffs` guarda continuidad y paquetes de traspaso.

## Que Se Toma De Cada Uno

### `control_operativo_20260615`

- `control_operativo.xlsx`
- `control_operativo.xlsx.inspect.ndjson`
- `resumen.png`, `registro.png`, `listas.png`
- `inspect_*.ndjson`
- `formula_errors.ndjson`

### `dataverse_blocker_frontier_20260614`

- `dataverse_blocker_frontier.xlsx`
- `README.md`
- `MAPA.md`
- `READBACK.md`
- `build_dataverse_blocker_frontier.py`

### `cabina_relationship_audit_20260614` y `universe_relationship_audit_20260614`

- Evidencia de auditoria y relacion entre superficies.
- Se toman para comparar, no para redefinir canon.

### `handoffs`

- Continuidad entre sesiones.
- Se toma cuando hay que reanudar sin perder el hilo.

## Regla de Uso

- Si la salida es evidencia, queda en `outputs`.
- Si la salida ya tiene equivalente vivo, la corrida no manda sobre la fuente.
- Si hay que cerrar una decision, se reutiliza la evidencia y se versiona el cierre.
