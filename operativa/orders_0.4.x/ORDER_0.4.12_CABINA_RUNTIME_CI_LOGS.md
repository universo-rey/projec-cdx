# ORDER 0.4.12 - Cabina runtime CI logs

## Estado
READY_FOR_REMOTE_LOG_COLLECTION_GATE

## Source gate
0.3.13

## Fuente
Varios correos reportan fallos del workflow `SDU Agent Runtime Connections Validation`; las snippets no contienen logs tecnicos suficientes para identificar la causa exacta.

## Target repo
universo-rey/cabina-universal-d

## Target workflow
SDU Agent Runtime Connections Validation

## Objetivo
Preparar recoleccion remota futura de logs del workflow para clasificar causa real sin rerun ni mutacion.

## Acciones esperadas cuando el owner autorice
- Recopilar logs remotos del workflow.
- Sanear evidencia de logs antes de registrarla.
- Mapear fallos a gates 0.4.0-0.4.8 cuando haya evidencia suficiente.
- Mantener `UNKNOWN_CI_FAILURE` si los logs no alcanzan.
- No inferir causa desde snippets de correo.

## Prohibido
- Inferir causa sin logs.
- Rerun de workflow.
- Workflow dispatch.
- Push.
- PR.
- Remote write.
- Lectura de secretos.

## Owner required
true

## Rollback
No aplica a lectura de logs. Si se genera evidencia incorrecta, descartar evidencia local y repetir lectura bajo gate.

## Postcheck
- Logs recopilados y saneados.
- Causa clasificada solo con evidencia tecnica suficiente.
- Fallos mapeados a gates 0.4.0-0.4.8 o marcados como `UNKNOWN_CI_FAILURE`.
- Sin rerun, push, PR ni workflow dispatch.

## Evidencia local
- operativa/READBACK_GATE_0.3.13_CABINA_RUNTIME_CI_TRIAGE_20260622.md
- operativa/GATE_0.3.13_CABINA_RUNTIME_CI_TRIAGE_MATRIX_20260622.csv
- operativa/SDU_0.4.x_REMOTE_PATCH_WAVE_MATRIX_20260622.csv

## Resultado
GATE_0.4.12_READY_FOR_REMOTE_LOG_COLLECTION_GATE
