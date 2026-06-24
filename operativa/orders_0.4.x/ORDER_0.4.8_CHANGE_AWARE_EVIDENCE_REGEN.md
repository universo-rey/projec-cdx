# ORDER 0.4.8 - Change-aware evidence regen

## Estado
READY_FOR_REMOTE_REGEN_AUTHORIZATION

## Source gate
0.3.20

## Fuente
Correo indica que el audit change-aware no coincide con `git show --name-only`: el array registra menos archivos que el commit evidenciado.

## Target repo
universo-rey/cabina-universal-d

## Objetivo
Preparar regeneracion remota futura de audit change-aware contra commit objetivo, con comparacion completa entre `changed_files` y `git show --name-only`.

## Patch esperado
- Regenerar audit change-aware contra commit objetivo.
- Comparar `changed_files` vs `git show --name-only`.
- No marcar PASS si hay omisiones.
- Registrar missing files y decision explicita cuando el array quede incompleto.

## Prohibido
- Remote regen sin owner gate.
- Push.
- PR.
- Workflow dispatch.
- Lectura de secretos.
- Marcar PASS con omisiones.

## Owner required
true

## Rollback
Revertir evidencia regenerada si no coincide con target commit o indice registrado.

## Postcheck
- `changed_files` coincide con `git show --name-only`.
- No quedan omisiones no declaradas.
- PASS queda bloqueado si el array registra menos archivos que el commit evidenciado.

## Evidencia local
- operativa/archive/legacy-root/20260622/GATE_0.3.20_CHANGE_AWARE_EVIDENCE_REFRESH_PACKET_20260622.md
- operativa/archive/legacy-root/20260622/GATE_0.3.20_CHANGE_AWARE_EVIDENCE_REFRESH_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.8_READY_FOR_REMOTE_REGEN_AUTHORIZATION
