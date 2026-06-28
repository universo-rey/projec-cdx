# READBACK_PLANNER_SHAREPOINT_SDU_PREPROD_20260627

## Estado

HECHO_VERIFICADO:

- La capa visible ya tiene una receta y un proceso para el carril
  `Planner + SharePoint + SDU` en modo `PRE_PRODUCTION`.
- Las matrices de cuenta/rol requeridas existen y quedan referenciadas desde
  CDF/TGE.
- El readback local sigue separado del write live.
- La capa viva de SharePoint ya quedo preparada con los contenedores
  `EXPEDIENTES` y `SDU` en la raiz del sitio.

## Sistemas tocados

- `recipes/planner-sharepoint-sdu-preprod-expediente.md`
- `procesos/planner-sharepoint-sdu-preprod-expediente.md`
- `recipes/README.md`
- `recipes/MAPA.md`
- `recipes/INDICE_RECETAS.md`
- `procesos/README.md`
- `procesos/MAPA.md`
- `procesos/INDICE_PROCESOS.md`
- `inventarios/PLANNER_SHAREPOINT_SDU_PREPROD_READBACK_20260627.md`
- `inventarios/PLANNER_HYBRID_READBACK_STATE_20260627.json`
- `inventarios/expediente_state_preprod.jsonl`
- SharePoint live root scaffold: `EXPEDIENTES`, `SDU`
- `C:\\CEO\\watchdog\\bus\\sdu-event-bus.jsonl`

## Sistemas no tocados

- Planner live write.
- SharePoint live write de expedientes o snapshots.
- Outlook live write.
- Teams live write.
- Entra / Graph / PAC / PnP live change.

## Cambios

- Se agrego el carril notarial preprod con estado base,
  matrices de cuenta, cadena SDU, reglas y stop conditions.
- Se anclo el origen de identidad y rol en CDF/TGE para evitar inferencias.
- Se dejo una salida preparada para `SDU_PLANNER_ENFORCEMENT_G8`.
- Se creo el scaffolding minimo en SharePoint para que el sistema tenga
  superficies reales donde colgar expedientes y snapshots.
- Se sembró el snapshot local `inventarios/expediente_state_preprod.jsonl`
  como bootstrap coherente con el estado vivo.
- Se registraron eventos SDU de arranque, creacion, validacion y snapshot en
  el bus local.

## Validacion

- Existencia de matrices confirmada en:
  - `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\STATE_SEMANTICS_OWNER_IDENTITY_NORMALIZATION\CDF_OWNER_IDENTITY_NORMALIZATION_MATRIX.csv`
  - `C:\Users\enzo1\Documents\GitHub\cdf-soluciones\03_OPERACION\TENANT_DICTAMEN_READINESS\CDF_TENANT_AGENT_ROLE_ASSIGNMENT_MATRIX.csv`
  - `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\TGE_CDF_STAFF_TENANT_LIVE_READONLY_PREFLIGHT_REPORT_20260527.md`
  - `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\MICROSOFT_365_CONNECTION_SURFACE_MATRIX.csv`
  - `C:\Users\enzo1\Documents\GitHub\torre-gemela-escribania\00_CONTEXT\PLANNER_ROLE_MATRIX.csv`
- La evidencia previa de Planner hybrid readback ya existe en `inventarios/`.
- Postcheck vivo confirmado en `https://escribaniabitsch.sharepoint.com/sites/sistema`:
  - `EXPEDIENTES`
  - `SDU`

## Riesgos

- El carril live de SharePoint sigue siendo gobernado para writes de
  expedientes y snapshots.
- La identidad efectiva no debe inferirse fuera de CDF/TGE.

## Rollback

- Borrar los tres archivos nuevos y revertir los tres indices actualizados.
- Eliminar los contenedores vivos `EXPEDIENTES` y `SDU` solo con orden
  gobernada y soporte de borrado disponible.
- Mantener intactos los snapshots previos de Planner.

## Proximos carriles

- Preflight live readonly acotado sobre SharePoint/Planner.
- Generacion de carpeta `/sites/sistema/EXPEDIENTES/{expediente_id}` cuando
  haya orden de escritura gobernada.
- Publicacion SDU del snapshot solo si el estado cambia.
