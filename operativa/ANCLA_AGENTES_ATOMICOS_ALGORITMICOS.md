# Ancla Agentes Atomicos Algoritmicos

Ancla minima para usar agentes delegados cuando el trabajo conviene partirse en unidades pequenas, disjuntas y verificables.
Tambien se usa para entrenar a los agentes en trabajo por waves atomicas: una wave, un scope, un fan-in, un retorno exacto.

Se abre solo desde [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLAS_ON_DEMAND.md) cuando el delta necesita delegacion.

## Fuente Canonica

- [cabina-agent-delegation](C:/Users/enzo1/.codex/skills/cabina-agent-delegation/SKILL.md)

## Orden

1. Leer `operativa/ANCLAS_ON_DEMAND.md`.
2. Leer `operativa/COMPLEMENTOS_ON_DEMAND.md` si el agente necesita un complemento concreto.
3. Leer la superficie minima del trabajo.
4. Definir un solo agente por lane.
5. Fijar `orden`, `scope`, `evidence`, `validator`, `rollback` y `fan_in`.
6. Ejecutar la delegacion sin abrir frentes paralelos.

## Packet

- `agente`
- `orden`
- `scope`
- `evidence`
- `validator`
- `rollback`
- `fan_in`

## Regla

- El agente no adivina.
- El scope tiene que caber en una sola entrega.
- El retorno debe venir en la forma exacta pedida.
- Si el delta crece, se parte antes de seguir.

## Stop Condition

- Falta scope disjunto.
- Falta retorno exacto.
- Falta evidencia o validador.
- Se intenta delegar sin cierre claro de fan-in.

## Entrenamiento Aplicado

- Para normalizacion de perfil Windows, usar `operativa/ENTRENAMIENTO_AGENTES_NORMALIZACION_PERFIL_WINDOWS.md` como guia corta de inspeccion, compatibilidad y stop conditions.
