# NOC local events

Mini bus local para eventos de gobierno SDU del NOC.

- Scope: `C:\CEO\project-cdx\noc\events`.
- Formato: JSON Lines en `log.jsonl`.
- Productores previstos: UI G2 del NOC via `/core/noc/events/log.json`.
- Eventos iniciales: `SDU_NOC_G2_DECREE_OBSERVED`, `CE-001_RECOGNITION_REQUIRED`, `CE-002_CONFLICTS_PRESENT`.
- Regla: no escribe en watchdog, SharePoint, Dataverse ni otras superficies externas.
