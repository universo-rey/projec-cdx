# ORDER 0.4.7 - Synthetic harness fixture

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.19

## Fuente
Correo indica que el eval falla por import de harness no resoluble y que falta el fixture `normalized_runtime_assets.json`.

## Target repo
universo-rey/cabina-universal-d

## Target probable
- .agents/codex/evals/SOURCE_TCU_RUNTIME_run_controlled_runtime_harness_eval.py
- .agents/codex/tools/SOURCE_TCU_RUNTIME_tcu_controlled_runtime_harness.py
- .agents/codex/07_FIXTURES_SANITIZED/normalized_runtime_assets.json

## Objetivo
Preparar patch remoto para que el eval synthetic harness pueda resolver el import del harness y operar con fixture sanitizado.

## Patch esperado
- Corregir import path.
- Anadir fixture sanitizado `normalized_runtime_assets.json`.
- O agregar fallback controlado si el fixture no existe.
- Test local del harness con fixture sanitizado.

## Prohibido
- Ejecutar remoto.
- Push.
- PR.
- Workflow dispatch.
- Leer secretos.
- Usar datos live.

## Owner required
true

## Rollback
Revertir patch de import, fixture y test local en el repo destino.

## Postcheck
- Eval resuelve import del harness.
- Fixture `normalized_runtime_assets.json` existe o fallback controlado queda documentado.
- Harness local corre con fixture sanitizado sin datos live.

## Evidencia local
- operativa/GATE_0.3.19_LOCAL_SYNTHETIC_HARNESS_PACKET_20260622.md
- operativa/GATE_0.3.19_LOCAL_SYNTHETIC_HARNESS_MATRIX_20260622.csv
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.7_READY_FOR_REMOTE_PATCH_AUTHORIZATION
