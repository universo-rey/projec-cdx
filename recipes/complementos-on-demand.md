# Complementos On Demand

Receta reusable para abrir complementos desde `PROJEC CDX` sin mezclar acceso, acceso rapido y permiso live.

## Cuándo Usarla

Cuando el pedido requiera:

- ver los complementos disponibles;
- abrir un complemento concreto;
- confirmar si un plugin o MCP directo existe;
- evitar inventar acceso que no esta documentado.

## Derivación

1. Leer `operativa/archive/legacy-root/undated/COMPLEMENTOS_ON_DEMAND.md`.
2. Confirmar la fuente canonica en `.codex/CAPACIDADES.md`.
3. Diferenciar `MCP directos` de `Plugins activos`.
4. Abrir solo el complemento pedido por el delta.
5. Si no existe, marcar `NO_DISPONIBLE`.
6. Si el complemento necesita superficie externa, exigir gate explicit o detener.
7. Registrar el cierre en `TRACE.md` cuando la apertura sea parte de una wave.

## Salida

Indice rapido de complementos, con acceso claro y sin confundir disponibilidad con habilitacion de escritura.

## Stop Condition

- Falta fuente canonica.
- Falta validador.
- Se intenta usar un complemento como atajo a live write.
- Se inventa un complemento o MCP no existente.
