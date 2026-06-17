# Orden - Promocion Seshat Home SharePoint

Estado: `LIVE_WRITE_APPROVED_BY_OWNER`
Fecha: `2026-06-16`

## Orden

Promover la huella atomica owner-approved al sitio SharePoint:

`https://escribaniabitsch.sharepoint.com/sites/SeshatHubRegistroN.8/SitePages/Home.aspx`

La superficie queda definida como canon visible de Seshat para el Registro N. 8,
con la Corte y el proposito como estructura de lectura.

## Target

- Tenant: `Escribania Bitsch`
- Host: `escribaniabitsch.sharepoint.com`
- Site path: `/sites/SeshatHubRegistroN.8`
- Site title: `Hub Seshat - Centro Rector de Conocimiento Notarial Digital`
- Superficie primaria: `SitePages/Home.aspx`
- Biblioteca de soporte canonico: `HUB_PaginasCanonicas`
- Archivo canonico: `HUELLA_ATOMICA_SESHAT_HOME_20260616.md`

## Gate

- Owner: Enzo Figueroa.
- Accion aprobada: publicar huella canonica de Seshat para consumo de agentes.
- Restriccion: no alterar permisos, no borrar, no publicar secretos.
- Rollback: retirar o reemplazar el archivo canonico exacto; si se edita Home.aspx por otro carril, restaurar version previa.
- Postcheck: confirmar sitio, confirmar archivo publicado o registrar delta tecnico si la API no permite editar pagina.

## Cierre Esperado

`SESHAT_HOME_CANON_PROMOTED` o `DELTA_GOBERNADO_API_PAGE_WRITE_REQUIRED`.
