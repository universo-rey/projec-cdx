# SDU G8.4 - Controlled Historical Migration ADX to Expediente

Fecha: 2026-06-25 18:20 ART
Modo: WRITE CONTROLADO / NO DELETE / NO MASS OPERATION
Entorno: HUBDesarrollo

## Dictamen

PASS.

Se migro el historico ADX acotado hacia `cr3c_expediente` sin borrar ni modificar los registros ADX existentes. La operacion quedo limitada a 5 `activityId` unicos, con `GET before POST`, backreference explicita y un solo `sharepointdocumentlocation` nuevo por expediente migrado.

## Preflight

- DocumentLocations iniciales: 10
- DocumentLocations ADX: 6
- `activityId` ADX unicos: 5
- Limite de operacion controlada: 5
- Resultado: dentro de limite, no mass operation

## Metadata

Se agrego y valido el campo de backreference:

- Entidad: `cr3c_expediente`
- Campo: `cr3c_adxactivityid`
- Schema: `cr3c_AdxActivityId`
- Tipo: `String`

Nota: el POST de metadata se ejecuto una sola vez. El primer readback fallo por consultar `MaxLength` sobre `AttributeMetadata`; no se repitio el POST, luego se valido el campo con metadata compatible.

## Mapping Creado

| activityId | expedienteId | targetDocumentLocationId | sourceDLCount | residual |
|---|---|---|---:|---|
| `25862f01-5470-f111-ab0e-000d3a340906` | `b39f750a-db70-f111-ab0e-000d3a340f50` | `d575780d-db70-f111-ab0e-000d3a340906` | 1 | no |
| `5a35472d-cd70-f111-ab0e-000d3a340b69` | `f675780d-db70-f111-ab0e-000d3a340906` | `1a76780d-db70-f111-ab0e-000d3a340906` | 1 | no |
| `ad6d3381-5070-f111-ab0e-000d3a340906` | `e759dc0b-db70-f111-ab0e-000d3a340b69` | `6076780d-db70-f111-ab0e-000d3a340906` | 1 | no |
| `d4f4dbac-5370-f111-ab0e-000d3a340b69` | `c78ad911-db70-f111-ab0e-000d3a340b69` | `d98ad911-db70-f111-ab0e-000d3a340b69` | 2 | PRE_FIX ADX preservado |
| `f22fbb06-77bc-42ff-8b97-0efc0cfb31d2` | `f08ad911-db70-f111-ab0e-000d3a340b69` | `7e529213-db70-f111-ab0e-000d3a340906` | 1 | no |

## Validacion Final

- Total DocumentLocations: 15
- ADX DocumentLocations: 6
- Expediente DocumentLocations: 9
- Expedientes migrados con backreference: 5
- DuplicateGroups total: 1
- DuplicateGroups en `cr3c_expediente`: 0
- Residual: `PRE_FIX_ADX_SOURCE_PRESERVED`
- Watchdog: YELLOW
- `locationsReviewed`: 15
- Graph failures: 0
- Non-info failed checks: 0

El estado YELLOW queda explicado por checks informativos de estructura de carpetas (`folder_structure_hints`) sin bloqueo operativo.

## Evidencia

- Preflight: `C:\CEO\watchdog\evidence\g8_4_migration_preflight_20260625_181205.json`
- Metadata readback: `C:\CEO\watchdog\evidence\g8_4_backreference_metadata_readback_20260625_181339.json`
- Migracion: `C:\CEO\watchdog\evidence\g8_4_historical_migration_20260625_181544.json`
- Watchdog top=25: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_181743.json`
- Validacion final: `C:\CEO\watchdog\evidence\g8_4_historical_migration_validation_20260625_182014.json`

## Confirmaciones

- Sin DELETE
- Sin PATCH/PUT
- Sin carpetas nuevas
- Sin flows
- Sin scheduler
- Sin push
- Sin PR
- ADX historico preservado
- Loop base no modificado en esta fase

## Proximo Paso

G8.5 recomendado: estabilizar cobertura del watchdog para que el `top` operativo ya no quede en 10 cuando el sistema supera ese volumen. Opcion de bajo riesgo: actualizar `config.sharepoint-link.json` con `sharePointLink.top = 25` y registrar evidencia, sin tocar logica del script.
