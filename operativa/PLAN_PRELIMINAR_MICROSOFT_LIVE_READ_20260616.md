---
artifact_id: operativa/PLAN_PRELIMINAR_MICROSOFT_LIVE_READ_20260616.md
categoria: operativa
tipo: plan
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/PLAN_PRELIMINAR_MICROSOFT_LIVE_READ_20260616.md
etiquetas:
- operativa
- plan
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Plan preliminar de lectura live de Microsoft con trazabilidad parcial.
fecha_evento: '2026-06-16'
---

# Plan Preliminar Microsoft Live Read 20260616

Estado: `PRELIMINAR`.
Live Microsoft: `NO_EJECUTADO`.
Write Microsoft: `ESPERANDO_CIERRE`.

## Primera Palabra

Entro a Microsoft como superficie viva solo para reconocer, no para modificar: primero ubico el sitio, la biblioteca, la lista o el canal; despues clasifico la evidencia como `confirmado`, `probable` o `inferido`.

## Objetivo

Preparar una pasada preliminar read-only por Microsoft para confirmar la superficie minima necesaria sin tocar permisos, listas, archivos, Planner, Teams ni Dataverse con writes.

## Evidencia Local Ya Leida

- `dataverse/GATE.md`
- `procesos/dataverse-gobernado.md`
- `recipes/dataverse-rehidratacion.md`
- `inventarios/AGENTES_SKILLS_RECETAS_20260616.md`
- `inventarios/07_SHAREPOINT_POWER_PLATFORM_SGIN_SURFACE_MAP_20260616.md`
- `hitos/20260616-pre-cierre-constitutivo-corte-agentes-v1`
- `operativa/MATRIZ_PRELIMINAR_DELTAS_CIERRE_TOTAL_20260616.csv`

## Gate

Permitido en preliminar:

- Leer evidencia local.
- Preparar plan de probes.
- Clasificar superficie Microsoft.
- Hacer, solo si se abre el gate, probes read-only minimos.

Bloqueado en preliminar:

- SharePoint write.
- Teams send/reply/create.
- Planner update.
- Dataverse/Power Platform live write.
- Cambios de permisos.
- Exports amplios o regulados.
- Lectura de secretos.

## Superficies Microsoft A Clasificar

| Superficie | Clasificacion esperada | Gate |
| --- | --- | --- |
| SharePoint site | `document-library`, `native-list`, `file-export` o `ambiguous` | `sdu-sharepoint-surface-guard` |
| SharePoint archivos/bibliotecas | `document-library` | read-only minimo |
| SharePoint listas/filas | `native-list` solo si hay reader real disponible | pausar si no hay tool nativa |
| Teams equipos/canales | `teams-read-only` | listar antes de mensajes |
| Teams chats | `teams-read-only` | listar antes de fetch |
| Planner | `planner-read-only` | listar planes/tareas, no actualizar |
| Dataverse/Power Platform | `metadata-only` o `live-read-gated` | requiere ambiente/org/target exactos |

## Tools Permitidos Por Defecto

SharePoint read-only:

- `mcp__codex_apps__microsoft_sharepoint._get_site`
- `mcp__codex_apps__microsoft_sharepoint._list_site_drives`
- `mcp__codex_apps__microsoft_sharepoint._list_folder_items`
- `mcp__codex_apps__microsoft_sharepoint._fetch`
- `mcp__codex_apps__microsoft_sharepoint._list_drives`

Teams read-only:

- `mcp__codex_apps__microsoft_teams._list_teams`
- `mcp__codex_apps__microsoft_teams._list_channels`
- `mcp__codex_apps__microsoft_teams._list_channel_messages`
- `mcp__codex_apps__microsoft_teams._list_chats`
- `mcp__codex_apps__microsoft_teams._list_chat_messages`
- `mcp__codex_apps__microsoft_teams._fetch`
- `mcp__codex_apps__microsoft_teams._list_planner_plans`
- `mcp__codex_apps__microsoft_teams._list_planner_tasks`

Tools en espera de cierre en esta wave:

- `mcp__codex_apps__microsoft_sharepoint._create_folder`
- `mcp__codex_apps__microsoft_sharepoint._delete_item`
- `mcp__codex_apps__microsoft_teams._send_chat_message`
- `mcp__codex_apps__microsoft_teams._reply_to_channel_message`
- `mcp__codex_apps__microsoft_teams._create_channel`
- `mcp__codex_apps__microsoft_teams._update_planner_task`

## Skills Y Recetas Para Agentes

| Agente | Skill | Receta/Proceso | Tool permitido | Retorno |
| --- | --- | --- | --- | --- |
| `seshat-normativa` | `sdu-sharepoint-context-refresh`, `dataverse-rehidratacion` | `recipes/dataverse-rehidratacion.md` | local files only | canon de entrada y targets candidatos |
| `thot-tecnico` | `sdu-sharepoint-surface-guard` | `procesos/dataverse-gobernado.md` | SharePoint/Teams read-only map | secuencia de probes minimos |
| `anubis-gate` | `sdu-auditor-sharepoint-vivo`, `no-inference-runtime-write-guard` | `dataverse/GATE.md` | ninguno hasta gate | condiciones de pausa e items en espera de cierre |
| `maat-cumplimiento` | `governed-readback-closeout` | `cierre-wave-documental` | local evidence, luego read-only | formato de evidencia y readback |
| `horus-riesgo` | `sdu-sharepoint-surface-guard` | riesgo/rollback/postcheck | ninguno hasta target | riesgo, rollback y red flags |
| `narrador-normativo` | `cabina-continuity-readback` | readback vivo | local files only | mandato y voz de apertura |

## Fan-In De La Corte

- `seshat-normativa`: mantener `metadata_only` y `prepared_not_executed`; no abrir `pac auth`, `pac env fetch` ni live read sin orden exacta.
- `thot-tecnico`: usar SharePoint en cadena minima `_get_site -> _list_site_drives -> _list_folder_items -> _fetch` puntual; Teams y Planner solo con limites.
- `anubis-gate`: dejar en espera de cierre writes, permisos, imports, publishes, activaciones, exports amplios, secretos y targets ambiguos.
- `maat-cumplimiento`: si se ejecuta, registrar `READBACK_MICROSOFT_PRELIMINAR_20260616` y hito `hitos/20260616-microsoft-preliminar-read-v1`.
- `horus-riesgo`: semaforo `AMARILLO_CONTROLADO`; no tocar `.env.local`, `auth.json`, certificados, tokens, backups `.reg`, registro, red, Defender, firewall ni `outputs/`.
- `narrador-normativo`: apertura viva: "Abrimos orden viva preliminar para lectura Microsoft: observar, contrastar y registrar sin ejecutar cambios."

## Secuencia Preliminar

1. Rehidratar evidencia local y targets candidatos.
2. Clasificar superficie: SharePoint, Teams, Planner, Dataverse o mixta.
3. Exigir target exacto antes de cualquier probe live.
4. Ejecutar solo probes read-only minimos si el target queda claro.
5. Clasificar hallazgos como `confirmado`, `probable` o `inferido`.
6. Registrar readback local.
7. No cerrar gate ni declarar estado live final sin postcheck.

## Datos Minimos Para Abrir Live Read

- tenant o hostname exacto.
- sitio, equipo, chat, canal, plan o ambiente exacto.
- surface type: `document-library`, `native-list`, `teams-channel`, `teams-chat`, `planner`, `dataverse`.
- owner de la pasada.
- evidencia esperada.
- condicion de pausa/cierre.
- criterio de no escritura.

## Condiciones De Pausa Y Cierre

- `surface_ambiguous`
- `target_identity_ambiguous`
- `native_list_read_unavailable`
- `wrong_environment_or_default`
- `write_tool_required`
- `permission_change_requested`
- `broad_regulated_export`
- `secret_detected`
- `rollback_missing`
- `postcheck_missing`

## Proximo Movimiento Unico

Elegir target exacto para el primer probe read-only Microsoft. Recomendacion preliminar: empezar por SharePoint como `document-library` si el target es `07_SHAREPOINT_POWER_PLATFORM_SGIN`, porque la evidencia local lo muestra como superficie de archivos y no como lista nativa.
