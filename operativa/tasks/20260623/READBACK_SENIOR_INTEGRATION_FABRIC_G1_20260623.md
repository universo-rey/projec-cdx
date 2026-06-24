---
artifact_id: operativa/tasks/20260623/READBACK_SENIOR_INTEGRATION_FABRIC_G1_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: "2026-06-23"
autoridad:
  tipo: sistema
  referencia: CABINA_SENIOR_INTEGRATION_FABRIC_G1
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_SENIOR_INTEGRATION_FABRIC_G1_20260623.md
etiquetas:
  - integration-fabric
  - vscode-insiders
  - github
  - dataverse
  - sharepoint
  - teams
  - local-only
relacionados:
  - operativa/tasks/20260623/SENIOR_INTEGRATION_FABRIC_G1_MAP_20260623.csv
  - operativa/tasks/20260623/SENIOR_INTEGRATION_FABRIC_G1_INDEX_20260623.json
  - tools/ceo-integration-map.ps1
  - tools/ceo-integration-status.ps1
descripcion: Readback del Senior Integration Fabric G1 entre IDE, agentes, GitHub, Dataverse, Power Platform, SharePoint, Teams y M365 sin ejecutar live.
---

# CABINA_SENIOR_INTEGRATION_FABRIC_G1 - READBACK

## 1. Dictamen ejecutivo

`SENIOR_INTEGRATION_FABRIC_READY_LOCAL_ONLY`

La cabina ya no queda como coleccion de herramientas. Queda modelada como fabric operativo gobernado:

```text
IDE -> Codex Cloud -> GitHub -> Dataverse -> Power Platform -> SharePoint -> Teams -> M365
```

Este cierre no abre conectores live. Prepara el plano operativo, los contratos, los gates, los comandos read-only y las tasks de VS Code Insiders.

## 2. Mapa senior de integracion

| Plano | Sistema | Estado | Gate |
| --- | --- | --- | --- |
| IDE | VS Code Insiders | READY_LOCAL | IDE_GATE |
| Agentes | Codex Cloud | CANDIDATE_GATE_REQUIRED | AGENT_GATE |
| Canon tecnico | GitHub | CANDIDATE_GATE_REQUIRED | REMOTE_GATE |
| Memoria | Dataverse | CANDIDATE_METADATA_ONLY | MEMORY_GATE |
| Automatizacion | Power Platform | CANDIDATE_BLUEPRINT_ONLY | AUTOMATION_GATE |
| Gobierno | SharePoint | CANDIDATE_NO_PUBLISH | GOVERNANCE_GATE |
| Ops | Teams | CANDIDATE_NO_POST | OPS_GATE |
| Colaboracion | Microsoft 365 | CANDIDATE_GATE_REQUIRED | COLLAB_GATE |

## 3. Contratos entre sistemas

- `IDE_TO_CODEX`: orden normalizada + carril + limites -> propuesta tecnica + diff/readback.
- `CODEX_TO_GITHUB`: cambio aprobado -> branch/commit/PR pack candidato.
- `GITHUB_TO_SHAREPOINT`: commit/tag/release/readback -> evidencia visible/bitacora/pagina.
- `GITHUB_TO_DATAVERSE`: metadata versionable -> registros metadata-only candidatos.
- `DATAVERSE_TO_POWER_PLATFORM`: metadata estructurada -> app/flow/vistas/logs candidatos.
- `SHAREPOINT_TO_TEAMS`: evidencia/readback/decision -> aviso operativo/handoff/cierre.
- `TEAMS_TO_IDE`: decision/handoff -> proxima ejecucion local.

## 4. Comandos producidos

- `tools\ceo-integration-map.ps1 -Json`
- `tools\ceo-integration-status.ps1 -Json`

## 5. Tasks agregadas

- `CEO: Integration Map`
- `CEO: Integration Status`
- `CEO: Senior Integration Fabric G1`

## 6. Modelo Dataverse metadata-only

Entidades candidatas:

- `sdu_system`
- `sdu_integration_endpoint`
- `sdu_agent`
- `sdu_skill`
- `sdu_recipe`
- `sdu_command`
- `sdu_task`
- `sdu_tool`
- `sdu_mcp_server`
- `sdu_repo`
- `sdu_workspace`
- `sdu_gate`
- `sdu_evidence`
- `sdu_decision`
- `sdu_risk`
- `sdu_runbook`
- `sdu_capability`
- `sdu_product_candidate`
- `sdu_sync_run`

No se crearon tablas reales.

## 7. Superficie SharePoint candidata

- Pagina Madre: Cabina Senior Integration Fabric.
- Lista: Integration Gates.
- Lista: Integration Evidence.
- Lista: Integration Decisions.
- Lista: Integration Risks.
- Biblioteca: Runbooks Cabina.
- Biblioteca: Evidence Packs.

No se publico en SharePoint.

## 8. Patron Teams

Canal candidato: `CABINA-SDU-OPS`.

Hilos candidatos:

- Gates.
- Readbacks.
- Incidencias.
- Publicacion remota.
- Agentes.
- Power Platform.
- SharePoint Evidence.
- Dataverse Memory.

No se creo canal ni se posteo mensaje.

## 9. Blueprints Power Platform

- GitHub commit/tag -> SharePoint evidence draft.
- SharePoint evidence approved -> Teams notification.
- Dataverse sync run failed -> Teams alert.
- Integration gate changed -> Teams readback.
- New skill/recipe approved -> Dataverse registry update.
- Evidence pack created -> SharePoint bitacora entry.

No se crearon flows.

## 10. Gates

- `IDE_GATE`
- `AGENT_GATE`
- `REMOTE_GATE`
- `MEMORY_GATE`
- `AUTOMATION_GATE`
- `GOVERNANCE_GATE`
- `OPS_GATE`
- `COLLAB_GATE`

## 11. Riesgos

- Codex Cloud queda en propuesta, no conectado formalmente al fabric.
- Dataverse/Power Platform/SharePoint/Teams requieren owner gate y target exacto.
- `node` puede afectar MCP si no se resuelve en runtime gobernado.
- El workspace tiene dirty amplio heredado; no bloquea el fabric local-only pero debe considerarse antes de publicar.

## 12. Oportunidades

- Convertir comandos candidatos en paquetes por sistema.
- Preparar `ceo-ide-to-codex-pack` como primer packet generator.
- Preparar `ceo-dataverse-memory-delta` metadata-only.
- Preparar `ceo-sharepoint-evidence-pack` sin publicar.

## 13. Proxima accion ejecutable

`SENIOR_INTEGRATION_FABRIC_G1_STEP2_PACKET_COMMANDS`

Orden recomendada:

```text
Crear generadores locales de paquetes: IDE_TO_CODEX, GITHUB_PR_PACK, DATAVERSE_MEMORY_DELTA y SHAREPOINT_EVIDENCE_PACK. No ejecutar live, no push, no PR, no publicar.
```

## Frontera

- No push.
- No PR.
- No live.
- No secretos.
- No MCP execution.
- No Dataverse write.
- No SharePoint publish.
- No Teams post.
- No Power Platform mutation.
