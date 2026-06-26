# FIX_PR03_WORKBENCH_LINK_CONTROL_20260626

## Estado
PR03_WORKBENCH_LINK_FIX_VERSIONED

## Identidad
- fecha_local: 2026-06-26T10:08:10-03:00
- fecha_utc: 2026-06-26T13:08:10.4082961Z
- live_branch: codex/live-state-g10-governed-20260626
- live_head: e9fcd7e949ebe2ed024d6bdd2cb6945d95f34b11
- integration_branch: codex/integration-g10-snapshot-20260626
- integration_old_head: b191ba07d7d9a0f1c535b8e35310c2f758c86867
- repair_commit: da9d05944a208128b62d1d6628f09b9e8adcf4dd

## Reparacion
- operativa/CONTROL.md: C:/Users/enzo1/PROJEC%20CDX/SDU_STATE_G10.md -> ../SDU_STATE_G10.md

## Criterio
- Reemplazo exclusivo de target absoluto roto hacia SDU_STATE_G10.md.
- Ruta relativa calculada desde el directorio de cada archivo Markdown.
- No checkout, no merge, no PR, no live, no G11 apply.

## Validadores
- workbench: OBSERVED
- sync: PASS
- operational_chain: PASS
- sdu_boot: PASS
- dataverse_metadata_wave: PASS
- git_diff_check_live_to_integration: PASS

## Decision
PR03_WORKBENCH_LINK_FIXED_WITH_REVIEW

## Rollback
- integration -> b191ba07d7d9a0f1c535b8e35310c2f758c86867

## Siguiente carril
OWNER_DECISION_AFTER_PR03_CORE_G10_FIXED
