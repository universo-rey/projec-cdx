# Patron SDU Dataverse Metadata Wave

## Forma

Una wave metadata-only convierte observacion viva en energia reusable para agentes:

`tenant -> evidencia -> metadata atomica -> skill/receta/proceso -> validador -> proximo delta`

## Reglas

- Una frontera por wave.
- Una matriz por wave.
- Un readback de cierre.
- Un rollback aunque no haya write.
- Un postcheck aunque solo sea local.
- Un proximo delta unico.

## Antipatrones

- Repetir `live/vivo` cuando no hay nueva lectura.
- Llamar `confirmado` a una inferencia.
- Guardar nombres sensibles si bastan IDs/conteos.
- Mezclar SGIN con todo Microsoft.
- Convertir metadata en permiso de ejecucion.
