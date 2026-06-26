# Readback Rehidratacion Dataverse Desde Paquetes 20260617

Estado: `DATAVERSE_REHYDRATION_LIVE_READ_CONFIRMED`.
Modo: `LIVE_READ_ONLY`.
Fecha: `2026-06-17`.
Live read ejecutado: `SI`.
Live write ejecutado: `NO`.
Codex Cloud task creada: `NO`.
Secretos impresos: `NO`.

## Orden

Corregir la cola porque SGIN ya fue leido y paquetizado. Rehidratar el carril
desde Dataverse antes de seguir.

Correccion posterior del owner: Dataverse ya estaba escrito, por lo tanto el
carril no podia quedar atrasado como `metadata_only`. Se ejecuto live read
solo-GET sobre las filas ya conocidas.

## Anclajes Leidos

- `dataverse/README.md`
- `dataverse/GATE.md`
- `dataverse/MAPA.md`
- `dataverse/ANCLA_REHIDRATACION.md`
- `dataverse/REGISTRO_CODEX_CLOUD_20260615.md`
- `operativa/archive/legacy-root/20260616/READBACK_SGIN_OBSERVED_READ_ONLY_20260616.md`
- `operativa/archive/legacy-root/20260617/READBACK_MICROSOFT_SGIN_HITOS_DOCUMENTAL_20260617.md`
- `hitos/20260617-microsoft-sgin-hitos-documental-v1`
- `operativa/archive/legacy-root/20260617/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`

## Clasificacion

| Superficie | Estado |
| --- | --- |
| SGIN lectura | `OBSERVED_READ_ONLY` |
| SGIN paquete documental | `MICROSOFT_SGIN_HITOS_CONSOLIDATED` |
| Dataverse lane | `live_rows_confirmed` |
| Codex Cloud Dataverse bridge | `validated_metadata_only` |
| Live Dataverse | `LIVE_READ_ONLY_CONFIRMED` |

## Postcheck Live

Ambiente: `HUBDesarrollo`.
Org: `https://org084965d9.crm.dynamics.com/`.
Environment ID: `7f65fc04-c27a-ea0d-bd2d-266aa9203c1e`.

Lectura ejecutada con `tools/read_dataverse_rehydration_live.ps1`.

Resultado: `5/5` parejas `source_artifact_registry/evidence_registry`
confirmadas con conteo exacto `1/1`.

## Nomenclatura Viva Confirmada

| Rol SDU | LogicalName | EntitySetName | PrimaryIdAttribute | PrimaryNameAttribute |
| --- | --- | --- | --- | --- |
| `source_artifact_registry` | `mon_sdu_source_artifact` | `mon_sdu_source_artifacts` | `mon_sdu_source_artifactid` | `mon_display_name` |
| `evidence_registry` | `mon_sdu_evidence` | `mon_sdu_evidences` | `mon_sdu_evidenceid` | `mon_display_name` |

`Completed` corresponde a `mon_status`, columna string del modelo SDU. El
estado nativo Dataverse queda separado: `statecode=0` / `statuscode=1`, ambos
con etiqueta `Activo`.

Canonical ids confirmados:

- `sdu:manifesto:escribania-bitsch:20260616:v1`
- `sharepoint:seshat-home:20260616:v1`
- `sharepoint:corte-proposito:20260616:v1`
- `sharepoint:corte-agent-index:20260617:v1`
- `sharepoint:binding-ui-seshat-home-atomos:20260617:v1`

## Decision

El siguiente movimiento unico es:

`delta_select_next_consumer_from_dataverse_live_rows`

No reabrir lectura SGIN. No reempaquetar SGIN. No volver a clasificar
Dataverse como `metadata_only` para estos atomos. La siguiente accion es elegir
la superficie consumidora exacta de las filas vivas confirmadas.

## Guardrails

- Cualquier write posterior vuelve al gate con ambiente, org, target, owner,
  rollback, postcheck y evidencia.
- No inferir writes desde la lectura live.
- No abrir documentos sensibles.
- No ejecutar flows.
- No escribir Dataverse sin orden explicita.

## Rollback

Revertir este readback, la matriz
`operativa/archive/legacy-root/20260617/REHIDRATACION_DATAVERSE_DESDE_PAQUETES_20260617.csv`, los cambios en
`CURRENT.md`, `NEXT.md`, `PENDIENTES_HOY_20260617.md`, `TRACE.md` y el hito
`20260617-rehidratacion-dataverse-desde-paquetes-v1`.
