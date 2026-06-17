# Pendientes Hoy 2026-06-17

Relevamiento operativo desde `NEXT.md`, `CURRENT.md`, `BLOCKERS.md`, `TRACE.md`, matriz preliminar y estado Git.

## Semaforo

- Bloqueos reales activos: `NINGUNO`.
- Cierre total: `NO_DECLARADO`.
- Etapa: `PACKAGES_ROUTER_AGENTS_CLOUD_REVIEWED`.
- Riesgo principal: mezclar binding UI, cierre documental, Dataverse y cambios Git en un solo paquete.

## Revision Paquetes Router Agents Codex Cloud

- Estado: `PACKAGES_ROUTER_AGENTS_CLOUD_REVIEWED`.
- Paquetes preparados: `thread-packets-20260617`, hito root repos, hito Cloud
  preflight, hito SDK launch, prompt Cloud UI y zips historicos.
- `router`: superficie distribuida; no se encontro repo independiente.
- `codex-root`: limpio en `main`, sin PR abierto.
- `agents-root`: limpio en rama y PR draft #1 abierto.
- Codex Cloud: smoke local y bridge `PASS`; UI Cloud queda externa/pending.
- Evidencia: `operativa/READBACK_PAQUETES_ROUTER_AGENTS_CODEX_CLOUD_20260617.md`.

## Maximo Estado Real Alcanzado

- Estado vigente: `MAX_STATE_FAN_IN_VERIFIED`.
- Maximo control tower: `MICROSOFT_SGIN_HITOS_CONSOLIDATED`.
- Maximo vivo historico: `LIVE_SHAREPOINT_DOCUMENT_WRITE` y `LIVE_METADATA_POINTER_WRITE`.
- Evidencia: `operativa/READBACK_MAXIMO_ESTADO_REAL_SUPERFICIES_20260617.md`, `operativa/MAXIMO_ESTADO_REAL_SUPERFICIES_20260617.csv`, `operativa/FAN_IN_AGENTES_MAXIMO_ESTADO_REAL_20260617.csv`.

## Pendientes Ejecutables Hoy

1. Binding visible de SeshatHub `Home.aspx`.
   - Target: `https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/SitePages/Home.aspx`.
   - Objetivo minimo: enlazar atomos ya publicados: `HUELLA_ATOMICA_SESHAT_HOME_20260616.md`, `HUELLA_ATOMICA_CORTE_PROPOSITO_20260616.md` e `INDICE_CORTE_AGENTES_20260617.md`.
   - Estado: superficie UI alternativa publicada; `Home.aspx` queda pendiente solo si hay UI/PnP/page API con permiso suficiente.
   - Evidencia lista: `operativa/BINDING_HOME_SESHAT_UI_READY_20260616.md`.
   - Evidencia ejecutada: `operativa/READBACK_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md`.

2. Binding UI/surface posterior para `INDICE_CORTE_AGENTES_20260617.md`.
   - Estado: SharePoint publicado, Dataverse registrado, binding UI alternativo publicado y puntero metadata-only del binding aplicado.
   - Source Dataverse: `sharepoint:corte-agent-index:20260617:v1`.
   - Evidence Dataverse: `evidence:sharepoint:corte-agent-index:20260617:v1`.
   - Binding source Dataverse: `sharepoint:binding-ui-seshat-home-atomos:20260617:v1`.
   - Binding evidence Dataverse: `evidence:sharepoint:binding-ui-seshat-home-atomos:20260617:v1`.
   - Siguiente accion: `Home.aspx` solo cuando exista UI/PnP/page API con permiso suficiente; no es bloqueo humano.

3. Consolidar hitos pendientes de la wave Microsoft/SGIN.
   - Pendientes con hito aun no empaquetado: Microsoft live read, Dataverse tenant read, SGIN observed, SGIN crosswalk, candidate count, SPGovernance disambiguation, SGIN own governance link, mapa SGIN/SPGovernance/SDU.
   - Estado: `CERRADO_COMO_MICROSOFT_SGIN_HITOS_CONSOLIDATED`.
   - Evidencia: `operativa/READBACK_MICROSOFT_SGIN_HITOS_DOCUMENTAL_20260617.md`, `operativa/MICROSOFT_SGIN_HITOS_CONSOLIDATION_20260617.csv`, `hitos/20260617-microsoft-sgin-hitos-documental-v1`.
   - Modo: documental/local; sin nueva lectura live.

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

Normalizar pendientes historicos/supersedidos despues de la revision de
paquetes/router/agents/Cloud y dejar solo carriles vivos: SGIN
listas/bibliotecas, SPGovernance soporte, SDU runtime queues, Home.aspx cuando
exista permiso UI/PnP/page API suficiente, o captura de smoke Codex Cloud UI si
el owner ejecuta la task externa.

## Validadores Asociados

- `pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_proj_cdx_workbench.ps1"`
- `pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_sdu_dataverse_metadata_wave.ps1" -Root "C:/Users/enzo1/PROJEC CDX" -WaveId "20260617-lane-b-corte-agent-index-dataverse-pointer-v1"`
