# ORDER 0.4.0 - Bridge auth validator hardening

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.10

## Fuente
Correo indica que el validador puede contar la definicion `function assertDevAuth(req)` como si fuera llamada real, permitiendo falso PASS si una ruta protegida pierde su guard.

## Target repo
universo-rey/cabina-universal-d

## Target file probable
local-agent-bridge/src/localActions.mjs

## Objetivo
Preparar patch remoto para validar llamadas reales de `assertDevAuth(req)` por bloque de ruta protegida.

## Rutas minimas
- `/v1/shell/command`
- `/v1/sdu/route`

## Prohibido
- Contar definicion de funcion como cobertura.
- Abrir bridge.
- Abrir puerto.
- Leer token.
- Hacer push.
- Abrir PR.
- Ejecutar workflow dispatch.

## Patch esperado
- Parser o regex por route block.
- Assert explicito por ruta.
- Exclusion explicita de `function assertDevAuth(req)` del conteo de cobertura.
- Test negativo: si una ruta pierde guard, el validator falla.

## Owner required
true

## Rollback
Revertir patch remoto del validator y cualquier test agregado en el repo destino.

## Postcheck
- `/v1/shell/command` se valida individualmente.
- `/v1/sdu/route` se valida individualmente.
- La definicion de `assertDevAuth(req)` no cuenta como llamada real.
- Validator falla si una ruta protegida queda sin guard.

## Evidencia local
- operativa/GATE_0.3.10_BRIDGE_AUTH_VALIDATOR_PATCH_PACKET_20260622.md
- operativa/GATE_0.3.10_BRIDGE_AUTH_VALIDATOR_PATCH_MATRIX_20260622.csv
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.0_READY_FOR_REMOTE_PATCH_AUTHORIZATION
