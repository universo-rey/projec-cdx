# Temas Y Relaciones 20260615

## Objetivo

Agrupar la raiz visible de `PROJEC CDX` por temas estables y relaciones reutilizables, para que la navegacion no dependa de memoria ni de un hilo largo.

## Familias Principales

| Tema | Senal | Canon principal | Relacion |
| --- | --- | --- | --- |
| Control y deltas | Cambios chicos, reversibles y verificables | `delta-gobernado`, `operativa/`, `playbooks/` | Ordena como se entra, se valida y se cierra cada delta. |
| Canon documental | Hilos, readbacks, hitos y carpetas que crecen | `canon-documental`, `cierre-wave-documental`, `hitos/` | Convierte evidencia dispersa en entradas navegables. |
| Dataverse gobernado | Evidencia local, metadata-only, gate y live separado | `dataverse/`, `ANCLA_REHIDRATACION`, `INDICE_DATAVERSE` | Mantiene el carril corto, verificable y sin inferencia. |
| Capacidades reutilizables | Patrones repetidos que pueden vivir como skill, receta o proceso | `skills/`, `recipes/`, `procesos/`, `patrones/` | Promueve repeticion estable a artefacto reusable. |
| Agentes y conexiones | Roster SDU, skills de gobierno y recetas de delegacion | `dataverse/MAPA_AGENTES_SDU.md`, `inventarios/AGENTES_SKILLS_RECETAS_20260616.md` | Une agentes, capas de gobierno y recetas visibles en una sola lectura. |
| Raices e inventarios | Raiz del workbench, raiz de repos y raiz global/historica | `PROJEC_CDX_ROOT_INVENTORY`, `GITHUB_REPOS_CANONICAL_20260615`, `CODEX_ROOT_INVENTORY` | Separa trabajo actual, repos canonicos y `.codex`. |
| Raiz fisica de disco | Carpetas visibles en `C:\` fuera de sistema y `Documents` | `RAIZ_DISCO_20260615` | Ayuda a llevar el disco a una forma limpia y accesible. |
| Continuidad de hilo | Reanudacion, traces y prompts cortos | `operativa/TRACE.md`, `operativa/START_HERE.md`, `operativa/PROMPT_NUEVO_HILO.md` | Permite continuar sin replay del hilo completo. |

## Relaciones Clave

- `skills` -> `recipes` -> `procesos` -> `patrones`
- `agentes` -> `skills` -> `recipes` -> `procesos`
- `hilos` -> `canon` -> `hitos`
- `dataverse` -> `gate` -> `indice` -> `ancla`
- `inventarios` -> `raiz del workspace` -> `raiz de repos` -> `.codex`
- `TRACE` -> `START_HERE` -> `NEXT` -> `PROMPT_NUEVO_HILO`

## Lectura

1. Si el pedido es operativo, abrir `operativa/`.
2. Si el pedido es documental, abrir `canon-documental`.
3. Si el pedido toca Dataverse, abrir `dataverse/INDICE_DATAVERSE.md`.
4. Si el pedido repite una forma, buscar primero en `patrones/` y `recipes/`.
5. Si el pedido cambia la estructura de raiz, actualizar este mapa junto con `README.md` y `MAPA.md`.

## Cierre

Este mapa no reemplaza los inventarios fuente; solo los vuelve mas conectados y faciles de recorrer.
