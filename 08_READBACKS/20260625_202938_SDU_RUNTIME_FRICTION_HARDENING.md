# SDU_RUNTIME_FRICTION_HARDENING_G6_G8

Fecha: 2026-06-25

## Dictamen

PASS local.

Se implementaron las cinco mejoras de reduccion de friccion operativa sobre el runtime/NOC local:

- deduplicacion activa por firma en `run-documentlocation-loop.ps1`
- agregacion de alertas HIGH no bloqueantes en `intelligence.ps1`
- deteccion de loop y recomendacion controlada
- trazabilidad de FAIL en `fails_index.jsonl`
- politica de promocion GREEN derivada, sin forzar falso verde

## Cambios Aplicados

Archivos modificados:

- `C:\CEO\watchdog\run-documentlocation-loop.ps1`
- `C:\CEO\watchdog\intelligence.ps1`
- `C:\CEO\watchdog\noc-web\app.js`
- `C:\CEO\watchdog\noc-web\index.html`
- `C:\CEO\watchdog\noc-web\styles.css`

Archivos/outputs locales creados o actualizados:

- `C:\CEO\watchdog\state\processed_signatures.jsonl`
- `C:\CEO\watchdog\logs\fails_index.jsonl`
- `C:\CEO\watchdog\outbox\recommended_actions.json`
- `C:\CEO\watchdog\state\predictive_score.json`
- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\evidence\sdu_runtime_friction_hardening_20260625_202938.json`

## Resultados

- processed signatures: 5
- alertas agregadas: 1
- FAIL indexados: 1
- score: 68
- health canonico: YELLOW
- effectiveHealth: YELLOW
- locationsReviewed: 15
- Graph OK: true
- top alert: AGGREGATED_ALERT / NOISE_CLUSTER
- loopDetected: true
- loopInefficiency: false
- reuseRatio: 63.6
- healthPromotionEligible: false
- motivo: duplicateDetected=true

## Control SDU

Confirmado:

- no Dataverse writes
- no SharePoint writes
- no scheduler
- no Power Automate
- no deletes
- no cleanup automatico
- no falso GREEN

## Validacion

- PowerShell parser: PASS
- `intelligence.ps1`: PASS
- NOC web: HTTP 200 en `http://localhost:8080/noc-web/`
- `recommended_actions.json`: actualizado con recomendaciones no ejecutables

## Proximo Paso

El sistema queda mas silencioso y observable. La promocion a GREEN queda retenida correctamente por residual conocido; resolver ese punto requiere gate separado de cleanup o aceptacion ejecutiva explicita.
