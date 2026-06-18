# Lane B Corte Agent Index Dataverse Pointer v1

Hito atomico para registrar el indice de agentes de Corte como puntero metadata-only en Dataverse.

## Alcance

- Tenant: `Escribania Bitsch`
- Tenant id: `858a0852-44a1-413e-a0fe-f053949797d6`
- Environment: `HUBDesarrollo`
- Environment id: `7f65fc04-c27a-ea0d-bd2d-266aa9203c1e`
- Environment URL: `https://org084965d9.crm.dynamics.com`
- SharePoint atom: `INDICE_CORTE_AGENTES_20260617.md`
- SharePoint URL: `https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/Documentos%20compartidos/INDICE_CORTE_AGENTES_20260617.md`

## Modo

`metadata_only_prepared` para el paquete y `live_metadata_pointer_write` solo mediante script idempotente con `canonical_id` exacto.

## Regla

No se guarda contenido documental sensible en Dataverse. Se guarda identidad, hash, ubicacion, estado, owner, evidencia, rollback y postcheck.

## Siguiente delta

Cuando el puntero exista con conteo exacto `1`, el siguiente delta queda en espera de cierre: enlazar desde `Home.aspx` o desde otra superficie UI autorizada.
