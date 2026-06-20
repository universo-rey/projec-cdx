# READBACK_DATA_ANALYTICS_WAVE_PROJEC_CDX_CONTROL_PLANE_20260620

## Estado

`WAVE_EJECUTADA_CON_DELTA_DETECTADO`

## Hecho

- Data Analytics quedo con capa semantica local: `C:\Users\enzo1\.codex\skills\projec-cdx-semantic-layer`.
- Polling semanal creado: `Semantic Layer Weekly Source Polling`.
- Hilo dedicado fijado: `019ee27c-f1c7-7400-8321-3d161299b2c0`.
- Readback de automatizacion: `kind=heartbeat`, `status=ACTIVE`, `target_thread_id=019ee27c-f1c7-7400-8321-3d161299b2c0`.
- Kickoff enviado al hilo dedicado.
- Reporte de wave creado: `outputs\data_analytics_wave_projec_cdx_control_plane_20260620\report.html`.

## Evidencia

- Workbook vigente abre correctamente: `workbooks\CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`.
- Workbook detectado con `56` hojas, incluyendo repos, ramas, Codex Cloud, agentes, entornos, colas, skills, recetas, tools, conexiones, Dataverse y matrices atomicas.
- `tools\validate_proj_cdx_operational_chain.ps1` devuelve `FAIL` por:
  - `chain_csv_exists`
  - `schema_csv_exists`
- En la misma validacion pasan:
  - `dataverse_source_map_exists`
  - `atomic_matrix_exists`

## Semaforo

| Frente | Estado | Lectura |
| --- | --- | --- |
| Data Analytics setup | VERDE | Capa semantica, polling, readback y kickoff activos. |
| Workbook decision surface | VERDE | Workbook abre y cubre las capas principales. |
| Dataverse local family | VERDE_GOBERNADO | Cubierto por plan/gate; sin write live. |
| Validador operational chain | AMARILLO | Mira CSV legacy faltantes aunque fuentes actuales existen. |
| Git/dirty state | AMARILLO | `main` esta `ahead 4` y hay muchos cambios mezclados. |

## Delta Siguiente

`validator_points_to_legacy_missing_csv`

Resolver `tools\validate_proj_cdx_operational_chain.ps1` para que consuma fuentes vigentes o declare parametros legacy con fallback actual.

## Stop Condition

No abrir matrices nuevas ni rehidratar inventario base. Cerrar esta wave cuando el validador deje de fallar por rutas legacy o cuando el owner decida conservar ese fallo como frontera historica documentada.
