# Mapa SGIN SPGovernance SDU Dataverse Wave 20260616

Estado: `OBSERVED_READ_ONLY / METADATA_ONLY_PREPARED`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.

## Carriles

| Carril | Estado | Evidencia | Lectura |
| --- | --- | --- | --- |
| SGIN documental | `confirmada` | `READBACK_SGIN_OBSERVED_READ_ONLY_20260616.md` | Site real `/sites/sistema`, drive `Documentos compartidos`, 41 listas/bibliotecas metadata. |
| SPGovernanceModel | `confirmada` | `READBACK_SPGOVERNANCE_COMPONENT_DISAMBIGUATION_20260616.md` | Modelo SharePoint/SDU que apunta a `/sites/soporte`, no a SGIN. |
| SDU runtime | `confirmada` | `READBACK_DATAVERSE_POWER_PLATFORM_TENANT_ESCRIBANIA_BITSCH_20260616.md` | 8 colas SDU, 373 items backlog, workflows SDU y control planes visibles. |
| Dataverse hydration | `metadata_only_prepared` | `hitos/20260616-sdu-dataverse-metadata-wave-v1` | 65 filas preparadas, no aplicadas. |

## Separacion Semantica

- `SGIN` no es todo Microsoft.
- `SPGovernanceModel` no es SGIN: apunta a `/sites/soporte`.
- `SDU runtime` puede ser compartido, pero no prueba por si solo vinculo SGIN.
- `metadata hydration` no es write Dataverse.
- `candidate_count_many` no habilita apply.

## Mapa De Energia Atomica

`observacion -> clasificacion -> metadata atomica -> skill/receta/proceso -> validador -> proximo delta`

## Proximo Delta Unico

Elegir el siguiente carril:

1. SGIN documental: mapa de listas/bibliotecas por tipo sin abrir documentos.
2. SPGovernance soporte: mapa de entidades `cr3c_*` y workflows SDU sin payloads.
3. SDU runtime: backlog por cola y reglas de prioridad metadata-only.
4. Dataverse hydration: candidate count por `mon_sdu_*` antes de cualquier apply.
