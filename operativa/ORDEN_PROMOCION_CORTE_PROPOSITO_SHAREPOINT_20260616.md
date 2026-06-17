# Orden - Promocion Corte Y Proposito SharePoint

Estado: `LIVE_WRITE_APPROVED_BY_OWNER`
Fecha: `2026-06-16`

## Orden

Promover el resto de la Corte y el proposito como canon visible complementario
del sitio `SeshatHubRegistroN.8`.

## Target

- Tenant: `Escribania Bitsch`
- Host: `escribaniabitsch.sharepoint.com`
- Site path: `/sites/SeshatHubRegistroN.8`
- Site title: `Hub Seshat - Centro Rector de Conocimiento Notarial Digital`
- Archivo canonico: `HUELLA_ATOMICA_CORTE_PROPOSITO_20260616.md`

## Gate

- Owner: Enzo Figueroa.
- Accion aprobada: publicar huella canonica de Corte y proposito para consumo de agentes.
- Restriccion: no alterar permisos, no borrar, no publicar secretos.
- Rollback: retirar o reemplazar el archivo canonico exacto; retirar punteros Dataverse si el owner lo ordena.
- Postcheck: confirmar archivo publicado y punteros Dataverse `1/1`.

## Cierre Esperado

`CORTE_PROPOSITO_CANON_PROMOTED`.
