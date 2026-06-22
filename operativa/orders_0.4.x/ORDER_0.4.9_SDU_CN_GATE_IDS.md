# ORDER 0.4.9 - SDU-CN gate IDs

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.6

## Fuente
Correo indica que los IDs en prompt SDU-CN no coinciden con `gates/gates.yaml`, y otro correo marca inconsistencia `G16_GITHUB_ISSUE_PREPARATION_REQUIRED` vs `G27_GITHUB_ISSUE_PREPARATION_REQUIRED`.

## Target repo
SeshatSgin/seshat-bootstrap-sdu-cn

## Objetivo
Preparar patch remoto para alinear gate IDs entre prompt, manifest, `gates/gates.yaml` y CI sin inventar gate IDs.

## Patch esperado
- Leer `gates/gates.yaml` como fuente canonica de gate IDs.
- Comparar prompt SDU-CN contra `gates/gates.yaml`.
- Comparar manifest contra `gates/gates.yaml`.
- Comparar CI/validators contra `gates/gates.yaml`.
- Resolver la inconsistencia `G16_GITHUB_ISSUE_PREPARATION_REQUIRED` vs `G27_GITHUB_ISSUE_PREPARATION_REQUIRED` usando solo el ID canonico existente.
- Bloquear PASS si prompt/manifest/CI usan IDs no presentes en `gates/gates.yaml`.

## Prohibido
- Inventar gate ID.
- Elegir G16 o G27 por inferencia.
- Push.
- PR.
- Workflow dispatch.
- Remote write sin owner gate.
- Lectura de secretos.

## Owner required
true

## Rollback
Revertir cambios remotos en prompt, manifest, `gates/gates.yaml` o CI si el owner autoriza ejecucion remota y luego decide volver al estado anterior.

## Postcheck
- Prompt SDU-CN usa solo gate IDs presentes en `gates/gates.yaml`.
- Manifest usa solo gate IDs presentes en `gates/gates.yaml`.
- CI/validators usan solo gate IDs presentes en `gates/gates.yaml`.
- La inconsistencia G16/G27 queda resuelta sin crear IDs nuevos.

## Evidencia local
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv
- operativa/orders_0.2.x/ORDER_0.2.4_SDU_CN_ISSUE_PREP_REMOTE_ALIGNMENT.md

## Resultado
GATE_0.4.9_READY_FOR_REMOTE_PATCH_AUTHORIZATION
