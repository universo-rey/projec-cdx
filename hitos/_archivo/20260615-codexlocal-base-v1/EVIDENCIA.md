# Evidencia CodexLocal Base v1

## Lectura Base

- [CodexLocal README](C:/Users/enzo1/Documents/CodexLocal/README.md)
- [CodexLocal mapa maestro](C:/Users/enzo1/Documents/CodexLocal/MAPA_MAESTRO.md)
- [CodexLocal indice](C:/Users/enzo1/Documents/CodexLocal/CODEXLOCAL_INDEX.csv)
- [CodexLocal AGENTS](C:/Users/enzo1/Documents/CodexLocal/AGENTS.md)

## Mapas Creados

- [CODEXLOCAL_SURFACE_MAP_20260615.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEXLOCAL_SURFACE_MAP_20260615.csv)
- [CODEXLOCAL_SPLIT_CABINA_20260615.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEXLOCAL_SPLIT_CABINA_20260615.csv)
- [CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEXLOCAL_INDEX_ONLY_CROSSWALK_20260615.csv)

## Split Cabina

- [Visible index](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/VISIBLE_INDEX.md)
- [work-dispatch-sdk-gates README](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/README.md)
- [CURRENT_STATE](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/02_AUTHORITY_CANON/CURRENT_STATE.md)
- [Work Queue Flow Operating Design](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/docs/powerautomate/WORK_QUEUE_FLOW_OPERATING_DESIGN.md)
- [Dataverse Target Architecture](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/docs/dataverse/DATAVERSE_TARGET_ARCHITECTURE.md)
- [SDU Agent Runtime](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/apps/sdu-agent-runtime/README.md)
- [Power Platform package](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/powerplatform/README.md)
- [Connection Reconciliation](C:/Users/enzo1/Documents/CodexLocal/cabina-universal-d-split-20260604/work-dispatch-sdk-gates/docs/connections/CONNECTION_RECONCILIATION_README.md)

## Hallazgo Operativo

- `CodexLocal` ya era el hub local correcto.
- `cabina-universal-d-split-20260604` no estaba al frente de `PROJEC CDX`.
- El split contiene deltas que explican parte de lo faltante en runtime, SDK, SDU CN, Dataverse work queues y friccion PowerShell/skills.
- Los worktrees de cabina estan atrasados y sucios; no se promocionan sin ronda de comparacion.
- Las 4 filas `INDEX_ONLY` del indice operativo quedan cruzadas contra CodexLocal y pasan a cadena visible gobernada.
