# ORDER 0.4.4 - Governance CI paths

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.16

## Fuente
Correo indica que el validador cubre `governance/canon/CABINA_FULL_AUTOMATION_BY_PLANES.md`, pero los filtros del workflow no incluyen `governance/canon/**`, por lo que CI podria no dispararse.

## Target repo
universo-rey/cabina-universal-d

## Objetivo
Preparar patch remoto para asegurar que cambios en canon de gobierno disparan los validadores correspondientes.

## Patch esperado
- Anadir `governance/canon/**` o equivalente a workflow path filters.
- Asegurar que cambios en `governance/canon/CABINA_FULL_AUTOMATION_BY_PLANES.md` disparan validadores.
- Mantener cobertura existente para governance/canon/manifests sin duplicar workflows.

## Prohibido
- Workflow dispatch.
- Push.
- PR.
- Modificar remoto sin owner gate.
- Leer secretos.

## Owner required
true

## Rollback
Revertir cambios de workflow path filters en el repo destino.

## Postcheck
- Cambio bajo `governance/canon/**` dispara validacion.
- Cambio en `governance/canon/CABINA_FULL_AUTOMATION_BY_PLANES.md` queda cubierto.
- No se ejecuta workflow dispatch desde este gate.

## Evidencia local
- operativa/GATE_0.3.16_GOVERNANCE_CI_PATH_COVERAGE_PACKET_20260622.md
- operativa/GATE_0.3.16_GOVERNANCE_CI_PATH_COVERAGE_MATRIX_20260622.csv
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.4_READY_FOR_REMOTE_PATCH_AUTHORIZATION
