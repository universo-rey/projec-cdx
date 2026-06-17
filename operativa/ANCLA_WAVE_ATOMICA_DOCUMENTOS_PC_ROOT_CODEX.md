# Ancla Wave Atomica Documentos PC Root Codex

Ancla minima para reanudar la secuencia de tres waves:

1. reconocimiento y clasificacion
2. transformacion en canon, recetas y procesos
3. registro punta a punta con mantenimiento y validacion

Se abre solo desde [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md).

## Fuente Canonica

- [Wave Atomica Documentos, PC Y Raiz Codex Implementation Plan](C:/Users/enzo1/PROJEC%20CDX/docs/superpowers/plans/2026-06-16-wave-atomica-documentos-pc-root-codex-mantenimiento.md)

## Orden

1. Leer la wave 1 ya absorbida en inventarios.
2. Reanudar la wave 2 solo si hay evidencia repetida para canon, recetas o procesos.
3. Seguir la wave 3 desde el ultimo delta confirmado.
4. Mantener las lanes disjuntas y el fan-in corto.

## Packet

- `wave`
- `lane`
- `scope`
- `evidence`
- `validator`
- `rollback`
- `fan_in`

## Regla

- No abrir todo el plan si alcanza con esta ancla.
- No convertir evidencia en canon sin repeticion.
- No mover nada sin rollback y postcheck.

## Stop Condition

- Falta delta real.
- Falta evidencia.
- Falta fan-in claro.
- Se intenta mezclar waves o abrir frentes paralelos.
