# ORDER 0.4.11 - SDU-CN validator CI

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.8

## Fuente
Correo indica que un validador live-activation no esta registrado en manifest/CI, por lo que artefactos gobernados podrian omitirse y la validacion seguir pasando.

## Target repo
SeshatSgin/seshat-bootstrap-sdu-cn

## Objetivo
Preparar patch remoto para registrar y ejecutar el validator live-activation dentro de la cadena real de validacion.

## Cambios esperados
- Registrar validator en manifests.
- Cablear validator en `ci/validate_repo.ps1`.
- Asegurar que workflow `validate.yml` lo ejecuta.
- Bloquear PASS si artefactos gobernados quedan omitidos.

## Prohibido
- Workflow dispatch.
- Remote write sin owner gate.
- Push.
- PR.
- Lectura de secretos.
- Simular ejecucion del validator.

## Owner required
true

## Rollback
Revertir registro en manifests, cableado en `ci/validate_repo.ps1` y cambios en `validate.yml` si el owner autoriza ejecucion remota y luego decide volver al estado anterior.

## Postcheck
- Validator live-activation figura en manifests.
- `ci/validate_repo.ps1` invoca el validator.
- `validate.yml` ejecuta la cadena que incluye el validator.
- Artefactos gobernados omitidos hacen fallar la validacion.

## Evidencia local
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv
- operativa/orders_0.2.x/ORDER_0.2.4_SDU_CN_ISSUE_PREP_REMOTE_ALIGNMENT.md

## Resultado
GATE_0.4.11_READY_FOR_REMOTE_PATCH_AUTHORIZATION
