# Complementos On Demand

## Entrada

Pedido de acceso, listado o verificacion de complementos disponibles en la sesion.

## Pasos

1. Leer `operativa/COMPLEMENTOS_ON_DEMAND.md`.
2. Leer `operativa/ANCLAS_ON_DEMAND.md` si el complemento se usa dentro de una wave.
3. Abrir `CAPACIDADES.md` y `CAPACIDADES.reference.md` como canon de capacidad.
4. Clasificar si el pedido necesita MCP directo o plugin.
5. Abrir solo el complemento minimo necesario.
6. Si no aparece en la fuente canonica, marcar `NO_DISPONIBLE`.
7. Si el complemento toca una superficie live, exigir gate y orden gobernada.
8. Validar con `tools/validate_proj_cdx_workbench.ps1` si el cambio toca docs del repo.

## Salida

Acceso claro a complementos, con lista corta, fuente canonica y stop conditions.

## Stop Condition

`no_evidence`, `no_validator`, `live_surface_without_order`, `invented_capability`
