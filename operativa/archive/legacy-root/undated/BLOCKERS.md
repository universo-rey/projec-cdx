# Blockers

Bloqueos reales de `PROJEC CDX`.

## Activos

Ningun bloqueo operativo activo.

## Pendiente Gobernado

- Ningun bloqueo pendiente por `Auditar` en esta ronda.
- La clasificacion fina quedo registrada en `operativa/archive/legacy-root/20260615/ACTA_AUDITAR_CLASIFICACION_20260615.md`.

## Guardrails

- No leer secretos.
- No tocar `auth.json` ni `cap_sid`.
- No editar global-state ni SQLite sin orden explicita.
- No mover ni borrar carpetas sin confirmacion.

## Desbloqueo

Si aparece un bloqueo, registrar target exacto, impacto, rollback, postcheck y evidencia minima antes de avanzar.
Desde la promocion owner-approved del Manifiesto SDU, una condicion tecnica de pausa se registra como `delta_gobernado`, proximo paso y evidencia requerida. Bloqueo real solo existe por decision humana expresa o por falta de autoridad humana para un write concreto.
