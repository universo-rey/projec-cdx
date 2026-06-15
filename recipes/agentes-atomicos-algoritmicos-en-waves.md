# Agentes Atomicos Algoritmicos En Waves

Receta reusable para delegar trabajo en waves cortas usando agentes atomicos algoritmicos.

## Cuándo Usarla

Cuando un delta se puede repartir en lanes pequenas y disjuntas, con retorno exacto y fan-in claro.

Se abre desde `operativa/ANCLAS_ON_DEMAND.md` cuando el pedido pide delegacion por waves.

## Derivación

1. Identificar el delta real y el resultado esperado.
2. Partir el trabajo en una sola wave util.
3. Definir un solo agente por lane.
4. Fijar `orden`, `scope`, `evidence`, `validator`, `rollback` y `fan_in`.
5. Elegir el complemento minimo solo si hace falta.
6. Mantener cada lane disjunta de las demas.
7. Exigir retorno exacto antes de abrir otra wave.
8. Registrar la salida en `TRACE.md` si la wave deja aprendizaje durable.
9. Validar con el validador local.

## Reglas

- La wave no se infla.
- El agente no inventa estado ni disponibilidad.
- Si el scope crece, se corta en una wave nueva.
- Si falta evidencia, no se promueve.
- Si falta fan-in, no se cierra.

## Salida

Delegacion por waves con energia util concentrada, evidencia clara y cierre gobernado.

## Stop Condition

- Falta scope disjunto.
- Falta retorno exacto.
- Falta evidencia o validador.
- Se intenta mezclar lanes o abrir frentes paralelos.
