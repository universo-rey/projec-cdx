# Hilos A Canon 20260615

## Objetivo

Cruzar los hilos versionados, las trazas y los hitos con la capa reusable de skills, recetas y patrones.

## Familias Detectadas

| Familia | Hilos o hitos visibles | Canon reusable principal | Observacion |
| --- | --- | --- | --- |
| Cierre documental | `20260614-hilo-anterior-v1`, `20260615-cierre-workbench-v1`, `20260615-pr-cierre-atomico-v1` | `canon-documental`, `cierre-wave-documental`, `P-003`, `P-006` | Convierte cierres sueltos en canon navegable. |
| Origen y continuidad | `20260615-hilo-origen-v1`, `operativa/TRACE.md` | `canon-documental`, `cabina-session-handoff`, `cabina-continuity-readback` | Sirve para reanudar sin rehacer contexto. |
| Patrones y procesos | `20260615-patrones-procesos-v1` | `delta-gobernado`, `canon-documental`, `P-001`, `P-002` | Levanta catálogos reutilizables. |
| Sincronizacion | `20260615-sincronizacion-tiempo-real-v1` | `sincronizacion-tiempo-real`, `matrix-recipe-skill-sync`, `P-013` | Mantiene alineadas fuentes, corridas y cierres. |
| Dataverse | `20260615-dataverse-conexiones-drift-v1`, `20260615-projec-cdx-dataverse-v1`, `20260615-corte-ejecutora-vs-sdu-v1`, `20260615-sincronizacion-tiempo-real-v1` | `dataverse-*`, `tcu-*`, `P-004`, `P-015`, `dataverse-rehidratacion`, `ANCLA_REHIDRATACION` | Requiere gate antes de live y ancla corta para rehidratar hilos largos. |
| GitHub y repos | `20260615-github-repos-canonical-v1`, `20260615-github-repos-chain-v1`, `20260615-repos-surface-github-v1` | `repo-agent-tool-governance`, `governed-readback-closeout` | Ordena canon de repos y surface maps. |
| Auditar | `20260615-auditar-surface-chain-v1`, `20260615-cierre-cadena-github-auditar-v1` | `codex-surface-map`, `repo-agent-tool-governance`, `P-002` | Separar agregador, hijos y cadenas. |
| Waves y agentes | `20260615-agentes-atomicos-algoritmicos-en-waves-v1`, `20260615-cobertura-atomica-energetica-v1` | `delta-gobernado`, `agentes-atomicos-algoritmicos-en-waves`, `P-001` | Un agente por lane, un hito por wave. |
| Entorno y limpieza | `20260615-codex-cloud-scaffold-v1`, `20260615-politica-ramas-versionado-v1`, `20260615-cierre-workbench-v1` | `delta-gobernado`, `canon-documental`, `tcu-optimizador-pc-local-seguro` | Mantiene la base visible y limpia. |

## Lectura

- Si un hilo ya tiene readback, mejor promoverlo a canon que resumirlo otra vez.
- Si el tema se repite con la misma forma, el destino natural es skill, receta o patron.
- Si el hilo solo necesita continuidad, alcanza con `TRACE.md` y un `hito` bien indexado.

## Salida

Mapa corto para decidir donde cae cada hilo sin mezclar fuente, evidencia y reutilizacion.
