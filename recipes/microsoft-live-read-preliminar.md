# Receta Microsoft Live Read Preliminar

Estado: `PREPARED_ONLY`.
Live Microsoft: `NO_EJECUTADO`.
Write Microsoft: `ESPERANDO_CIERRE`.

## Primera Lectura

Entro a Microsoft como superficie viva solo para reconocer: mis ojos leen, mis manos quedan quietas, y cada hallazgo vuelve clasificado como `confirmado`, `probable` o `inferido`.

## Cuando Usar

Usar esta receta cuando una wave necesite revisar Microsoft en vivo, pero todavia este en etapa preliminar.

Aplica a:

- SharePoint sites, bibliotecas y archivos.
- SharePoint listas, solo si hay reader nativo real.
- Teams equipos, canales, mensajes y chats.
- Planner planes y tareas.
- Power Platform y Dataverse, solo como metadata/read-only con gate exacto.

## Frontera

Permitido:

- Rehidratar evidencia local antes de tocar conectores.
- Preparar probes read-only.
- Clasificar la superficie: `native-list`, `document-library`, `file-export`, `teams-read-only`, `planner-read-only`, `dataverse-metadata` o `ambiguous`.
- Capturar evidencia minima y sanitizada.

En espera de cierre explicito:

- Escribir, crear, borrar, mover, subir o editar.
- Cambiar permisos, columnas, vistas, flows, apps, tareas o mensajes.
- Ejecutar `pac auth`, `pac env fetch`, imports, publishes o activaciones.
- Abrir secretos, tokens, certificados, cookies, connection strings o `.env.local`.
- Hacer exports amplios o regulados.

## Datos Minimos Antes De Live

- Tenant o hostname exacto.
- Sitio, equipo, canal, chat, plan, lista, biblioteca, environment u org exacta.
- Surface type esperado.
- Owner de la pasada.
- Evidencia esperada.
- Profundidad maxima.
- Limite de items o mensajes.
- Stop condition aceptada.
- Criterio de no escritura.

## Skills

| Agente | Skill principal | Funcion |
| --- | --- | --- |
| `seshat-normativa` | `sdu-sharepoint-context-refresh`, `dataverse-rehidratacion` | Traer canon local, frontera y targets candidatos. |
| `thot-tecnico` | `sdu-sharepoint-surface-guard` | Diseñar probes minimos y no confundir biblioteca con lista nativa. |
| `anubis-gate` | `sdu-auditor-sharepoint-vivo`, `no-inference-runtime-write-guard` | Mantener gate, items en espera de cierre y condiciones de pausa. |
| `maat-cumplimiento` | `governed-readback-closeout` | Definir formato de evidencia, RACI y condicion de cierre. |
| `horus-riesgo` | `sdu-sharepoint-surface-guard` | Detectar secretos, entorno equivocado, rollback faltante y postcheck ausente. |
| `narrador-normativo` | `cabina-continuity-readback` | Redactar readback vivo, breve y gobernado. |

## Tools Read-Only Permitidas

SharePoint:

- `mcp__codex_apps__microsoft_sharepoint._get_site`
- `mcp__codex_apps__microsoft_sharepoint._list_site_drives`
- `mcp__codex_apps__microsoft_sharepoint._list_folder_items`
- `mcp__codex_apps__microsoft_sharepoint._fetch`
- `mcp__codex_apps__microsoft_sharepoint._list_drives`, solo como fallback autorizado.

Teams:

- `mcp__codex_apps__microsoft_teams._list_teams`
- `mcp__codex_apps__microsoft_teams._list_channels`
- `mcp__codex_apps__microsoft_teams._list_channel_messages`
- `mcp__codex_apps__microsoft_teams._list_chats`
- `mcp__codex_apps__microsoft_teams._list_chat_messages`
- `mcp__codex_apps__microsoft_teams._fetch`
- `mcp__codex_apps__microsoft_teams._list_planner_plans`
- `mcp__codex_apps__microsoft_teams._list_planner_tasks`

## Tools En Espera De Cierre En Esta Wave

- `mcp__codex_apps__microsoft_sharepoint._create_folder`
- `mcp__codex_apps__microsoft_sharepoint._delete_item`
- `mcp__codex_apps__microsoft_teams._send_chat_message`
- `mcp__codex_apps__microsoft_teams._reply_to_channel_message`
- `mcp__codex_apps__microsoft_teams._create_channel`
- `mcp__codex_apps__microsoft_teams._update_planner_task`
- Cualquier tool Graph/PnP/PAC de tipo create, update, set, add, remove, delete, import, publish o activate.

## Secuencia

1. Leer evidencia local y gate activo.
2. Confirmar target exacto.
3. Clasificar superficie.
4. Ejecutar solo el primer probe read-only minimo.
5. Pausar si aparece ambiguedad, secreto, permiso dudoso o herramienta de write.
6. Registrar evidencia como `confirmado`, `probable` o `inferido`.
7. Hacer readback local sin declarar cierre total.

## Condiciones De Pausa Y Cierre

- `live_surface_without_order`
- `target_identity_ambiguous`
- `wrong_environment_or_default`
- `surface_ambiguous`
- `native_list_not_exposed`
- `write_tool_required`
- `secret_detected`
- `rollback_missing`
- `postcheck_missing`
- `broad_regulated_export`

## Salida Esperada

Crear o actualizar un readback local con:

- Estado: `OBSERVED_READ_ONLY` o `NO_CONCLUYENTE`.
- Target exacto.
- Hora y cuenta/rol observado si el conector lo expone.
- Evidencia minima capturada.
- Que no se toco.
- Postcheck de no escritura.
- Stop condition aplicada si corresponde.
