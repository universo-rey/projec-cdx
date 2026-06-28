---
artifact_id: operativa/PENDIENTES_HOY_20260617.md
categoria: operativa
tipo: plan
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/PENDIENTES_HOY_20260617.md
etiquetas:
- operativa
- plan
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Listado de pendientes operativos del dia con trazabilidad parcial.
fecha_evento: '2026-06-17'
---

# Pendientes Hoy 2026-06-17

Relevamiento operativo desde `NEXT.md`, `CURRENT.md`, `BLOCKERS.md`, `TRACE.md`, matriz preliminar y estado Git.

## Semaforo

- Bloqueos reales activos: `NINGUNO`.
- Cierre total: `NO_DECLARADO`.
- Etapa: `DATAVERSE_REHYDRATION_LIVE_READ_CONFIRMED`.
- Riesgo principal: mezclar binding UI, cierre documental, Dataverse y cambios Git en un solo paquete.
- Regla de ruido: no crear paquetes nuevos si el delta ya esta cubierto por hito, readback, indice o paquete existente.

## Revision Paquetes Router Agents Codex Cloud

- Estado: `PACKAGES_ROUTER_AGENTS_CLOUD_REVIEWED`.
- Paquetes preparados: `thread-packets-20260617`, hito root repos, hito Cloud
  preflight, hito SDK launch, prompt Cloud UI y zips historicos.
- Vigencia: `thread-packets-20260617` ya fue consumido por live dispatch/fan-in; no reabrirlo como pendiente de creacion.
- Zips historicos: `packages/` es canon visible; `.codex/workpapers/.../source_zips` es espejo exacto verificado por SHA-256.
- Ruido identificado sin borrado: `hitos/20260617-ajuste-sgin-ya-leido-v1` es carpeta vacia y queda `EMPTY_SUPERSEDED_NO_CANON`.
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

## Carriles Vivos Normalizados

1. `Dataverse_rehidratacion_desde_paquetes`.
   - Estado: `CLOSED_LIVE_READ_CONFIRMED`.
   - Modo: live read-only confirmado; no write.
   - Evidencia base: `dataverse/ANCLA_REHIDRATACION.md`, `dataverse/GATE.md`, `operativa/READBACK_REHIDRATACION_DATAVERSE_DESDE_PAQUETES_20260617.md`, `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`.
   - Resultado: `5/5` parejas source/evidence con conteo `1/1`.

2. `SGIN_documental_lists_metadata`.
   - Estado: `CLOSED_READ_AND_PACKAGED`.
   - Modo: consumible como fuente para Dataverse; no reabrir lectura ni paquete.
   - Evidencia base: `operativa/READBACK_SGIN_OBSERVED_READ_ONLY_20260616.md`, `inventarios/SGIN_SHAREPOINT_LISTS_LIVE_20260616.csv` y `hitos/20260617-microsoft-sgin-hitos-documental-v1`.

3. `SPGovernance_soporte_metadata`.
   - Estado: `ACTIVE_CANDIDATE`.
   - Modo: read-only preflight, metadata-only.
   - Evidencia base: `operativa/READBACK_SPGOVERNANCE_COMPONENT_DISAMBIGUATION_20260616.md`.

4. `SDU_runtime_queue_priorities`.
   - Estado: `ACTIVE_CANDIDATE`.
   - Modo: read-only preflight, metadata-only.
   - Evidencia base: `operativa/READBACK_DATAVERSE_POWER_PLATFORM_TENANT_ESCRIBANIA_BITSCH_20260616.md`.

5. `Home_aspx_page_binding`.
   - Estado: `WAITING_TECHNICAL_CONTEXT`.
   - No es bloqueo humano; espera UI/PnP/page API suficiente.
   - Evidencia base: `operativa/BINDING_HOME_SESHAT_UI_READY_20260616.md` y `operativa/READBACK_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md`.

6. `Codex_Cloud_UI_smoke_capture`.
   - Estado: `WAITING_OWNER_EXTERNAL_TASK`.
   - No es bloqueo local; espera que el owner ejecute el prompt en UI Cloud y traiga el resultado.
   - Evidencia base: `operativa/CODEX_CLOUD_SMOKE_TASK_20260617.md` y `operativa/READBACK_CODEX_CLOUD_SDK_LAUNCH_20260617.md`.

## Supersedidos Cerrados

- Consolidar hitos Microsoft/SGIN: `SUPERSEDED_CLOSED` por `20260617-microsoft-sgin-hitos-documental-v1`.
- Separar paquete Git generico: `SUPERSEDED_CLOSED` por paquetes scoped, root repos review y max-state fan-in.
- CDF `seshat/resto-corte`: `SUPERSEDED_CLOSED` por PR draft #28 y readback CDF split.
- Paquetes `5+1`: `SUPERSEDED_CLOSED` por live dispatch y fan-in final.
- Buscar repo `router`: `SUPERSEDED_CLOSED`; router es superficie distribuida, no repo independiente observado.
- Setup Codex Cloud base: `SUPERSEDED_CLOSED`; local smoke/bridge PASS y Cloud UI queda externa.

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

`delta_select_next_consumer_from_dataverse_live_rows`.

Motivo: SGIN ya fue leido y paquetizado, y Dataverse ya fue confirmado live.
El paso seguro ahora es elegir la superficie consumidora exacta de esas filas
vivas sin ejecutar writes por inferencia.

## Validadores Asociados

- `pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_proj_cdx_workbench.ps1"`
- `pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_sdu_dataverse_metadata_wave.ps1" -Root "C:/Users/enzo1/PROJEC CDX" -WaveId "20260617-lane-b-corte-agent-index-dataverse-pointer-v1"`
