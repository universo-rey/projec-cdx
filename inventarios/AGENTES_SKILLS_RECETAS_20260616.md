# Agentes Skills Recetas 20260616

Mapa corto de conexiones visibles entre agentes, skills, recetas y procesos de `PROJEC CDX`.

## Fuente

- [Mapa de agentes SDU](C:/Users/enzo1/PROJEC%20CDX/dataverse/MAPA_AGENTES_SDU.md)
- [Tabla unificada de skills](C:/Users/enzo1/PROJEC%20CDX/inventarios/SKILLS_UNIFIED_TABLE.md)
- [Indice de recetas](C:/Users/enzo1/PROJEC%20CDX/recipes/INDICE_RECETAS.md)
- [Mapa de recetas](C:/Users/enzo1/PROJEC%20CDX/recipes/MAPA.md)
- [Matriz skills tools recetas](C:/Users/enzo1/PROJEC%20CDX/operativa/MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md)
- [Patrones a skills](C:/Users/enzo1/PROJEC%20CDX/inventarios/PATRONES_A_SKILLS_20260615.md)

## Roster SDU Confirmado

Los canonical IDs de agente estan confirmados; los cruces agente -> skill/receta del bloque siguiente son conexiones operativas inferidas desde la evidencia local, no enlaces runtime directos.

| Agente | Canonical ID | Conexion operativa |
| --- | --- | --- |
| `seshat-normativa` | `sdu.agent.seshat_normativa.runtime_actions` | Fijar evidencia base y sostener el canon de entrada del carril Dataverse. |
| `thot-tecnico` | `sdu.agent.thot_tecnico.runtime_actions` | Ordenar el esquema y convertir la orden en movimiento util. |
| `anubis-gate` | `sdu.agent.anubis_gate.runtime_actions` | Marcar frontera, gate y stop condition. |
| `maat-cumplimiento` | `sdu.agent.maat_cumplimiento.runtime_actions` | Cuidar coherencia, RACI y condicion de cierre. |
| `horus-riesgo` | `sdu.agent.horus_riesgo.runtime_actions` | Señalar ruido, exposicion, rollback y postcheck. |
| `narrador-normativo` | `sdu.agent.narrador_normativo.runtime_actions` | Dar la voz final del readback y del siguiente paso. |

## Puentes De Capas

| Capa | Skill o receta | Uso en la cartografia |
| --- | --- | --- |
| Navegacion | `codex-surface-map` | Mantener visibles los indices, mapas y referencias sin romper enlaces. |
| Sincronizacion | `matrix-recipe-skill-sync` | Mantener alineados mapas, recetas, skills y agentes cuando cambia una capa. |
| Delegacion | `cabina-agent-delegation` | Empaquetar un agente con orden, scope, evidence y fan-in. |
| Waves | `agentes-atomicos-algoritmicos-en-waves` | Partir la delegacion en waves pequenas con retorno exacto. |
| Rehidratacion | `dataverse-rehidratacion` | Volver al carril Dataverse sin mezclar metadata con live. |
| Cierre | `cierre-wave-documental` | Absorber el delta en hito, readback e indice navegable. |

## Cruce Agente -> Capa

| Agente | Skilles de gobierno | Recetas o procesos visibles |
| --- | --- | --- |
| `seshat-normativa` | `dataverse-rehidratacion`, `cierre-wave-documental`, `codex-surface-map` | `recipes/dataverse-rehidratacion.md`, `procesos/dataverse-rehidratacion.md` |
| `thot-tecnico` | `cabina-agent-delegation`, `matrix-recipe-skill-sync` | `recipes/agentes-atomicos-algoritmicos-en-waves.md`, `procesos/agentes-atomicos-algoritmicos-en-waves.md` |
| `anubis-gate` | `no-inference-runtime-write-guard`, `matrix-recipe-skill-sync` | `recipes/dataverse-rehidratacion.md`, `procesos/dataverse-rehidratacion.md` |
| `maat-cumplimiento` | `governed-readback-closeout`, `cierre-wave-documental` | `recipes/cierre-wave-documental.md`, `procesos/cierre-wave-documental.md` |
| `horus-riesgo` | `no-inference-runtime-write-guard`, `governed-readback-closeout` | `recipes/cierre-wave-documental.md`, `procesos/cierre-wave-documental.md` |
| `narrador-normativo` | `cabina-continuity-readback`, `governed-readback-closeout` | `recipes/cierre-wave-documental.md`, `procesos/cierre-wave-documental.md` |

## Lectura Operativa

- Los seis agentes SDU comparten el mismo roster gobernado, pero no la misma funcion.
- Las skills de navegacion y sincronizacion sostienen la capa; las recetas sostienen la repeticion.
- `dataverse-rehidratacion` es la puerta corta para volver al carril cuando el hilo se alarga.
- `agentes-atomicos-algoritmicos-en-waves` es la receta corta para repartir trabajo sin abrir frentes paralelos.
- `cierre-wave-documental` absorbe la salida durable cuando el delta ya quedo resuelto.

## Regla

- Si cambia un agente, una skill o una receta, primero se actualiza este mapa y luego el indice visible.
- Si el cruce deja de ser claro, marcarlo `NO_CONSTA` en lugar de inventarlo.
- Si aparece una nueva relacion estable, promoverla a inventario, receta o skill antes de dejarla solo en conversacion.
