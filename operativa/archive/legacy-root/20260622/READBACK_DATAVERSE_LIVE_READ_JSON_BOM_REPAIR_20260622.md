# DATAVERSE LIVE READ JSON BOM REPAIR 20260622

## Estado
DATAVERSE_LIVE_READ_JSON_PARSE_STABLE_LOCAL

## Archivos actualizados
- `tools/update_codex_config_workbook.py`
- `tests/test_dataverse_json_encoding.py`
- `operativa/archive/legacy-root/20260622/DATAVERSE_LIVE_READ_JSON_ENCODING_AUDIT_20260622.csv`

## Evidencia local
- `operativa/archive/legacy-root/20260617/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json` existe.
- El archivo actual no contiene BOM UTF-8.
- El parse local funciona con `utf-8` y `utf-8-sig`.

## Decision
No se reescribe la evidencia JSON porque no necesita reparacion fisica. Se endurece el lector local para tolerar evidencia futura con BOM.

## Frontera
- No se leyo Dataverse live.
- No se escribio Dataverse.
- No se regenero workbook.
- No se abrio ningun externo.
