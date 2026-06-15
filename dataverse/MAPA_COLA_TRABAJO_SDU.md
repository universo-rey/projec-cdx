# Mapa De Cola De Trabajo SDU

Surface de colas SDU confirmada para `HUBDesarrollo`.

## Fuente

- `C:\Users\enzo1\.codex\matrices\sdu\SDU_ENVIRONMENT_CAPABILITY_MAP.csv`
- `C:\Users\enzo1\.codex\matrices\sdu\SDU_QUEUE_IDENTITY_RECONCILIATION.csv`
- `C:\Users\enzo1\PROJEC CDX\dataverse\ACTA_CORTE_EJECUTORA_20260615.md`

## Base De Cola

- `workqueue`
- `workqueueitem`

## Cola Operativa Principal

- `SDU.Dataverse.Apply.Queue`
- Worker: `SDU_Process_Dataverse_Apply_Work_Items`
- Workflow id: `65468687-515f-f111-a826-00224805fc91`
- Estado operativo: `packet known / no-op listo already active`

## Colas SDU Confirmadas

- `SDU.Matrix.Intake.Queue`
- `SDU.Connection.Seed.Queue`
- `SDU.Dataverse.Apply.Queue`
- `SDU.Drift.Detection.Queue`
- `SDU.Gate.Review.Queue`
- `SDU.Exception.Remediation.Queue`
- `SDU.Evidence.Publish.Queue`
- `SDU.Agent.Dispatch.Queue`

## Lectura Operativa

- La cola de trabajo se gobierna por nombre canonico, no por inferencia de id.
- `SDU.Matrix.Intake.Queue` tiene drift de id entre snapshots, pero el nombre canonico se conserva.
- El apply worker sigue siendo el carril local conocido para la corte ejecutora.
- No hay live write nuevo solo por registrar esta superficie.

## Criterio

Si se agrega una cola nueva, debe entrar con nombre canonico, evidencia de origen, id por entorno y estado postcheckeado.
