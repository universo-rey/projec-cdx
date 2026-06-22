# ORDER 0.2.1 - CHANGE AWARE EVIDENCE CABINA SYNC

## Gate
`GATE_0.2.1_CHANGE_AWARE_EVIDENCE_CABINA_SYNC`

## Estado
BLOCKED_WITH_GATE_PACKET

## Superficie
GitHub / `cabina-universal-d`.

## Objetivo
Sincronizar o regenerar evidencia change-aware en el repo origen sin empujar cambios ni abrir PR desde este paquete.

## Inputs requeridos
- Repo target.
- Source artifact.
- Expected commit.
- Regeneration command if present.

## Frontera
- Preparacion local: allowed.
- Push: blocked without owner gate.
- PR: blocked without owner gate.
- External repo mutation: blocked.

## Rollback
Toda accion futura debe declarar rama, commit base, archivos afectados y comando de reversa.

## Postcheck
Validar que la evidencia regenerada coincide con el source artifact y no introduce drift en PROJEC CDX.

## Evidencia
Readback del gate con diff, validation output y referencia al commit externo si se autoriza.

## Decision actual
NO_PUSH_NO_PR
