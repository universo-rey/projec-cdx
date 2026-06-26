---
artifact_id: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.md
categoria: operativa
tipo: reporte
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.md
etiquetas:
  - runtime
  - residual
  - classification
  - owner-decision
relacionados:
  - operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.json
  - operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.csv
descripcion: Clasificacion gobernada de superficies residuales locales sin aplicar acciones.
---
# LOCAL RESIDUAL SURFACES CLASSIFICATION 20260623

## Dictamen

LOCAL_RESIDUAL_CLASSIFIED_NO_ACTION

Se clasificaron 87 entradas desde git status --short, usando solo metadata local: ruta, estado Git, extension, tamano y fecha. No se borro, movio, stageo ni commiteo nada.

## Conteo por categoria

- LOCAL_EVIDENCE_ONLY: 57
- RAW_EVIDENCE_DO_NOT_VERSION: 0
- BACKUP_RETENTION: 5
- CONFIG_PROPOSALS: 15
- PATCH_PROPOSALS: 2
- SCRIPT_BACKUPS: 2
- RUNTIME_EVENT_OUTPUT: 2
- OPERATIVA_LOCAL_EVIDENCE: 3
- CANDIDATE_FUTURE_DELTA: 0
- OWNER_DECISION_REQUIRED: 1

## Diagnostico especial tracked

tools/promote_sdu_manifesto_dataverse.ps1 queda como UNKNOWN_NEEDS_OWNER.

Motivo: git diff -w queda vacio, pero git diff --ignore-space-at-eol y git diff --ignore-cr-at-eol siguen viendo un cambio de whitespace inicial; ademas Git reporta warning LF-to-CRLF. No se clasifica como cambio funcional automatico ni como line-ending-only estricto.

Recomendacion: abrir LOCAL_LINE_ENDING_POLICY_G1 o normalizacion/revert de whitespace con gate owner. Si owner confirma intencion funcional, abrir DELTA_PROMOTE_SDU_MANIFESTO_DATAVERSE_SCRIPT_G1.

## Salidas detalladas

- JSON: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.json
- CSV: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.csv
- CSV metadata: operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.csv.meta.json

## Frontera

- stage: false
- commit: false
- delete: false
- move: false
- push: false
- pr: false
- live: false
- secretos: false
