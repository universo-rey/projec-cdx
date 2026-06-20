# Gate Dataverse

Gate local para cualquier trabajo Dataverse desde `PROJEC CDX`.

## Jerarquia

- Gobierno: `C:\CEO`.
- Entrada canonica: `C:\CEO\project-cdx`.
- Workspace fisico real: `C:\Users\enzo1\PROJEC CDX`.
- Familia: `dataverse/`.

Este gate solo gobierna la familia Dataverse. No reemplaza el plan rector ni convierte Dataverse en autoridad raiz.

Plan rector: `docs/superpowers/plans/2026-06-19-plan-rector-cobertura-total.md`.
Plan de familia visible: `docs/superpowers/plans/2026-06-19-dataverse-familia-cobertura.md`.

## Permitido Sin Nueva Orden

- leer evidencia local ya materializada
- mapear skills, outputs, readbacks e inventarios
- preparar plan metadata-only
- registrar bloqueos y stop conditions
- declarar Dataverse como fuente canonica esperada de una matriz, sin consultar ni escribir live
- ejecutar `pac help`, `pac auth list` y `pac env who` solo cuando el target exacto ya esta declarado

## Requiere Orden Explicita

- `pac auth`
- `pac env fetch`
- cualquier lectura live distinta de `pac env who` con target exacto ya declarado
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
