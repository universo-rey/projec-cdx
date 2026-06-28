# Proceso Planner SharePoint SDU Preprod Expediente

## Entrada

- Orden del owner para preparar Planner + SharePoint + SDU en modo
  preproduccion.
- Target oficial: `https://escribaniabitsch.sharepoint.com/sites/sistema`.
- Matrices de cuenta y rol:
  - `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\STATE_SEMANTICS_OWNER_IDENTITY_NORMALIZATION\CDF_OWNER_IDENTITY_NORMALIZATION_MATRIX.csv`
  - `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\TENANT_DICTAMEN_READINESS\CDF_TENANT_AGENT_ROLE_ASSIGNMENT_MATRIX.csv`
  - `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\TGE_CDF_STAFF_TENANT_LIVE_READONLY_PREFLIGHT_REPORT_20260527.md`
  - `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\MICROSOFT_365_CONNECTION_SURFACE_MATRIX.csv`
  - `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\PLANNER_ROLE_MATRIX.csv`
- Evidencia local:
  - `inventarios/PLANNER_HYBRID_READBACK_STATE_20260627.json`
  - `inventarios/PLANNER_TASK_LEVEL_READBACK_HYBRID_20260627.jsonl`

## Pasos

1. Rehidratar identidad, tenant y rol desde CDF/TGE antes de abrir cualquier
   superficie live.
2. Clasificar la superficie SharePoint como `document-library`.
3. Inventariar tareas activas de Planner a nivel task y conservar el snapshot
   previo como ancla anti falso missing.
4. Generar o validar `expediente_id` con formato
   `{TIPO_ACTO}-{APELLIDO}-{AÑO}-{CORRELATIVO}`.
5. Verificar o preparar la carpeta
   `/sites/sistema/EXPEDIENTES/{expediente_id}` con la estructura exacta:
   `01_DATOS_BASE`, `02_DOCUMENTACION_REQUERIDA`, `03_DOCUMENTACION_RECIBIDA`,
   `04_MINUTA`, `05_VALIDACIONES`, `06_FIRMA`, `07_REGISTRACION`,
   `08_RESPALDO`, `09_COMUNICACIONES`.
6. Asegurar que la nota de Planner contenga el link de SharePoint y la
   estructura minima de expediente.
7. Normalizar notas, datos criticos y estado textual del expediente.
8. Calcular `consistency_score` con Planner, Teams, Outlook y SharePoint; marcar
   duplicados y gaps de trazabilidad.
9. Persistir el snapshot SDU preprod en
   `inventarios/expediente_state_preprod.jsonl` y preparar el puntero para
   `/sites/sistema/SDU/expediente_state_preprod.jsonl` cuando exista orden de
   escritura gobernada.
10. Bloquear la promocion a produccion si falta carpeta, ID, responsable o si
    la consistencia cae por debajo del umbral.
11. Emitir eventos SDU y dejar el readback listo para enforcement G8.

## Validacion

- Cada task tiene `task_id`, `plan_id`, `title`, `assigned_to`,
  `current_bucket`, `last_activity`.
- Cada expediente tiene carpeta, link, responsable y notas normalizadas.
- La fuente de identidad y rol queda trazada contra CDF/TGE.
- La salida es reproducible sin inventar acceso ni permisos.

## Salida

- `inventarios/PLANNER_TASK_LEVEL_READBACK_HYBRID_20260627.jsonl`
- `inventarios/PLANNER_HYBRID_READBACK_STATE_20260627.json`
- `inventarios/PLANNER_SHAREPOINT_SDU_PREPROD_READBACK_20260627.md`
- readiness para `SDU_PLANNER_ENFORCEMENT_G8`

## Stop Condition

- `live_surface_without_governed_order`
- `identity_or_target_ambiguous`
- `rollback_missing`
- `postcheck_missing`
- `missing_account_matrix_source`

