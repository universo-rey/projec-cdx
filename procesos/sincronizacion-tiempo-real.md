# Sincronizacion Tiempo Real

## Entrada

Cambio en una superficie viva o pedido de alineacion total.

## Pasos

1. Detectar la superficie fuente.
2. Actualizar la entrada visible correspondiente.
3. Regenerar la corrida en `outputs/` si la fuente es un workbook o un artefacto generado.
4. Versionar en `hitos/` si el cambio es durable.
5. Si el cambio toca Dataverse, leer `dataverse/GATE.md` y clasificar local, metadata-only o live gateado.
6. Ejecutar el validador local de sincronizacion.
7. Dejar readback con evidencia.

## Salida

`workbooks/`, `outputs/`, `hitos/` y `operativa/` quedan alineados en la misma version operativa.
`dataverse/` queda alineado solo por evidencia local o metadata-only, salvo gate explicito para live.

## Validador

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_sync.ps1"
```

## Stop Conditions

- `source_surface_changed_without_visible_update`
- `output_surface_desynced`
- `hito_missing_for_durable_change`
- `live_surface_without_order`
- `validator_not_run`
