# G5 Controlled Live Operations Scope

Estado:
LIVE_ARMED_NOT_ENABLED

## Alcance

G5 prepara una capa local para operaciones live controladas, sin ejecutar live real.

## Reglas

- Live real deshabilitado.
- External write bloqueado por defecto.
- Multi-owner obligatorio para `LIVE_CONTROLLED`.
- Rollback obligatorio.
- Evidence obligatorio.
- Runtime no versionado.
- Dashboard no escribe en `web/`.
- Toda ejecucion G5 inicial es simulada.

## Componentes

- live authorization;
- multi-owner gate;
- preflight guardrails;
- simulated live executor;
- rollback validation;
- local audit closure.

## Fase posterior

Cualquier `LIVE_CONTROLLED_REAL` requiere una fase separada, aprobacion formal, target exacto, rollback, postcheck y evidencia.
