# Dataverse Rehidratacion

Receta para volver a tomar contexto Dataverse cuando un hilo se alarga o se pierde continuidad.

## Cuándo Usarla

Cuando el frente Dataverse ya tiene evidencia local, pero el hilo necesita volver a la base sin reconstruir todo.

## Derivación

1. Leer `hitos/20260615-sincronizacion-tiempo-real-v1/README.md`.
2. Leer `dataverse/INDICE_DATAVERSE.md`.
3. Leer `dataverse/GATE.md`, `dataverse/README.md` y `dataverse/MAPA.md`.
4. Leer `operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md` si la wave se va a repartir en agentes.
5. Si el delta toca archivo, leer `hitos/INDICE_MAESTRO.md` y `hitos/_archivo/README.md` antes de mover nada.
6. Clasificar el estado como `local_evidence`, `metadata_only`, `prepared_not_executed`, `live_rows_confirmed` o `blocked`.
7. Si el siguiente paso sigue abierto, volver a la ancla corta y a `operativa/TRACE.md`.
8. Si hace falta salida durable, versionarla en `hitos/`.

## Salida

Contexto recuperado, carril reducido y siguiente delta visible sin confundir evidencia con live.

Si el frente ya quedo absorbido, el archivo vive en `hitos/_archivo/` y el semaforo historico sigue como hito propio.

## Stop Condition

- Falta gate.
- Falta evidencia.
- Falta target exacto.
- Se intenta inferir live sin orden explicita.
