# ORDER 0.2.2 - PR130 CONSTITUTION SYNC CABINA

## Gate
`GATE_0.2.2_PR130_CONSTITUTION_SYNC_CABINA`

## Estado
BLOCKED_WITH_GATE_PACKET

## Superficie
GitHub / `cabina-universal-d`.

## Objetivo
Resolver drift entre `MANIFEST` y constitucion PR130 en el repo canonico correspondiente.

## Inputs requeridos
- PR130 source evidence.
- Manifest.
- Constitution.
- Owner decision.

## Frontera
- Analisis local: allowed.
- Escritura en repo externo: blocked without owner gate.
- PR externo: blocked without owner gate.

## Rollback
La accion futura debe conservar commit base, branch de trabajo, diffs y retorno a manifest anterior si el postcheck falla.

## Postcheck
Confirmar que manifest y constitucion declaran el mismo alcance y que no se rompen indices asociados.

## Evidencia
Readback del gate con comparacion manifest/constitucion y resultado del check externo autorizado.

## Decision actual
NO_PUSH_NO_PR
