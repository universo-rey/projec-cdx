# Readback Dataverse Pointer Binding UI Seshat Home Atomos

Fecha: `2026-06-17`
Estado: `LIVE_METADATA_POINTER_WRITE`

## Resultado

El atomo `BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md`, ya publicado en SharePoint y normalizado con el contenido local, quedo registrado en Dataverse como puntero metadata-only.

## Target

- Tenant id: `858a0852-44a1-413e-a0fe-f053949797d6`
- Environment: `HUBDesarrollo`
- Environment id: `7f65fc04-c27a-ea0d-bd2d-266aa9203c1e`
- Environment URL: `https://org084965d9.crm.dynamics.com`
- Source table: `mon_sdu_source_artifacts`
- Evidence table: `mon_sdu_evidences`

## Canonical IDs

- Source: `sharepoint:binding-ui-seshat-home-atomos:20260617:v1`
- Evidence: `evidence:sharepoint:binding-ui-seshat-home-atomos:20260617:v1`
- Source id: `8b5d03ca-976a-f111-ab0e-00224805f8f9`
- Evidence id: `5dda6cc7-976a-f111-ab0e-00224805fc91`

## SharePoint Atom

- URL: `https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/Documentos%20compartidos/BINDING_UI_SESHAT_HOME_ATOMOS_20260617.md`
- Item id: `017KTOXDC3JY4I65TK2NHYNU7FHHS3AZC7`
- Drive id: `b!O3h4VaIAl0G8IAlSWZQfBt6x2B-fiCFLtg4yI57A_sbIqOZZIimRT6k3y6Abfa8A`
- Source SHA256: `10754ef29b3f509d77b5fe2b8b1544ae9a3b504b1d584748ae314d33cb051b82`

## Evidencia

- Result JSON: `operativa/DATAVERSE_PROMOTION_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.json`
- Hito: `hitos/20260617-binding-ui-seshat-home-atomos-dataverse-pointer-v1`
- Script: `tools/promote_binding_ui_seshat_home_atomos_dataverse.ps1`

## Postcheck

- Source count by canonical id: `1`
- Evidence count by canonical id: `1`
- No payload documental escrito en Dataverse.
- No secretos impresos.
- No `Home.aspx` edit.
- No flow run.
- No cambios de permisos, navegacion ni page publish.

## Siguiente Delta Natural De Este Carril

`delta_home_aspx_page_binding_when_ui_or_pnp_context_available`

Ese delta solo debe ejecutarse cuando exista UI, PnP o page API con permiso suficiente. Hasta entonces, la mesa puede avanzar por el siguiente delta local accionable.
