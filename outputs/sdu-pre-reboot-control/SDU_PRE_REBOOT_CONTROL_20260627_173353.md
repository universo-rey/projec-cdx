# SDU Pre-Reboot Control

- Timestamp: 2026-06-27T17:33:53.4552419-03:00
- Host: 
- User: ceo\enzo1
- Elevated: False
- Root: C:/CEO/project-cdx
- Workspace: C:/CEO/project-cdx/CEO_CONTROL_PLANE.code-workspace
- code-insiders: True C:/Users/enzo1/AppData/Local/Programs/Microsoft VS Code Insiders/bin/code-insiders.cmd
- rg available: True
- Metadata wave PASS: True

## JSON Checks

path                                                                                                                   e
                                                                                                                       x
                                                                                                                       i
                                                                                                                       s
                                                                                                                       t
                                                                                                                       s
----                                                                                                                   -
C:/CEO/project-cdx/CEO_CONTROL_PLANE.code-workspace                                                                    e
C:/CEO/project-cdx/.cabina/SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/WORKSPACES/SDU-FEDERAL-CONTROL.code-workspace e
C:/CEO/project-cdx/.cabina/SDU_RUNTIME_ROOT/05_CONFIG/federation-bindings.v1.json                                      e

## CSV Checks

path                                                                                           exists rows error
----                                                                                           ------ ---- -----
C:/CEO/project-cdx/.cabina/SDU_RUNTIME_ROOT/10_FEDERATION/SDU_SCRIPT_TOOL_BINDING_20260627.csv   True   24

## Git Root Status
```text
## codex/audit-governance-hardening...origin/codex/audit-governance-hardening [ahead 2]
 M .github/workflows/codeql.yml
 M AGENTS.md
 M MAPA_CAPAS.md
 M MAPA_CORTO.md
 M README_ARRANQUE_CODEX_CLOUD.md
 M README_CORTO.md
 M docs/referencia/AGENTS.reference.md
 M docs/superpowers/plans/MAPA.md
 M docs/superpowers/plans/README.md
 M inventarios/INDICE_COMPACTO.md
 M inventarios/INDICE_INVENTARIOS.md
 M inventarios/MAPA.md
 M main.py
 M operativa/PROMPT_CIERRE_WAVE.md
 M operativa/PROMPT_NUEVO_HILO.md
 M operativa/SETUP_APERTURA_CODEX_UI.md
 M playbooks/MAPA.md
 M playbooks/README.md
 M procesos/INDICE_PROCESOS.md
 M procesos/MAPA.md
 M procesos/README.md
 M recipes/INDICE_RECETAS.md
 M recipes/MAPA.md
 M recipes/README.md
 M recipes/configuracion-entorno-codex-ui.md
 M src/launch_desk/config.py
 M src/metadata/cli.py
 M src/metadata/indexer.py
 M src/metadata/validator.py
 M src/projec_cdx_cloud/agent.py
 M src/projec_cdx_cloud/cli.py
 M src/projec_cdx_cloud/cloud_bridge.py
 M tests/test_metadata_cli.py
 M tools/MAPA.md
 M tools/README.md
 M tools/build_codex_root_inventory.py
 M tools/build_index.py
 M tools/build_skills_workbook.py
 M tools/build_universe_relationship_audit.py
 M tools/codex-cloud-bootstrap.ps1
 M tools/codex-cloud-maintenance.ps1
 M tools/codex-control-total.ps1
 M tools/codex-environment-setup.ps1
 M tools/rehome_codex_root_safe.ps1
 M tools/update_codex_config_workbook.py
 M tools/validate.py
 M tools/validate_proj_cdx_operational_chain.ps1
 M tools/validate_proj_cdx_sync.ps1
 M tools/validate_proj_cdx_workbench.ps1
 M validate-scope.json
?? .agent/
?? .bmad-backup/
?? .bookmarks/
?? .cabina/.gitignore
?? .cabina/CABINA_OPERATIONAL_STATE.json
?? .cabina/DELTA_OWNER_MATRIX.json
?? .cabina/SDU_RUNTIME_ROOT/
?? .cabina/canon/
?? .cabina/dataverse/
?? .cabina/execution-g1/
?? .cabina/execution-runtime/ADVANCED_COMMANDS_G16_REPORT.json
?? .cabina/execution-runtime/AUTONOMOUS_G10_REPORT.json
?? .cabina/execution-runtime/CABINA_OPERATE_REPORT.json
?? .cabina/execution-runtime/CABINA_OPERATE_STATE.json
?? .cabina/execution-runtime/CABINA_OPERATIONAL_STATE.json
?? .cabina/execution-runtime/CABINA_START_OPERATIONAL_MODE_REPORT.json
?? .cabina/execution-runtime/EXECUTION_DISPATCH_G6_REPORT.json
?? .cabina/execution-runtime/EXECUTION_FABRIC_G2_REPORT.json
?? .cabina/execution-runtime/NOC_G8_REPORT.json
?? .cabina/execution-runtime/NOC_G9_INTELLIGENCE_REPORT.json
?? .cabina/execution-runtime/REAL_OPERATION_G16_REPORT.json
?? .cabina/execution-runtime/SDU_G11_REPORT.json
?? .cabina/execution-runtime/SDU_G12_GOVERNANCE_REPORT.json
?? .cabina/execution-runtime/advanced-commands/
?? .cabina/execution-runtime/agents/
?? .cabina/execution-runtime/autonomous/
?? .cabina/execution-runtime/backlog/
?? .cabina/execution-runtime/cognitive/
?? .cabina/execution-runtime/control-flow/
?? .cabina/execution-runtime/event-bus-proxy.jsonl
?? .cabina/execution-runtime/evolution/
?? .cabina/execution-runtime/execution-bindings.json
?? .cabina/execution-runtime/execution-map.json
?? .cabina/execution-runtime/execution-pipelines.json
?? .cabina/execution-runtime/guardian/
?? .cabina/execution-runtime/hot-adjustments.json
?? .cabina/execution-runtime/impact/
?? .cabina/execution-runtime/intelligence/NOC_G9_INTELLIGENCE_REPORT.json
?? .cabina/execution-runtime/intelligence/intelligence-metrics.json
?? .cabina/execution-runtime/intelligence/intelligence-scores.json
?? .cabina/execution-runtime/intelligence/multi-domain-intelligence.json
?? .cabina/execution-runtime/kpi/
?? .cabina/execution-runtime/learned-patterns.json
?? .cabina/execution-runtime/noc-dispatcher.jsonl
?? .cabina/execution-runtime/noc-panel.json
?? .cabina/execution-runtime/objectives/
?? .cabina/execution-runtime/openai-key-reuse-state.json
?? .cabina/execution-runtime/planner/
?? .cabina/execution-runtime/queue/
?? .cabina/execution-runtime/real-operation-engine.ps1
?? .cabina/execution-runtime/real-operation-loop.lock.json
?? .cabina/execution-runtime/real-operation-loop.ps1
?? .cabina/execution-runtime/real-operation-promotions.json
?? .cabina/execution-runtime/real-operation-state.json
?? .cabina/execution-runtime/real-operation.jsonl
?? .cabina/execution-runtime/system-bootstrap.json
?? .cabina/governance/
?? .cabina/local-reconcile/
?? .cabina/nervous-system/
?? .cabina/organizacion-total/
?? .cabina/performance/
?? .cabina/runtime/
?? .cabina/sdu/SDU_G11_REPORT.json
?? .cabina/sdu/sdu-federation-map.json
?? .cabina/sdu/sdu-governance.json
?? .cabina/tmp_git_delta_raw.txt
?? .codex/config.toml.bak_20260627_150504
?? .codex/config.toml.bak_20260627_151144
?? .cursor/
?? .github/agents/
?? .github/codeql/
?? .github/skills/
?? .graphifyignore
?? .opencode/
?? .pytest_tmp/
?? .sdu/
?? .vscode/
?? CEO_CONTROL_PLANE.code-workspace
?? SDU_AGENT_CLOSEOUT.md
?? SDU_BOOT_ROOT_FIX.md
?? SDU_FRONTDOOR_ACTIVATION_PLAN.md
?? SDU_RUNTIME_ROOT_PROMOTION_EVALUATION.md
?? WEB_DISCOVERY_REPORT.json
?? codex-agent-runtime.json
?? docs/superpowers/plans/SDU_ENV_AUDIT_PLAN.md
?? docs/superpowers/plans/sdu-environment-audit-plan.json
?? inventarios/PLANNER_GRAPH_AUTH_RECOVERY_20260627.json
?? inventarios/PLANNER_HYBRID_READBACK_STATE_20260627.json
?? inventarios/PLANNER_INCIDENT_CASE_AUDIT_20260627.md
?? inventarios/PLANNER_LIVE_TASK_EVIDENCE_20260627.json
?? inventarios/PLANNER_SHAREPOINT_SDU_PREPROD_READBACK_20260627.md
?? inventarios/PLANNER_TASK_LEVEL_READBACK_20260627.jsonl
?? inventarios/PLANNER_TASK_LEVEL_READBACK_HYBRID_20260627.jsonl
?? inventarios/PLANNER_TEAMS_ACTIVITY_EVIDENCE_20260627.json
?? inventarios/expediente_state_preprod.jsonl
?? noc/
?? operativa/sentinel/
?? path-normalization-report.json
?? playbooks/08-planner-graph-auth-recovery.md
?? procesos/planner-sharepoint-sdu-preprod-expediente.md
?? recipes/planner-anomaly-investigation.md
?? recipes/planner-hybrid-readback-stabilization.md
?? recipes/planner-sharepoint-sdu-preprod-expediente.md
?? sdu-agent-closeout-report.json
?? sdu-boot-root-fix-report.json
?? sdu-frontdoor-activation-plan.json
?? sdu-path-policy.json
?? sdu-runtime-root-promotion-evaluation.json
?? src/metadata/audit_compare.py
?? src/metadata/path_policy.py
?? src/metadata/runtime_checks.py
?? src/projec_cdx_cloud/runtime.py
?? tests/test_audit_compare.py
?? tools/build_planner_task_level_snapshot.ps1
?? tools/compare_sdu_environment_audits.py
?? tools/graphify-freeze-guard.ps1
?? tools/planner_graph_auth_recovery.ps1
?? tools/update_planner_hybrid_readback.ps1
?? work/
```

## Git Cabina Status
```text
## main
 M SDU_RUNTIME_ROOT/00_START_HERE/CAPABILITY_FRONTDOOR.md
 M SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md
 M SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md
 M SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/LAUNCHERS/open-federal.ps1
 D SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/README.md
 M SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/TASKS/federal.tasks.json
 M SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/TASKS/tasks.json
 M SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/WORKSPACES/SDU-FEDERAL-CONTROL.code-workspace
 M SDU_RUNTIME_ROOT/09_SKILLS_RECIPES_TOOLS/RECIPES_CATALOG_20260623.csv
 M SDU_RUNTIME_ROOT/12_CONTROL_PLANE/GOVERNANCE_MATRIX_CROSSWALK_20260623.csv
 D SDU_RUNTIME_ROOT/13_EVIDENCE/SNAPSHOTS/CEO_CONFIG_SNAPSHOT_20260623-173300/policy.json
 D SDU_RUNTIME_ROOT/99_ARCHIVE/SUPERSEDED_BASELINES/organizacion-total-leftovers-20260623/templates/AGENT_REGISTRY.patch.yaml
?? CABINA_OPERATIONAL_STATE.json
?? DELTA_OWNER_MATRIX.json
?? SDU_RUNTIME_ROOT/05_CONFIG/federation-bindings.v1.json
?? SDU_RUNTIME_ROOT/08_AGENTS/
?? SDU_RUNTIME_ROOT/10_FEDERATION/
?? SDU_RUNTIME_ROOT/13_EVIDENCE/READBACKS/20260624/
?? SDU_RUNTIME_ROOT/13_EVIDENCE/READBACKS/20260626/
?? SDU_RUNTIME_ROOT/13_EVIDENCE/READBACKS/20260627/
?? canon/
?? dataverse/
?? execution-g1/
?? execution-runtime/
?? governance/
?? local-reconcile/
?? nervous-system/
?? organizacion-total/
?? performance/
?? runtime/
?? sdu/
?? tmp_git_delta_raw.txt
```

## Validation
```text
PASS | required:README.md | OK
PASS | required:MANIFEST.yaml | OK
PASS | required:READBACK.md | OK
PASS | required:EVIDENCIA.md | OK
PASS | required:INDICE.csv | OK
PASS | required:METADATA_HYDRATION_MATRIX.csv | OK
PASS | required:METADATA_HYDRATION_MATRIX.json | OK
PASS | required:ROLLBACK.md | OK
PASS | required:POSTCHECK.md | OK
PASS | required:STOP_CONDITIONS.md | OK
PASS | matrix_rows | 65
PASS | matrix_status | METADATA_ONLY_PREPARED
PASS | planner_sanitized | no_plan_title
STATUS: PASS
```

## Post-Reboot Compare
Compare this snapshot with a new sdu-pre-reboot-control snapshot after restart; focus on elevated, cwd, PATH, code-insiders, codex, git roots, and validation.metadata_wave_pass.
