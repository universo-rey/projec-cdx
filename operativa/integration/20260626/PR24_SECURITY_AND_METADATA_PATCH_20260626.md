# PR24 Security And Metadata Patch 20260626

- PR: #24
- Branch: codex/integration-g10-snapshot-20260626
- Head anterior: 64204dc4c2156b8b765006690915d2749c309c66
- Base: main
- Estado: PATCH_LOCAL_VALIDATED_PENDING_REMOTE_RERUN

## Archivos Tocadas

- tmp-owner-action-layer/noc-web/owner_actions_server.py
- SDU_STATE_G10.md
- operativa/integration/20260626/PR24_SECURITY_AND_METADATA_PATCH_20260626.md
- operativa/integration/20260626/PR24_SECURITY_AND_METADATA_PATCH_20260626.json

## Clasificacion CodeQL

- Alerta: Uncontrolled command line
- Archivo: tmp-owner-action-layer/noc-web/owner_actions_server.py
- Linea reportada: 133
- Clasificacion: SECURITY_BLOCKER_REPAIRED_LOCALLY
- Patron: subprocess.run con argv dependiente de request/catalog-selected values; reemplazado por dispatch estatico allowlisted.

## Hardening Aplicado

- OWNER_ACTIONS estatico.
- Validacion regex de action id antes del lookup.
- Script resuelto desde script_name constante.
- shell=False y check=False explicitos.
- cwd fijo bajo commands.
- env minima allowlisted.
- timeout obligatorio conservado.
- stdout/stderr crudos no se devuelven ni se registran.

## Metadata Patch

- SDU_STATE_G10.md: agregado categoria, tipo, version, etiquetas, relacionados, descripcion.
- Eliminado modo.
- autoridad.tipo corregido a sistema segun schema.json.

## Validadores Ejecutados

| Validador | Estado | Exit |
| --- | --- | --- |
| py_compile_owner_actions_server | PASS | 0 |
| metadata_validator | PASS | 0 |
| validate_proj_cdx_sync | PASS | 0 |
| validate_proj_cdx_workbench | PASS | 0 |
| validate_proj_cdx_operational_chain | PASS | 0 |
| sdu_boot_dry_run | PASS | 0 |
| validate_sdu_dataverse_metadata_wave | PASS | 0 |

Sensitive scan: PASS

## Checks Remotos

Pendientes de rerun por GitHub despues del push. No se fuerza rerun y no se convierte el PR a ready.

## Rollback

Mover integration a:

$parent

## Prohibiciones

No merge, no live, no G11, no main mutation, no tag, no PR ready, no approval.
