# ORDER 0.4.2 - Power Automate validator

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.5

## Fuente
Correo indica que un readback marca evidencia `ready` mientras el validador Power Automate figura como `NO_DISPONIBLE`; pide proveer/ejecutar validador o degradar el cierre a `blocked`.

## Target repo
universo-rey/cabina-universal-d

## Target artifacts
- readbacks/runtime/READBACK_DEV_RUNTIME_CONTROLLED_ACTIVATION.md
- validation/runtime/*
- matrices/runtime/*

## Objetivo
Preparar patch remoto para impedir que un cierre `ready` quede aprobado sin validador Power Automate efectivo o equivalente estructural.

## Decision esperada
- Si validador existe: wire + ejecutar.
- Si no existe: structural parse equivalente.
- Si no hay ninguno: downgrade `ready` a `blocked`.

## Prohibido
- Flow execution.
- Power Platform mutation.
- Dataverse live.
- Lectura de secretos.
- Hacer push.
- Abrir PR.
- Ejecutar workflow dispatch.

## Owner required
true

## Rollback
Revertir wiring del validator o restaurar el readback previo si el owner lo autoriza.

## Postcheck
- Validator especifico se ejecuta cuando existe.
- Structural parse equivalente queda explicitamente identificado si reemplaza al validator.
- `ready` no pasa con validator `NO_DISPONIBLE`.
- No se ejecuta flow ni mutacion Power Platform.

## Evidencia local
- operativa/archive/legacy-root/20260622/GATE_0.3.5_POWER_AUTOMATE_VALIDATOR_PATCH_PACKET_20260622.md
- operativa/archive/legacy-root/20260622/GATE_0.3.5_POWER_AUTOMATE_VALIDATOR_PATCH_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.2_READY_FOR_REMOTE_PATCH_AUTHORIZATION
