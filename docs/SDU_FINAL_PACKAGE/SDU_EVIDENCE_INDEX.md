# SDU Evidence Index

Fecha: 2026-06-25

## Objetivo

Este indice referencia las evidencias usadas para certificar el paquete institucional SDU. No copia datos sensibles ni contenido documental de SharePoint; solo lista fuentes de control, logs y resultados.

## Certificacion y snapshots

- `C:\CEO\watchdog\state\system_certification.json`
- `C:\CEO\watchdog\state\system_snapshot.json`
- `C:\CEO\watchdog\state\predictive_score.json`
- `C:\CEO\watchdog\outbox\recommended_actions.json`

## Evidencia G8

- `C:\CEO\watchdog\evidence\g8_dual_mode_20260625_174034.json`
- `C:\CEO\watchdog\evidence\g8_2_runtime_switch_20260625_175238.json`
- `C:\CEO\watchdog\evidence\g8_3_adx_creation_disabled_20260625_180649.json`
- `C:\CEO\watchdog\evidence\g8_4_migration_preflight_20260625_181205.json`
- `C:\CEO\watchdog\evidence\g8_4_backreference_metadata_readback_20260625_181339.json`
- `C:\CEO\watchdog\evidence\g8_4_historical_migration_20260625_181544.json`
- `C:\CEO\watchdog\evidence\g8_4_historical_migration_validation_20260625_182014.json`
- `C:\CEO\watchdog\evidence\g8_5_final_normalization_20260625_182545.json`

## Watchdog

Fuente principal actual:

- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_183012.json`

Evidencias cercanas:

- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_182549.json`
- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_181743.json`
- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_181623.json`

Resultado consolidado:

- Health: `YELLOW`
- locationsReviewed: `15`
- Graph failures: `0`

## NOC

- `C:\CEO\watchdog\evidence\noc_alert_patch_20260625_183058.json`
- `C:\CEO\watchdog\evidence\noc_screen_deploy_20260625.json`
- `C:\CEO\watchdog\evidence\noc_web_dashboard_20260625.json`
- `C:\CEO\watchdog\evidence\noc_web_alignment.json`

Logs:

- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\logs\g6_loop_events.jsonl`
- `C:\CEO\watchdog\logs\noc_session.jsonl`

## Intelligence

- `C:\CEO\watchdog\evidence\noc_intelligence_upgrade.json`
- `C:\CEO\watchdog\state\predictive_score.json`
- `C:\CEO\watchdog\logs\anomalies.jsonl`
- `C:\CEO\watchdog\outbox\alerts_out.jsonl`
- `C:\CEO\watchdog\outbox\recommended_actions.json`

## Configuracion multi-dominio

- `C:\CEO\watchdog\config\systems.json`

Carriles:

- `DOCUMENTAL -> documentlocation`
- `EXPEDIENTES -> expediente`
- `FIRMAS -> signature`
- `COMUNICACIONES -> messages`
- `RUNTIME -> config-only`

## Readbacks principales

- `C:\CEO\project-cdx\08_READBACKS\SDU_NOC_WEB.md`
- `C:\CEO\project-cdx\08_READBACKS\SDU_NOC_INTELLIGENCE.md`
- `C:\CEO\project-cdx\08_READBACKS\20260625_182615_SDU_G8_5_FINAL_NORMALIZATION.md`
- `C:\CEO\project-cdx\08_READBACKS\20260625_170732_SDU_G6_CERTIFICATION.md`

## Nota de uso

Para auditoria institucional, usar este indice como mapa de evidencia. Para decision operativa, usar `recommended_actions.json` y confirmar contra la ultima evidencia watchdog.
