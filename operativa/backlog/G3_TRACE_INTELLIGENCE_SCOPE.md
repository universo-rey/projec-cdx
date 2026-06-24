# G3 Trace Intelligence Scope

Estado:
G3_TRACE_INTELLIGENCE_LAYER_PREPARED

## Alcance

G3 opera sobre el event bus persistente de G2 y agrega:

- trace index local;
- query engine local;
- dashboard local;
- anomaly detection local;
- alert engine local;
- replay control dry-run;
- policy feedback suggestion-only.

## Frontera

- LOCAL_FIRST.
- Sin acciones externas.
- Sin live write.
- Sin push.
- Sin PR.
- Sin self-healing automatico.
- Alertas LOCAL_ONLY.
- Policy feedback SUGGESTION_ONLY.
- Replay control DRY_RUN_ONLY.
- Runtime no versionado.
- Dashboard no publica superficie web.

## Deuda Legacy

La deuda legacy registrada en G2 permanece fuera del alcance de G3 salvo tratamiento explicito posterior.

Fase sugerida:
G3B_LEGACY_REFERENCE_SANITIZATION

## Criterio de cierre

G3 queda listo cuando:

- contratos G3 son JSON validos;
- herramientas G3 devuelven JSON;
- tests G3 pasan;
- delta G3 no contiene rutas generadas reales;
- runtime G3 queda aislado fuera del stage.
