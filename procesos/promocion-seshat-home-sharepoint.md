# Proceso - Promocion Seshat Home SharePoint

## Entrada

Orden del owner que define `SeshatHubRegistroN.8/SitePages/Home.aspx` como
superficie canonica visible.

## Pasos

1. Confirmar sitio exacto.
2. Identificar si `Home.aspx` es editable por el carril disponible.
3. Si no hay page API, publicar artefacto canonico en el sitio.
4. Registrar Dataverse metadata-only con canonical id.
5. Registrar delta tecnico para el binding de pagina.
6. Cerrar con readback, rollback y postcheck.

## Salida

- Huella publicada o preparada en SharePoint.
- Puntero Dataverse.
- Hito versionado.

## Stop Condition

`page_api_permission_missing` se trata como `delta_gobernado`, no como bloqueo
real.
