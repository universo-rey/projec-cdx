# Readback Dataverse Pointer Indice Corte Agentes

Fecha: `2026-06-17`
Estado: `LIVE_METADATA_POINTER_WRITE`

## Resultado

El atomo `INDICE_CORTE_AGENTES_20260617.md`, ya publicado en SharePoint, quedo registrado en Dataverse como puntero metadata-only.

## Target

- Tenant id: `858a0852-44a1-413e-a0fe-f053949797d6`
- Environment: `HUBDesarrollo`
- Environment id: `7f65fc04-c27a-ea0d-bd2d-266aa9203c1e`
- Environment URL: `https://org084965d9.crm.dynamics.com`
- Source table: `mon_sdu_source_artifacts`
- Evidence table: `mon_sdu_evidences`

## Canonical IDs

- Source: `sharepoint:corte-agent-index:20260617:v1`
- Evidence: `evidence:sharepoint:corte-agent-index:20260617:v1`
- Source id: `4e61a882-786a-f111-ab0e-00224805fc91`
- Evidence id: `ecd5578a-786a-f111-ab0e-00224805f8f9`

## SharePoint Atom

- URL: `https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/Documentos%20compartidos/INDICE_CORTE_AGENTES_20260617.md`
- Item id: `017KTOXDE5ATYNJCFLPRC2HEWRFQJMJKEM`
- Drive id: `b!O3h4VaIAl0G8IAlSWZQfBt6x2B-fiCFLtg4yI57A_sbIqOZZIimRT6k3y6Abfa8A`

## Evidencia

- Result JSON: `operativa/DATAVERSE_PROMOTION_INDICE_CORTE_AGENTES_20260617.json`
- Hito: `hitos/20260617-lane-b-corte-agent-index-dataverse-pointer-v1`
- Script: `tools/promote_lane_b_corte_agent_index_dataverse.ps1`

## Postcheck

- Source count by canonical id: `1`
- Evidence count by canonical id: `1`
- No payload documental escrito en Dataverse.
- No secretos impresos.
- No `Home.aspx` edit.
- No flow run.
- No cambios de permisos, navegacion ni page publish.

## Nota Tecnica

El primer intento de script revelo una interpolacion PowerShell incorrecta: `$EntitySet?` se interpretaba como variable. Se corrigio a `${EntitySet}?...`, y el script quedo idempotente.

## Siguiente Delta

`delta_lane_b_home_link_or_ui_surface_binding_after_pointer`
