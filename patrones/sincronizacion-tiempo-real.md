# Sincronizacion Tiempo Real

## Regla

Toda modificacion relevante debe reflejarse sin demora en la superficie visible, la corrida generada y el cierre versionado que le corresponda.

## Alcance

- `workbooks/` como fuente viva.
- `outputs/` como evidencia generada.
- `hitos/` como versionado durable.
- `operativa/` como control y trazabilidad.
- `README.md` y `MAPA_MAESTRO.md` como entrada visible.
- `dataverse/` como carril propio, pero solo en local, metadata-only o live gateado.

## Uso

Aplicar cuando una fuente cambia y otra superficie queda desalineada.

## Fuente

- `workbooks/README.md`
- `outputs/README.md`
- `hitos/README.md`
- `operativa/CONTROL.md`
- `dataverse/GATE.md`

## Salida

- Superficies declaradas.
- Corrida regenerada si corresponde.
- Hito versionado si el cambio es durable.
- Validador local en `PASS`.
- Dataverse sigue sin inferencia live si no hay orden explicita.

## Stop Conditions

- `source_surface_changed_without_visible_update`
- `output_surface_desynced`
- `hito_missing_for_durable_change`
