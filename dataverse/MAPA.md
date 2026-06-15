# Mapa De Dataverse

Vista unica del carril Dataverse de `PROJEC CDX`.

La wave visible mas reciente queda absorbida en [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

El acceso on-demand a waves de cierre queda en [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md).

## Piezas

- `README.md`
- `GATE.md`
- `MAPA_AGENTES.md`
- `MAPA_AGENTES_SDU.md`
- `MAPA_COLA_TRABAJO_SDU.md`
- `MAPA_CONEXIONES_DATAVERSE.md`
- `REGISTRO_BLOQUEOS.md`
- `PLAN_SEGUNDA_PASADA.md`
- `READBACK_EXCEL_BLOCKER_FRONTIER.md`
- `ACTA_CORTE_EJECUTORA_20260615.md`
- `MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md`
- `REGISTRO_LIMPIEZA_PC_LOCAL_20260615.md`
- `DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv`
- `playbooks/07-dataverse-fronteras.md`

## Evidencia Local Actual

- [Dataverse Blocker Frontier](C:/Users/enzo1/PROJEC%20CDX/outputs/dataverse_blocker_frontier_20260614/README.md)
- [Mapa de agentes Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_AGENTES.md)
- [Mapa de agentes SDU](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_AGENTES_SDU.md)
- [Mapa de cola de trabajo SDU](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_COLA_TRABAJO_SDU.md)
- [Mapa de conexiones Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_CONEXIONES_DATAVERSE.md)
- [Readback Excel Blocker Frontier](C:/Users/enzo1/PROJEC%20CDX/dataverse/READBACK_EXCEL_BLOCKER_FRONTIER.md)
- [Acta corte ejecutora Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/ACTA_CORTE_EJECUTORA_20260615.md)
- [Matriz cadena operativa Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md)
- [Registro limpieza PC local segura](C:/Users/enzo1/PROJEC%20CDX/dataverse/REGISTRO_LIMPIEZA_PC_LOCAL_20260615.md)
- [Mapa fuente cadena operativa Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv)
- [Dataverse fronteras playbook](C:/Users/enzo1/PROJEC%20CDX/playbooks/07-dataverse-fronteras.md)
- [Registro de bloqueos Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/REGISTRO_BLOQUEOS.md)
- [Skills Dataverse](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.md)
- [Cabina audit deep](C:/Users/enzo1/PROJEC%20CDX/outputs/cabina_relationship_audit_20260614/CABINA_RELATIONSHIP_AUDIT_DEEP.md)
- [Universe relationship audit](C:/Users/enzo1/PROJEC%20CDX/outputs/universe_relationship_audit_20260614/README.md)

## Estados Permitidos

- `local_evidence`
- `metadata_only`
- `prepared_not_executed`
- `live_rows_confirmed`
- `target_ambiguous`
- `blocked`

## Regla

Metadata no equivale a live rows. Preparado no equivale a ejecutado.
Las filas de Dataverse valen mas cuando registran bloqueos y decisiones que cuando intentan duplicar inventarios ya presentes en repos o workbooks.
La corte ejecutora de Dataverse reutiliza el packet ya activo del apply worker hasta que exista un target nuevo y unico.
Las conexiones, gates y evidencia de semilla viven en `MAPA_CONEXIONES_DATAVERSE.md`.
El acceso a waves de cierre que toquen Dataverse vive en `operativa/ANCLAS_ON_DEMAND.md`; desde alli se abre `ANCLA_CIERRE_WAVE.md` solo cuando el delta lo pide.
La cadena operativa se gobierna desde Dataverse. `DATAVERSE_OPERATIONAL_CHAIN_MATRIX` es el nombre funcional canonico; su superficie viva actual es compuesta y mapeada a `mon_sdu_*`, `workqueue` y `workqueueitem`.
La copia local solo proyecta estado para validacion, versionado y trabajo de cabina.
La limpieza local de PC queda registrada como metadata en `REGISTRO_LIMPIEZA_PC_LOCAL_20260615.md` y no abre write live.
