# Rollback

Rollback permitido solo por orden humana.

## Si solo esta preparado

- Retirar este hito o marcarlo como superseded.
- No hay Dataverse write para revertir.

## Si fue promovido a Dataverse

- Buscar por `mon_canonical_id` exacto:
  - `sharepoint:binding-ui-seshat-home-atomos:20260617:v1`
  - `evidence:sharepoint:binding-ui-seshat-home-atomos:20260617:v1`
- Cambiar estado a `Pending`, `Retired` o eliminar solo los ids exactos registrados en `operativa/archive/legacy-root/20260617/DATAVERSE_PROMOTION_BINDING_UI_SESHAT_HOME_ATOMOS_20260617.json`, segun orden del owner.

No revertir por busqueda amplia ni por display name.
