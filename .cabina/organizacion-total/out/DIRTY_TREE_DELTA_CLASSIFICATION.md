# DIRTY_TREE_DELTA_CLASSIFICATION

Estado: CLASSIFIED_METADATA_ONLY

## Resumen

- CABINA_ORG_TOTAL_CANON_VERSIONABLE: 33
- CABINA_ORG_TOTAL_LOCAL_ONLY: 73
- RUNTIME_STATE_DELTA: 12
- TEMP_BACKUP_RETENTION: 7

## Canon cabina versionable seleccionado

- [M] .cabina/organizacion-total/.vscode/tasks.json
- [M] .cabina/organizacion-total/CABINA_CONTRACT_G1.md
- [A] .cabina/organizacion-total/config/agent-capabilities.v1.yaml
- [A] .cabina/organizacion-total/config/agent-raci.v1.yaml
- [A] .cabina/organizacion-total/config/agent-recipes.v1.yaml
- [A] .cabina/organizacion-total/config/agent-risk-controls.v1.yaml
- [A] .cabina/organizacion-total/config/agent-skills.v1.yaml
- [A] .cabina/organizacion-total/config/cabina-execution-capabilities.v1.yaml
- [A] .cabina/organizacion-total/config/cabina-top001-settings.v1.yaml
- [A] .cabina/organizacion-total/config/local-file-classification-rules.v1.json
- [A] .cabina/organizacion-total/config/local-folder-map.v1.yaml
- [A] .cabina/organizacion-total/config/local-nervous-index.v1.yaml
- [A] .cabina/organizacion-total/config/top001-agent-teams.v1.yaml
- [A] .cabina/organizacion-total/config/top001-automations.v1.yaml
- [A] .cabina/organizacion-total/config/top001-mcp-capabilities.v1.yaml
- [A] .cabina/organizacion-total/config/top001-monitoring.v1.yaml
- [A] .cabina/organizacion-total/config/top001-specialized-agents.v1.yaml
- [A] .cabina/organizacion-total/docs/LOCAL_FOLDER_MASTER_MAP.md
- [A] .cabina/organizacion-total/docs/TOP001_MONITORING_RUNBOOK.md
- [A] .cabina/organizacion-total/EVIDENCE_RETENTION_POLICY.md
- [A] .cabina/organizacion-total/out/DIRTY_TREE_DELTA_CLASSIFICATION.json
- [A] .cabina/organizacion-total/out/DIRTY_TREE_DELTA_CLASSIFICATION.md
- [A] .cabina/organizacion-total/out/FINAL_MASTER_READBACK_SDU_COMPLETION_CHAIN_20260623.md
- [A] .cabina/organizacion-total/out/FINAL_READBACK_CABINA_CONTRACT_AND_CONFIG_REPAIR_G1.md
- [A] .cabina/organizacion-total/out/FINAL_READBACK_CABINA_ENABLEMENT_INTELLIGENT_EXECUTION_G1.md
- [A] .cabina/organizacion-total/out/FINAL_READBACK_CABINA_EXPANSION_LOCAL_CANONIZATION_G1.md
- [A] .cabina/organizacion-total/out/FINAL_READBACK_LOCAL_FILESYSTEM_TOTAL_ORDER_G1.md
- [A] .cabina/organizacion-total/out/FINAL_READBACK_NERVOUS_SYSTEM_LOCAL_CANONIZATION_G1.md
- [A] .cabina/organizacion-total/out/FINAL_READBACK_TOP001_CODEX_CONFIG_ENABLEMENT_G1.md
- [A] .cabina/organizacion-total/scripts/Invoke-CabinaPwsh.ps1
- [A] .cabina/organizacion-total/scripts/Invoke-SDULocalFilesystemOrder.ps1
- [A] .cabina/organizacion-total/scripts/Test-CabinaExecutionGate.ps1
- [M] .gitignore

## Reglas

- Runtime state excluido: VERSION_STATE.json, index.json, operativa/*.
- Temporales/backups excluidos: .tmp_sdu_org_total/, work/, *.previous-*.
- Evidencia cruda local-only: out/*.csv, logs/, JSON no seleccionado.
- Propuestas no adoptadas local-only: config/*.proposed.json.
- Stage permitido solo para CABINA_ORG_TOTAL_CANON_VERSIONABLE y .gitignore si se actualiza.
