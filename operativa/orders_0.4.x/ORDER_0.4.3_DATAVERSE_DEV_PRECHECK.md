# ORDER 0.4.3 - Dataverse DEV precheck

## Estado
READY_FOR_REMOTE_PATCH_AUTHORIZATION

## Source gate
0.3.4

## Fuente
Correo indica dos riesgos: el precheck puede pasar con PAC auth activo apuntando a entorno equivocado, y dry-run import puede requerir readiness DEV aunque `apply=false`.

## Target repo
universo-rey/cabina-universal-d

## Target files probables
- dataverse/scripts/precheck_dataverse_environment.ps1
- .github/workflows/dataverse-import-dev.manual.yml
- dataverse/scripts/import_solution_dev.ps1

## Objetivo
Preparar patch remoto para validar el entorno PAC activo exacto antes de apply y separar el dry-run no mutante cuando `apply=false`.

## Patch esperado
- Verificar active PAC environment contra `EnvironmentUrl`, `EnvironmentId` y `Profile`.
- Si `apply=false`, permitir dry-run sin `RequireDevReady`.
- Postcheck dry-run local.
- `apply` sigue bloqueado sin DEV ready explicito.

## Prohibido
- PAC live.
- Solution import/export.
- Dataverse write.
- Lectura de secretos.
- Hacer push.
- Abrir PR.
- Ejecutar workflow dispatch.

## Owner required
true

## Rollback
Revertir patch remoto del precheck/import y restaurar comportamiento anterior.

## Postcheck
- Precheck falla si el PAC activo no coincide con `EnvironmentUrl`, `EnvironmentId` o `Profile`.
- Dry-run con `apply=false` no exige `RequireDevReady`.
- Dry-run no muta.
- `apply=true` sigue bloqueado sin DEV ready explicito.

## Evidencia local
- operativa/archive/legacy-root/20260622/GATE_0.3.4_DATAVERSE_DEV_PRECHECK_PATCH_PACKET_20260622.md
- operativa/archive/legacy-root/20260622/GATE_0.3.4_DATAVERSE_DEV_PRECHECK_PATCH_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.3_READY_FOR_REMOTE_PATCH_AUTHORIZATION
