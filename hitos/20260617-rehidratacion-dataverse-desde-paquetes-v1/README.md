# Rehidratacion Dataverse Desde Paquetes v1

Estado: `DATAVERSE_REHYDRATION_LIVE_READ_CONFIRMED`.

Hito de correccion y continuidad: SGIN ya fue leido y paquetizado. El carril se
actualizo con live read porque Dataverse ya contenia los atomos escritos.

El resultado confirmado es `live_rows_confirmed`: `5/5` parejas
`source_artifact_registry/evidence_registry` devuelven conteo exacto `1/1` en
Dataverse.

Nomenclatura viva:

- `source_artifact_registry`: `LogicalName=mon_sdu_source_artifact`,
  `EntitySetName=mon_sdu_source_artifacts`.
- `evidence_registry`: `LogicalName=mon_sdu_evidence`,
  `EntitySetName=mon_sdu_evidences`.
- `Completed` es `mon_status`; `Activo` es `statecode/statuscode` nativo.

## Evidencia

- `operativa/READBACK_REHIDRATACION_DATAVERSE_DESDE_PAQUETES_20260617.md`
- `operativa/REHIDRATACION_DATAVERSE_DESDE_PAQUETES_20260617.csv`
- `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`
- `tools/read_dataverse_rehydration_live.ps1`
- `dataverse/ANCLA_REHIDRATACION.md`
- `dataverse/GATE.md`

## Siguiente

`delta_select_next_consumer_from_dataverse_live_rows`
