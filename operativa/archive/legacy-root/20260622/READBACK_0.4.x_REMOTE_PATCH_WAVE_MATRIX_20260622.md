# SDU 0.4.x REMOTE PATCH WAVE MATRIX

## Estado
SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_READY

## Archivo rector
operativa/archive/legacy-root/20260622/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Reconciliacion aplicada
La matriz 0.4.x queda normalizada con el esquema de wave remota:

- gate_id
- target_version
- source_gate
- priority
- target_repo
- surface
- issue
- source_email_ref
- patch_type
- external_write_required
- live_surface_required
- owner_required
- rollback_required
- postcheck_required
- evidence_required
- decision
- order_file
- expected_result

## Alcance
Se materializa la wave 0.4.x como paquete local de decision y autorizacion futura.

La matriz incluye:

- 0.4.0 a 0.4.3 como prioridad P0.
- 0.4.4 a 0.4.8 como prioridad P1.
- 0.4.9 a 0.4.11 como prioridad P2 para SDU-CN.
- 0.4.12 como gate de recoleccion remota de logs.

## Frontera conservada
- No push.
- No PR.
- No workflow_dispatch.
- No Dataverse live.
- No Microsoft live.
- No SharePoint live.
- No Power Platform mutation.
- No OpenAI live.
- No Codex Cloud execution.
- No lectura de secretos.

## Validacion local
- Sentinel scan: WARN esperado por doc drift local del recorte.
- Auto-remediation analyze: PASS.
- Sentinel check: PASS.
- Metadata validate: OK.
- Tests: PASS.
- git diff --check: PASS.

## Resultado
READY_FOR_0.4.x_ORDER_MATERIALIZATION
