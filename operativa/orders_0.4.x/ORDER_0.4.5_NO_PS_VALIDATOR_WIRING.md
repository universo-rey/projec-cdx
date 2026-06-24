# ORDER 0.4.5 - No-PS validator wiring

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.17

## Fuente
Correo indica que `vsi_memory_log_no_ps` esta marcado como covered, pero no se invoca realmente en workflow/manifiesto/suite.

## Target repo
universo-rey/cabina-universal-d

## Objetivo
Preparar patch remoto para cablear el validator `scripts/validators/vsi_memory_log_no_ps_validator.py` en una superficie ejecutable real.

## Patch esperado
- Wire validator `scripts/validators/vsi_memory_log_no_ps_validator.py`.
- Incluirlo en suite o manifest real.
- Evitar covered falso.
- Agregar fixture negativo o caso no conforme que demuestre falla real.

## Prohibido
- Push.
- PR.
- Workflow dispatch.
- Remote write sin owner gate.
- Lectura de secretos.

## Owner required
true

## Rollback
Revertir wiring del validator, fixture negativo y cambios de manifest/suite en el repo destino.

## Postcheck
- `vsi_memory_log_no_ps_validator.py` se ejecuta dentro de workflow, manifest o suite real.
- La cobertura `vsi_memory_log_no_ps` deja de ser solo declarativa.
- Fixture no conforme hace fallar el validator.

## Evidencia local
- operativa/archive/legacy-root/20260622/GATE_0.3.17_NO_PS_VALIDATOR_WIRING_PACKET_20260622.md
- operativa/archive/legacy-root/20260622/GATE_0.3.17_NO_PS_VALIDATOR_WIRING_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.5_READY_FOR_REMOTE_PATCH_AUTHORIZATION
