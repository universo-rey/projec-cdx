---
artifact_id: operativa/archive/legacy-root/20260616/ORDEN_PROMOCION_HUELLA_ATOMICA_TENANT_DATAVERSE_20260616.md
categoria: operativa
tipo: orden
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/archive/legacy-root/20260616/ORDEN_PROMOCION_HUELLA_ATOMICA_TENANT_DATAVERSE_20260616.md
etiquetas:
- operativa
- orden
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Orden de promocion de huella atomica a tenant y Dataverse con trazabilidad
  parcial.
fecha_evento: '2026-06-16'
---

# Orden De Promocion - Huella Atomica SDU A Tenant Y Dataverse

Estado: `LIVE_METADATA_POINTER_WRITE_EXECUTED`
Fecha: `2026-06-16`
Owner: `Enzo Figueroa / SDU Owner Operativo`
Tenant: `Escribania Bitsch`
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`
Environment: `HUBDesarrollo`
Environment ID: `7f65fc04-c27a-ea0d-bd2d-266aa9203c1e`
Environment URL: `https://org084965d9.crm.dynamics.com`

## Orden Viva

La huella atomica aprobada del Manifiesto SDU debe quedar visible para el
tenant y especialmente para Dataverse como memoria institucional, fuente de
orden y punto de despertar para agentes.

## Regla Rectora

- Solo la autoridad humana establece o deroga bloqueos reales.
- Los `stop_condition` se interpretan como deltas gobernados, senales de
  revision o proximos pasos.
- Dataverse contiene la memoria de largo plazo; Codex y los agentes consumen la
  huella desde fuente viva o desde almacen.
- La promocion no autoriza payloads sensibles, secretos, documentos de
  expediente, activacion de flows ni writes amplios por inferencia.

## Target Vivo Ejecutado

| tabla | canonical_id | resultado |
| --- | --- | --- |
| `mon_sdu_source_artifacts` | `sdu:manifesto:escribania-bitsch:20260616:v1` | `created_or_confirmed` |
| `mon_sdu_evidences` | `evidence:sdu:manifesto:escribania-bitsch:20260616:v1` | `created_or_confirmed` |

## Postcheck

Evidencia local: `operativa/archive/legacy-root/20260616/DATAVERSE_PROMOTION_MANIFESTO_SDU_20260616.json`.

Resultado esperado:

- `source_count = 1`
- `evidence_count = 1`
- `mode = LIVE_METADATA_POINTER_WRITE`

## Rollback

Rollback tecnico por `canonical_id`:

- Parchear las filas exactas a `Pending`/retirado si el owner ordena reversa.
- O eliminar solo los ids exactos creados, preservando evidencia de rollback.

No se debe borrar evidencia historica ni limpiar filas por busqueda amplia.

## Proximo Delta

Propagar la misma semantica en mapas, recetas, procesos y agentes: bloqueo real
solo por autoridad humana; toda condicion tecnica se convierte en delta
accionable con owner, evidencia, rollback y postcheck.
