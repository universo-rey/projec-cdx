# Metodo Operativo

Forma corta de trabajar `PROJEC CDX`.

## Idea

Una sola unidad activa por vez, con evidencia antes de cierre.

## Secuencia

1. Leer `CONTROL.md`, `CURRENT.md`, `NEXT.md`, `BLOCKERS.md` y `TRACE.md`.
2. Declarar una sola unidad de trabajo en `NEXT.md`.
3. Mover esa unidad a `CURRENT.md`.
4. Ejecutar el playbook minimo correspondiente.
5. Registrar salida y evidencia en `TRACE.md` y en el workbook.
6. Si el cierre es durable, versionar en `hitos/`.
7. Validar con `tools/validate_proj_cdx_workbench.ps1`.
8. Si aparece aprendizaje estable, promoverlo a `patrones/` o `procesos/`.

## Reglas

- No abrir dos unidades activas a la vez.
- No dar por cerrado nada sin validacion fresca.
- No promover a live por inferencia.
- Si hay bloqueo, nombrarlo con target, impacto, rollback, postcheck y evidencia.

## Resultado

La mesa queda retomable por otro hilo sin depender de la conversacion.
