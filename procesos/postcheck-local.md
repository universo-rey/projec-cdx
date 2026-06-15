# Postcheck Local

## Entrada

Delta ejecutado.

## Pasos

1. Ejecutar `tools/validate_proj_cdx_workbench.ps1`.
2. Revisar `PASS`, `OBSERVED` o `FAIL`.
3. Corregir enlaces o mapas si corresponde.
4. Registrar evidencia en `TRACE` o readback.

## Salida

Cierre validado.

## Stop Condition

`validator_not_run`, `link_broken`, `required_map_missing`
