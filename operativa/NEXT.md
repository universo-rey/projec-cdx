---
artifact_id: operativa/NEXT.md
categoria: operativa
tipo: plan
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/NEXT.md
etiquetas:
  - next
  - convergencia
  - delegacion
  - local-only
relacionados:
  - operativa/CURRENT.md
  - operativa/tasks/20260623/ROOT_GAP_RESOLUTION_DELEGATION_MATRIX_20260623.csv
  - operativa/tasks/20260623/ROOT_SURFACE_CONVERGENCE_TASKS_20260623.csv
descripcion: Siguiente movimiento vivo para resolver brechas de convergencia de raiz.
---

# Next

Movimiento unico:

```text
EXECUTE_ROOT_GAP_RESOLUTION_AND_DELEGATION_20260623
```

## Estado de Entrada

```text
CABINA_FRONTDOOR_CONVERGED_LOCAL_ONLY
ORGANISMO_VIVO_LANGUAGE_AND_POLICY_INJERTADO_EN_CABINA
```

## Objetivo

Resolver las brechas detectadas bajo la convergencia de raiz:

1. estado vivo alineado;
2. puertas cortas sin alias fisico como workspace principal;
3. ubicacion de matrices de gobierno reconciliada;
4. `.cabina/organizacion-total/out` clasificado por familias;
5. metadata/index refrescable sin drift;
6. cierre con readback y decision de versionado.

## Carriles Delegados

```text
Seshat -> estado vivo CURRENT/NEXT
Anubis -> rutas, identidad y gobernanza
Horus -> staging .cabina/out
Maat -> metadata/index y criterio de validacion
Narrador -> cierre/readback
```

## Siguiente Orden Tecnica

```text
RST-10 -> RST-05 -> RST-11 -> RST-12
```

`RST-01` y `RST-04` ya quedaron aplicados local-only.

## Frontera

- No live.
- No secretos.
- No DB/cache.
- No mover historia.
- No borrar outputs.
- No push.
- No PR.
- No stage/commit sin decision.
