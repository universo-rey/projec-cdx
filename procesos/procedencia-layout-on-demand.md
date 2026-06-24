# Procedencia Layout On Demand

## Entrada

Delta recurrente que debe quedar documentado como procedencia tecnica, acceso on-demand o nota visible compacta.

## Pasos

1. Leer `operativa/CURRENT.md`, `operativa/TRACE.md` y `operativa/archive/legacy-root/undated/ANCLAS_ON_DEMAND.md`.
2. Identificar si el delta afecta configuracion interna, ancla o nota visible.
3. Clasificar la superficie como visible, referencia, on-demand o live.
4. Mover la procedencia tecnica a la capa de referencia si no debe quedar al frente.
5. Mantener la superficie visible corta y sin lenguaje que sugiera habilitacion live.
6. Abrir la pieza concreta solo desde `operativa/archive/legacy-root/undated/ANCLAS_ON_DEMAND.md`.
7. Registrar el cambio en las superficies afectadas.
8. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Salida

Notas y anclas coherentes, con la procedencia tecnica aislada de la lectura visible.

## Stop Condition

`no_evidence`, `no_validator`, `live_write_by_inference`, `secret_or_state_touch`
