# Readback

Estado: `DATAVERSE_REHYDRATION_LIVE_READ_CONFIRMED`.

SGIN ya fue leido y paquetizado. La cola queda corregida hacia Dataverse vivo:
las filas `source_artifact_registry/evidence_registry` ya escritas fueron
leidas en `HUBDesarrollo` y confirmadas con conteo `1/1`.

Nomenclatura confirmada: `mon_sdu_source_artifact` ->
`mon_sdu_source_artifacts`; `mon_sdu_evidence` -> `mon_sdu_evidences`.
`mon_status=Completed` y estado nativo Dataverse `Activo`.

Siguiente delta:

`delta_select_next_consumer_from_dataverse_live_rows`
