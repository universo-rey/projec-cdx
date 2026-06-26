# Ancla Energia Atomica

Ancla minima para introducir el elemento atomico energetico en una wave.

Se abre solo desde [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/undated/ANCLAS_ON_DEMAND.md) cuando el delta pide cobertura energetica.

## Orden

1. Leer `operativa/archive/legacy-root/20260615/COBERTURA_ATOMICA_ENERGETICA_20260615.md`.
2. Leer `atomic/CODEX_ATOMIC_OPERATING_CONTRACT.md`.
3. Leer `operativa/archive/legacy-root/20260615/NOMENCLATURA_CADENA_OPERATIVA_20260615.md`.
4. Leer la superficie concreta que se va a gobernar.
5. Declarar `atomic_energy_phase` y `atomic_next_impulse`.
6. Reflejar la energia en la entrada visible minima.
7. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Regla

- No se replica energia por costumbre.
- La superficie gobernada debe decir como arranca y como cierra.
- Si la superficie es generada, basta con referenciar el contrato.

## Stop Condition

- Falta fase atomica.
- Falta proximo impulso.
- Se intenta imponer el mismo encabezado a una superficie generada.
- Se toca live por inferencia.
