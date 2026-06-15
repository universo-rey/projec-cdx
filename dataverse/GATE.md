# Gate Dataverse

Gate local para cualquier trabajo Dataverse desde `PROJEC CDX`.

## Permitido Sin Nueva Orden

- leer evidencia local ya materializada
- mapear skills, outputs, readbacks e inventarios
- preparar plan metadata-only
- registrar bloqueos y stop conditions
- declarar Dataverse como fuente canonica esperada de una matriz, sin consultar ni escribir live

## Requiere Orden Explicita

- `pac auth`
- `pac env fetch`
- cualquier lectura live
- cualquier import, update, patch, activation o flow run
- cambio en Power Platform, Dataverse, Power Automate o ambiente Microsoft
- confirmar filas live de la matriz fuente sin ambiente y target exactos

## Datos Minimos Antes De Live

- ambiente exacto
- org exacta
- target exacto
- owner
- rollback
- postcheck
- evidencia esperada
- stop condition

## Stop Conditions

- `wrong_environment_or_default`
- `target_identity_ambiguous`
- `metadata_only`
- `rows_absent`
- `rollback_missing`
- `postcheck_missing`
- `secret_detected`
