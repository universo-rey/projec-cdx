# SGIN candidate count: listo para desambiguar, no para aplicar

Estado: `OBSERVED_READ_ONLY`.
Frontera: `TENANT_ONLY`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.
Hora local: `2026-06-16 18:20 -03:00`.
Write Dataverse/Power Platform: `NO_EJECUTADO`.
Contenido sensible: `NO_REPRODUCIDO`.

## Fuente

- `inventarios/SGIN_COMPONENT_CANDIDATE_COUNTS_20260616.csv`
- `operativa/archive/legacy-root/20260616/SGIN_GROUP_SITE_DRIVE_PLAN_PROBES_20260616.json`
- `inventarios/DATAVERSE_SDU_SGIN_SOLUTIONCOMPONENTS_20260616.csv`
- `hitos/20260616-sdu-dataverse-metadata-wave-v1/METADATA_HYDRATION_MATRIX.csv`

## Confirmada

| Busqueda | Resultado |
| --- | --- |
| `SPGovernanceModel` en soluciones | `candidate_count_one` |
| SGIN group/team | Confirmado por JSON de probes |
| SGIN site real | `https://escribaniabitsch.sharepoint.com/sites/sistema` |
| SGIN drive | Confirmado en JSON de probes; no aparece en CSV de listas porque ese CSV esta a nivel site/list |
| Metadata wave | 65 filas `METADATA_ONLY_PREPARED` |

## Observada

| Busqueda | Resultado |
| --- | --- |
| `SDU` en soluciones, workflows, workqueues y solutioncomponents | `candidate_count_many` |
| `SharePoint` en soluciones/workflows/listas | `candidate_count_many` |
| `site_name=sistema` | `candidate_count_many` por listas del site y soluciones sistema genericas |
| `group_id` en CSV de probes | `candidate_count_many` porque el mismo group id aparece en varios probes del mismo contenedor |

## Lectura

La wave no tiene todavia un vinculo exacto `SGIN site/drive -> componente SDU unico`. Hay un candidato unico para `SPGovernanceModel` como solucion, pero SDU y SharePoint siguen siendo familias con multiples candidatos. El siguiente paso no es aplicar: es desambiguar por componente estructurado o metadata de definicion sin payloads.

## No Ejecutado

- No se abrieron documentos.
- No se leyeron definiciones con secretos.
- No se ejecutaron flows.
- No se tocaron colas.
- No se escribio Dataverse.

## Proximo Delta Unico

Preparar una tabla de desambiguacion `SPGovernanceModel`:

1. Agrupar componentes por `componenttype`.
2. Para tipos seguros, resolver nombre logico desde metadata publica.
3. Detener si el siguiente campo exige definicion, conexion, secreto, payload o documento.
