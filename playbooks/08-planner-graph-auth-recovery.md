# Planner Graph Auth Recovery

Estado operativo:

- `READBACK_UNTRUSTED=true`
- `GRAPH_ACCESS=DEGRADED`
- Ausencia en SDU/NOC no implica ausencia real en Planner.

Scopes observados por error Graph:

- `Chat.Read`
- `ChannelMessage.Read.All`
- `Files.Read.All`
- `Files.ReadWrite.All`
- `Sites.Read.All`
- `User.Read`

Scopes requeridos para lectura soberana:

- `Tasks.Read`
- `Tasks.ReadWrite`
- `Group-Conversation.Read.All`
- `Group.Read.All`
- `Directory.Read.All`
- `Team.ReadBasic.All`

Delta de validacion:

1. `GET /me/planner/plans`
2. `GET /planner/plans/{plan-id}/tasks`
3. `GET /planner/tasks/{task-id}`
4. `GET /planner/tasks/{task-id}/details`
5. `GET /groups/{group-id}/threads/{thread-id}/posts`

Resultado esperado para cada delta: `STATUS 200`.

Si Planner/Graph falla:

- mantener `READBACK_UNTRUSTED`
- usar fallback Outlook Planner notifications
- conservar snapshot task-level indirecto
- no inferir borrado por `403`, `404`, `401`, token expirado o campo ausente

Comando local:

```powershell
.\tools\planner_graph_auth_recovery.ps1 -ClientId '<app-client-id>'
```

Sin `ClientId`, el script genera manifest de scopes y delta validation, pero no puede generar URLs concretas de consentimiento.
