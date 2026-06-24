# GATE 0.2.8 SDU-CN GATE ID CANONICALIZATION

## Estado
BLOCKED_WITH_GATE_PACKET

## Objetivo
Canonicalizar IDs de gates SDU-CN contra `gates/gates.yaml` sin tocar el repo remoto.

## Evidencia
- Relectura de correos: inconsistencia G16/G27 en issue prep.
- Relectura de correos: prompts y README pueden no estar alineados con `gates/gates.yaml`.

## Decision
La fuente canonica remota sera `gates/gates.yaml` solo cuando exista gate de lectura/escritura autorizado.

## Resultado
SDU_CN_GATE_ID_CANONICALIZATION_PACKET_READY
