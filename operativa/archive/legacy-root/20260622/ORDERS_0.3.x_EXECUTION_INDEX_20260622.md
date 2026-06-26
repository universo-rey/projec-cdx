# SDU 0.3.x External Execution Index

## Estado base
SDU_0.2.x_EXTENDED_PACKET_BASELINE_CLOSED_LOCAL

## Regla de ejecucion
Una version 0.3.x abre una unica superficie externa, con owner, rollback, postcheck y evidencia.

## Orden recomendado
1. 0.3.0 GitHub labels Dependabot en universo-rey/projec-cdx
2. 0.3.1 Change-aware evidence cabina sync
3. 0.3.2 PR130 constitution sync
4. 0.3.3 SDU-CN issue prep alignment
5. 0.3.4 Dataverse DEV precheck hardening
6. 0.3.5 Power Automate validator enforcement
7. 0.3.6 SDU-CN gate ID canonicalization
8. 0.3.7 SDU-CN prompt/tool enum alignment
9. 0.3.8 SDU-CN validator CI registration
10. 0.3.9 Agent memory boundary hardening
11. 0.3.10 Bridge auth validator hardening
12. 0.3.11 Agile Canvas postcheck enforcement
13. 0.3.12 Dependabot PR review
14. 0.3.13 Cabina runtime CI failure triage

## Recomendacion
El primer gate externo recomendado es 0.3.0 porque es GitHub label write de bajo riesgo relativo y no toca codigo funcional.
