# 04 - Validar Delta

Validacion local posterior a cada delta de `PROJEC CDX`.

## Objetivo

Probar que el cambio quedo navegable, coherente y sin enlaces rotos evidentes.

## Checklist

- La raiz sigue siendo `C:\Users\enzo1\PROJEC CDX`.
- Los archivos nuevos tienen entrada desde el mapa correspondiente.
- `README.md` y `MAPA_MAESTRO.md` no duplican detalle innecesario.
- Los links absolutos principales resuelven con `Test-Path`.
- Si hay workbook, el archivo `.xlsx` abre como ZIP valido.
- Si hay formulas, `formula_errors.ndjson` queda sin hallazgos.
- Si hay Dataverse, no se ejecuto live sin gate explicito.

## Validador

Ejecutar:

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_workbench.ps1"
```

## Stop Conditions

- `link_broken`
- `required_map_missing`
- `workbook_invalid`
- `formula_error_detected`
- `dataverse_gate_violation`
- `unexpected_external_write`

## Salida

- Estado: `PASS`, `OBSERVED` o `FAIL`.
- Evidencia exacta.
- Correccion aplicada o bloqueo registrado.
