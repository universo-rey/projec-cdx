# Documentos Canon Atomico

Receta reusable para convertir una superficie documental en atlas + canon + registro sin perder cronologia ni mezclar snapshot con material reusable.

## Cuando Usarla

Usar esta receta cuando una carpeta como `Documents\Codex` o una superficie pesada tenga:

- cronologia por fecha;
- snapshots o indices de rastreo;
- evidencia repetida;
- necesidad de canon reusable;
- un siguiente delta claro para waves posteriores.

## Flujo

1. Inventariar la raiz visible y separar top-level de subcarpetas.
2. Marcar cada entrada como `cronologia`, `snapshot`, `evidencia`, `reusable` o `soporte`.
3. Extraer el canon solo desde evidencias repetidas o validadas.
4. Publicar el atlas en `README` y `MAPA`.
5. Guardar el indice nominal de la raiz visible.
6. Cerrar con readback corto y un unico siguiente delta.

## Guardrails

- No convertir cronologia en canon por defecto.
- No mover evidencia sin rollback.
- No mezclar indexacion con transformacion.
- No abrir live write por inferencia.

## Salida

Atlas corto, canon reusable, indice navegable y siguiente paso unico.

## Stop Condition

- La raiz visible no esta inventariada.
- El canon no tiene criterio de repeticion.
- Falta ruta visible para el delta siguiente.
