# SDU SENTINEL STATE

## Estado
SDU_SENTINEL_ACTIVE_LOCAL_GOVERNED

## Modo
LOCAL_FIRST
NO_EXTERNAL_BY_DEFAULT

## Frontera activa
- local: permitido bajo validacion
- github: BLOCKED_WITHOUT_GATE
- openai: BLOCKED_WITHOUT_GATE
- microsoft: BLOCKED_WITHOUT_GATE
- sharepoint: BLOCKED_WITHOUT_GATE
- dataverse: BLOCKED_WITHOUT_GATE
- power_platform: BLOCKED_WITHOUT_GATE
- codex_cloud: BLOCKED_WITHOUT_GATE

## Checks obligatorios
- git_clean
- boundary_matrix_present
- boot_pass
- resolver_pass
- tests_pass
- metadata_valid
- no_secret_print
- no_external_execution

## Ultimo resultado
WARN

## Drift
EVIDENCE_GAP_DRIFT
