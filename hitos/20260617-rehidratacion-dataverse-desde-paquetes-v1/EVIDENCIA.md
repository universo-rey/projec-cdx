# Evidencia

- `dataverse/README.md`, `dataverse/GATE.md`, `dataverse/MAPA.md` y
  `dataverse/ANCLA_REHIDRATACION.md` releidos.
- SGIN lectura confirmada en `operativa/READBACK_SGIN_OBSERVED_READ_ONLY_20260616.md`.
- SGIN paquete documental consolidado en `hitos/20260617-microsoft-sgin-hitos-documental-v1`.
- Live read Dataverse ejecutado en `HUBDesarrollo` sobre
  `mon_sdu_source_artifacts` y `mon_sdu_evidences`.
- Evidencia JSON: `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`.
- Herramienta de lectura: `tools/read_dataverse_rehydration_live.ps1`.
- Resultado: `5/5` parejas `source_artifact_registry/evidence_registry`
  confirmadas con conteo `1/1`.
- Nomenclatura confirmada: `mon_sdu_source_artifact` usa endpoint
  `mon_sdu_source_artifacts`; `mon_sdu_evidence` usa endpoint
  `mon_sdu_evidences`.
- Estado SDU: `mon_status=Completed`. Estado nativo Dataverse:
  `statecode=0/statuscode=1`, etiqueta `Activo`.

No hubo live write, flow run, task Cloud ni secretos impresos.
