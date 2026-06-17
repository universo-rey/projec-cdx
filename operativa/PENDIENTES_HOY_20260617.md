# Pendientes Hoy 2026-06-17

Relevamiento operativo desde `NEXT.md`, `CURRENT.md`, `BLOCKERS.md`, `TRACE.md`, matriz preliminar y estado Git.

## Semaforo

- Bloqueos reales activos: `NINGUNO`.
- Cierre total: `NO_DECLARADO`.
- Etapa: `PRELIMINARES_CIERRE_TOTAL`.
- Riesgo principal: mezclar binding UI, cierre documental, Dataverse y cambios Git en un solo paquete.

## Pendientes Ejecutables Hoy

1. Binding visible de SeshatHub `Home.aspx`.
   - Target: `https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/SitePages/Home.aspx`.
   - Objetivo minimo: enlazar atomos ya publicados: `HUELLA_ATOMICA_SESHAT_HOME_20260616.md`, `HUELLA_ATOMICA_CORTE_PROPOSITO_20260616.md` e `INDICE_CORTE_AGENTES_20260617.md`.
   - Estado: superficie UI alternativa publicada; `Home.aspx` queda pendiente solo si hay UI/PnP/page API con permiso suficiente.
   - Evidencia lista: `operativa/BINDING_HOME_SESHAT_UI_READY_20260616.md`.
   - Evidencia ejecutada: `operativa/READBACK_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md`.

2. Binding UI/surface posterior para `INDICE_CORTE_AGENTES_20260617.md`.
   - Estado: SharePoint publicado, Dataverse registrado y binding UI alternativo publicado.
   - Source Dataverse: `sharepoint:corte-agent-index:20260617:v1`.
   - Evidence Dataverse: `evidence:sharepoint:corte-agent-index:20260617:v1`.
   - Siguiente accion: registrar `BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md` como puntero metadata-only en Dataverse si se desea simetria de memoria larga.

3. Consolidar hitos pendientes de la wave Microsoft/SGIN.
   - Pendientes con hito aun no empaquetado: Microsoft live read, Dataverse tenant read, SGIN observed, SGIN crosswalk, candidate count, SPGovernance disambiguation, SGIN own governance link, mapa SGIN/SPGovernance/SDU.
   - Modo: documental/local; sin nueva lectura live salvo que se pida refresco.

4. Separar paquete Git de cierre preliminar.
   - PROJEC CDX tiene muchos cambios locales y untracked ya clasificados.
   - Accion de hoy: separar en paquetes: `cloud_runtime`, `hitos_canon`, `canon_recetas_patrones`, `dataverse_sharepoint_atoms`.
   - Stop condition: no stagear ni cerrar sin revisar diff por paquete.

5. CDF `seshat/resto-corte`.
   - Repo: `C:/Users/enzo1/Documents/GitHub/cdf-soluciones`.
   - Estado: paquetes locales/documentales creados; cambios sin commitear.
   - Accion de hoy: revisar y versionar paquete CDF separado, sin tocar `README.md` preexistente si no corresponde.

## Pendientes En Espera Gobernada

- `Home.aspx` directo por Graph Pages API tuvo `403`; no es bloqueo humano, es delta tecnico de permiso/contexto.
- Manifiesto SDU: borrador fan-in integrado; pendiente version firmable/aprobable por owner si se desea formalizar mas alla de la huella owner-approved ya registrada.
- SGIN profundizacion: siguiente carril posible es metadata-only; no abrir documentos ni ejecutar flows por inferencia.
- Agentes/workpapers: no hay pendiente material nuevo; solo mantener matrices nativas sincronizadas si se abre ese carril.

## No Tocar Sin Orden Explicita

- Secretos, `auth.json`, `cap_sid`, tokens, global-state, SQLite.
- Permisos, navegacion, page publish, flow run o contenido documental sensible.
- Borrados/movimientos de carpetas.
- Git destructivo o staging masivo sin paquete definido.

## Proximo Movimiento Unico Recomendado

Registrar `BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md` como puntero metadata-only en Dataverse, o mantenerlo solo como SharePoint atom hasta orden expresa.

## Validadores Asociados

- `pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_proj_cdx_workbench.ps1"`
- `pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_sdu_dataverse_metadata_wave.ps1" -Root "C:/Users/enzo1/PROJEC CDX" -WaveId "20260617-lane-b-corte-agent-index-dataverse-pointer-v1"`
