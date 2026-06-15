# Dataverse

Carril gobernado para Dataverse dentro de `PROJEC CDX`.

La wave visible mas reciente queda absorbida en [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

El acceso on-demand a waves de cierre queda en [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md).

- [MAPA.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA.md)
- [MAPA_AGENTES.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_AGENTES.md)
- [MAPA_AGENTES_SDU.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_AGENTES_SDU.md)
- [MAPA_COLA_TRABAJO_SDU.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_COLA_TRABAJO_SDU.md)
- [MAPA_CONEXIONES_DATAVERSE.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_CONEXIONES_DATAVERSE.md)
- [GATE.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/GATE.md)
- [REGISTRO_BLOQUEOS.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/REGISTRO_BLOQUEOS.md)
- [PLAN_SEGUNDA_PASADA.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/PLAN_SEGUNDA_PASADA.md)
- [READBACK_EXCEL_BLOCKER_FRONTIER.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/READBACK_EXCEL_BLOCKER_FRONTIER.md)
- [ACTA_CORTE_EJECUTORA_20260615.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/ACTA_CORTE_EJECUTORA_20260615.md)
- [MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md](C:/Users/enzo1/PROJEC%20CDX/dataverse/MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md)
- [DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv](C:/Users/enzo1/PROJEC%20CDX/dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv)

## Regla

Dataverse queda como superficie gobernada del ecosistema. La consulta viva de lectura confirmo `HUBDesarrollo`, `SDUCapabilityControlPlane` y `sdu_runtime_control_plane`.
Para bloquear, decidir y escalar, usar el modelo de `REGISTRO_BLOQUEOS.md` en lugar de inventariar todo el universo.
Para superficies de conexion y drift, usar `MAPA_CONEXIONES_DATAVERSE.md`.
Para waves de cierre que tocan Dataverse, entrar por `operativa/ANCLAS_ON_DEMAND.md` y abrir `ANCLA_CIERRE_WAVE.md` solo despues del gate y solo si el delta toca Dataverse.
La matriz fuente de cadena operativa vive en Dataverse como fuente funcional gobernada: `DATAVERSE_OPERATIONAL_CHAIN_MATRIX`. Su traduccion a logical surfaces reales esta en `DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv`.
Cualquier CSV local es proyeccion/cache verificable.
