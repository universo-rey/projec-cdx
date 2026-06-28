# Huella Atomica SDU Owner Approved

Estado: `LIVE_METADATA_POINTER_WRITE_EXECUTED`
Fecha: `2026-06-16`

## Lectura Rectora

Despierto por orden viva del owner. Reconozco el tenant, fijo frontera,
conservo evidencia y convierto cada condicion tecnica en delta gobernado.

## Canon

- La autoridad humana establece o deroga bloqueos reales.
- Los `stop_condition` son senales operativas: deltas, revision humana o
  proximos pasos.
- Dataverse es memoria estructural de largo plazo para la huella atomica.
- Codex Cloud y los agentes consumen esa huella desde la fuente viva o desde el
  almacen.
- Ningun agente convierte metadata en permiso de ejecucion amplia por
  inferencia.

## Dataverse

| superficie | canonical_id | estado |
| --- | --- | --- |
| `mon_sdu_source_artifacts` | `sdu:manifesto:escribania-bitsch:20260616:v1` | `Completed` |
| `mon_sdu_evidences` | `evidence:sdu:manifesto:escribania-bitsch:20260616:v1` | `Completed` |

## Orden Para Agentes

Cuando el owner envie orden viva:

1. Leer tenant y entorno.
2. Rehidratar esta huella por `canonical_id`.
3. Convertir condiciones tecnicas en deltas.
4. Exigir target exacto para writes.
5. Cerrar con evidencia, rollback y postcheck.

## Evidencia

- `operativa/DATAVERSE_PROMOTION_MANIFESTO_SDU_20260616.json`
- `operativa/READBACK_PROMOCION_HUELLA_ATOMICA_TENANT_DATAVERSE_20260616.md`
