# Agentes Atomicos Algoritmicos En Waves

## Entrada

Delta que conviene partir en waves cortas con agentes disjuntos y retorno exacto.

Se abre desde `operativa/ANCLAS_ON_DEMAND.md` cuando el pedido requiere delegacion gobernada.

## Pasos

1. Leer `operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md`.
2. Leer `recipes/agentes-atomicos-algoritmicos-en-waves.md`.
3. Identificar el delta real y el fan-in esperado.
4. Definir una sola wave util.
5. Asignar un agente por lane con `orden`, `scope`, `evidence`, `validator`, `rollback` y `fan_in`.
6. Ejecutar la wave sin abrir frentes paralelos.
7. Validar el retorno de cada lane.
8. Si el delta crece, abrir una wave nueva.
9. Registrar la salida y el aprendizaje en `TRACE.md` si aplica.
10. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Salida

Wave delegada, verificable y cerrada con fan-in claro.

## Stop Condition

`no_evidence`, `no_validator`, `scope_not_disjoint`, `fan_in_missing`, `parallel_lanes_opened`
