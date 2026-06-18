# SPGovernanceModel desambiguado: no apunta a SGIN

Estado: `OBSERVED_READ_ONLY`.
Frontera: `TENANT_ONLY`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.
Hora local: `2026-06-16 18:24 -03:00`.
Write Dataverse/Power Platform: `NO_EJECUTADO`.

## Confirmada

| Punto | Resultado |
| --- | --- |
| Solucion | `SPGovernanceModel` |
| Componentes totales | `445` |
| Entidades resueltas | `9` |
| Workflows resueltos | `3` |
| Variables de entorno resueltas | `4 definitions`, `4 values` |
| Variable leida puntualmente | `cr3c_SharePointSiteUrl` |
| Valor observado | `https://escribaniabitsch.sharepoint.com/sites/soporte` |
| Match con SGIN site `/sites/sistema` | `NO` |

## Lectura

`SPGovernanceModel` es un modelo SharePoint/SDU real dentro de `HUBDesarrollo`, pero el valor de `cr3c_SharePointSiteUrl` apunta a `/sites/soporte`, no al site SGIN resuelto en `/sites/sistema`.

Esto descarta el vinculo exacto directo `SGIN site -> SPGovernanceModel` por esa variable. No descarta que SGIN comparta runtime SDU, ni que tenga otro modelo, flujo o mapping.

## Evidencia

- `inventarios/SPGOVERNANCE_COMPONENT_DISAMBIGUATION_20260616.csv`
- `inventarios/SPGOVERNANCE_SHAREPOINT_SITEURL_VALUE_20260616.csv`
- `inventarios/DATAVERSE_SDU_SGIN_SOLUTIONCOMPONENTS_20260616.csv`

## No Ejecutado

- No se abrieron documentos.
- No se leyeron conexiones.
- No se leyeron secretos.
- No se ejecutaron flows.
- No se escribio Dataverse.

## Proximo Delta Unico

Buscar vinculo propio de SGIN:

1. Buscar `/sites/sistema`, `sistema`, `SGIN` y group id en variables de entorno no secretas, solution components y workflows metadata.
2. Separar `no_candidate`, `candidate_count_one` y `candidate_count_many`.
3. Si no hay candidato, cerrar SGIN como `site_documental_confirmado_sin_modelo_spgovernance_directo`.
