---
artifact_id: operativa/archive/legacy-root/20260616/MATRIZ_PRELIMINAR_DELTAS_CIERRE_TOTAL_20260616.md
categoria: operativa
tipo: matriz
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/archive/legacy-root/20260616/MATRIZ_PRELIMINAR_DELTAS_CIERRE_TOTAL_20260616.md
etiquetas:
- operativa
- matriz
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Matriz preliminar de deltas para cierre total con trazabilidad parcial.
fecha_evento: '2026-06-16'
---

# Matriz Preliminar Deltas Cierre Total 20260616

Estado: `PRELIMINARES`.
Cierre total: `NO_DECLARADO`.

Esta matriz clasifica la superficie Git observada para decidir que se absorbe, que se versiona, que queda preparado y que debe quedar fuera del cierre. No declara cierre, no ejecuta live y no revierte trabajo paralelo.

## Resumen

| Tipo | Cantidad |
| --- | ---: |
| Deltas trackeados | 44 |
| Entradas no versionadas | 85 |
| Total entradas observadas | 129 |

Nota: este corte es posterior al paquete `hitos/20260616-pre-cierre-constitutivo-corte-agentes-v1` y posterior a la clasificacion por owner/estado.

## Detalle CSV

- Archivo: `operativa/archive/legacy-root/20260616/MATRIZ_PRELIMINAR_DELTAS_CIERRE_TOTAL_20260616.csv`.
- Filas: `129`, reconciliadas contra `git status --porcelain`.
- Proposito: asignar `frente`, `paquete`, `estado`, `owner`, `accion_propuesta`, `riesgo` y `stop_condition` por path.

## Corte Por Paquete

| Paquete | Trackeados | No versionados | Estado | Owner |
| --- | ---: | ---: | --- | --- |
| `pre_cierre_constitutivo_corte_agentes` | 7 | 4 | `absorber` | `corte-ejecutora-fan-in` |
| `cloud_runtime` | 6 | 0 | `preparado` | `thot-tecnico` |
| `guardrails_secretos` | 1 | 0 | `absorber_guardrail` | `anubis-gate` |
| `hitos_canon` | 22 | 17 | `absorber` | `maat-cumplimiento` |
| `inventarios` | 1 | 12 | `absorber_preliminar` | `maat-cumplimiento` |
| `operativa_cierre` | 1 | 15 | `absorber_preliminar` | `seshat-normativa` |
| `operativa_json_revision` | 0 | 5 | `preparado_revisar` | `maat-cumplimiento` |
| `canon_recetas_patrones` | 6 | 20 | `preparado_canonico` | `seshat-normativa` |
| `outputs_generados` | 0 | 9 | `generado` | `maat-cumplimiento` |
| `backups_sensibles` | 0 | 2 | `fuera_de_scope` | `horus-riesgo` |
| `archivo_historico` | 0 | 1 | `fuera_de_scope` | `maat-cumplimiento` |

## Corte Por Frente

| Frente | Trackeados | No versionados | Lectura preliminar | Decision de paquete |
| --- | ---: | ---: | --- | --- |
| `.codex` | 2 | 0 | Configuracion local/cloud tocada. | Absorber solo si queda alineada con root real y UI cloud. |
| `.gitignore` | 1 | 0 | Proteccion local modificada. | Revisar que cubra secretos y no esconda evidencia necesaria. |
| `operativa/archive/root-loose/20260618/README_ARRANQUE_CODEX_CLOUD.md` | 1 | 0 | Documentacion cloud en ajuste. | Absorber con runner si smoke queda consistente. |
| `src` | 2 | 0 | Runner cloud local modificado. | Validar smoke y declarar como delta tecnico. |
| `tools` | 1 | 0 | Tooling de entorno tocado. | Revisar si es soporte de cloud o workbench. |
| `atomic` | 1 | 0 | Mapa atomico tocado. | Absorber si corresponde al canon de waves. |
| `docs` | 0 | 3 | Planes nuevos no versionados. | Clasificar como planes de wave o fuera de cierre. |
| `hitos` | 22 | 18 | Mayor peso documental/versionado. | Normalizar indices, mapas y paquetes antes de pre-cierre. |
| `inventarios` | 1 | 12 | Inventarios nuevos y uno modificado. | Separar evidencia canonica de snapshots auxiliares. |
| `operativa` | 2 | 25 | Muchas actas/ordenes/reportes nuevos. | Fan-in obligatorio antes de tocar `CURRENT` o `TRACE`. |
| `outputs` | 0 | 9 | Indices generados en outputs. | Tratar como generado; absorber solo si el hito lo exige. |
| `patrones` | 1 | 9 | Patrones nuevos y uno modificado. | Promover solo patrones estables. |
| `procesos` | 2 | 4 | Procesos nuevos/modificados. | Cruzar con recipes y skills antes de cierre. |
| `recipes` | 2 | 4 | Recetas nuevas/modificadas. | Mantener simetria con procesos/patrones. |

## Clasificacion Resultante

| Decision | Paquetes |
| --- | --- |
| `absorber` | `pre_cierre_constitutivo_corte_agentes`, `hitos_canon` |
| `absorber_preliminar` | `inventarios`, `operativa_cierre` |
| `preparado` | `cloud_runtime` |
| `preparado_canonico` | `canon_recetas_patrones` |
| `preparado_revisar` | `operativa_json_revision` |
| `generado` | `outputs_generados` |
| `fuera_de_scope` | `backups_sensibles`, `archivo_historico` |

## Reglas Para La Siguiente Wave

- No tocar secretos ni leer `.env.local`.
- No borrar, mover ni revertir sin orden explicita.
- No mezclar `outputs` generados con canon si no hay hito que los consuma.
- No convertir una lista nueva en canon sin validar si es receta, patron, proceso, indice o evidencia.
- No declarar `PASS` final hasta ejecutar validador y smoke despues de la absorcion.

## Proximo Paso Atomico

Procesar paquetes en waves separadas, empezando por `cloud_runtime` o `hitos_canon`; no mezclar runtime con cierre documental.
